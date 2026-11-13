--[[
═══════════════════════════════════════════════════════════════════════════════
  AirFlow — ЗАГРУЗЧИК (запускай ЭТОТ файл, а не AirFlow_Menu.lua)
═══════════════════════════════════════════════════════════════════════════════
  AirFlow_Menu.lua — это только БИБЛИОТЕКА: она сама ничего не рисует.
  Окно появляется только после CreateWindow(...) — что и делает этот файл.

  КАК ПОЛЬЗОВАТЬСЯ (Delta):
    1. Залей AirFlow_Menu.lua в свой репозиторий (уже сделано)
    2. Залей ЭТОТ файл (AirFlow_Загрузчик.lua) в тот же репозиторий
    3. В Delta выполни:
       loadstring(game:HttpGet("https://raw.githubusercontent.com/mellnikovden-sketch/Mm2-plugins/refs/heads/main/AirFlow_Загрузчик.lua"))()
    4. Появится плавающая кнопка на экране — жми её, чтобы открыть/закрыть меню
       (на ПК меню также открывается клавишей RightControl)

  Файл можно выполнять ПОВТОРНО — старое меню выгрузится само.
═══════════════════════════════════════════════════════════════════════════════
]]

-- ── 0. Выгрузка предыдущего меню (если было) ────────────────────────────────
local genv = (typeof(getgenv) == "function" and getgenv()) or _G
if genv.MyHubUnload then
    pcall(genv.MyHubUnload)
end

-- ── 1. Загрузка библиотеки с твоего GitHub ─────────────────────────────────
local LIB_URL = "https://raw.githubusercontent.com/mellnikovden-sketch/Mm2-plugins/refs/heads/main/AirFlow_Menu.lua"

local AirFlow
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(LIB_URL))()
    end)
    if ok then
        AirFlow = result
    end
end

-- Запасной вариант: библиотека уже выполнена ранее
if not AirFlow then
    AirFlow = genv.AirFlow
end

-- Запасной вариант: файл рядом на устройстве
if not AirFlow then
    local ok, result = pcall(function()
        return loadstring(readfile("AirFlow_Menu.lua"))()
    end)
    if ok then AirFlow = result end
end

if not AirFlow then
    warn("[AirFlow] Библиотека не загрузилась — проверь ссылку/файл")
    return
end
genv.AirFlow = AirFlow

-- ── 2. Окно ─────────────────────────────────────────────────────────────────
local window = AirFlow:CreateWindow({
    Name            = "AirFlow",
    Title           = "AirFlow",
    LoadingTitle    = "AirFlow",
    LoadingSubtitle = "загрузка…",
    ToggleUIKeybind = "RightControl",          -- клавиша меню на ПК
    Theme           = "Cybrion",
    DefaultTheme    = "Cybrion",
    Weather         = "Matrix",                -- фон: Snow / Rain / Hell Fire / Sakura / Fireflies / Matrix / None
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "AirFlow/Configs",
    },
    -- Плавающая кнопка открытия меню: на телефоне (Delta) БЕЗ неё никак
    ToggleButton = { Platform = "Both", Icon = "layout-grid" },
})

-- Уведомления (Type: Success / Warning / Error / Info)
local function Notify(title, text, typ)
    window:Notify({ Title = title, Content = text, Duration = 4, Type = typ })
end

-- ═══════════════════════════════════════════════════════════════════════════
--  ВКЛАДКА 1: MAIN — мини-демо элементов
-- ═══════════════════════════════════════════════════════════════════════════
do
    local tab = window:CreateTab({ Name = "Main", Icon = "star", Desc = "Демо-элементы" })

    local left = tab:AddLeftGroupbox({ Name = "Настройки", Icon = "cog" })
    left:CreateToggle({
        Name     = "Включить функцию",
        Desc     = "Главный тумблер",
        Default  = false,
        Flag     = "DemoToggle",           -- Flag → попадает в конфиги автоматически
        Callback = function(v)
            Notify("AirFlow", "Функция: " .. (v and "ВКЛ" or "ВЫКЛ"), v and "Success" or nil)
        end,
    })
    left:CreateSlider({
        Name     = "Скорость",
        Min      = 0, Max = 100, Default = 50,
        Suffix   = "%",
        Flag     = "DemoSpeed",
        Callback = function(v) print("[AirFlow] Скорость:", v) end,
    })
    left:CreateDropdown({
        Name     = "Режим",
        Options  = { "Лёгкий", "Нормальный", "Хардкор" },
        Default  = "Нормальный",
        Flag     = "DemoMode",
        Callback = function(v) Notify("AirFlow", "Режим: " .. tostring(v)) end,
    })
    left:CreateButton({
        Name = "Проверить меню", Style = "Primary", Icon = "check",
        Callback = function()
            Notify("AirFlow", "Меню полностью работает!", "Success")
        end,
    })

    local right = tab:AddRightGroupbox({ Name = "Информация", Icon = "info" })
    right:CreateLabel("Это демо-вкладка загрузчика.")
    right:CreateParagraph({
        Title   = "Как пользоваться",
        Content = "Плавающая кнопка на экране открывает/закрывает меню. "
                .. "На ПК — клавиша RightControl. "
                .. "Добавляй свои элементы по образцу из этого файла.",
    })
    right:CreateDivider("конец")
end

-- ═══════════════════════════════════════════════════════════════════════════
--  ВКЛАДКА 2: SETTINGS — готовые менеджеры тем и конфигов + утилиты
-- ═══════════════════════════════════════════════════════════════════════════
do
    local tab = window:CreateTab({ Name = "Settings", Icon = "settings" })

    local ui = tab:AddLeftGroupbox({ Name = "Интерфейс", Icon = "monitor" })
    ui:CreateKeybind({
        Name = "Клавиша меню", Default = "RightControl",
        Callback = function(key) if key then window:SetKeybind(key) end end,
    })
    ui:CreateDropdown({
        Name    = "Кнопка на экране",
        Options = { "Mobile only", "Mobile & PC" }, Default = "Mobile & PC",
        Callback = function(opt)
            window:SetToggleButtonPlatform(opt == "Mobile & PC" and "Both" or "Mobile")
        end,
    })
    ui:CreateDropdown({
        Name    = "Фон (погода)",
        Options = { "None", "Snow", "Rain", "Hell Fire", "Sakura", "Fireflies", "Matrix" },
        Default = "Matrix",
        Callback = function(v) window:SetWeather(tostring(v)) end,
    })
    ui:CreateSlider({
        Name = "Масштаб", Min = 60, Max = 150, Default = 100, Suffix = "%",
        Callback = function(v) window:SetUIScale(v / 100) end,
    })
    ui:CreateButton({
        Name = "Выгрузить меню", Icon = "power", Style = "Danger",
        Callback = function()
            window:Confirm({
                Title       = "Выгрузить AirFlow?",
                Content     = "Меню закроется и очистится.",
                ConfirmText = "Выгрузить",
                Callback    = function() genv.MyHubUnload() end,
            })
        end,
    })

    -- Готовые менеджеры конфигов и тем (полноценный UI в один вызов)
    tab:CreateConfigManager({ Name = "Конфиги", Side = "Left" })
    tab:CreateThemeManager({ Name = "Темы", Side = "Right" })
end

-- ── 3. Выгрузка: чистит всё при повторном запуске ───────────────────────────
genv.MyHubUnload = function()
    genv.MyHubUnload = nil
    if window and not window._destroyed then
        pcall(window.Destroy, window)
    end
end

print("[AirFlow] Меню загружено. Кнопка на экране / RightControl")
