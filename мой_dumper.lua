--// stage2 dumper v3 | runtime: Delta (Luau, no jit)
--// order: tracer -> this file -> target
--// every loadstring chunk -> own file, HTTP urls -> meta log
--// unload: getgenv().stage2_unload()
--// bytecode test before flipping CFG.BYTECODE:
--//   local f = loadstring("return 1"); print(pcall(getfunctionbytecode, f))

local CFG = {
    FOLDER        = "logdump",
    PER_RUN       = true,   -- each run gets its own run_<time> subfolder
    DEDUPE        = true,   -- identical sources are written once, later ones logged as DUP
    TRACE         = true,   -- short caller traceback per load, goes to meta log
    TRACE_LEN     = 400,
    HTTP_FUNCS    = true,   -- hook request / http_request / httpget / httppost
    HTTP_NAMECALL = true,   -- hook game:HttpGet / HttpPost via __namecall (hot path: runs on every Instance method call)
    BYTECODE      = false,  -- VERIFY: getfunctionbytecode semantics on Delta, see test line above
}

local env = getgenv() -- OK: (in dump)
-- double load (v2 or v3): restore first, hooks never stack
if env.stage2_unload then pcall(env.stage2_unload) end

local DIR = CFG.FOLDER
if CFG.PER_RUN then DIR = DIR .. "/run_" .. tostring(os.time()) end

-- OK: makefolder, isfolder, writefile, appendfile, readfile, isfile (all in dump)
pcall(function()
    if not isfolder(CFG.FOLDER) then makefolder(CFG.FOLDER) end
    if not isfolder(DIR) then makefolder(DIR) end
end)

local function w(path, data)
    pcall(writefile, path, data)
end

local function a(path, s)
    pcall(appendfile, path, tostring(s))
end

local META = DIR .. "/stage2_meta.log"
local n = 0
local seen = {}       -- src -> first id (DEDUPE)
local active = true   -- false after unload: hooks that could not be removed become passthrough
local busy = false    -- reentrancy guard around logging
local restores = {}
local hookedFns = {}  -- function -> true, so request/http_request aliases are hooked once

local function pad(i) return string.format("%04d", tonumber(i) or 0) end
local function clip(v, len) return tostring(v):sub(1, len or 300) end

