--// stage2 dumper v2 | runtime: Delta, Luau
--// order: tracer -> this file -> target
--// hooks loadstring/load, every chunk goes to its own file
--// unload: getgenv().stage2_unload()
--// VERIFY executor funcs: print(makefolder, isfolder, writefile, appendfile, readfile, isfile, getscriptbytecode)

local CFG = {
    FOLDER    = "logdump",
    PER_RUN   = true,   -- each run gets its own run_<time> subfolder, old dumps are never overwritten
    DEDUPE    = true,   -- identical sources are written once, later ones are logged as DUP
    TRACE     = true,   -- short caller traceback per load, goes to meta log
    TRACE_LEN = 300,
    BYTECODE  = false,  -- VERIFY: getscriptbytecode usually wants a script Instance, not a function
}

local env = getgenv()
-- double load: restore first, hooks never stack
if env.stage2_unload then pcall(env.stage2_unload) end

local DIR = CFG.FOLDER
if CFG.PER_RUN then DIR = DIR .. "/run_" .. tostring(os.time()) end

-- OK: (executor fs, tagged VERIFY above)
pcall(function()
    if not (makefolder and isfolder) then return end
    if not isfolder(CFG.FOLDER) then makefolder(CFG.FOLDER) end
    if not isfolder(DIR) then makefolder(DIR) end
end)

local function w(path, data)
    if writefile then pcall(writefile, path, data) end
end

local function a(path, s)
    s = tostring(s)
    if appendfile then
        pcall(appendfile, path, s)
    elseif writefile then
        local ok, r = pcall(function() return isfile and isfile(path) and readfile(path) or "" end)
        local old = (ok and type(r) == "string") and r or ""
        pcall(writefile, path, old .. s)
    end
end

local META = DIR .. "/stage2_meta.log"
local n = 0
local seen = {}      -- src -> first id (for DEDUPE)
local active = true  -- after unload, a hook someone else wrapped just passes through

local function pad(i) return string.format("%04d", tonumber(i) or 0) end

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
    if not CFG.BYTECODE or not getscriptbytecode or type(fn) ~= "function" then return end
    local ok, bc = pcall(getscriptbytecode, fn) -- VERIFY: may reject functions
    if ok and type(bc) == "string" and #bc > 0 then
        w(DIR .. "/bytecode_" .. pad(id) .. ".luac", bc)
        a(META, "[BC] #" .. pad(id) .. " chunk=" .. tostring(chunk) .. " bclen=" .. #bc .. "\n")
    else
        a(META, "[BC FAIL] #" .. pad(id) .. " " .. tostring(bc):sub(1, 200) .. "\n")
    end
end

local function makeHook(tag, orig)
    return function(src, chunk, ...)
        if not active then return orig(src, chunk, ...) end
        -- OK: debug.traceback (Luau stdlib); level 2 = caller of this hook
        local tb = CFG.TRACE and debug.traceback("", 2) or nil
        local okd, id = pcall(dumpOne, tag, chunk, src, tb)
        if not okd then id = n end -- logging must never break the target
        local fn, err = orig(src, chunk, ...)
        if fn then
            pcall(tryBytecode, fn, id, chunk)
        else
            pcall(a, META, "[COMPILE FAIL] #" .. pad(id) .. " " .. tostring(err):sub(1, 200) .. "\n")
        end
        return fn, err
    end
end

local origLS, origLoad = loadstring, load
local hookLS   = origLS   and makeHook("loadstring", origLS)
local hookLoad = origLoad and makeHook("load", origLoad)
if hookLS   then env.loadstring = hookLS end
if hookLoad then env.load = hookLoad end

env.stage2_unload = function()
    active = false
    -- restore only if nobody wrapped us after; otherwise active=false makes our hook a passthrough
    if hookLS   and env.loadstring == hookLS   then env.loadstring = origLS end
    if hookLoad and env.load == hookLoad then env.load = origLoad end
    env.stage2_unload = nil
    a(META, "=== STAGE2 OFF " .. os.date("%H:%M:%S") .. " ===\n")
    print("[stage2] off")
end

a(META, "=== STAGE2 ON " .. os.date("%H:%M:%S") .. " dir=" .. DIR .. " ===\n")
print("[stage2] on -> " .. DIR .. ". жду таргет. снять: getgenv().stage2_unload()")
