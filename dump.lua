-- stage3_dump.lua — дампер loadstring/load с ПОЛНЫМ исходником
-- Ставить В САМОМ НАЧАЛЕ, ДО запуска чита (перед stage_0001 / scriptblox-заглушкой).
-- Каждая загрузка кода пишется в workspace: stage3_0001.lua, stage3_0002.lua, ...
-- Лог: stage3_log.txt (типы аргументов, длины, имена чанков, откуда вызывали).
-- Ничего не блокирует и не меняет поведение скрипта — только копирует.

local idx = 0
local logLines = {}

local function flush()
    pcall(writefile, "stage3_log.txt", table.concat(logLines, "\n") .. "\n")
end

local function where()
    local ok, tr = pcall(function() return debug.traceback("", 2) end)
    if ok and type(tr) == "string" then
        local last = ""
        for line in tr:gmatch("[^\n]+") do last = line end
        return last
    end
    return ""
end

local function dump(kind, src, chunk)
    idx = idx + 1
    local tag = ("#%04d"):format(idx)
    if type(src) ~= "string" then
        -- вот этот случай наш старый лог записал как "non-string src (nil)" (LOAD #0007)
        local t = type(typeof == "function" and typeof(src) or type(src))
        logLines[#logLines + 1] = ("%s %s NON-STRING typeof=%s tostring=%.300s | %s"):format(
            tag, kind, t, tostring(src), where())
        flush()
        return
    end
    local fname = ("stage3_%04d.lua"):format(idx)
    local ok, err = pcall(writefile, fname, src)
    local head = (src:sub(1, 110):gsub("[%c]", " "))
    logLines[#logLines + 1] = ("%s %s len=%d chunk=%s file=%s(%s) head=%s | %s"):format(
        tag, kind, #src, tostring(chunk), fname, tostring(ok and "ok" or tostring(err)), head, where())
    flush()
end

local realLS = loadstring
local realLoad = load

getgenv().loadstring = function(src, chunk)
    pcall(dump, "loadstring", src, chunk)
    return realLS(src, chunk)
end

if type(realLoad) == "function" then
    getgenv().load = function(src, chunk)
        pcall(dump, "load", src, chunk)
        return realLoad(src, chunk)
    end
end

-- страховка: если где-то лежит ссылка на старую loadstring через getgenv до нас
local env = getfenv(0)
if type(env) == "table" then
    env.loadstring = getgenv().loadstring
    if type(realLoad) == "function" then env.load = getgenv().load end
end

pcall(writefile, "stage3_log.txt", "stage3 dump active " .. tostring(os.date and os.date() or "") .. "\n")
print("[stage3] dump активен: каждая loadstring/load -> workspace/stage3_XXXX.lua")