local function dumpOne(tag, chunk, src, tb)
    n += 1
    local id = n
    if type(src) ~= "string" then
        a(META, string.format("[LOAD] #%s tag=%s chunk=%s non-string src (%s)\n",
            pad(id), tag, tostring(chunk), type(src)))
        return id
    end
    local line = string.format("[LOAD] #%s tag=%s chunk=%s len=%d", pad(id), tag, tostring(chunk), #src)
    local first = CFG.DEDUPE and seen[src]
    if first then
        a(META, line .. " DUP of #" .. pad(first) .. "\n")
    else
        if CFG.DEDUPE then seen[src] = id end
        w(DIR .. "/stage_" .. pad(id) .. ".lua", src)
        a(META, line .. "\n")
    end
    if tb then
        local flat = tostring(tb):gsub("%s*\n%s*", " | ")
        a(META, "  from: " .. flat:sub(1, CFG.TRACE_LEN) .. "\n")
    end
    return id
end

local function tryBytecode(fn, id, chunk)
    if not CFG.BYTECODE or not getfunctionbytecode or type(fn) ~= "function" then return end
    local ok, bc = pcall(getfunctionbytecode, fn) -- VERIFY: in dump, semantics unknown
    if ok and type(bc) == "string" and #bc > 0 then
        w(DIR .. "/bytecode_" .. pad(id) .. ".luac", bc)
        a(META, "[BC] #" .. pad(id) .. " chunk=" .. tostring(chunk) .. " bclen=" .. #bc .. "\n")
    else
        a(META, "[BC FAIL] #" .. pad(id) .. " " .. clip(bc, 200) .. "\n")
    end
end

local function logHttp(kind, a1, a2)
    local url, extra = a1, ""
    if type(a1) == "table" then
        url = a1.Url or a1.url
        extra = " method=" .. clip(a1.Method or a1.method or "GET", 10)
    end
    a(META, "[HTTP] " .. kind .. " " .. clip(url) .. extra .. "\n")
end

-- hooks a global executor function in place: hookfunction catches references captured
-- before us; falls back to swapping the global if hookfunction refuses
local function hookGlobalFn(name, handler)
    local target = env[name]
    if type(target) ~= "function" then return "none" end
    local old
    local fn = function(...)
        if not active then return old(...) end
        return handler(old, ...)
    end
    if newcclosure then -- OK: (in dump)
        local okc, c = pcall(newcclosure, fn)
        if okc and type(c) == "function" then fn = c end
    end
    if hookfunction then -- OK: (in dump)
        local okh, res = pcall(hookfunction, target, fn)
        if okh and type(res) == "function" then
            old = res
            restores[#restores + 1] = function()
                if restorefunction then restorefunction(target) else hookfunction(target, old) end -- VERIFY: restorefunction (in dump)
            end
            return "hook"
        end
    end
    old = target
    env[name] = fn
    restores[#restores + 1] = function() if env[name] == fn then env[name] = target end end
    return "global"
end

local function loadHandler(tag)
    return function(old, src, chunk, ...)
        if busy then return old(src, chunk, ...) end
        busy = true
        -- OK: debug.traceback (Luau stdlib); first frames are our own hook, level offset not verified
        local tb = CFG.TRACE and debug.traceback("", 2) or nil
        local okd, id = pcall(dumpOne, tag, chunk, src, tb)
        busy = false
        if not okd then id = n end -- logging must never break the target
        local fn, err = old(src, chunk, ...)
        if fn then
            pcall(tryBytecode, fn, id, chunk)
        else
            pcall(a, META, "[COMPILE FAIL] #" .. pad(id) .. " " .. clip(err, 200) .. "\n")
        end
        return fn, err
    end
end

local status = {}
status[#status + 1] = "loadstring=" .. hookGlobalFn("loadstring", loadHandler("loadstring"))
status[#status + 1] = "load=" .. hookGlobalFn("load", loadHandler("load")) -- nil on Delta, reported as none

if CFG.HTTP_FUNCS then
    for _, name in ipairs({ "request", "http_request", "httpget", "httppost" }) do
        local f = env[name]
        if type(f) == "function" and not hookedFns[f] then
            hookedFns[f] = true
            status[#status + 1] = name .. "=" .. hookGlobalFn(name, function(old, ...)
                pcall(logHttp, name, ...)
                return old(...)
            end)
        end
    end
end

if CFG.HTTP_NAMECALL and hookmetamethod and getnamecallmethod and setnamecallmethod then -- OK: (all in dump)
    local ncSet = { HttpGet = true, HttpGetAsync = true, HttpPost = true, HttpPostAsync = true }
    local oldNC
    local function nc(self, ...)
        if active and self == game then
            local m = getnamecallmethod()
            if ncSet[m] then
                pcall(logHttp, "game:" .. m, ...)
                setnamecallmethod(m) -- logging may have touched the namecall slot
            end
        end
        return oldNC(self, ...)
    end
    local f = nc
    if newcclosure then
        local okc, c = pcall(newcclosure, nc)
        if okc and type(c) == "function" then f = c end
    end
    local okh, res = pcall(hookmetamethod, game, "__namecall", f)
    if okh and type(res) == "function" then
        oldNC = res
        status[#status + 1] = "namecall=hook" -- unload only flips active=false, hook stays as passthrough until rejoin
    else
        status[#status + 1] = "namecall=fail"
    end
end

env.stage2_unload = function()
    active = false
    for _, r in ipairs(restores) do pcall(r) end
    env.stage2_unload = nil
    a(META, "=== STAGE2 OFF " .. os.date("%H:%M:%S") .. " ===\n")
    print("[stage2] off")
end

local okx, exName = pcall(function() return identifyexecutor and identifyexecutor() or "?" end) -- OK: (in dump)
local summary = table.concat(status, " ")
a(META, "=== STAGE2 ON " .. os.date("%H:%M:%S") .. " exec=" .. tostring(okx and exName or "?") .. " dir=" .. DIR .. " " .. summary .. " ===\n")
print("[stage2] on -> " .. DIR .. " | " .. summary .. " | снять: getgenv().stage2_unload()")
