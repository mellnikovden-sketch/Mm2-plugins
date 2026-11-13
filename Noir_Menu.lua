--[[
═══════════════════════════════════════════════════════════════════════════════
  Noir UI — ПОЛНАЯ БИБЛИОТЕКА МЕНЮ (все её функции) | бренд NOIR CREATOR
  Построена на базе UI-библиотеки AirFlow (из stage_7.lua "FieldKit / Cybrion"):
  тот же движок и анимации, но своё имя, логотип, тема Noir и погода Rain.
  Вкладка Combat: Silent Aim для пистолета (GunFired) и ножа
  (HandleTouched / KnifeThrown / KnifeStabbed).
═══════════════════════════════════════════════════════════════════════════════

  ЧТО ЭТО
  Автономная UI-библиотека для меню в Roblox-исполнителях (Synapse Z, Wave,
  Delta, Krnl, Solara, Fluxus и др.). Окно, вкладки, подвкладки, группы,
  20+ типов элементов, конфиги, темы, поиск, уведомления, диалоги, погода,
  мобильная кнопка открытия, тултипы, перетаскивание, масштаб.

  КАК ЗАГРУЗИТЬ
    -- из файла (положи рядом и executed):
    local Noir = loadstring(readfile("Noir_Menu.lua"))()
    -- или по ссылке (залей на GitHub raw / pastebin):
    local Noir = loadstring(game:HttpGet("https://.../Noir_Menu.lua"))()

  ⚡ АВТОЗАПУСК
    При выполнении этого файла меню открывается СРАЗУ — ничего вызывать
    не нужно. Просто выполни файл (или loadstring со ссылкой на него).
    На телефоне/Delta меню открывает плавающая кнопка на экране, на ПК —
    клавиша RightControl. Внизу файла есть помеченный БЛОК АВТОЗАПУСКА
    с демо-вкладками: правь его под себя или удали целиком (до строки
    "return Library") — тогда файл снова станет чистой библиотекой.

  ТРЕБОВАНИЯ (опционально)
    • writefile / readfile / isfile / isfolder / makefolder / getcustomasset —
      для кастомного шрифта ValleySans и встроенного логотипа.
    • game:HttpGet — для иконок lucide (если недоступны, меню работает и без них).
    • Без этих функций библиотека НЕ падает — просто отключает часть красоты.

───────────────────────────────────────────────────────────────────────────────
  1. ОКНО
───────────────────────────────────────────────────────────────────────────────
  local window = Noir:CreateWindow({
      Name            = "My Hub",          -- имя окна
      Title           = "My Hub",          -- заголовок шапки
      LoadingTitle    = "My Hub",          -- экран загрузки
      LoadingSubtitle = "by you",          -- подпись на экране загрузки
      ToggleUIKeybind = "RightControl",    -- клавиша открытия/закрытия меню
      Theme           = "Noir",            -- стартовая тема (см. список ниже)
      DefaultTheme    = "Noir",            -- тема по умолчанию для всех
      Weather         = "Matrix",          -- фон: Snow/Rain/Hell Fire/Sakura/
                                           -- Fireflies/Matrix/None
      ConfigurationSaving = {              -- автосохранение конфигов
          Enabled    = true,
          FolderName = "MyHub/Configs",    -- папка в workspace исполнителя
      },
      ToggleButton = { Platform = "Mobile", Icon = "layout-grid" },
          -- Platform: "Mobile" | "Both" (кнопка открытия на экране)
      Home = {                             -- вкладка Home в шапке
          Discord = "discord.gg/xxxxx",
          Stats   = { "Players", "Session", "FPS", "Ping" },
      },
  })

───────────────────────────────────────────────────────────────────────────────
  2. ВКЛАДКИ, ПОДВКЛАДКИ, ГРУППЫ
───────────────────────────────────────────────────────────────────────────────
  local tab  = window:CreateTab({ Name = "Main", Icon = "star", Desc = "описание" })
  local sub  = tab:CreateSubTab({ Name = "Страница 1", Icon = "zap" })  -- внутри вкладки
  local left = tab:AddLeftGroupbox({ Name = "Группа слева", Icon = "box" })
  local right= tab:AddRightGroupbox({ Name = "Группа справа", Icon = "cog" })
  local any  = tab:AddGroupbox({ Name = "Группа", Icon = "star", Side = "Left" })
      -- опции группы: Name, Icon, Side ("Left"/"Right"), Desc,
      -- Collapsed = true (свернуть), PoppedOut = true (отдельное окно)

───────────────────────────────────────────────────────────────────────────────
  3. ЭЛЕМЕНТЫ (добавляются в группу ИЛИ сразу в tab/sub)
───────────────────────────────────────────────────────────────────────────────
  Общие опции у всех: Name, Desc, Flag (ключ для конфигов), Visible,
  Tooltip (строка или {Title=, Text=, Icon=}).

  • Тумблер
    local t = group:CreateToggle({
        Name = "Функция", Desc = "описание",
        Default = false,                   -- начальное значение
        Callback = function(value) end,    -- вызывается при смене
    })
  • Слайдер
    group:CreateSlider({
        Name = "Дальность", Min = 50, Max = 3000, Default = 1500,
        Increment = 50, Suffix = "m",      -- шаг и суффикс
        Callback = function(value) end,
    })
  • Выпадающий список
    group:CreateDropdown({
        Name = "Режим", Options = { "A", "B", "C" }, Default = "A",
        Multi = false,                     -- мультивыбор (Default = {"A"})
        AllowNone = true, Searchable = true, MaxRows = 6,
        Callback = function(option) end,   -- при Multi приходит таблица
    })
  • Кнопка
    group:CreateButton({
        Name = "Действие", Desc = "описание", Icon = "zap",
        Style = "Primary",                 -- "Primary" (акцент) | "Danger" | обычная
        Callback = function() end,
    })
  • Ряд кнопок (равная ширина)
    group:CreateButtonRow({
        { Name = "Кнопка 1", Callback = function() end },
        { Name = "Кнопка 2", Style = "Danger", Callback = function() end },
    })
  • Клавиша (бинд)
    group:CreateKeybind({
        Name = "Хоткей", Default = "E",    -- строка KeyCode, напр. "E", "RightShift"
        Callback = function(key) end,      -- новая клавиша
        OnChanged = function(key) end,     -- то же, алиас
    })
  • Выбор цвета
    group:CreateColorPicker({
        Name = "Цвет", Default = Color3.fromRGB(50, 230, 150),
        Callback = function(color) end,
    })
  • Текстовое поле
    group:CreateInput({
        Name = "Ввод", Default = "", Placeholder = "текст...",
        Icon = "search",                   -- иконка внутри поля
        Callback = function(text) end,     -- по Enter / потере фокуса
        OnChanged = function(text) end,    -- на каждый символ
    })
  • Степпер (- значение +)
    group:CreateStepper({
        Name = "Кол-во", Min = 1, Max = 10, Default = 1,
        Step = 1, Suffix = "x", Callback = function(v) end,
    })
  • Прогресс-бар (значение 0..1)
    local p = group:CreateProgress({
        Name = "Загрузка", Default = 0.25, -- доля от 0 до 1
        Format = function(frac) return string.format("%d/%d", frac * 20, 20) end,
    })
    p:Set(0.5)                            -- обновлять из кода (0..1)
  • Список-сортировщик (перетаскивание строк)
    group:CreateOrderList({
        Name = "Список",
        Items = { "Пункт 1", "Пункт 2", "Пункт 3" },  -- просто значения
        MaxRows = 6, Numbered = true, Arrows = true,
        Callback = function(items) end,   -- приходит НОВЫЙ порядок
    })
  • Надпись
    group:CreateLabel("Просто текст")   -- или CreateLabel({ Text = "...", Icon = "info" })
  • Абзац (заголовок + текст)
    local par = group:CreateParagraph({ Title = "Заголовок", Content = "Текст" })
    par:Set("новый текст")               -- обновление из кода
  • Строки состояния (live-статистика)
    local rows = group:CreateStatuses({
        { Name = "Деньги", Value = "$0" },
        { Name = "Килы",  Value = "0" },
    }, { Style = "Row" })
        -- Style: "Plain" | "Row" | "Badge" | "Dot" | "Bar" | "Stat"
    rows["Деньги"]:Set("$500")           -- обновление по имени
    -- одиночная строка: group:CreateStatus({ Name = "Пинг", Value = "0", Style = "Dot" })
  • Разделитель
    group:CreateDivider()                -- или CreateDivider("Текст по центру")
    group:CreateSection("ЗАГОЛОВОК")     -- секция-подпись
  • Таблица / лидерборд (сортировка по клику на колонку, поиск)
    local t = group:CreateTable({
        Name = "Игроки", Rank = true,        -- колонка с местами
        Columns = {
            { Name = "Имя", Width = 0.6 },  -- Width: >1 пиксели, <1 доля, Align = "Right" },
            { Name = "Килы", Width = 60, Sortable = true, Format = function(v) return tostring(v) end },
        },
        Rows = { { "Alice", 12 }, { "Bob", 7 } },   -- или { { Name="Alice", Kills=12 } }
        MaxRows = 8, Search = true,
        Callback = function(row) end,      -- клик по строке
    })
    -- методы таблицы: SetColumns, SetRows, GetRows, AddRow, UpdateRow,
    --                RemoveRow, Clear, Sort, SetTitle, SetMaxRows, SetSearch
  • Картинка
    local img = group:CreateImage({ Name = "Превью", Image = "rbxassetid://123",
                        Height = 160, ScaleType = "Crop", Color = Color3.new(1,1,1) })
    img:SetImage("rbxassetid://456")        -- смена картинки из кода
  • 3D-вьюпорт (модель в меню)
    group:CreateViewport({ Name = "Скин", Model = someModel,
                           FieldOfView = 35, Ambient = Color3..., LightColor = Color3... })
  • Список статусов (прокручиваемый, для логов)
    local log = group:CreateStatusList({ Name = "Лог", MaxRows = 5 })
    log:Set({ { Text = "строка 1", Value = "ок" }, { Text = "строка 2" } })  -- обновить весь список
    log:SetName("Новый заголовок")

  МЕТОДЫ КАЖДОГО ЭЛЕМЕНТА (возвращается объект):
    el:Set(value, silent)   -- выставить значение (silent = без Callback)
    el:Get()                -- прочитать значение
    el:SetVisible(false)    -- скрыть/показать элемент
    el:SetTooltip("подсказка")
    el:Destroy()            -- удалить элемент

───────────────────────────────────────────────────────────────────────────────
  4. ОКНО: МЕТОДЫ
───────────────────────────────────────────────────────────────────────────────
  window:Notify({ Title = "Заголовок", Content = "Текст", Duration = 3,
                  Icon = "check", Type = "Success" })  -- Success/Warning/Error/обычный
  window:Confirm({ Title = "Точно?", Content = "описание", ConfirmText = "Да",
                   CancelText = "Нет", Callback = function() end })
  window:Dialog({ Title = "...", Content = "текст", Buttons = {
                   { Name = "OK", Variant = "Primary", Callback = fn } } })
  window:Toggle(true/false)      -- открыть/закрыть меню программно
  window:SetKeybind(Enum.KeyCode.X)         -- сменить клавишу меню
  window:SetToggleButtonPlatform("Both")    -- "Mobile" | "Both"
  window:SetBackdrop(true)      -- затемнение фона за меню
  window:SetWeather("Matrix")   -- смена погоды на ходу
  window:SetUIScale(1.1)        -- масштаб интерфейса
  window:SetDensity("Compact")  -- "Compact" | "Comfortable"
  window:SetSize(UDim2.fromOffset(720, 520))
  window:Destroy()              -- полностью убрать меню

───────────────────────────────────────────────────────────────────────────────
  5. КОНФИГИ И ТЕМЫ
───────────────────────────────────────────────────────────────────────────────
  Каждый элемент с Flag = "Имя" автоматически сохраняется в конфиг.
  Готовый менеджер — одна строка на вкладке:
    tab:CreateConfigManager({ Name = "Конфиги", Side = "Left" })
    tab:CreateThemeManager({ Name = "Темы", Side = "Right" })
  Программно:
    window:SaveConfig("main") / LoadConfig("main") / DeleteConfig("main")
    window:RenameConfig("main", "pvp") / ListConfigs()
    window:ExportConfig("main")            -- код для передачи
    window:ImportConfig(code, "имя")       -- импорт кода
    window:ResetConfig()                   -- сброс всего к дефолтам
    window:SetAutoload("main")             -- грузить при старте
    window:LoadAutoload()
    Noir:SetTheme("Midnight")           -- смена темы
    window:SaveTheme("моя") / LoadTheme("моя") / ListThemes()

  ТЕМЫ (31 шт.): Noir (брендовая), Cybrion, Midnight, Ocean, Rose, Emerald, Amber, Mono, Nebula,
  Synthwave, Sakura, Velvet, Crimson, Sunset, Gold, Cyber, Toxic, Matcha,
  Aurora, Frost, Abyss, Halloween, Haunted, Christmas, Valentine, Lunar,
  Tropical, Dracula, Coffee.

  ПОГОДА (фон меню): Snow, Rain, Hell Fire, Sakura, Fireflies, Matrix, None.
  Режимы погоды: SetWeatherMode("Screen" | "UI") — весь экран или только окно.

───────────────────────────────────────────────────────────────────────────────
  6. ПРОЧЕЕ
───────────────────────────────────────────────────────────────────────────────
  • Кастомный шрифт:  Noir:LoadFont({ Name = "ValleySans" })
      (скачивает и подключает настоящий TTF-шрифт, нужен writefile+getcustomasset)
  • Иконки:          Noir:PreloadIcons()
      набор lucide: "star", "crosshair", "eye", "settings", "zap", "bomb", ...
      или свой asset: Icon = 123456789 / "rbxassetid://..."
  • Скругления:      Noir:SetCornerRadius(10)
  • Флаги напрямую:  Noir.Flags["MyFlag"]:Set(true)
  • Несколько окон:  Noir.Windows — список всех открытых окон.
  • Меню перетаскивается за шапку, ресайзится за угол, сворачивается,
    работает на ПК и телефоне (тач), есть поиск по элементам.

───────────────────────────────────────────────────────────────────────────────
  ДАЛЬШЕ ИДЁТ ПОЛНЫЙ КОД БИБЛИОТЕКИ (не меняй его, если не знаешь Lua).
  Логотип NOIR CREATOR вшит в файл и подхватывается автоматически.
───────────────────────────────────────────────────────────────────────────────
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local Library = {}

Library.Flags = {}
Library.Windows = {}

local function normalize(source, map)
    local opts = {}
    if type(source) == "string" then
        opts.Name = source
    elseif type(source) == "table" then
        for key, value in pairs(source) do
            opts[key] = value
        end
    end
    for from, to in pairs(map or {}) do
        if opts[to] == nil and opts[from] ~= nil then
            opts[to] = opts[from]
        end
    end
    if opts.Range then
        opts.Min = opts.Min or opts.Range[1]
        opts.Max = opts.Max or opts.Range[2]
    end
    return opts
end

local function finishElement(tab, opts, element, frame, kind)
    element._type = kind
    element._frame = frame
    element._listeners = element._listeners or {}
    local window = tab and tab.Window
    local searchText = opts.Name or opts.Text or opts.Title
    element._searchName = type(searchText) == "string" and searchText or ""
    element._searchKey = string.lower(element._searchName)
    if tab and tab._items then
        table.insert(tab._items, element)
    end
    if opts.Flag then
        Library.Flags[opts.Flag] = element
        if window then
            window:_flagCreated(opts.Flag, element)
        end
    end
    element._userVisible = opts.Visible ~= false
    function element:IsVisible()
        return element._userVisible
    end
    function element:_isShown()
        return element._userVisible and not (tab and tab._userVisible == false)
    end
    function element:SetVisible(visible)
        visible = visible and true or false
        if visible == element._userVisible or element._destroyed then
            return
        end
        element._userVisible = visible
        if not visible then
            if element._onHide then
                element._onHide()
            end
            if element.Open and type(element.SetOpen) == "function" then
                element:SetOpen(false)
            end
        end
        if frame then
            frame.Visible = visible
        end
        if window then
            window._controlsDirty = true
        end
    end
    if frame and not element._userVisible then
        frame.Visible = false
    end
    -- Tooltip: a string, or { Title, Text, Icon }. nil, false or "" hides it.
    function element:SetTooltip(tip)
        element._tooltip = tip
        if frame and window and not element._tooltipBound then
            element._tooltipBound = true
            window:_attachTooltip(element, frame)
        end
    end
    function element:GetTooltip()
        return element._tooltip
    end
    if opts.Tooltip ~= nil and opts.Tooltip ~= false then
        element:SetTooltip(opts.Tooltip)
    end
    function element:Destroy()
        if element._destroyed then
            return
        end
        element._destroyed = true
        if window and window._tipOwner == element then
            window:_hideTooltip()
        end
        for _, disconnect in ipairs(element._listeners) do
            disconnect()
        end
        element._listeners = {}
        if tab and tab._items then
            local index = table.find(tab._items, element)
            if index then
                table.remove(tab._items, index)
            end
        end
        if opts.Flag and Library.Flags[opts.Flag] == element then
            Library.Flags[opts.Flag] = nil
        end
        if window then
            window._controlsDirty = true
        end
        if frame then
            frame:Destroy()
        end
    end
    return element
end

Library.Theme = {
    Background = Color3.fromRGB(12, 14, 12),
    Surface = Color3.fromRGB(16, 20, 17),
    Surface2 = Color3.fromRGB(22, 28, 23),
    Surface3 = Color3.fromRGB(32, 44, 34),
    Stroke = Color3.fromRGB(28, 44, 31),
    StrokeHover = Color3.fromRGB(50, 105, 65),
    Accent = Color3.fromRGB(50, 230, 150),
    AccentDark = Color3.fromRGB(12, 28, 18),
    Text = Color3.fromRGB(235, 248, 238),
    Muted = Color3.fromRGB(115, 145, 125),
    Warning = Color3.fromRGB(240, 190, 75),
    Success = Color3.fromRGB(50, 230, 150),
    Error = Color3.fromRGB(245, 85, 85),
}

-- Order decides which key wins when two theme colors are identical.
local THEME_KEYS = {
    "Accent", "AccentDark", "Background", "Surface", "Surface2", "Surface3",
    "Stroke", "StrokeHover", "Text", "Muted", "Warning", "Success", "Error",
}

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local function preset(background, surface, surface2, surface3, strokeColor, strokeHover, accent, accentDark, text, muted)
    return {
        Background = rgb(table.unpack(background)),
        Surface = rgb(table.unpack(surface)),
        Surface2 = rgb(table.unpack(surface2)),
        Surface3 = rgb(table.unpack(surface3)),
        Stroke = rgb(table.unpack(strokeColor)),
        StrokeHover = rgb(table.unpack(strokeHover)),
        Accent = rgb(table.unpack(accent)),
        AccentDark = rgb(table.unpack(accentDark)),
        Text = rgb(table.unpack(text)),
        Muted = rgb(table.unpack(muted)),
    }
end

Library.ThemePresets = {
    Noir = preset({ 7, 7, 9 }, { 10, 10, 13 }, { 14, 14, 18 }, { 22, 22, 28 }, { 20, 20, 26 }, { 86, 34, 40 }, { 228, 52, 66 }, { 30, 8, 12 }, { 240, 240, 244 }, { 132, 130, 138 }),
    -- Colours here must not be pure white, pure black or any other colour the
    -- library hard-codes, or those objects would get bound to the theme.
    Cybrion = preset({ 12, 14, 12 }, { 16, 20, 17 }, { 22, 28, 23 }, { 32, 44, 34 }, { 28, 44, 31 }, { 50, 105, 65 }, { 50, 230, 150 }, { 12, 28, 18 }, { 235, 248, 238 }, { 115, 145, 125 }),
    Midnight = preset({ 15, 18, 26 }, { 18, 22, 31 }, { 22, 26, 37 }, { 37, 44, 60 }, { 34, 40, 55 }, { 70, 84, 112 }, { 128, 160, 246 }, { 14, 18, 30 }, { 228, 232, 242 }, { 116, 126, 148 }),
    Ocean = preset({ 12, 20, 24 }, { 15, 24, 29 }, { 18, 29, 35 }, { 31, 48, 56 }, { 29, 44, 52 }, { 58, 92, 104 }, { 110, 214, 222 }, { 10, 24, 28 }, { 226, 238, 240 }, { 108, 134, 140 }),
    Rose = preset({ 22, 15, 18 }, { 27, 18, 22 }, { 32, 21, 26 }, { 48, 34, 40 }, { 45, 30, 37 }, { 98, 64, 78 }, { 246, 160, 186 }, { 30, 14, 20 }, { 240, 228, 232 }, { 138, 112, 120 }),
    Emerald = preset({ 13, 20, 17 }, { 16, 24, 20 }, { 20, 29, 24 }, { 33, 47, 40 }, { 30, 44, 37 }, { 62, 96, 78 }, { 132, 226, 170 }, { 12, 26, 18 }, { 228, 240, 233 }, { 110, 136, 122 }),
    Amber = preset({ 22, 18, 13 }, { 27, 22, 16 }, { 32, 26, 19 }, { 49, 41, 31 }, { 46, 38, 28 }, { 100, 82, 58 }, { 246, 196, 120 }, { 30, 22, 10 }, { 242, 236, 226 }, { 140, 126, 106 }),
    Mono = preset({ 16, 16, 17 }, { 20, 20, 21 }, { 25, 25, 26 }, { 40, 40, 42 }, { 38, 38, 40 }, { 84, 84, 88 }, { 236, 236, 240 }, { 20, 20, 22 }, { 234, 234, 236 }, { 122, 122, 128 }),
    Nebula = preset({ 14, 12, 28 }, { 18, 15, 35 }, { 23, 19, 43 }, { 39, 32, 68 }, { 35, 29, 62 }, { 84, 68, 140 }, { 199, 125, 255 }, { 22, 10, 40 }, { 236, 230, 252 }, { 124, 114, 160 }),
    Synthwave = preset({ 20, 12, 30 }, { 25, 15, 37 }, { 31, 18, 45 }, { 52, 30, 72 }, { 47, 27, 66 }, { 110, 58, 150 }, { 255, 94, 198 }, { 38, 8, 30 }, { 250, 232, 246 }, { 150, 118, 160 }),
    Sakura = preset({ 24, 14, 20 }, { 29, 17, 24 }, { 35, 20, 29 }, { 54, 32, 45 }, { 50, 29, 41 }, { 112, 66, 92 }, { 255, 158, 200 }, { 36, 12, 24 }, { 248, 232, 240 }, { 150, 112, 132 }),
    Velvet = preset({ 20, 10, 16 }, { 25, 12, 20 }, { 31, 15, 25 }, { 50, 25, 40 }, { 46, 23, 37 }, { 104, 52, 82 }, { 222, 110, 170 }, { 30, 8, 20 }, { 244, 228, 238 }, { 142, 106, 126 }),
    Crimson = preset({ 18, 10, 12 }, { 23, 12, 15 }, { 28, 14, 18 }, { 46, 24, 29 }, { 42, 22, 27 }, { 104, 46, 56 }, { 244, 74, 94 }, { 32, 8, 12 }, { 244, 230, 232 }, { 142, 106, 112 }),
    Sunset = preset({ 22, 13, 14 }, { 27, 16, 17 }, { 33, 19, 21 }, { 52, 31, 32 }, { 48, 28, 30 }, { 112, 62, 58 }, { 255, 138, 92 }, { 34, 14, 8 }, { 248, 234, 228 }, { 150, 118, 110 }),
    Gold = preset({ 14, 13, 11 }, { 18, 17, 14 }, { 23, 21, 17 }, { 38, 35, 28 }, { 35, 32, 26 }, { 92, 80, 54 }, { 232, 196, 122 }, { 30, 22, 8 }, { 240, 234, 222 }, { 136, 126, 106 }),
    Cyber = preset({ 13, 13, 15 }, { 17, 17, 19 }, { 21, 21, 24 }, { 36, 36, 40 }, { 33, 33, 37 }, { 86, 84, 70 }, { 250, 226, 72 }, { 30, 26, 4 }, { 240, 240, 232 }, { 126, 124, 118 }),
    Toxic = preset({ 11, 14, 11 }, { 14, 18, 14 }, { 18, 23, 18 }, { 31, 39, 30 }, { 28, 36, 28 }, { 74, 98, 60 }, { 184, 255, 74 }, { 18, 30, 6 }, { 232, 242, 228 }, { 116, 134, 110 }),
    Matcha = preset({ 16, 19, 14 }, { 20, 23, 17 }, { 24, 28, 21 }, { 40, 46, 34 }, { 37, 42, 31 }, { 84, 98, 70 }, { 176, 214, 140 }, { 18, 26, 10 }, { 236, 240, 228 }, { 128, 136, 116 }),
    Aurora = preset({ 10, 20, 22 }, { 12, 25, 27 }, { 15, 30, 33 }, { 26, 50, 53 }, { 24, 45, 48 }, { 50, 104, 104 }, { 94, 240, 180 }, { 6, 30, 22 }, { 224, 246, 240 }, { 102, 142, 134 }),
    Frost = preset({ 13, 17, 23 }, { 16, 21, 28 }, { 20, 26, 34 }, { 34, 43, 56 }, { 31, 40, 52 }, { 72, 92, 118 }, { 164, 214, 255 }, { 12, 22, 34 }, { 230, 238, 246 }, { 114, 128, 146 }),
    Abyss = preset({ 7, 11, 22 }, { 9, 14, 28 }, { 12, 18, 35 }, { 22, 31, 58 }, { 20, 28, 52 }, { 44, 64, 120 }, { 72, 148, 255 }, { 6, 14, 34 }, { 226, 234, 250 }, { 100, 116, 152 }),
    -- Seasonal and themed palettes.
    Halloween = preset({ 18, 12, 20 }, { 23, 15, 25 }, { 28, 18, 30 }, { 46, 30, 48 }, { 43, 28, 44 }, { 104, 62, 40 }, { 255, 138, 36 }, { 36, 16, 4 }, { 246, 234, 224 }, { 146, 120, 128 }),
    Haunted = preset({ 14, 12, 20 }, { 18, 15, 26 }, { 22, 18, 32 }, { 38, 31, 54 }, { 35, 29, 50 }, { 70, 96, 64 }, { 156, 255, 110 }, { 14, 30, 8 }, { 232, 240, 228 }, { 120, 116, 140 }),
    Christmas = preset({ 12, 20, 15 }, { 15, 25, 19 }, { 19, 30, 23 }, { 32, 50, 38 }, { 30, 46, 35 }, { 100, 54, 56 }, { 236, 72, 80 }, { 34, 8, 10 }, { 240, 244, 236 }, { 120, 142, 128 }),
    Valentine = preset({ 24, 12, 17 }, { 30, 14, 21 }, { 36, 17, 25 }, { 58, 27, 40 }, { 54, 25, 37 }, { 130, 56, 84 }, { 255, 92, 140 }, { 40, 8, 20 }, { 252, 232, 240 }, { 160, 112, 132 }),
    Lunar = preset({ 22, 10, 10 }, { 28, 12, 12 }, { 34, 15, 14 }, { 54, 24, 22 }, { 50, 22, 20 }, { 130, 92, 40 }, { 246, 196, 84 }, { 38, 16, 6 }, { 250, 236, 222 }, { 160, 120, 108 }),
    Tropical = preset({ 10, 22, 24 }, { 12, 27, 30 }, { 15, 33, 36 }, { 26, 54, 58 }, { 24, 50, 54 }, { 44, 110, 110 }, { 255, 170, 90 }, { 36, 18, 6 }, { 232, 246, 244 }, { 104, 144, 142 }),
    Dracula = preset({ 24, 25, 33 }, { 29, 30, 40 }, { 34, 36, 47 }, { 52, 55, 70 }, { 48, 50, 64 }, { 98, 114, 164 }, { 189, 147, 249 }, { 26, 18, 44 }, { 246, 246, 238 }, { 126, 132, 168 }),
    Coffee = preset({ 20, 16, 13 }, { 25, 20, 16 }, { 30, 24, 19 }, { 48, 39, 31 }, { 45, 36, 29 }, { 104, 82, 62 }, { 214, 170, 124 }, { 32, 22, 12 }, { 240, 230, 218 }, { 142, 124, 108 }),
}

Library.ThemeName = "Noir"
Library.DefaultTheme = "Noir"

Library.Assets = {
    Shadow = "rbxassetid://6014261993",
    Glow = "rbxassetid://8992230677",
    Logo = "crown",
}

local LUCIDE_URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
local lucideSet = nil

local function loadLucide()
    if lucideSet ~= nil then
        return lucideSet
    end
    local ok, result = pcall(function()
        local source = game:HttpGet(LUCIDE_URL)
        return loadstring(source)()
    end)
    if ok and type(result) == "table" then
        lucideSet = result
    else
        lucideSet = false
        warn("[Noir] lucide icons unavailable: " .. tostring(result))
    end
    return lucideSet
end

local FONT_PRESETS = {
    ValleySans = {
        Regular = "https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Regular.ttf",
        Medium = "https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-Medium.ttf",
        SemiBold = "https://raw.githubusercontent.com/HelsinkiTypeStudio/valley-sans/main/fonts/ttf/ValleySans-SemiBold.ttf",
    },
}

local FONT_WEIGHTS = {
    Regular = { 400, Enum.FontWeight.Regular },
    Medium = { 500, Enum.FontWeight.Medium },
    SemiBold = { 600, Enum.FontWeight.SemiBold },
    Bold = { 700, Enum.FontWeight.Bold },
}

function Library:LoadFont(opts)
    opts = normalize(opts, {})
    if type(writefile) ~= "function" or type(isfile) ~= "function" or typeof(getcustomasset) ~= "function" then
        warn("[Noir] custom fonts need writefile, isfile and getcustomasset")
        return false
    end
    local name = opts.Name or "CustomFont"
    local weights = opts.Weights or FONT_PRESETS[name]
    if type(weights) ~= "table" then
        warn("[Noir] no font weights for " .. name)
        return false
    end
    local folder = opts.Folder or "NoirFonts"
    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(folder) then
            makefolder(folder)
        end
    end)
    local faces = {}
    for weightName, url in pairs(weights) do
        local info = FONT_WEIGHTS[weightName]
        if info then
            local path = folder .. "/" .. name .. "-" .. weightName .. ".ttf"
            local ok = true
            if not isfile(path) then
                ok = pcall(function()
                    writefile(path, game:HttpGet(url))
                end)
            end
            if ok then
                table.insert(faces, { name = weightName, weight = info[1], style = "normal", assetId = getcustomasset(path) })
            else
                warn("[Noir] could not download " .. weightName .. " weight of " .. name)
            end
        end
    end
    if #faces == 0 then
        return false
    end
    local familyPath = folder .. "/" .. name .. ".json"
    local okWrite = pcall(function()
        writefile(familyPath, HttpService:JSONEncode({ name = name, faces = faces }))
    end)
    if not okWrite then
        return false
    end
    local family = getcustomasset(familyPath)
    local function face(weightName, fallback)
        local info = FONT_WEIGHTS[weightName]
        if info and weights[weightName] then
            return Font.new(family, info[2])
        end
        return fallback
    end
    Library.Fonts.Regular = face("Regular", Library.Fonts.Regular)
    Library.Fonts.Medium = face("Medium", face("Regular", Library.Fonts.Medium))
    Library.Fonts.Bold = face("SemiBold", face("Bold", Library.Fonts.Bold))
    return true
end

function Library:PreloadIcons()
    return loadLucide() ~= false
end

-- Numbers, digit strings and asset URLs are custom images; anything else is
-- a lucide name.
local function assetId(value)
    if type(value) == "number" then
        return "rbxassetid://" .. string.format("%.0f", value)
    end
    if type(value) == "string" then
        if value:match("^%d+$") then
            return "rbxassetid://" .. value
        end
        if value:find("^rbxassetid://") or value:find("^rbxasset://") or value:find("^rbxthumb://") or value:find("^http") or (Assets and value == Assets.Logo) then
            return value
        end
    end
    return nil
end

-- Returns image, rect offset, rect size, whether it is a custom image, and
-- whether that custom image should still take the theme tint.
local function resolveIcon(icon)
    if typeof(icon) == "table" then
        return assetId(icon.Image) or icon.Image, icon.RectOffset, icon.RectSize, true, icon.Tint == true
    end
    local asset = assetId(icon)
    if asset then
        return asset, nil, nil, true, false
    end
    if type(icon) ~= "string" then
        return nil
    end
    local name = icon:gsub("^lucide:", "")
    local set = loadLucide()
    if not set then
        return nil
    end
    local entry = (set.Icons and set.Icons[name]) or set[name]
    if type(entry) == "table" then
        local image = entry.Image
        if type(image) == "number" then
            image = "rbxassetid://" .. tostring(image)
        end
        local sheet = (set.Spritesheets and set.Spritesheets[tostring(image)]) or image
        return sheet, entry.ImageRectPosition, entry.ImageRectSize
    elseif type(entry) == "string" then
        return entry
    end
    warn("[Noir] unknown lucide icon: " .. name)
    return nil
end

local BUTTON_HINT_ICON = "chevron-right"

local FONT_FAMILY = "rbxasset://fonts/families/BuilderSans.json"
Library.Fonts = {
    Regular = Font.new(FONT_FAMILY, Enum.FontWeight.Regular),
    Medium = Font.new(FONT_FAMILY, Enum.FontWeight.Medium),
    Bold = Font.new(FONT_FAMILY, Enum.FontWeight.SemiBold),
}

local Theme = Library.Theme
local Assets = Library.Assets

-- The Noir mark (NOIR CREATOR), embedded as a PNG so it needs no upload.
-- It is written to the workspace once and loaded with getcustomasset.
local EMBEDDED_LOGO = "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"

local function decodeBase64(data)
    local lookup = {}
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    for i = 1, #alphabet do
        lookup[alphabet:byte(i)] = i - 1
    end
    local out = {}
    for i = 1, #data, 4 do
        local a, b, c, d = data:byte(i, i + 3)
        local n = lookup[a] * 262144 + lookup[b] * 4096 + (lookup[c] or 0) * 64 + (lookup[d] or 0)
        local x, y, z = n // 65536, n // 256 % 256, n % 256
        if d ~= 61 then
            out[#out + 1] = string.char(x, y, z)
        elseif c ~= 61 then
            out[#out + 1] = string.char(x, y)
        else
            out[#out + 1] = string.char(x)
        end
    end
    return table.concat(out)
end

pcall(function()
    local getasset = (typeof(getcustomasset) == "function" and getcustomasset)
        or (typeof(getsynasset) == "function" and getsynasset)
    if type(writefile) ~= "function" or typeof(getasset) ~= "function" then
        return
    end
    local folder = "NoirAssets"
    if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(folder) then
        makefolder(folder)
    end
    local path = folder .. "/CybrionLogo.png"
    local png = decodeBase64(EMBEDDED_LOGO)
    local fresh = type(isfile) == "function" and type(readfile) == "function" and isfile(path) and readfile(path) == png
    if not fresh then
        writefile(path, png)
    end
    local asset = getasset(path)
    if type(asset) == "string" and asset ~= "" then
        Assets.Logo = asset
    end
end)
local Fonts = Library.Fonts

local TOUCH = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
Library.Touch = TOUCH

local SIDEBAR_WIDTH = 188
local HEADER_HEIGHT = 62
local TAB_TILE_HEIGHT = 34
local CARD_HEIGHT = TOUCH and 54 or 48
local CARD_HEIGHT_DESC = TOUCH and 70 or 64
local DROPDOWN_OPTION_HEIGHT = TOUCH and 40 or 34
local CHIP_HEIGHT = TOUCH and 34 or 28
local PROFILE_HEIGHT = 64
local SEARCH_WIDTH = 176
local STACK_BELOW = 440

-- Elements read their geometry from one of these. Cards stand alone on a tab,
-- rows sit flush inside a groupbox.
local METRICS = {
    Card = {
        Compact = false,
        Height = CARD_HEIGHT,
        DescHeight = CARD_HEIGHT_DESC,
        Chip = CHIP_HEIGHT,
        Option = DROPDOWN_OPTION_HEIGHT,
        TextSize = 14,
        DescSize = 13,
        TitleHeight = 18,
        DescGap = 20,
        DescLine = 17,
        Slider = CARD_HEIGHT_DESC,
    },
    Row = {
        Compact = true,
        Height = TOUCH and 40 or 32,
        DescHeight = TOUCH and 54 or 46,
        Chip = TOUCH and 30 or 24,
        Option = TOUCH and 34 or 28,
        TextSize = 13,
        DescSize = 12,
        TitleHeight = 16,
        DescGap = 17,
        DescLine = 15,
        Slider = TOUCH and 54 or 46,
    },
}

local tweenInfoCache = {}

-- Theme bindings: every instance property painted with a theme color is
-- remembered by theme key, so SetTheme can repaint the whole UI live.
-- Held strongly: an Instance's Lua handle can be collected while the Instance
-- still exists, which would silently drop it from a weak table. Destroyed
-- objects are pruned instead, once they have been parentless for two sweeps.
local themeBindings = {}
local themeHooks = {}
local themeLookup = {}
local orphanMarks = {}
local bindingCount = 0
local sweepAt = 4000

local function pruneTable(map, counted)
    for object in pairs(map) do
        if object.Parent == nil then
            if orphanMarks[object] then
                map[object] = nil
                orphanMarks[object] = nil
                if counted then
                    bindingCount -= 1
                end
            else
                orphanMarks[object] = true
            end
        else
            orphanMarks[object] = nil
        end
    end
end

local function sweepBindings()
    pruneTable(themeBindings, true)
    pruneTable(themeHooks, false)
    sweepAt = math.max(4000, bindingCount * 2)
end

local function colorKey(color)
    return math.floor(color.R * 255 + 0.5) .. "," .. math.floor(color.G * 255 + 0.5) .. "," .. math.floor(color.B * 255 + 0.5)
end

local function rebuildThemeLookup()
    table.clear(themeLookup)
    for index = #THEME_KEYS, 1, -1 do
        local name = THEME_KEYS[index]
        themeLookup[colorKey(Library.Theme[name])] = name
    end
end
rebuildThemeLookup()

local function bindColors(object, props)
    for property, value in pairs(props) do
        if typeof(value) == "Color3" then
            local name = themeLookup[colorKey(value)]
            local bound = themeBindings[object]
            if name then
                if not bound then
                    bound = {}
                    themeBindings[object] = bound
                    bindingCount += 1
                    if bindingCount >= sweepAt then
                        sweepBindings()
                    end
                end
                bound[property] = name
            elseif bound then
                bound[property] = nil
            end
        end
    end
end

-- Repaints every bound property from the colours on screen to the new theme.
-- One Heartbeat loop lerps each theme key once per frame and assigns the
-- result, instead of creating a tween per object, which hitched the frame the
-- theme changed on large UIs. A change mid-fade picks up from what is shown.
local shownTheme = table.clone(Library.Theme)
local themeDriver = nil

local function paintBinding(object, bound, colors)
    for property, name in pairs(bound) do
        local color = colors[name]
        if color then
            object[property] = color
        end
    end
end

local function paintBindings(colors)
    for object, bound in pairs(themeBindings) do
        pcall(paintBinding, object, bound, colors)
    end
end

local function driveTheme(duration)
    if themeDriver then
        themeDriver:Disconnect()
        themeDriver = nil
    end
    local from, colors = {}, {}
    for _, name in ipairs(THEME_KEYS) do
        local target = Library.Theme[name]
        local current = shownTheme[name] or target
        if current ~= target then
            from[name] = current
            colors[name] = current
        end
    end
    local function finish()
        for _, name in ipairs(THEME_KEYS) do
            colors[name] = Library.Theme[name]
            shownTheme[name] = Library.Theme[name]
        end
        paintBindings(colors)
    end
    if duration <= 0 or next(from) == nil then
        finish()
        return
    end
    local elapsed = 0
    themeDriver = RunService.Heartbeat:Connect(function(deltaTime)
        elapsed += deltaTime
        if elapsed >= duration then
            themeDriver:Disconnect()
            themeDriver = nil
            finish()
            return
        end
        local alpha = 1 - (1 - elapsed / duration) ^ 5
        for name, start in pairs(from) do
            local color = start:Lerp(Library.Theme[name], alpha)
            colors[name] = color
            shownTheme[name] = color
        end
        paintBindings(colors)
    end)
end

-- Runs fn now and again whenever the theme changes, while owner exists.
local function onTheme(owner, fn)
    themeHooks[owner] = fn
    fn()
end

local function tween(object, props, duration, style, direction, raw)
    duration = duration or 0.2
    if not raw then
        bindColors(object, props)
    end
    if duration <= 0 then
        for key, value in pairs(props) do
            object[key] = value
        end
        return nil
    end
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local key = duration .. style.Name .. direction.Name
    local info = tweenInfoCache[key]
    if not info then
        info = TweenInfo.new(duration, style, direction)
        tweenInfoCache[key] = info
    end
    local t = TweenService:Create(object, info, props)
    t:Play()
    return t
end

local function create(className, props, children)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        if key ~= "Parent" then
            inst[key] = value
        end
    end
    bindColors(inst, props)
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end

    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

-- Corners in pixels follow the player's corner radius setting: each one
-- remembers the radius it was drawn at, and Library:SetCornerRadius rescales
-- them all. Scale corners (pills, circles) stay as they are.
Library.Roundness = 0.8
-- A strong table: weak keys would drop the Lua handles for corners nothing
-- else in Lua holds, and those corners would never rescale. Destroyed ones
-- are pruned whenever the radius changes.
Library._cornerBases = {}

local function corner(parent, radius)
    radius = radius or UDim.new(0, 8)
    local object = create("UICorner", {
        CornerRadius = radius.Scale == 0 and UDim.new(0, math.floor(radius.Offset * Library.Roundness + 0.5)) or radius,
        Parent = parent,
    })
    if radius.Scale == 0 then
        Library._cornerBases[object] = radius.Offset
    end
    return object
end

-- A corner that ignores the setting, for shapes that animate their own
-- radius (the minimized island, the morph panels).
function Library._fixedCorner(parent, radius)
    return create("UICorner", { CornerRadius = radius, Parent = parent })
end

-- The radius the window's own corners are drawn at right now.
function Library._radius(pixels)
    return math.floor(pixels * Library.Roundness + 0.5)
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, left, right, top, bottom)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent,
    })
end

local function label(props)
    local defaults = {
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        TextSize = 14,
        FontFace = Fonts.Medium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }
    for key, value in pairs(props) do
        defaults[key] = value
    end
    return create("TextLabel", defaults)
end

local function glow(parent, size, position, transparency, rotation)
    local image = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Image = Assets.Glow,
        ImageColor3 = Color3.fromRGB(226, 218, 230),
        ImageTransparency = 1,
        Visible = false,
        ZIndex = 0,
        Parent = parent,
    })
    local gradient = create("UIGradient", {
        Rotation = rotation or 90,
        Parent = image,
    })
    onTheme(gradient, function()
        gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Theme.Accent)
    end)
    return image
end

local function edgeHighlight(parent)
    return create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = parent,
    })
end

local CUSTOM_ICON_SCALE = 1.35

local function applyIcon(imageLabel, icon, fixedSize)
    local image, rectOffset, rectSize, custom, tint = resolveIcon(icon)
    if not image then
        return
    end
    imageLabel.Image = image
    imageLabel.ImageRectOffset = rectOffset or Vector2.zero
    imageLabel.ImageRectSize = rectSize or Vector2.zero
    -- Brand logo preserves its original colours
    if icon == Assets.Logo then
        tint = false
    end
    local keepColours = custom and not tint
    imageLabel:SetAttribute("CustomIcon", keepColours or nil)
    if keepColours then
        -- Original colours, and out of the theme's reach.
        local bound = themeBindings[imageLabel]
        if bound then
            bound.ImageColor3 = nil
        end
        tween(imageLabel, { ImageColor3 = Color3.new(1, 1, 1) }, 0)
    end
    -- Uploaded images usually carry transparent padding and read smaller than
    -- the lucide set, so they are drawn larger. A table icon can pick its own
    -- Scale. Brand logos pass fixedSize, their slots are already sized for them.
    local scale = custom and not fixedSize and icon ~= Assets.Logo and (typeof(icon) == "table" and tonumber(icon.Scale) or CUSTOM_ICON_SCALE) or 1
    local scaler = imageLabel:FindFirstChild("CustomIconScale")
    if scale ~= 1 then
        scaler = scaler or create("UIScale", { Name = "CustomIconScale", Parent = imageLabel })
        scaler.Scale = scale
    elseif scaler then
        scaler:Destroy()
    end
end

-- Selection state for icons: tinted icons change colour, custom images keep
-- their colours and dim instead.
local function tintIcon(imageLabel, color, active, duration)
    if imageLabel:GetAttribute("CustomIcon") then
        tween(imageLabel, { ImageTransparency = active and 0 or 0.4 }, duration)
    else
        tween(imageLabel, { ImageColor3 = color }, duration)
    end
end

local function defaultParent()
    local hidden
    pcall(function()
        if typeof(gethui) == "function" then
            hidden = gethui()
        end
    end)
    if typeof(hidden) == "Instance" then
        return hidden
    end
    local core
    pcall(function()
        core = game:GetService("CoreGui")
        local probe = Instance.new("Folder")
        probe.Parent = core
        probe:Destroy()
    end)
    if core then
        return core
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local insetFrame, insetValue = nil, Vector2.zero
local function pointerPosition()
    local frame = time()
    if insetFrame ~= frame then
        insetFrame = frame
        insetValue = GuiService:GetGuiInset()
    end
    return UserInputService:GetMouseLocation() - insetValue
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function usingTouch()
    return UserInputService:GetLastInputType() == Enum.UserInputType.Touch
end

-- A press that turned into a scroll is not a tap. Returns a check to call
-- from the click handler.
local function tapGuard(button, getScroller)
    local startCanvas
    button.InputBegan:Connect(function(input)
        if isPress(input) then
            local frame = getScroller()
            startCanvas = frame and frame.CanvasPosition
        end
    end)
    return function()
        local frame = getScroller()
        return not (startCanvas and frame and (frame.CanvasPosition - startCanvas).Magnitude > 4)
    end
end

local function pointInside(point, object)
    local position, size = object.AbsolutePosition, object.AbsoluteSize
    return point.X >= position.X and point.X <= position.X + size.X
        and point.Y >= position.Y and point.Y <= position.Y + size.Y
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function glowIcon(parent, icon, color, position)
    local holder = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = position,
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local image = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ImageColor3 = color,
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    applyIcon(image, icon)
    return holder, image
end

local function arrowIndicator(parent, anchorX, offsetX)
    local holder = create("Frame", {
        AnchorPoint = Vector2.new(anchorX, 0.5),
        Position = UDim2.new(anchorX, offsetX, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local indicator = {}
    local image = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    applyIcon(image, "chevron-down")
    if image.Image ~= "" then
        function indicator:Set(open)
            tween(image, {
                Rotation = open and 180 or 0,
                ImageColor3 = open and Theme.Accent or Theme.Muted,
            }, 0.3, Enum.EasingStyle.Quint)
        end
        return indicator
    end
    image:Destroy()
    local function glyph(rotation, transparency)
        return label({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18),
            Text = "›",
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextColor3 = Theme.Muted,
            TextTransparency = transparency,
            Rotation = rotation,
            Parent = holder,
        })
    end
    local down = glyph(90, 0)
    local up = glyph(270, 1)
    function indicator:Set(open)
        tween(down, { TextTransparency = open and 1 or 0 }, 0.2)
        tween(up, { TextTransparency = open and 0 or 1, TextColor3 = open and Theme.Accent or Theme.Muted }, 0.2)
    end
    return indicator
end

local ripplePool = {}

local function ripple(button)
    local mouse = pointerPosition()
    local diameter = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2
    local circle = table.remove(ripplePool)
    -- A pooled circle can't be reparented if it was destroyed along the way.
    if circle and not pcall(function()
        circle.Parent = nil
    end) then
        circle = nil
    end
    if not circle then
        circle = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
        })
        corner(circle, UDim.new(1, 0))
    end
    circle.Position = UDim2.fromOffset(mouse.X - button.AbsolutePosition.X, mouse.Y - button.AbsolutePosition.Y)
    circle.Size = UDim2.fromOffset(0, 0)
    circle.BackgroundColor3 = Theme.Accent
    circle.BackgroundTransparency = 0.82
    circle.ZIndex = button.ZIndex + 1
    circle.Parent = button
    tween(circle, { Size = UDim2.fromOffset(diameter, diameter), BackgroundTransparency = 1 }, 0.55)
    task.delay(0.55, function()
        -- A button destroyed mid-ripple takes the circle with it: drop it.
        if circle.Parent ~= button or not button.Parent then
            pcall(circle.Destroy, circle)
            return
        end
        circle.Parent = nil
        if #ripplePool < 4 then
            table.insert(ripplePool, circle)
        else
            circle:Destroy()
        end
    end)
end

local function flashStroke(strokeObject)
    if not strokeObject or strokeObject:GetAttribute("Hidden") then
        return
    end
    tween(strokeObject, { Color = Theme.Accent, Transparency = 0.2 }, 0.08)
    task.delay(0.12, function()
        tween(strokeObject, { Color = Theme.Stroke, Transparency = 0 }, 0.35)
    end)
end

local function hoverStroke(target, strokeObject)
    target.MouseEnter:Connect(function()
        tween(strokeObject, { Color = Theme.StrokeHover }, 0.12)
    end)
    target.MouseLeave:Connect(function()
        tween(strokeObject, { Color = Theme.Stroke }, 0.25)
    end)
end

local KEY_NAMES = {
    [Enum.KeyCode.LeftControl] = "LCtrl",
    [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftShift] = "LShift",
    [Enum.KeyCode.RightShift] = "RShift",
    [Enum.KeyCode.LeftAlt] = "LAlt",
    [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.KeyCode.Return] = "Enter",
    [Enum.KeyCode.Escape] = "Esc",
    [Enum.KeyCode.Backspace] = "Backspace",
}

local function keyName(keyCode)
    if keyCode == nil then
        return "None"
    end
    return KEY_NAMES[keyCode] or keyCode.Name
end

local function safeCall(callback, ...)
    if type(callback) ~= "function" then
        return
    end
    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[Noir] callback error: " .. tostring(err))
    end
end

-- Runs a user callback on its own thread and waits for it with task.wait.
-- A callback that yields inside an engine call (InvokeServer and the like)
-- resumes at game identity, which can no longer touch the GUI in CoreGui;
-- keeping that on a separate thread leaves the caller's identity intact.
local function isolatedCall(callback)
    local result = nil
    task.spawn(function()
        result = table.pack(pcall(callback))
    end)
    while result == nil do
        task.wait()
    end
    return table.unpack(result, 1, result.n)
end

local function numberFormat(min, max, step)
    local decimals = 0
    local text = tostring(step)
    local dot = text:find("%.")
    if dot then
        decimals = #text - dot
    end
    local pattern = "%." .. decimals .. "f"
    return {
        snap = function(value)
            value = math.floor(value / step + 0.5) * step
            return math.clamp(value, min, max)
        end,
        format = function(value)
            return string.format(pattern, value)
        end,
    }
end

local function metricsOf(tab)
    return tab._metrics or METRICS.Card
end

-- Width of a value control inside a groupbox row. Every dropdown and input in
-- a groupbox uses the same share of the row, so their left edges line up.
local function rowControlWidth(frame, window)
    local width = frame.AbsoluteSize.X / window.Scale.Scale
    return math.clamp(math.floor(width * 0.48), 90, 220)
end

local function card(tab, className, height, opts)
    local compact = metricsOf(tab).Compact
    local props = {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = compact and 1 or 0,
        BorderSizePixel = 0,
        LayoutOrder = tab:_nextOrder(),
        Parent = tab.List,
    }
    if className == "TextButton" then
        props.AutoButtonColor = false
        props.Text = ""
    end
    local frame = create(className, props)
    frame:SetAttribute("NoDrag", true)
    corner(frame)
    local frameStroke = stroke(frame, Theme.Stroke, compact and 1 or 0)
    if compact then
        frameStroke:SetAttribute("Hidden", true)
    end
    return frame, frameStroke
end

local function titleDesc(parent, name, desc, rightReserve, metrics)
    metrics = metrics or METRICS.Card
    local title, descLabel
    if desc then
        local top = math.floor((metrics.DescHeight - (metrics.DescGap + metrics.DescLine)) / 2)
        title = label({
            Position = UDim2.fromOffset(14, top),
            Size = UDim2.new(1, -(14 + rightReserve), 0, metrics.TitleHeight),
            Text = name,
            TextSize = metrics.TextSize,
            Parent = parent,
        })
        descLabel = label({
            Position = UDim2.fromOffset(14, top + metrics.DescGap),
            Size = UDim2.new(1, -(14 + rightReserve), 0, metrics.DescLine),
            Text = desc,
            TextSize = metrics.DescSize,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = parent,
        })
    else
        title = label({
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -(14 + rightReserve), 1, 0),
            Text = name,
            TextSize = metrics.TextSize,
            Parent = parent,
        })
    end
    return title, descLabel
end

local function beginElement(tab, opts, map, className, rightReserve, fallbackName)
    opts = normalize(opts, map)
    local metrics = metricsOf(tab)
    local height = opts.Desc and metrics.DescHeight or metrics.Height
    local frame, frameStroke = card(tab, className or "Frame", height, opts)
    hoverStroke(frame, frameStroke)
    local title, descLabel
    if rightReserve then
        title, descLabel = titleDesc(frame, opts.Name or fallbackName, opts.Desc, rightReserve, metrics)
    end
    return opts, frame, frameStroke, height, title, descLabel
end

local function reserveRight(title, descLabel, width)
    if title then
        title.Size = UDim2.new(1, -(14 + width), title.Size.Y.Scale, title.Size.Y.Offset)
    end
    if descLabel then
        descLabel.Size = UDim2.new(1, -(14 + width), 0, descLabel.Size.Y.Offset)
    end
end

local Tab = {}
Tab.__index = Tab

function Tab:_nextOrder()
    self._order = self._order + 1
    return self._order
end

function Tab:Section(text)
    local visible = not (type(text) == "table" and text.Visible == false)
    if type(text) == "table" then
        text = text.Name or text.Title or ""
    end
    local inset = metricsOf(self).Compact and 14 or 2
    local holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = self:_nextOrder(),
        Parent = self.List,
    })
    local text_ = label({
        Position = UDim2.fromOffset(inset, 8),
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = string.upper(text),
        TextSize = 12,
        TextColor3 = Theme.Muted,
        TextTruncate = Enum.TextTruncate.None,
        Parent = holder,
    })
    local ruleInset = inset == 2 and 0 or inset
    local rule = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -ruleInset, 0, 16),
        Size = UDim2.new(1, -12, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = holder,
    })
    local function fitRule()
        rule.Size = UDim2.new(1, -(text_.AbsoluteSize.X / self.Window.Scale.Scale + inset + 12 + ruleInset), 0, 1)
    end
    text_:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitRule)
    task.defer(fitRule)
    return finishElement(self, { Visible = visible }, {
        Set = function(_, value)
            text_.Text = string.upper(value)
        end,
    }, holder, "Section")
end

function Tab:Divider(opts)
    local caption = type(opts) == "table" and (opts.Text or opts.Name) or type(opts) == "string" and opts or nil
    if caption then
        -- A centred caption with a rule on each side.
        local inset = metricsOf(self).Compact and 14 or 2
        local holder = create("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder = self:_nextOrder(),
            Parent = self.List,
        })
        local text_ = label({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0, 0, 0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = caption,
            TextSize = 11,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextTruncate = Enum.TextTruncate.None,
            Parent = holder,
        })
        padding(text_, 8, 8)
        local rules = {}
        for index, anchor in ipairs({ 0, 1 }) do
            rules[index] = create("Frame", {
                AnchorPoint = Vector2.new(anchor, 0.5),
                Position = UDim2.new(anchor, anchor == 0 and inset or -inset, 0.5, 0),
                Size = UDim2.new(0.5, -inset, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
                Parent = holder,
            })
        end
        local function fitRules()
            local half = text_.AbsoluteSize.X / self.Window.Scale.Scale / 2
            for _, rule in ipairs(rules) do
                rule.Size = UDim2.new(0.5, -(inset + half), 0, 1)
            end
        end
        text_:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitRules)
        task.defer(fitRules)
        return finishElement(self, { Visible = not (type(opts) == "table" and opts.Visible == false) }, {
            Set = function(_, value)
                text_.Text = tostring(value)
            end,
        }, holder, "Divider")
    end
    local line = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        LayoutOrder = self:_nextOrder(),
        Parent = self.List,
    })
    if metricsOf(self).Compact then
        line.BackgroundTransparency = 1
        line.Size = UDim2.new(1, 0, 0, 9)
        create("Frame", {
            Position = UDim2.fromOffset(14, 4),
            Size = UDim2.new(1, -28, 0, 1),
            BackgroundColor3 = Theme.Stroke,
            BorderSizePixel = 0,
            Parent = line,
        })
    end
    return finishElement(self, { Visible = not (type(opts) == "table" and opts.Visible == false) }, {}, line, "Divider")
end

function Tab:Label(opts)
    opts = normalize(opts, { Name = "Text", Title = "Text" })
    local text_ = label({
        Size = UDim2.new(1, 0, 0, 18),
        Text = Library._rich(opts.Text or ""),
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Library._color(opts.Color) or Theme.Muted,
        RichText = true,
        LayoutOrder = self:_nextOrder(),
        Parent = self.List,
    })
    if metricsOf(self).Compact then
        text_.TextSize = 12
        padding(text_, 14, 14)
    else
        padding(text_, 2)
    end
    local handle = {
        Set = function(_, value)
            text_.Text = Library._rich(value)
        end,
        Get = function()
            return text_.Text
        end,
        SetColor = function(_, color)
            tween(text_, { TextColor3 = Library._color(color) or Theme.Muted }, 0.25)
        end,
    }
    if type(opts.Update) == "function" then
        local rate = math.max(tonumber(opts.UpdateRate) or 1, 0.05)
        local running = true
        handle._listeners = handle._listeners or {}
        table.insert(handle._listeners, function()
            running = false
        end)
        task.spawn(function()
            while running and text_.Parent do
                local ok, value = isolatedCall(opts.Update)
                if ok and value ~= nil then
                    text_.Text = Library._rich(value)
                elseif not ok then
                    warn("[Noir] label update error: " .. tostring(value))
                end
                task.wait(rate)
            end
        end)
        function handle:SetUpdateRate(seconds)
            rate = math.max(tonumber(seconds) or rate, 0.05)
        end
    end
    return finishElement(self, opts, handle, text_, "Label")
end

function Tab:Paragraph(opts)
    opts = normalize(opts, { Title = "Name" })
    local frame = card(self, "Frame", 0, opts)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    if metricsOf(self).Compact then
        padding(frame, 14, 14, 6, 8)
    else
        padding(frame, 14, 14, 11, 12)
    end
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = frame,
    })
    label({
        Size = UDim2.new(1, 0, 0, 14),
        Text = opts.Name or "",
        LayoutOrder = 1,
        Parent = frame,
    })
    local content = label({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = Library._rich(opts.Content or ""),
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        TextYAlignment = Enum.TextYAlignment.Top,
        RichText = true,
        LayoutOrder = 2,
        Parent = frame,
    })
    return finishElement(self, opts, {
        Set = function(_, value)
            content.Text = Library._rich(value)
        end,
    }, frame, "Paragraph")
end

local function rowButton(tab, opts)
    local primary = opts.Style == "Primary"
    local boxHeight = TOUCH and 34 or 28
    local height = boxHeight + 6 + (opts.Desc and 16 or 0)
    local button = card(tab, "TextButton", height, opts)

    local box = create("Frame", {
        Position = UDim2.fromOffset(14, 3),
        Size = UDim2.new(1, -28, 0, boxHeight),
        BackgroundColor3 = primary and Theme.Accent or Theme.Surface3,
        BackgroundTransparency = primary and 0.12 or 0.45,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = button,
    })
    corner(box, UDim.new(0, 6))
    local boxStroke = stroke(box, primary and Theme.Accent or Theme.Stroke, primary and 0.4 or 0)

    local row = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = box,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = row,
    })
    local textColor = primary and Theme.AccentDark or Theme.Text
    if opts.Icon then
        local image = create("ImageLabel", {
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            ImageColor3 = primary and Theme.AccentDark or Theme.Accent,
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 1,
            Parent = row,
        })
        applyIcon(image, opts.Icon)
    end
    local title = label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = opts.Name or "Button",
        TextSize = 13,
        TextColor3 = textColor,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = row,
    })
    if opts.Desc then
        label({
            Position = UDim2.fromOffset(14, boxHeight + 6),
            Size = UDim2.new(1, -28, 0, 14),
            Text = opts.Desc,
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = button,
        })
    end

    local restBg = primary and 0.12 or 0.45
    button.MouseEnter:Connect(function()
        tween(box, { BackgroundTransparency = primary and 0 or 0.2 }, 0.12)
        tween(boxStroke, primary and { Transparency = 0 } or { Color = Theme.StrokeHover }, 0.12)
    end)
    button.MouseLeave:Connect(function()
        tween(box, { BackgroundTransparency = restBg }, 0.25)
        tween(boxStroke, primary and { Transparency = 0.4 } or { Color = Theme.Stroke }, 0.25)
    end)
    button.MouseButton1Click:Connect(function()
        ripple(box)
        safeCall(opts.Callback)
    end)

    return finishElement(tab, opts, {
        SetText = function(_, value)
            title.Text = value
        end,
    }, button, "Button")
end

function Tab:Button(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc" })
    if metricsOf(self).Compact then
        return rowButton(self, opts)
    end
    local primary = opts.Style == "Primary"
    local height = opts.Desc and CARD_HEIGHT_DESC or CARD_HEIGHT
    local button, buttonStroke = card(self, "TextButton", height, opts)
    button.ClipsDescendants = true

    if primary then
        tween(button, { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.12 }, 0)
        tween(buttonStroke, { Color = Theme.Accent }, 0)
        buttonStroke.Transparency = 0.4
        button.MouseEnter:Connect(function()
            tween(button, { BackgroundTransparency = 0 }, 0.12)
            tween(buttonStroke, { Transparency = 0 }, 0.12)
        end)
        button.MouseLeave:Connect(function()
            tween(button, { BackgroundTransparency = 0.12 }, 0.25)
            tween(buttonStroke, { Transparency = 0.4 }, 0.25)
        end)
    else
        hoverStroke(button, buttonStroke)
    end

    local textColor = primary and Theme.AccentDark or Theme.Text
    local iconOffset = 0
    if opts.Icon then
        glowIcon(button, opts.Icon, primary and Theme.AccentDark or Theme.Accent, UDim2.new(0, 14, 0.5, 0))
        iconOffset = 26
    end
    local title = titleDesc(button, opts.Name or "Button", opts.Desc, 30)
    if iconOffset > 0 then
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("TextLabel") then
                child.Position = child.Position + UDim2.fromOffset(iconOffset, 0)
                child.Size = child.Size - UDim2.fromOffset(iconOffset, 0)
            end
        end
    end
    if primary then
        for _, child in ipairs(button:GetChildren()) do
            if child:IsA("TextLabel") then
                tween(child, { TextColor3 = textColor }, 0)
            end
        end
    end

    glowIcon(button, BUTTON_HINT_ICON, primary and Theme.AccentDark or Theme.Muted, UDim2.new(1, -30, 0.5, 0))

    button.MouseButton1Click:Connect(function()
        ripple(button)
        safeCall(opts.Callback)
    end)

    return finishElement(self, opts, {
        SetText = function(_, value)
            title.Text = value
        end,
    }, button, "Button")
end

function Tab:Toggle(opts)
    local button, buttonStroke
    opts, button, buttonStroke = beginElement(self, opts, { Title = "Name", Description = "Desc", CurrentValue = "Default", Value = "Default" }, "TextButton", 56, "Toggle")

    local pill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = TOUCH and UDim2.fromOffset(44, 24) or UDim2.fromOffset(36, 20),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = button,
    })
    corner(pill, UDim.new(1, 0))
    stroke(pill, Theme.Stroke)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = TOUCH and UDim2.fromOffset(18, 18) or UDim2.fromOffset(14, 14),
        BackgroundColor3 = Theme.Muted,
        BorderSizePixel = 0,
        Parent = pill,
    })
    corner(knob, UDim.new(1, 0))
    local pillGlow = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 24, 1, 24),
        BackgroundTransparency = 1,
        Image = Assets.Glow,
        ImageColor3 = Theme.Accent,
        ImageTransparency = 1,
        ZIndex = 0,
        Parent = pill,
    })

    local self_ = { Value = opts.Default == true }

    local function render(animate)
        local on = self_.Value
        local duration = animate and 0.25 or 0
        tween(pill, { BackgroundColor3 = on and Theme.Accent or Theme.Surface3 }, duration)
        tween(pillGlow, { ImageTransparency = on and 0.75 or 1 }, duration)
        local knobSize = TOUCH and 18 or 14
        tween(knob, {
            Position = on and UDim2.new(0, (TOUCH and 44 or 36) - 3 - knobSize, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = on and Theme.AccentDark or Theme.Muted,
        }, duration, Enum.EasingStyle.Back)
        if animate then
            tween(knob, { Size = UDim2.fromOffset(knobSize + 4, knobSize - 2) }, 0.08)
            task.delay(0.08, function()
                tween(knob, { Size = UDim2.fromOffset(knobSize, knobSize) }, 0.2, Enum.EasingStyle.Back)
            end)
        end
    end

    local fromClick = false
    function self_:Set(value, silent)
        value = value == true
        if value == self_.Value then
            return
        end
        self_.Value = value
        render(true)
        if not fromClick then
            flashStroke(buttonStroke)
        end
        if not silent then
            safeCall(opts.Callback, value)
        end
    end

    function self_:Get()
        return self_.Value
    end

    render(false)
    button.MouseButton1Click:Connect(function()
        fromClick = true
        self_:Set(not self_.Value)
        fromClick = false
    end)

    local handle = finishElement(self, opts, self_, button, "Toggle")
    if self_.Value then
        safeCall(opts.Callback, true)
    end
    return handle
end

function Tab:Slider(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc", CurrentValue = "Default", Value = "Default", Increment = "Step" })
    local min = opts.Min or 0
    local max = opts.Max or 100
    local step = opts.Step or 1
    local suffix = opts.Suffix or ""
    local numbers = numberFormat(min, max, step)

    local metrics = metricsOf(self)
    local compact = metrics.Compact
    local height = metrics.Slider
    local frame, frameStroke = card(self, "Frame", height, opts)
    hoverStroke(frame, frameStroke)

    label({
        Position = UDim2.fromOffset(14, compact and 5 or 12),
        Size = UDim2.new(1, -120, 0, 18),
        Text = opts.Name or "Slider",
        TextSize = metrics.TextSize,
        Parent = frame,
    })

    local valueChip = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, compact and -14 or -10, 0, compact and 2 or 9),
        Size = UDim2.fromOffset(40, 24),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = frame,
    })
    corner(valueChip, UDim.new(0, 6))
    local chipStroke = stroke(valueChip)
    local valueLabel = label({
        Size = UDim2.new(1, 0, 1, 0),
        TextSize = 13,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        Parent = valueChip,
    })
    local valueBox = create("TextBox", {
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Medium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Visible = false,
        Parent = valueChip,
    })
    create("UISizeConstraint", { MinSize = Vector2.new(14, 0), Parent = valueBox })
    local suffixLabel = label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = suffix,
        TextSize = 13,
        TextColor3 = Theme.Accent,
        TextTruncate = Enum.TextTruncate.None,
        Visible = false,
        Parent = valueChip,
    })
    local chipButton = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
        Parent = valueChip,
    })
    local editing = false
    local function fitChip(instant)
        local width
        if editing then
            width = 9 + valueBox.AbsoluteSize.X / (self.Window.Scale.Scale) + suffixLabel.TextBounds.X + 9
            suffixLabel.Position = UDim2.fromOffset(9 + valueBox.AbsoluteSize.X / (self.Window.Scale.Scale), 0)
        else
            width = valueLabel.TextBounds.X + 18
        end
        width = math.max(width, 36)
        if instant then
            valueChip.Size = UDim2.fromOffset(width, 24)
        else
            tween(valueChip, { Size = UDim2.fromOffset(width, 24) }, 0.2)
        end
    end
    valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        if not editing then
            fitChip(false)
        end
    end)
    valueBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if editing then
            fitChip(false)
        end
    end)

    local track = create("Frame", {
        Position = UDim2.new(0, 14, 0, height - (compact and 13 or 18)),
        Size = UDim2.new(1, -28, 0, 5),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(track, UDim.new(1, 0))
    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, UDim.new(1, 0))

    local knobGlow = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        Image = Assets.Glow,
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.85,
        ZIndex = 2,
        Parent = track,
    })
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = track,
    })
    corner(knob, UDim.new(1, 0))

    local hit = create("TextButton", {
        Position = UDim2.new(0, 8, 0, height - (compact and 13 or 18) - (TOUCH and 19 or 13)),
        Size = UDim2.new(1, -16, 0, TOUCH and 40 or 28),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = frame,
    })

    local self_ = { Value = math.clamp(opts.Default or min, min, max) }
    local dragging = false
    chipButton.MouseEnter:Connect(function()
        tween(chipStroke, { Color = Theme.StrokeHover }, 0.12)
    end)
    chipButton.MouseLeave:Connect(function()
        if not valueBox:IsFocused() then
            tween(chipStroke, { Color = Theme.Stroke }, 0.2)
        end
    end)
    chipButton.MouseButton1Click:Connect(function()
        editing = true
        valueBox.Text = numbers.format(self_.Value)
        valueLabel.Visible = false
        valueBox.Visible = true
        suffixLabel.Visible = suffix ~= ""
        chipButton.Visible = false
        tween(chipStroke, { Color = Theme.StrokeHover }, 0.12)
        valueBox:CaptureFocus()
        task.defer(fitChip, false)
    end)
    valueBox.FocusLost:Connect(function()
        local typed = tonumber(valueBox.Text)
        editing = false
        valueBox.Visible = false
        suffixLabel.Visible = false
        valueLabel.Visible = true
        chipButton.Visible = true
        tween(chipStroke, { Color = Theme.Stroke }, 0.2)
        if typed then
            self_:Set(typed)
        end
        fitChip(false)
    end)
    hit.MouseEnter:Connect(function()
        if not dragging then
            tween(knobGlow, { ImageTransparency = 0.78, Size = UDim2.fromOffset(34, 34) }, 0.15)
        end
    end)
    hit.MouseLeave:Connect(function()
        if not dragging then
            tween(knobGlow, { ImageTransparency = 0.85, Size = UDim2.fromOffset(28, 28) }, 0.2)
        end
    end)

    local snap = numbers.snap

    local function fraction()
        return (max - min) == 0 and 0 or (self_.Value - min) / (max - min)
    end

    local function moveTo(frac, duration, style)
        style = style or Enum.EasingStyle.Linear
        tween(fill, { Size = UDim2.new(frac, 0, 1, 0) }, duration, style)
        tween(knob, { Position = UDim2.new(frac, 0, 0.5, 0) }, duration, style)
        tween(knobGlow, { Position = UDim2.new(frac, 0, 0.5, 0) }, duration, style)
    end

    local function render(duration, style)
        moveTo(fraction(), duration, style)
        valueLabel.Text = numbers.format(self_.Value) .. suffix
    end

    local function settleTo(previousFrac)
        local target = fraction()
        local width = math.max(track.AbsoluteSize.X, 1)
        local overshoot = (target >= previousFrac and 1 or -1) * (5 / width)
        moveTo(math.clamp(target + overshoot, 0, 1), 0.22, Enum.EasingStyle.Quint)
        task.delay(0.22, function()
            if not dragging then
                moveTo(fraction(), 0.18, Enum.EasingStyle.Quint)
            end
        end)
        valueLabel.Text = numbers.format(self_.Value) .. suffix
    end

    local function bounceKnob()
        tween(knob, { Size = UDim2.fromOffset(14, 12) }, 0.08)
        tween(knobGlow, { Size = UDim2.fromOffset(32, 32), ImageTransparency = 0.78 }, 0.12)
        task.delay(0.1, function()
            tween(knob, { Size = UDim2.fromOffset(12, 12) }, 0.25, Enum.EasingStyle.Quint)
            tween(knobGlow, { Size = UDim2.fromOffset(28, 28), ImageTransparency = 0.85 }, 0.25)
        end)
    end

    function self_:Set(value, silent)
        value = snap(tonumber(value) or min)
        if value == self_.Value then
            return
        end
        local previousFrac = fraction()
        self_.Value = value
        if dragging then
            render(0.05)
        else
            settleTo(previousFrac)
            bounceKnob()
            flashStroke(frameStroke)
        end
        if not silent then
            safeCall(opts.Callback, value)
        end
    end

    function self_:Get()
        return self_.Value
    end

    local function updateFromX(x)
        local frac = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        self_:Set(min + (max - min) * frac)
    end

    hit.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            self_.Dragging = true
            tween(knob, { Size = UDim2.fromOffset(16, 16) }, 0.15, Enum.EasingStyle.Back)
            tween(knobGlow, { Size = UDim2.fromOffset(44, 44), ImageTransparency = 0.7 }, 0.15)
            updateFromX(pointerPosition().X)
        end
    end)

    self.Window:_listen("Changed", function(input)
        if dragging and isMove(input) then
            updateFromX(pointerPosition().X)
        end
    end, self_)

    self.Window:_listen("Ended", function(input)
        if dragging and isPress(input) then
            dragging = false
            self_.Dragging = false
            tween(knob, { Size = UDim2.fromOffset(12, 12) }, 0.2)
            tween(knobGlow, { Size = UDim2.fromOffset(28, 28), ImageTransparency = 0.85 }, 0.2)
            safeCall(opts.OnRelease, self_.Value)
        end
    end, self_)

    self_.Value = snap(self_.Value)
    render(0)
    task.defer(fitChip, true)
    return finishElement(self, opts, self_, frame, "Slider")
end

function Tab:Dropdown(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc", CurrentOption = "Default", Value = "Default", MultipleOptions = "Multi", Values = "Options" })
    if opts.Multi and type(opts.Default) ~= "table" and opts.Default ~= nil then
        opts.Default = { opts.Default }
    elseif not opts.Multi and type(opts.Default) == "table" then
        opts.Default = opts.Default[1]
    end
    local multi = opts.Multi == true
    local options = opts.Options or {}
    local frame, frameStroke, height
    opts, frame, frameStroke, height = beginElement(self, opts, {}, "Frame")
    local metrics = metricsOf(self)
    local compact = metrics.Compact
    local chipHeight = metrics.Chip
    local window = self.Window
    local ROW = TOUCH and 40 or 30
    local MAX_ROWS = opts.MaxRows or 6
    -- Stacked: the chip spans the whole row, with the name (if any) above it.
    local stacked = compact and opts.Stacked == true
    local stackTop = 2
    if stacked then
        stackTop = (opts.Name or "") ~= "" and 20 or 2
        chipHeight = TOUCH and 34 or 30
        height = stackTop + chipHeight + 4
        frame.Size = UDim2.new(1, 0, 0, height)
    end

    local header = create("TextButton", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    local titleLabel, descLabel
    if not stacked then
        titleLabel, descLabel = titleDesc(header, opts.Name or "Dropdown", opts.Desc, 180, metrics)
    elseif stackTop > 2 then
        titleLabel = label({
            Position = UDim2.fromOffset(14, 1),
            Size = UDim2.new(1, -28, 0, 16),
            Text = opts.Name,
            TextSize = metrics.TextSize,
            Parent = header,
        })
    end

    local chip = create("Frame", {
        AnchorPoint = stacked and Vector2.zero or Vector2.new(1, 0.5),
        Position = stacked and UDim2.fromOffset(14, stackTop) or UDim2.new(1, compact and -14 or -10, 0.5, 0),
        Size = UDim2.fromOffset(60, chipHeight),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = header,
    })
    corner(chip, UDim.new(0, 6))
    local chipStroke = stroke(chip)
    local valueLabel = label({
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -34, 1, 0),
        TextColor3 = Theme.Muted,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.None,
        ClipsDescendants = true,
        Parent = chip,
    })
    local arrow = arrowIndicator(chip, 1, -6)
    local measure = label({
        Size = UDim2.fromOffset(0, chipHeight),
        AutomaticSize = Enum.AutomaticSize.X,
        TextSize = 13,
        Visible = false,
        Parent = chip,
    })
    local fullText = ""
    local function trimmed()
        local maxText = (stacked and frame.AbsoluteSize.X / window.Scale.Scale - 28 or compact and rowControlWidth(frame, window) or 190) - 10 - 34
        measure.Text = fullText
        if measure.TextBounds.X <= maxText then
            return fullText
        end
        local text = fullText
        while #text > 1 do
            text = text:sub(1, -2)
            measure.Text = text .. ".."
            if measure.TextBounds.X <= maxText then
                return text .. ".."
            end
        end
        return ".."
    end
    local function fitChip(instant)
        if stacked then
            chip.Size = UDim2.new(1, -28, 0, chipHeight)
            return
        end
        local width
        if compact then
            width = rowControlWidth(frame, window)
        else
            width = math.clamp(valueLabel.TextBounds.X + 10 + 34, 60, 190)
        end
        reserveRight(titleLabel, descLabel, width + (compact and 24 or 20))
        if instant then
            chip.Size = UDim2.fromOffset(width, chipHeight)
        else
            tween(chip, { Size = UDim2.fromOffset(width, chipHeight) }, 0.2)
        end
    end
    valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        if not compact then
            fitChip(false)
        end
    end)
    if compact then
        -- The chip follows the row every frame; re-measuring the text waits
        -- until the width stops changing so resizing stays cheap.
        local lastWidth, pending = 0, false
        frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local width = frame.AbsoluteSize.X
            if width == lastWidth then
                return
            end
            lastWidth = width
            fitChip(true)
            if not pending then
                pending = true
                task.delay(0.12, function()
                    pending = false
                    valueLabel.Text = trimmed()
                end)
            end
        end)
    end

    -- Popup: floats over the window under the chip, with search, bulk
    -- actions for multi selection and a scrolling list of checkbox rows.
    -- The popup is a plain clipped frame that unfolds out of the chip, so text
    -- stays crisp. The shadow sits outside the clip.
    local popup = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.fromOffset(220, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 45,
        Parent = window.Body,
    })
    popup:SetAttribute("NoDrag", true)
    local popupShadow = create("ImageLabel", {
        Position = UDim2.fromOffset(-18, -12),
        Size = UDim2.new(1, 36, 1, 36),
        BackgroundTransparency = 1,
        Image = Assets.Shadow,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = popup,
    })
    local panel = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = popup,
    })
    corner(panel, UDim.new(0, 10))
    local panelStroke = stroke(panel, Theme.Stroke, 1)
    edgeHighlight(panel)
    local inner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 120),
        BackgroundTransparency = 1,
        Parent = panel,
    })
    padding(inner, 8, 8, 8, 8)

    local searchHolder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = inner,
    })
    corner(searchHolder, UDim.new(0, 7))
    local searchStroke = stroke(searchHolder)
    local searchIconHolder, searchIcon = glowIcon(searchHolder, "search", Theme.Muted, UDim2.new(0, 10, 0.5, 0))
    searchIconHolder.Size = UDim2.fromOffset(14, 14)
    local searchBox = create("TextBox", {
        Position = UDim2.fromOffset(32, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = opts.SearchPlaceholder or "Search",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = false,
        Parent = searchHolder,
    })
    searchBox.Focused:Connect(function()
        tween(searchStroke, { Color = Theme.StrokeHover }, 0.15)
        tween(searchIcon, { ImageColor3 = Theme.Accent }, 0.15)
    end)
    searchBox.FocusLost:Connect(function()
        tween(searchStroke, { Color = Theme.Stroke }, 0.2)
        tween(searchIcon, { ImageColor3 = Theme.Muted }, 0.2)
    end)

    local actions = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Visible = multi,
        Parent = inner,
    })
    local function actionButton(text, position)
        local button = create("TextButton", {
            Position = position,
            Size = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = Theme.Surface3,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true,
            Parent = actions,
        })
        corner(button, UDim.new(0, 6))
        local buttonStroke = stroke(button)
        label({
            Size = UDim2.fromScale(1, 1),
            Text = text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = button,
        })
        button.MouseEnter:Connect(function()
            tween(button, { BackgroundTransparency = 0.05 }, 0.15)
            tween(buttonStroke, { Color = Theme.StrokeHover }, 0.15)
        end)
        button.MouseLeave:Connect(function()
            tween(button, { BackgroundTransparency = 0.35 }, 0.25)
            tween(buttonStroke, { Color = Theme.Stroke }, 0.25)
        end)
        button.MouseButton1Click:Connect(function()
            ripple(button)
        end)
        return button
    end
    local selectAll = actionButton(opts.SelectAllText or "Select all", UDim2.fromOffset(0, 0))
    local clearAll = actionButton(opts.ClearAllText or "Clear all", UDim2.new(0.5, 3, 0, 0))

    local list = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = TOUCH and 4 or 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        -- Sized by hand: AutomaticCanvasSize under the window's UIScale
        -- sometimes leaves the canvas short, so the list would not scroll.
        CanvasSize = UDim2.new(),
        Parent = inner,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = list,
    })
    local noResults = label({
        Size = UDim2.new(1, 0, 0, ROW),
        Text = opts.NoResultsText or "No results",
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 0,
        Visible = false,
        Parent = list,
    })

    local self_ = { Open = false }
    local selected = {}
    local optionButtons = {}
    local filter = ""

    local function matches(option)
        return filter == "" or string.find(string.lower(tostring(option)), filter, 1, true) ~= nil
    end

    -- Option labels are rich text, so the part matching the search can light up.
    local function escapeRich(text)
        return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end
    local function optionText(option)
        local text = tostring(option)
        local at = filter ~= "" and string.find(string.lower(text), filter, 1, true)
        if not at then
            return escapeRich(text)
        end
        local stop = at + #filter - 1
        return escapeRich(text:sub(1, at - 1))
            .. '<font color="#' .. Theme.Accent:ToHex() .. '"><b>' .. escapeRich(text:sub(at, stop)) .. "</b></font>"
            .. escapeRich(text:sub(stop + 1))
    end

    if multi then
        for _, value in ipairs(opts.Default or {}) do
            selected[value] = true
        end
    elseif opts.Default ~= nil then
        selected[opts.Default] = true
    end

    local function currentValue()
        if multi then
            local picked = {}
            for _, option in ipairs(options) do
                if selected[option] then
                    table.insert(picked, option)
                end
            end
            return picked
        end
        for _, option in ipairs(options) do
            if selected[option] then
                return option
            end
        end
        return nil
    end

    -- A picked row rests on a faint accent tint; hovering lifts either kind.
    local function restRow(entry, duration)
        local on, hover = entry.On == true, entry.Hover == true
        tween(entry.Frame, {
            BackgroundColor3 = on and Theme.Accent or Theme.Surface3,
            BackgroundTransparency = on and (hover and 0.8 or 0.88) or (hover and 0.55 or 1),
        }, duration)
        tween(entry.Label, { TextColor3 = (on or hover) and Theme.Text or Theme.Muted }, duration)
    end

    local function paintOption(button, animate)
        local on = selected[button.Option] == true
        if button.On == on and animate then
            return
        end
        button.On = on
        local duration = animate and 0.18 or 0
        restRow(button, duration)
        if multi then
            tween(button.Box, { BackgroundColor3 = on and Theme.Accent or Theme.Surface2 }, duration)
            tween(button.BoxStroke, { Color = on and Theme.Accent or Theme.Stroke }, duration)
        else
            tween(button.Bar, {
                BackgroundTransparency = on and 0 or 1,
                Size = UDim2.fromOffset(3, on and ROW - 14 or 4),
            }, animate and 0.3 or 0, Enum.EasingStyle.Quint)
        end
        tween(button.Check, { ImageTransparency = on and 0 or 1 }, duration)
        if animate and on then
            button.CheckScale.Scale = 0.5
            tween(button.CheckScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        else
            button.CheckScale.Scale = 1
        end
    end

    local function renderValue(animate)
        local value = currentValue()
        if #options == 0 then
            fullText = opts.EmptyText or "None"
        elseif multi then
            -- Two names at most, then a count, so a long pick stays readable.
            if #value > 2 then
                fullText = tostring(value[1]) .. ", " .. tostring(value[2]) .. "  +" .. (#value - 2)
            else
                fullText = #value > 0 and table.concat(value, ", ") or (opts.NoneText or "None")
            end
        else
            fullText = value ~= nil and tostring(value) or (opts.NoneText or "None")
        end
        valueLabel.Text = trimmed()
        -- A picked value reads in full colour; "None" stays muted.
        local picked = #options > 0 and (if multi then #value > 0 else value ~= nil)
        tween(valueLabel, { TextColor3 = picked and Theme.Text or Theme.Muted }, animate and 0.15 or 0)
        for _, button in pairs(optionButtons) do
            paintOption(button, animate)
        end
    end

    local function visibleCount()
        local count = 0
        for _, option in ipairs(options) do
            if matches(option) then
                count += 1
            end
        end
        return count
    end

    local searchShown = true
    local targetSize = Vector2.new(220, 120)
    local opened = false
    local function layoutPopup(instant)
        searchShown = opts.Searchable ~= false and #options > (opts.SearchAfter or 0)
        searchHolder.Visible = searchShown
        local top = 0
        if searchShown then
            top += 38
        end
        actions.Position = UDim2.fromOffset(0, top)
        if multi and #options > 0 then
            actions.Visible = true
            top += 34
        else
            actions.Visible = false
        end
        local count = visibleCount()
        noResults.Visible = count == 0
        local rows = math.clamp(count, 1, MAX_ROWS)
        local listHeight = rows * ROW + (rows - 1) * 2
        list.CanvasSize = UDim2.fromOffset(0, math.max(count, 1) * (ROW + 2) - 2)
        local scale = window.Scale.Scale
        -- Shrink the list to whichever side of the chip has more room, so the
        -- popup never runs off a short window (phones in landscape).
        local host = window:_popupHost(frame)
        local bodyHeight = host.AbsoluteSize.Y / scale
        local chipTop = (chip.AbsolutePosition.Y - host.AbsolutePosition.Y) / scale
        local room = math.max(bodyHeight - (chipTop + chip.AbsoluteSize.Y / scale) - 14, chipTop - 14) - top - 16
        if room >= ROW then
            listHeight = math.min(listHeight, room)
        end
        list.Position = UDim2.fromOffset(0, top)
        list.Size = UDim2.new(1, 0, 0, listHeight)
        local width = math.max(math.floor(chip.AbsoluteSize.X / scale), opts.PopupWidth or 210)
        local bodyWidth = host.AbsoluteSize.X / scale
        width = math.min(width, math.max(bodyWidth - 16, 120))
        targetSize = Vector2.new(width, top + listHeight + 16)
        inner.Size = UDim2.new(1, 0, 0, targetSize.Y)
        if not opened then
            return
        end
        if instant then
            popup.Size = UDim2.fromOffset(targetSize.X, targetSize.Y)
        else
            tween(popup, { Size = UDim2.fromOffset(targetSize.X, targetSize.Y) }, 0.22, Enum.EasingStyle.Quint)
        end
    end

    local function applyFilter()
        for option, button in pairs(optionButtons) do
            local shown = matches(option)
            button.Frame.Visible = shown
            if shown then
                button.Label.Text = optionText(option)
            end
        end
    end

    local scroller = nil
    local function place()
        local body = window:_popupHost(frame)
        local scale = window.Scale.Scale
        if scroller then
            local centre = chip.AbsolutePosition + chip.AbsoluteSize / 2
            if not pointInside(centre, scroller) then
                self_:SetOpen(false)
                return
            end
        end
        local bodySize = body.AbsoluteSize / scale
        local chipPosition = (chip.AbsolutePosition - body.AbsolutePosition) / scale
        local chipSize = chip.AbsoluteSize / scale
        local right = math.clamp(chipPosition.X + chipSize.X, targetSize.X + 8, math.max(bodySize.X - 8, targetSize.X + 8))
        local below = chipPosition.Y + chipSize.Y + 6
        -- Opening upward pins the content to the bottom edge so it unfolds from the chip.
        if below + targetSize.Y > bodySize.Y - 8 and chipPosition.Y - 6 - targetSize.Y >= 8 then
            popup.AnchorPoint = Vector2.new(1, 1)
            popup.Position = UDim2.fromOffset(right, chipPosition.Y - 6)
            inner.AnchorPoint = Vector2.new(0, 1)
            inner.Position = UDim2.fromScale(0, 1)
        else
            popup.AnchorPoint = Vector2.new(1, 0)
            popup.Position = UDim2.fromOffset(right, below)
            inner.AnchorPoint = Vector2.zero
            inner.Position = UDim2.fromScale(0, 0)
        end
    end

    local stopFollowing = nil
    local closeGeneration = 0
    -- The page behind stops scrolling while the popup is open, so wheel and
    -- swipe input always reach the list instead of dragging the page away.
    local lockedScroller = nil
    local function unlockScroller()
        if lockedScroller then
            lockedScroller.ScrollingEnabled = true
            lockedScroller = nil
        end
    end
    local function scrollToSelected()
        list.CanvasPosition = Vector2.zero
        if multi then
            return
        end
        local value = currentValue()
        if value == nil then
            return
        end
        for index, option in ipairs(options) do
            if option == value then
                list.CanvasPosition = Vector2.new(0, math.max(0, (index - 2) * (ROW + 2)))
                return
            end
        end
    end
    local function setOpen(open)
        if open == self_.Open then
            return
        end
        self_.Open = open
        arrow:Set(open)
        tween(chipStroke, { Color = open and Theme.Accent or Theme.Stroke, Transparency = open and 0.35 or 0 }, 0.2)
        tween(chip, { BackgroundColor3 = open and Theme.Surface2 or Theme.Surface }, 0.2)
        closeGeneration += 1
        if open then
            if window._closePopup and window._closePopup ~= self_._close then
                window._closePopup()
            end
            window._closePopup = self_._close
            scroller = frame:FindFirstAncestorWhichIsA("ScrollingFrame")
            if scroller and scroller.ScrollingEnabled then
                lockedScroller = scroller
                scroller.ScrollingEnabled = false
            end
            -- Drawn over a floating panel when the dropdown lives in one.
            popup.Parent = window:_popupHost(frame)
            filter = ""
            searchBox.Text = ""
            searchBox.PlaceholderText = opts.SearchPlaceholder or (#options > 6 and ("Search " .. #options .. " options") or "Search")
            applyFilter()
            layoutPopup(true)
            renderValue(false)
            scrollToSelected()
            opened = true
            popup.Size = UDim2.fromOffset(targetSize.X, 0)
            place()
            popup.Visible = true
            tween(popup, { Size = UDim2.fromOffset(targetSize.X, targetSize.Y) }, 0.3, Enum.EasingStyle.Quint)
            tween(panelStroke, { Transparency = 0 }, 0.12)
            tween(popupShadow, { ImageTransparency = 0.4 }, 0.3)
            if not stopFollowing then
                stopFollowing = window:_listen("Render", place)
            end
        else
            if window._closePopup == self_._close then
                window._closePopup = nil
            end
            unlockScroller()
            if searchBox:IsFocused() then
                searchBox:ReleaseFocus()
            end
            opened = false
            tween(popup, { Size = UDim2.fromOffset(targetSize.X, 0) }, 0.2, Enum.EasingStyle.Quint)
            tween(popupShadow, { ImageTransparency = 1 }, 0.16)
            local generation = closeGeneration
            task.delay(0.14, function()
                if closeGeneration == generation and not self_.Open then
                    tween(panelStroke, { Transparency = 1 }, 0.06)
                end
            end)
            task.delay(0.21, function()
                if closeGeneration == generation and not self_.Open then
                    popup.Visible = false
                    if stopFollowing then
                        stopFollowing()
                        stopFollowing = nil
                    end
                end
            end)
        end
    end
    self_._close = function()
        setOpen(false)
    end

    local function commit()
        renderValue(true)
        safeCall(opts.Callback, currentValue())
    end

    local function buildOptions()
        local keep = {}
        for index, option in ipairs(options) do
            keep[option] = index
        end
        for option, button in pairs(optionButtons) do
            if not keep[option] then
                button.Frame:Destroy()
                optionButtons[option] = nil
            end
        end
        for index, option in ipairs(options) do
            local existing = optionButtons[option]
            if existing then
                existing.Frame.LayoutOrder = index
                continue
            end
            local row = create("TextButton", {
                Size = UDim2.new(1, -6, 0, ROW),
                BackgroundColor3 = Theme.Surface3,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = index,
                Parent = list,
            })
            corner(row, UDim.new(0, 7))
            -- Multi selection ticks a checkbox on the left. A single pick
            -- gets an accent bar on the left edge and a check on the right.
            local box, boxStroke, bar, check
            if multi then
                box = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 8, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundColor3 = Theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                corner(box, UDim.new(0, 5))
                boxStroke = stroke(box, Theme.Stroke)
                check = create("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundTransparency = 1,
                    ImageColor3 = Theme.AccentDark,
                    ImageTransparency = 1,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = box,
                })
            else
                bar = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.fromOffset(3, 4),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                corner(bar, UDim.new(1, 0))
                check = create("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    BackgroundTransparency = 1,
                    ImageColor3 = Theme.Accent,
                    ImageTransparency = 1,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = row,
                })
            end
            applyIcon(check, "check")
            local checkScale = create("UIScale", { Parent = check })
            local text_ = label({
                Position = UDim2.fromOffset(multi and 36 or 14, 0),
                Size = UDim2.new(1, multi and -44 or -46, 1, 0),
                Text = optionText(option),
                TextSize = 13,
                TextColor3 = Theme.Muted,
                RichText = true,
                Parent = row,
            })
            local entry = { Option = option, Frame = row, Box = box, BoxStroke = boxStroke, Bar = bar, Check = check, CheckScale = checkScale, Label = text_, On = nil, Hover = false }
            local isTap = tapGuard(row, function()
                return list
            end)
            row.MouseEnter:Connect(function()
                -- Touch fires enter without a matching leave; skip the hover.
                if usingTouch() then
                    return
                end
                entry.Hover = true
                restRow(entry, 0.15)
                if boxStroke and not selected[option] then
                    tween(boxStroke, { Color = Theme.StrokeHover }, 0.15)
                end
            end)
            row.MouseLeave:Connect(function()
                entry.Hover = false
                restRow(entry, 0.25)
                if boxStroke and not selected[option] then
                    tween(boxStroke, { Color = Theme.Stroke }, 0.25)
                end
            end)
            row.MouseButton1Click:Connect(function()
                if not isTap() then
                    return
                end
                if selected[option] then
                    if not multi and opts.AllowNone == false then
                        setOpen(false)
                        return
                    end
                    selected[option] = nil
                else
                    if not multi then
                        selected = {}
                    end
                    selected[option] = true
                end
                commit()
                if not multi then
                    setOpen(false)
                end
            end)
            optionButtons[option] = entry
            paintOption(entry, false)
        end
        applyFilter()
        if self_.Open then
            layoutPopup(false)
        end
    end

    selectAll.MouseButton1Click:Connect(function()
        for _, option in ipairs(options) do
            if matches(option) then
                selected[option] = true
            end
        end
        commit()
    end)
    clearAll.MouseButton1Click:Connect(function()
        selected = {}
        commit()
    end)

    function self_:Set(value, silent)
        selected = {}
        if multi then
            for _, item in ipairs(type(value) == "table" and value or { value }) do
                selected[item] = true
            end
        elseif value ~= nil then
            selected[value] = true
        end
        renderValue(self_.Open)
        flashStroke(frameStroke)
        if not silent then
            safeCall(opts.Callback, currentValue())
        end
    end

    function self_:Get()
        return currentValue()
    end

    local function sameValue(a, b)
        if type(a) ~= "table" or type(b) ~= "table" then
            return a == b
        end
        if #a ~= #b then
            return false
        end
        for index, item in ipairs(a) do
            if b[index] ~= item then
                return false
            end
        end
        return true
    end

    -- A kept pick only counts once its option exists, so a list filled in after a
    -- config load changes the value; the callback runs so scripts see it.
    function self_:Refresh(newOptions, keepSelection, silent)
        local before = currentValue()
        options = newOptions or {}
        if not keepSelection then
            selected = {}
        end
        buildOptions()
        renderValue(false)
        if not silent and not sameValue(before, currentValue()) then
            safeCall(opts.Callback, currentValue())
        end
    end

    -- Every pick, including ones whose option isn't in the list right now, so
    -- saving never drops them.
    function self_:_saveValue()
        local picked = currentValue()
        if multi then
            local seen = {}
            for _, item in ipairs(picked) do
                seen[item] = true
            end
            for item in pairs(selected) do
                if not seen[item] then
                    table.insert(picked, item)
                end
            end
            return picked
        end
        if picked == nil then
            picked = next(selected)
        end
        return picked
    end

    function self_:SetOpen(open)
        setOpen(open == true)
    end

    local headerTap = tapGuard(header, function()
        return frame:FindFirstAncestorWhichIsA("ScrollingFrame")
    end)
    header.MouseButton1Click:Connect(function()
        if headerTap() then
            setOpen(not self_.Open)
        end
    end)
    -- The chip answers the pointer before it is opened.
    header.MouseEnter:Connect(function()
        if not self_.Open and not usingTouch() then
            tween(chipStroke, { Color = Theme.StrokeHover }, 0.15)
            tween(chip, { BackgroundColor3 = Theme.Surface2 }, 0.15)
        end
    end)
    header.MouseLeave:Connect(function()
        if not self_.Open then
            tween(chipStroke, { Color = Theme.Stroke }, 0.25)
            tween(chip, { BackgroundColor3 = Theme.Surface }, 0.25)
        end
    end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        filter = string.lower(searchBox.Text)
        applyFilter()
        if self_.Open then
            layoutPopup(false)
        end
    end)
    self_._listeners = {
        function()
            setOpen(false)
            unlockScroller()
            if stopFollowing then
                stopFollowing()
                stopFollowing = nil
            end
            popup:Destroy()
        end,
    }
    window:_listen("Began", function(input)
        if not self_.Open then
            return
        end
        if input.KeyCode == Enum.KeyCode.Escape then
            setOpen(false)
        elseif isPress(input) then
            local point = pointerPosition()
            if not pointInside(point, popup) and not pointInside(point, header) then
                setOpen(false)
            end
        end
    end, self_)

    buildOptions()
    renderValue(false)
    task.defer(fitChip, true)
    return finishElement(self, opts, self_, frame, "Dropdown")
end

Library._amountSuffixes = { k = 1e3, m = 1e6, b = 1e9, t = 1e12, qa = 1e15, qi = 1e18 }

function Library._parseAmount(text)
    text = string.lower(tostring(text)):gsub("[%s,_%$]", "")
    text = text:gsub("kg$", ""):gsub("/s$", "")
    local number = tonumber(text)
    if number then
        return number
    end
    local digits, suffix = text:match("^(.-)(%a+)$")
    local scale = suffix and Library._amountSuffixes[suffix]
    number = digits and tonumber(digits)
    if number and scale then
        return number * scale
    end
    return nil
end

function Tab:Input(opts)
    local frame, frameStroke, _, titleLabel, descLabel
    opts, frame, frameStroke, _, titleLabel, descLabel = beginElement(self, opts, { Title = "Name", Description = "Desc", PlaceholderText = "Placeholder", CurrentValue = "Default", Value = "Default" }, "Frame", 160, "Input")
    local compact = metricsOf(self).Compact
    local boxHeight = compact and metricsOf(self).Chip + 2 or 30

    local boxHolder = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, compact and -14 or -10, 0.5, 0),
        Size = UDim2.fromOffset(170, boxHeight),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(boxHolder, UDim.new(0, 6))
    local boxStroke = stroke(boxHolder)

    local boxIcon = opts.Icon
    if boxIcon then
        glowIcon(boxHolder, boxIcon, Theme.Muted, UDim2.new(0, 8, 0.5, 0))
    end
    local box = create("TextBox", {
        Position = UDim2.fromOffset(boxIcon and 30 or 8, 0),
        Size = UDim2.new(1, boxIcon and -38 or -16, 1, 0),
        BackgroundTransparency = 1,
        Text = opts.Default or "",
        PlaceholderText = opts.Placeholder or "",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = compact and 13 or 14,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        TextTruncate = Enum.TextTruncate.None,
        ClipsDescendants = true,
        Parent = boxHolder,
    })
    boxHolder.ClipsDescendants = true

    local lastText = box.Text
    local value = opts.Numeric and Library._parseAmount(lastText) or nil
    if opts.Numeric and not value then
        lastText = ""
    end
    local focused = false
    local textInset = (boxIcon and 30 or 8) + 8
    local function fitBox(instant)
        local width
        if compact then
            width = rowControlWidth(frame, self.Window)
        else
            local cardWidth = frame.AbsoluteSize.X / self.Window.Scale.Scale
            local maxWidth = math.clamp(cardWidth - 14 - 110 - 20, 100, 200)
            local measured = box.TextBounds.X
            if #box.Text == 0 then
                measured = math.min(box.TextBounds.X, 90)
            end
            width = math.clamp(measured + textInset + 12, 90, maxWidth) + (focused and 8 or 0)
            width = math.min(width, maxWidth + 8)
        end
        reserveRight(titleLabel, descLabel, width + (compact and 24 or 20))
        if instant then
            boxHolder.Size = UDim2.fromOffset(width, boxHeight)
        else
            tween(boxHolder, { Size = UDim2.fromOffset(width, boxHeight) }, 0.18)
        end
    end
    local lastWidth = 0
    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if frame.AbsoluteSize.X ~= lastWidth then
            lastWidth = frame.AbsoluteSize.X
            fitBox(true)
        end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(function()
        fitBox(false)
    end)
    box:GetPropertyChangedSignal("TextBounds"):Connect(function()
        fitBox(false)
    end)
    task.defer(fitBox, true)

    box.Focused:Connect(function()
        focused = true
        tween(boxStroke, { Color = Theme.StrokeHover }, 0.15)
        fitBox(false)
    end)
    box.FocusLost:Connect(function(enterPressed)
        focused = false
        tween(boxStroke, { Color = Theme.Stroke }, 0.15)
        fitBox(false)
        if opts.Numeric then
            local number = Library._parseAmount(box.Text)
            if not number then
                box.Text = lastText
                return
            end
            lastText, value = box.Text, number
            safeCall(opts.Callback, number, enterPressed)
            return
        end
        safeCall(opts.Callback, box.Text, enterPressed)
    end)

    return finishElement(self, opts, {
        Set = function(_, newValue)
            box.Text = tostring(newValue)
            if opts.Numeric then
                local number = Library._parseAmount(box.Text)
                if number then
                    lastText, value = box.Text, number
                else
                    box.Text = lastText
                end
            end
            flashStroke(frameStroke)
        end,
        Get = function()
            if opts.Numeric then
                return value
            end
            return box.Text
        end,
        _saveValue = opts.Numeric and function()
            return lastText
        end or nil,
    }, frame, "Input")
end

function Tab:Keybind(opts)
    local frame, frameStroke, _, titleLabel, descLabel
    opts, frame, frameStroke, _, titleLabel, descLabel = beginElement(self, opts, { Title = "Name", Description = "Desc", CurrentKeybind = "Default", Value = "Default" }, "Frame", 110, "Keybind")
    if type(opts.Default) == "string" then
        opts.Default = Enum.KeyCode[opts.Default]
    end
    local compact = metricsOf(self).Compact
    local chipHeight = metricsOf(self).Chip

    local chip = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, compact and -14 or -10, 0.5, 0),
        Size = UDim2.fromOffset(44, chipHeight),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = frame,
    })
    corner(chip, UDim.new(0, 6))
    local chipStroke = stroke(chip)
    local chipLabel = label({
        Size = UDim2.new(1, 0, 1, 0),
        TextSize = 13,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        Parent = chip,
    })

    local self_ = { Value = opts.Default, Listening = false }

    local function fitChip(instant)
        local width = math.max(chipLabel.TextBounds.X + 20, TOUCH and 44 or 36)
        reserveRight(titleLabel, descLabel, width + (compact and 24 or 20))
        if instant then
            chip.Size = UDim2.fromOffset(width, chipHeight)
        else
            tween(chip, { Size = UDim2.fromOffset(width, chipHeight) }, 0.2)
        end
    end
    chipLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        fitChip(false)
    end)

    local function render()
        chipLabel.Text = self_.Listening and "..." or keyName(self_.Value)
        tween(chipStroke, { Color = self_.Listening and Theme.StrokeHover or Theme.Stroke }, 0.15)
        tween(chipLabel, { TextColor3 = self_.Listening and Theme.Accent or Theme.Muted }, 0.15)
    end

    function self_:Set(keyCode, silent)
        local wasListening = self_.Listening
        self_.Value = keyCode
        self_.Listening = false
        render()
        if not wasListening then
            flashStroke(frameStroke)
        end
        if not silent then
            safeCall(opts.OnChanged, keyCode)
        end
    end

    chip.MouseButton1Click:Connect(function()
        self_.Listening = not self_.Listening
        render()
    end)

    self.Window:_listen("Began", function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if self_.Listening then
            self.Window._consumedKey = input.KeyCode
            self.Window._consumedAt = os.clock()
            if input.KeyCode == Enum.KeyCode.Escape then
                self_.Listening = false
                render()
            else
                self_:Set(input.KeyCode)
            end
            return
        end
        if not gameProcessed and self_.Value ~= nil and input.KeyCode == self_.Value then
            safeCall(opts.Callback, input.KeyCode)
        end
    end, self_)

    render()
    task.defer(fitChip, true)
    function self_:Get()
        return self_.Value
    end
    self_._onHide = function()
        if self_.Listening then
            self_.Listening = false
            render()
        end
    end
    return finishElement(self, opts, self_, frame, "Keybind")
end

function Tab:ColorPicker(opts)
    local PANEL_HEIGHT = 194
    local frame, frameStroke, height
    opts, frame, frameStroke, height = beginElement(self, opts, { Title = "Name", Description = "Desc", Color = "Default", CurrentValue = "Default", Value = "Default" }, "Frame")
    frame.ClipsDescendants = true
    local metrics = metricsOf(self)
    local compact = metrics.Compact

    local header = create("TextButton", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    titleDesc(header, opts.Name or "Color", opts.Desc, 140, metrics)

    -- Closed, the row shows the hex code beside a rounded swatch.
    local swatch = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, compact and -38 or -34, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        BorderSizePixel = 0,
        Parent = header,
    })
    corner(swatch, UDim.new(0, 6))
    stroke(swatch, Theme.Stroke)
    local swatchHex = label({
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, compact and -68 or -64, 0.5, 0),
        Size = UDim2.fromOffset(64, 16),
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header,
    })
    local arrow = arrowIndicator(header, 1, compact and -14 or -12)

    local panel = create("Frame", {
        Position = UDim2.fromOffset(14, height + 2),
        Size = UDim2.new(1, -28, 0, PANEL_HEIGHT - 12),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = frame,
    })

    -- Saturation runs left to right, brightness top to bottom.
    local svBox = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 118),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = panel,
    })
    corner(svBox, UDim.new(0, 8))
    stroke(svBox, Theme.Stroke)
    local svHueGradient = create("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 0, 0)),
        Parent = svBox,
    })
    local svDark = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Parent = svBox,
    })
    corner(svDark, UDim.new(0, 8))
    create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Rotation = 90,
        Parent = svDark,
    })

    -- Both handles are a white ring filled with the colour under them, with a
    -- faint dark edge so they read on light and dark spots alike.
    local function knob(parent, size)
        local ring = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = parent,
        })
        corner(ring, UDim.new(1, 0))
        stroke(ring, Color3.new(0, 0, 0), 0.7)
        local fill = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, -4, 1, -4),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = ring,
        })
        corner(fill, UDim.new(1, 0))
        return ring, fill
    end
    local svCursor, svFill = knob(svBox, 14)

    -- Hue is a slim horizontal track under the square.
    local hueBar = create("TextButton", {
        Position = UDim2.fromOffset(0, 132),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = panel,
    })
    corner(hueBar, UDim.new(1, 0))
    create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueBar,
    })
    local hueCursor, hueFill = knob(hueBar, 16)
    hueCursor.Position = UDim2.fromScale(0, 0.5)

    -- Bottom row: a preview chip and hex field on the left, RGB on the right.
    local hexHolder = create("Frame", {
        Position = UDim2.fromOffset(0, 154),
        Size = UDim2.fromOffset(compact and 110 or 124, 28),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = panel,
    })
    corner(hexHolder, UDim.new(0, 7))
    local hexStroke = stroke(hexHolder)
    local preview = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 6, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BorderSizePixel = 0,
        Parent = hexHolder,
    })
    corner(preview, UDim.new(0, 4))
    stroke(preview, Theme.Stroke)
    local hexBox = create("TextBox", {
        Position = UDim2.fromOffset(30, 0),
        Size = UDim2.new(1, -38, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextTruncate = Enum.TextTruncate.None,
        ClipsDescendants = false,
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = hexHolder,
    })
    local rgbLabel = label({
        Position = UDim2.fromOffset(compact and 118 or 134, 154),
        Size = UDim2.new(1, compact and -118 or -134, 0, 28),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = panel,
    })

    local self_ = { Open = false }
    local hue, sat, val = Color3.toHSV(opts.Default or Theme.Accent)
    local dragTarget = nil

    local function toHex(color)
        return string.format("#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5))
    end

    local function render(duration)
        local color = Color3.fromHSV(hue, sat, val)
        self_.Value = color
        swatch.BackgroundColor3 = color
        preview.BackgroundColor3 = color
        svFill.BackgroundColor3 = color
        hueFill.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        swatchHex.Text = toHex(color)
        svHueGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(hue, 1, 1))
        tween(svCursor, { Position = UDim2.fromScale(sat, 1 - val) }, duration, Enum.EasingStyle.Quint)
        tween(hueCursor, { Position = UDim2.fromScale(hue, 0.5) }, duration, Enum.EasingStyle.Quint)
        if not hexBox:IsFocused() then
            hexBox.Text = toHex(color)
        end
        rgbLabel.Text = string.format("%d  %d  %d",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5))
    end

    local function commit(duration, silent)
        render(duration)
        if not silent then
            safeCall(opts.Callback, self_.Value)
        end
    end

    function self_:Set(color, silent)
        hue, sat, val = Color3.toHSV(color)
        commit(0.25, silent)
        flashStroke(frameStroke)
    end

    function self_:Get()
        return self_.Value
    end

    local function setOpen(open)
        self_.Open = open
        tween(frame, { Size = UDim2.new(1, 0, 0, open and (height + PANEL_HEIGHT) or height) }, 0.35, Enum.EasingStyle.Quint)
        arrow:Set(open)
        if open then
            panel.Visible = true
        else
            task.delay(0.35, function()
                if not self_.Open then
                    panel.Visible = false
                end
            end)
        end
    end

    function self_:SetOpen(open)
        setOpen(open == true)
    end

    header.MouseButton1Click:Connect(function()
        setOpen(not self_.Open)
    end)

    local function updateSV(position)
        sat = math.clamp((position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
        val = 1 - math.clamp((position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
        commit(0.04)
    end
    local function updateHue(position)
        hue = math.clamp((position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 0.999)
        commit(0.04)
    end

    svBox.InputBegan:Connect(function(input)
        if isPress(input) then
            dragTarget = "sv"
            tween(svCursor, { Size = UDim2.fromOffset(18, 18) }, 0.2, Enum.EasingStyle.Quint)
            updateSV(pointerPosition())
        end
    end)
    hueBar.InputBegan:Connect(function(input)
        if isPress(input) then
            dragTarget = "hue"
            tween(hueCursor, { Size = UDim2.fromOffset(20, 20) }, 0.2, Enum.EasingStyle.Quint)
            updateHue(pointerPosition())
        end
    end)
    self.Window:_listen("Changed", function(input)
        if not dragTarget or not isMove(input) then
            return
        end
        local position = pointerPosition()
        if dragTarget == "sv" then
            updateSV(position)
        else
            updateHue(position)
        end
    end, self_)
    self.Window:_listen("Ended", function(input)
        if dragTarget and isPress(input) then
            dragTarget = nil
            tween(svCursor, { Size = UDim2.fromOffset(14, 14) }, 0.25, Enum.EasingStyle.Quint)
            tween(hueCursor, { Size = UDim2.fromOffset(16, 16) }, 0.25, Enum.EasingStyle.Quint)
        end
    end, self_)

    hexBox.Focused:Connect(function()
        tween(hexStroke, { Color = Theme.StrokeHover }, 0.15)
    end)
    hexBox.FocusLost:Connect(function()
        tween(hexStroke, { Color = Theme.Stroke }, 0.15)
        local r, g, b = hexBox.Text:match("^%s*#?(%x%x)(%x%x)(%x%x)%s*$")
        if r then
            self_:Set(Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)))
        else
            hexBox.Text = toHex(self_.Value)
        end
    end)

    render(0)
    return finishElement(self, opts, self_, frame, "ColorPicker")
end

function Tab:Stepper(opts)
    local frame, frameStroke, _, titleLabel, descLabel
    opts, frame, frameStroke, _, titleLabel, descLabel = beginElement(self, opts, { Title = "Name", Description = "Desc", CurrentValue = "Default", Value = "Default", Increment = "Step" }, "Frame", 150, "Stepper")
    local min = opts.Min or 0
    local max = opts.Max or 100
    local step = opts.Step or 1
    local suffix = opts.Suffix or ""
    local numbers = numberFormat(min, max, step)
    local compact = metricsOf(self).Compact
    local chipHeight = metricsOf(self).Chip

    local group = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, compact and -14 or -10, 0.5, 0),
        Size = UDim2.fromOffset(0, chipHeight),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(group, UDim.new(0, 6))
    local groupStroke = stroke(group)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = group,
    })

    local function stepButton(text, order)
        local button = create("TextButton", {
            Size = UDim2.fromOffset(chipHeight, chipHeight),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Muted,
            TextSize = 18,
            FontFace = Fonts.Medium,
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = group,
        })
        button.MouseEnter:Connect(function()
            tween(button, { TextColor3 = Theme.Accent }, 0.12)
        end)
        button.MouseLeave:Connect(function()
            tween(button, { TextColor3 = Theme.Muted }, 0.2)
        end)
        return button
    end
    local minus = stepButton("−", 1)
    local valueLabel = label({
        Size = UDim2.new(0, 30, 1, 0),
        TextSize = 13,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = group,
    })
    local plus = stepButton("+", 3)
    local function fitValue(instant)
        local width = math.max(valueLabel.TextBounds.X + 12, 30)
        if instant then
            valueLabel.Size = UDim2.new(0, width, 1, 0)
        else
            tween(valueLabel, { Size = UDim2.new(0, width, 1, 0) }, 0.2)
        end
    end
    valueLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
        fitValue(false)
    end)
    group:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        reserveRight(titleLabel, descLabel, group.AbsoluteSize.X / self.Window.Scale.Scale + (compact and 24 or 20))
    end)

    local self_ = { Value = math.clamp(opts.Default or min, min, max) }
    local snap = numbers.snap
    local fromButton = false
    local function render()
        valueLabel.Text = numbers.format(self_.Value) .. suffix
        tween(minus, { TextTransparency = self_.Value <= min and 0.6 or 0 }, 0.15)
        tween(plus, { TextTransparency = self_.Value >= max and 0.6 or 0 }, 0.15)
    end
    function self_:Set(value, silent)
        value = snap(tonumber(value) or min)
        if value == self_.Value then
            return
        end
        self_.Value = value
        render()
        if not fromButton then
            flashStroke(frameStroke)
        end
        if not silent then
            safeCall(opts.Callback, value)
        end
    end
    function self_:Get()
        return self_.Value
    end

    local function bump(direction)
        fromButton = true
        self_:Set(self_.Value + direction * step)
        fromButton = false
        tween(groupStroke, { Color = Theme.StrokeHover }, 0.08)
        task.delay(0.12, function()
            tween(groupStroke, { Color = Theme.Stroke }, 0.2)
        end)
    end
    local function holdRepeat(button, direction)
        local holding = false
        button.InputBegan:Connect(function(input)
            if not isPress(input) then
                return
            end
            holding = true
            bump(direction)
            task.delay(0.4, function()
                while holding do
                    bump(direction)
                    task.wait(0.07)
                end
            end)
        end)
        button.InputEnded:Connect(function(input)
            if isPress(input) then
                holding = false
            end
        end)
        button.MouseLeave:Connect(function()
            holding = false
        end)
    end
    holdRepeat(minus, -1)
    holdRepeat(plus, 1)

    render()
    task.defer(fitValue, true)
    return finishElement(self, opts, self_, frame, "Stepper")
end

function Tab:Progress(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc", CurrentValue = "Default", Value = "Default" })
    local metrics = metricsOf(self)
    local compact = metrics.Compact
    local extra = compact and 6 or 10
    local frame, frameStroke = card(self, "Frame", (opts.Desc and metrics.DescHeight or metrics.Height) + extra, opts)
    hoverStroke(frame, frameStroke)
    local top
    if opts.Desc then
        top = math.floor((metrics.DescHeight - (metrics.DescGap + metrics.DescLine)) / 2) - 2
    else
        top = compact and 5 or 12
    end

    label({
        Position = UDim2.fromOffset(14, top),
        Size = UDim2.new(1, -110, 0, 18),
        Text = opts.Name or "Progress",
        TextSize = metrics.TextSize,
        Parent = frame,
    })
    if opts.Desc then
        label({
            Position = UDim2.fromOffset(14, top + metrics.DescGap),
            Size = UDim2.new(1, -110, 0, metrics.DescLine),
            Text = opts.Desc,
            TextSize = metrics.DescSize,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = frame,
        })
    end
    local valueLabel = label({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, top),
        Size = UDim2.fromOffset(90, 18),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 13,
        TextColor3 = Library._color(opts.TextColor) or Theme.Accent,
        RichText = true,
        Parent = frame,
    })
    local track = create("Frame", {
        Position = UDim2.new(0, 14, 1, compact and -12 or -16),
        Size = UDim2.new(1, -28, 0, 5),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(track, UDim.new(1, 0))
    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library._color(opts.Color) or Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, UDim.new(1, 0))

    local self_ = { Value = math.clamp(opts.Default or 0, 0, 1) }
    local formatter = opts.Format
    local function render(duration)
        local frac = self_.Value
        tween(fill, { Size = UDim2.new(frac, 0, 1, 0) }, duration, Enum.EasingStyle.Quint)
        if type(formatter) == "function" then
            valueLabel.Text = Library._rich(formatter(frac))
        else
            valueLabel.Text = string.format("%d%%", math.floor(frac * 100 + 0.5))
        end
    end
    function self_:Set(value, silent)
        value = math.clamp(tonumber(value) or 0, 0, 1)
        if value == self_.Value then
            return
        end
        self_.Value = value
        render(0.35)
        if not silent then
            safeCall(opts.Callback, value)
        end
    end
    function self_:Get()
        return self_.Value
    end
    function self_:SetColor(color)
        tween(fill, { BackgroundColor3 = Library._color(color) or Theme.Accent }, 0.25)
    end
    -- The percentage's colour; nil goes back to the accent.
    function self_:SetTextColor(color)
        tween(valueLabel, { TextColor3 = Library._color(color) or Theme.Accent }, 0.25)
    end
    -- Runs render now, and again on a theme change for theme tags in Format.
    onTheme(valueLabel, function()
        render(0)
    end)
    return finishElement(self, opts, self_, frame, "Progress")
end

-- An always-open list the player puts in order: drag a row (by its grip on
-- touch, anywhere on PC) or nudge it with the arrows. Past MaxRows the list
-- scrolls, and dragging near its top or bottom edge scrolls it along.
function Tab:OrderList(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc", Options = "Items", Values = "Items" })
    local metrics = metricsOf(self)
    local compact = metrics.Compact
    local window = self.Window
    local ROW = TOUCH and 40 or 32
    local GAP = 4
    local STEP = ROW + GAP
    local GRIP = TOUCH and 34 or 26
    local ARROW = TOUCH and 30 or 22
    local maxRows = math.max(math.floor(tonumber(opts.MaxRows) or 6), 1)
    local numbered = opts.Numbered ~= false
    local arrows = opts.Arrows ~= false

    local frame = card(self, "Frame", 0, opts)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    if compact then
        padding(frame, 14, 14, 6, 8)
    else
        padding(frame, 14, 14, 11, 12)
    end
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = frame,
    })
    local name = tostring(opts.Name or "")
    label({
        Size = UDim2.new(1, 0, 0, 18),
        Text = name,
        TextSize = metrics.TextSize,
        Visible = name ~= "",
        LayoutOrder = 1,
        Parent = frame,
    })
    if opts.Desc then
        label({
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = opts.Desc,
            TextSize = metrics.DescSize,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 2,
            Parent = frame,
        })
    end
    local scroller = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, ROW + 2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = TOUCH and 4 or 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        -- Sized by hand, like the dropdown list, so it scrolls under UIScale.
        CanvasSize = UDim2.new(),
        ScrollingEnabled = false,
        LayoutOrder = 3,
        Parent = frame,
    })
    scroller:SetAttribute("NoDrag", true)
    local content = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = scroller,
    })
    local empty = label({
        Size = UDim2.new(1, 0, 0, ROW),
        Text = tostring(opts.EmptyText or "Nothing to order"),
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false,
        Parent = content,
    })

    -- A lucide icon, or a text glyph when the icon set didn't load.
    local function iconButton(parent, icon, glyph, rotation, props)
        props.BackgroundTransparency = 1
        props.Text = ""
        props.AutoButtonColor = false
        props.Parent = parent
        local button = create("TextButton", props)
        local image = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = TOUCH and UDim2.fromOffset(16, 16) or UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Muted,
            ScaleType = Enum.ScaleType.Fit,
            Parent = button,
        })
        applyIcon(image, icon)
        if image.Image ~= "" then
            return button, { Object = image, Color = "ImageColor3", Fade = "ImageTransparency" }
        end
        image:Destroy()
        local text_ = label({
            Size = UDim2.fromScale(1, 1),
            Text = glyph,
            TextSize = 18,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.None,
            Rotation = rotation,
            Parent = button,
        })
        return button, { Object = text_, Color = "TextColor3", Fade = "TextTransparency" }
    end
    local function tint(icon, color, transparency, duration)
        tween(icon.Object, { [icon.Color] = color, [icon.Fade] = transparency }, duration)
    end

    local self_ = {}
    local entries = {}
    -- The last order Set asked for, including items not in the list right now,
    -- so a saved order still applies once Refresh brings those items in.
    local remembered = {}
    local dragging = nil
    local nudge, beginDrag

    local function slotY(slot)
        return 1 + (slot - 1) * STEP
    end

    local function values()
        local list = {}
        for index, entry in ipairs(entries) do
            list[index] = entry.Value
        end
        return list
    end

    local function layout(instant)
        local count = #entries
        for slot, entry in ipairs(entries) do
            entry.Index.Text = tostring(slot)
            if entry ~= dragging then
                tween(entry.Frame, { Position = UDim2.fromOffset(3, slotY(slot)) }, instant and 0 or 0.22, Enum.EasingStyle.Quint)
            end
            if entry.UpIcon then
                tween(entry.UpIcon.Object, { [entry.UpIcon.Fade] = slot == 1 and 0.7 or 0 }, instant and 0 or 0.15)
                tween(entry.DownIcon.Object, { [entry.DownIcon.Fade] = slot == count and 0.7 or 0 }, instant and 0 or 0.15)
            end
        end
    end

    local function fit()
        local count = #entries
        local canvas = math.max(count, 1) * STEP - GAP + 2
        local shown = math.clamp(count, 1, maxRows)
        local height = shown * STEP - GAP + 2
        local scrolling = count > maxRows
        scroller.Size = UDim2.new(1, 0, 0, height)
        scroller.CanvasSize = UDim2.fromOffset(0, canvas)
        content.Size = UDim2.new(1, scrolling and -8 or 0, 0, canvas)
        if not dragging then
            scroller.ScrollingEnabled = scrolling
        end
        empty.Visible = count == 0
        local maxScroll = math.max(canvas - height, 0)
        if scroller.CanvasPosition.Y > maxScroll then
            scroller.CanvasPosition = Vector2.new(0, maxScroll)
        end
    end

    local function changed(silent)
        self_.Value = values()
        if not silent then
            safeCall(opts.Callback, values())
        end
    end

    local function listScroller()
        if scroller.ScrollingEnabled then
            return scroller
        end
        return frame:FindFirstAncestorWhichIsA("ScrollingFrame")
    end

    local function newEntry(value)
        local row = create("Frame", {
            Size = UDim2.new(1, -6, 0, ROW),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Parent = content,
        })
        corner(row, UDim.new(0, 7))
        local entry = { Value = value, Frame = row }
        entry.Stroke = stroke(row)
        entry.Scale = create("UIScale", { Parent = row })
        local grip
        grip, entry.GripIcon = iconButton(row, "grip-vertical", "=", 0, {
            Size = UDim2.new(0, GRIP, 1, 0),
        })
        local x = GRIP
        entry.Index = label({
            Position = UDim2.fromOffset(x, 0),
            Size = UDim2.new(0, 22, 1, 0),
            TextSize = 12,
            TextColor3 = Theme.Accent,
            TextTruncate = Enum.TextTruncate.None,
            Visible = numbered,
            Parent = row,
        })
        if numbered then
            x += 22
        end
        local right = arrows and ARROW * 2 + 8 or 10
        entry.Text = label({
            Position = UDim2.fromOffset(x, 0),
            Size = UDim2.new(1, -(x + right), 1, 0),
            Text = tostring(value),
            TextSize = 13,
            Parent = row,
        })
        local buttons = {}
        if arrows then
            local up, down
            up, entry.UpIcon = iconButton(row, "chevron-up", "›", -90, {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -(ARROW + 6), 0, 0),
                Size = UDim2.new(0, ARROW, 1, 0),
            })
            down, entry.DownIcon = iconButton(row, "chevron-down", "›", 90, {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -4, 0, 0),
                Size = UDim2.new(0, ARROW, 1, 0),
            })
            for button, direction in pairs({ [up] = -1, [down] = 1 }) do
                local icon = direction < 0 and entry.UpIcon or entry.DownIcon
                local isTap = tapGuard(button, listScroller)
                button.MouseEnter:Connect(function()
                    if not usingTouch() then
                        tween(icon.Object, { [icon.Color] = Theme.Accent }, 0.12)
                    end
                end)
                button.MouseLeave:Connect(function()
                    tween(icon.Object, { [icon.Color] = Theme.Muted }, 0.2)
                end)
                button.MouseButton1Click:Connect(function()
                    if isTap() then
                        nudge(entry, direction)
                    end
                end)
                table.insert(buttons, button)
            end
        end
        grip.InputBegan:Connect(function(input)
            if isPress(input) then
                beginDrag(entry)
            end
        end)
        -- On PC the whole row drags; on touch only the grip does, so a swipe
        -- across the rows still scrolls.
        row.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end
            local point = pointerPosition()
            for _, button in ipairs(buttons) do
                if pointInside(point, button) then
                    return
                end
            end
            beginDrag(entry)
        end)
        row.MouseEnter:Connect(function()
            if not usingTouch() and entry ~= dragging then
                tween(entry.Stroke, { Color = Theme.StrokeHover }, 0.12)
                tint(entry.GripIcon, Theme.Text, 0, 0.12)
            end
        end)
        row.MouseLeave:Connect(function()
            if entry ~= dragging then
                tween(entry.Stroke, { Color = Theme.Stroke }, 0.25)
                tint(entry.GripIcon, Theme.Muted, 0, 0.25)
            end
        end)
        return entry
    end

    -- Reuses the rows whose item is still in the list, so a reorder slides
    -- rows instead of rebuilding them.
    local function build(list)
        local pool = {}
        for _, entry in ipairs(entries) do
            pool[entry.Value] = pool[entry.Value] or {}
            table.insert(pool[entry.Value], entry)
        end
        local nextEntries = {}
        for index, value in ipairs(list) do
            local bucket = pool[value]
            local entry = bucket and table.remove(bucket, 1)
            if not entry then
                entry = newEntry(value)
                entry.Frame.Position = UDim2.fromOffset(3, slotY(index))
            end
            nextEntries[index] = entry
        end
        for _, bucket in pairs(pool) do
            for _, entry in ipairs(bucket) do
                entry.Frame:Destroy()
            end
        end
        entries = nextEntries
    end

    -- items sorted by where they sit in ranking; the rest keep their order after.
    local function arrange(items, ranking)
        local left = {}
        for _, value in ipairs(items) do
            left[value] = (left[value] or 0) + 1
        end
        local result = {}
        for _, pass in ipairs({ ranking, items }) do
            for _, value in ipairs(pass) do
                if (left[value] or 0) > 0 then
                    left[value] -= 1
                    table.insert(result, value)
                end
            end
        end
        return result
    end

    local function scrollIntoView(slot)
        local top = slotY(slot) - 1
        local view = scroller.AbsoluteWindowSize.Y / window.Scale.Scale
        local y = scroller.CanvasPosition.Y
        if top < y then
            y = top
        elseif top + ROW + 2 > y + view then
            y = top + ROW + 2 - view
        end
        if y ~= scroller.CanvasPosition.Y then
            tween(scroller, { CanvasPosition = Vector2.new(0, math.max(y, 0)) }, 0.2)
        end
    end

    function nudge(entry, direction)
        if dragging then
            return
        end
        local from = table.find(entries, entry)
        local to = from and from + direction
        if not to or to < 1 or to > #entries then
            return
        end
        entries[from], entries[to] = entries[to], entries[from]
        layout(false)
        tween(entry.Stroke, { Color = Theme.Accent }, 0.08)
        task.delay(0.18, function()
            if entry ~= dragging then
                tween(entry.Stroke, { Color = Theme.Stroke }, 0.3)
            end
        end)
        scrollIntoView(to)
        changed(false)
    end

    local grabOffset, lastPointer = 0, nil
    local startEntries, stopRender, lockedPage = nil, nil, nil

    -- Moves the held row under the pointer and slides the others out of its way.
    local function follow(pointer)
        local scale = window.Scale.Scale
        local y = (pointer.Y - grabOffset - scroller.AbsolutePosition.Y) / scale + scroller.CanvasPosition.Y
        y = math.clamp(y, slotY(1), slotY(#entries))
        dragging.Frame.Position = UDim2.fromOffset(3, y)
        local slot = math.clamp(math.floor((y - 1) / STEP + 0.5) + 1, 1, #entries)
        local current = table.find(entries, dragging)
        if current ~= slot then
            table.remove(entries, current)
            table.insert(entries, slot, dragging)
            layout(false)
        end
    end

    -- Holding the row near the list's top or bottom edge scrolls it, faster
    -- the closer the pointer gets.
    local function autoScroll(deltaTime)
        if not dragging or not lastPointer then
            return
        end
        local scale = window.Scale.Scale
        local top = scroller.AbsolutePosition.Y
        local bottom = top + scroller.AbsoluteSize.Y
        local zone = ROW * scale
        local speed = 0
        if lastPointer.Y < top + zone then
            speed = -(top + zone - lastPointer.Y) / zone
        elseif lastPointer.Y > bottom - zone then
            speed = (lastPointer.Y - (bottom - zone)) / zone
        end
        if speed == 0 then
            return
        end
        local maxScroll = math.max(scroller.CanvasSize.Y.Offset - scroller.AbsoluteWindowSize.Y / scale, 0)
        local y = math.clamp(scroller.CanvasPosition.Y + math.clamp(speed, -1.5, 1.5) * 360 * deltaTime, 0, maxScroll)
        if y ~= scroller.CanvasPosition.Y then
            scroller.CanvasPosition = Vector2.new(0, y)
            follow(lastPointer)
        end
    end

    function beginDrag(entry)
        if dragging or #entries < 2 or self_._destroyed then
            return
        end
        dragging = entry
        startEntries = table.clone(entries)
        lastPointer = pointerPosition()
        grabOffset = lastPointer.Y - entry.Frame.AbsolutePosition.Y
        entry.Frame.ZIndex = 5
        tween(entry.Frame, { BackgroundColor3 = Theme.Surface3 }, 0.12)
        tween(entry.Stroke, { Color = Theme.Accent }, 0.12)
        tween(entry.Scale, { Scale = 1.02 }, 0.18, Enum.EasingStyle.Back)
        tint(entry.GripIcon, Theme.Accent, 0, 0.12)
        -- Neither the list nor the page scrolls under the finger while dragging.
        scroller.ScrollingEnabled = false
        local page = frame:FindFirstAncestorWhichIsA("ScrollingFrame")
        if page and page.ScrollingEnabled then
            lockedPage = page
            page.ScrollingEnabled = false
        end
        stopRender = window:_listen("Render", autoScroll)
    end

    local function endDrag(silent)
        local entry = dragging
        if not entry then
            return
        end
        dragging = nil
        lastPointer = nil
        if stopRender then
            stopRender()
            stopRender = nil
        end
        if lockedPage then
            lockedPage.ScrollingEnabled = true
            lockedPage = nil
        end
        tween(entry.Frame, { BackgroundColor3 = Theme.Surface }, 0.2)
        tween(entry.Stroke, { Color = Theme.Stroke }, 0.25)
        tween(entry.Scale, { Scale = 1 }, 0.2)
        tint(entry.GripIcon, Theme.Muted, 0, 0.25)
        task.delay(0.22, function()
            if entry ~= dragging then
                entry.Frame.ZIndex = 1
            end
        end)
        layout(false)
        fit()
        for index, other in ipairs(entries) do
            if startEntries[index] ~= other then
                changed(silent)
                break
            end
        end
    end

    window:_listen("Changed", function(input)
        if dragging and isMove(input) then
            lastPointer = pointerPosition()
            follow(lastPointer)
        end
    end, self_)
    window:_listen("Ended", function(input)
        if dragging and isPress(input) then
            endDrag(false)
        end
    end, self_)
    table.insert(self_._listeners, function()
        endDrag(true)
    end)
    self_._onHide = function()
        endDrag(false)
    end

    -- Reorders the items already in the list. Unknown items are remembered for
    -- a later Refresh; items missing from the list keep their order after.
    function self_:Set(list, silent)
        if type(list) ~= "table" then
            return
        end
        endDrag(true)
        remembered = table.clone(list)
        build(arrange(values(), remembered))
        layout(false)
        fit()
        changed(silent)
    end

    function self_:Get()
        return values()
    end

    -- Replaces the items. Items that were already there keep the player's
    -- order unless keepOrder is false; new ones go to the end.
    function self_:Refresh(items, keepOrder, silent)
        endDrag(true)
        items = type(items) == "table" and table.clone(items) or {}
        if keepOrder ~= false then
            items = arrange(items, self_:_saveValue())
        else
            remembered = {}
        end
        build(items)
        layout(false)
        fit()
        changed(silent)
    end

    -- The shown order, then remembered items that aren't in the list right now.
    function self_:_saveValue()
        local list = values()
        local left = {}
        for _, value in ipairs(list) do
            left[value] = (left[value] or 0) + 1
        end
        for _, value in ipairs(remembered) do
            if (left[value] or 0) > 0 then
                left[value] -= 1
            else
                table.insert(list, value)
            end
        end
        return list
    end

    build(type(opts.Items) == "table" and opts.Items or {})
    layout(true)
    fit()
    self_.Value = values()
    return finishElement(self, opts, self_, frame, "OrderList")
end


for name, method in pairs(table.clone(Tab)) do
    if type(method) == "function" and name:sub(1, 1) ~= "_" and name:sub(1, 6) ~= "Create" then
        Tab["Create" .. name] = method
    end
end

local function detectExecutor()
    local name
    pcall(function()
        if typeof(identifyexecutor) == "function" then
            name = (identifyexecutor())
        elseif typeof(getexecutorname) == "function" then
            name = getexecutorname()
        end
    end)
    if type(name) == "string" and #name > 0 then
        return name
    end
    return RunService:IsStudio() and "Studio" or "Unknown"
end

local function executorReport(opts)
    local executor = detectExecutor()
    local supported = opts.SupportedExecutors
    if type(supported) == "table" then
        local lowered = string.lower(executor)
        for _, name in ipairs(supported) do
            if string.find(lowered, string.lower(tostring(name)), 1, true) then
                return executor, true, "Your executor is supported and fully compatible."
            end
        end
        return executor, false, "Not on the supported list. Some features may not work."
    end
    local capabilities = {
        { "writefile", writefile },
        { "readfile", readfile },
        { "getcustomasset", getcustomasset },
        { "setclipboard", setclipboard or toclipboard },
        { "request", request or http_request or (syn and syn.request) },
    }
    local missing = {}
    for _, entry in ipairs(capabilities) do
        if type(entry[2]) ~= "function" then
            table.insert(missing, entry[1])
        end
    end
    if #missing == 0 then
        return executor, true, "Your executor is supported and fully compatible."
    end
    return executor, false, "Missing " .. table.concat(missing, ", ") .. ". Some features may not work."
end

-- "Don't ask again" on the unsupported executor warning: the executor's
-- name goes in a file in the script folder, and the warning is skipped while
-- the same executor is in use. Resetting the folder brings it back.
-- A table, not separate locals: the main chunk is at Luau's 200 local limit.
local UnsupportedSkip = {}

function UnsupportedSkip.Path(folder)
    return tostring(folder) .. "/unsupported_skip.txt"
end

function UnsupportedSkip.Available()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

function UnsupportedSkip.Saved(folder, executor)
    if not UnsupportedSkip.Available() then
        return false
    end
    local path = UnsupportedSkip.Path(folder)
    local ok, saved = pcall(function()
        return isfile(path) and readfile(path) or nil
    end)
    return ok and saved == executor
end

function UnsupportedSkip.Write(folder, path, content)
    if not UnsupportedSkip.Available() then
        return false
    end
    return pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            local built = ""
            for segment in tostring(folder):gmatch("[^/\\]+") do
                built = built == "" and segment or built .. "/" .. segment
                if not isfolder(built) then
                    makefolder(built)
                end
            end
        end
        writefile(path, content)
    end)
end

function UnsupportedSkip.Save(folder, executor)
    return UnsupportedSkip.Write(folder, UnsupportedSkip.Path(folder), executor)
end

-- Custom disclaimers ticked "Don't show again": one key per line in
-- disclaimers.txt. The key is the disclaimer's Id, or a hash of its title
-- and text, so rewording a disclaimer shows it again.
function UnsupportedSkip.DisclaimerKey(entry)
    if entry.Id ~= nil then
        return (tostring(entry.Id):gsub("[\r\n]", " "))
    end
    local source = tostring(entry.Title) .. "\0" .. tostring(entry.Text)
    local hash = 5381
    for index = 1, #source do
        hash = (hash * 33 + source:byte(index)) % 4294967296
    end
    return string.format("%08x", hash)
end

function UnsupportedSkip.DisclaimerAccepted(folder, key)
    if not UnsupportedSkip.Available() then
        return false
    end
    local path = tostring(folder) .. "/disclaimers.txt"
    local ok, saved = pcall(function()
        return isfile(path) and readfile(path) or ""
    end)
    if not ok or type(saved) ~= "string" then
        return false
    end
    for line in saved:gmatch("[^\r\n]+") do
        if line == key then
            return true
        end
    end
    return false
end

function UnsupportedSkip.AcceptDisclaimer(folder, key)
    if UnsupportedSkip.DisclaimerAccepted(folder, key) then
        return true
    end
    local path = tostring(folder) .. "/disclaimers.txt"
    local ok, saved = pcall(function()
        return isfile(path) and readfile(path) or ""
    end)
    saved = ok and type(saved) == "string" and saved or ""
    if saved ~= "" and not saved:match("\n$") then
        saved ..= "\n"
    end
    return UnsupportedSkip.Write(folder, path, saved .. key .. "\n")
end

local gameInfoCache = nil

local function fetchGameInfo()
    if gameInfoCache == nil then
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        gameInfoCache = ok and type(info) == "table" and info or false
    end
    return gameInfoCache or nil
end

local function detectGameName()
    local info = fetchGameInfo()
    if info and info.Name then
        return info.Name
    end
    return RunService:IsStudio() and "Studio" or "Unknown game"
end

local REGION_NAMES = {
    US = "United States", GB = "United Kingdom", DE = "Germany", FR = "France",
    NL = "Netherlands", SG = "Singapore", JP = "Japan", AU = "Australia",
    BR = "Brazil", IN = "India", HK = "Hong Kong", CA = "Canada",
}

local function detectRegion(callback)
    task.spawn(function()
        local requester = request or http_request or (syn and syn.request) or (http and http.request)
        local region
        if type(requester) == "function" then
            pcall(function()
                local response = requester({ Url = "https://ipinfo.io/json", Method = "GET" })
                local body = type(response) == "table" and (response.Body or response.body) or nil
                if type(body) == "string" then
                    local data = HttpService:JSONDecode(body)
                    if type(data) == "table" and data.country then
                        local label = REGION_NAMES[data.country] or data.country
                        region = data.city and (data.city .. ", " .. label) or label
                    end
                end
            end)
        end
        callback(region or "Unavailable")
    end)
end

local NOTIFY_COLORS = setmetatable({}, {
    __index = function(_, kind)
        if kind == "Success" or kind == "Warning" or kind == "Error" then
            return Theme[kind]
        end
        return nil
    end,
})

local Window = {}
Window.__index = Window

function Library.Window(_, opts)
    opts = normalize(opts, { Name = "Title", LoadingSubtitle = "Subtitle", ToggleUIKeybind = "Keybind" })

    if type(opts.Keybind) == "string" then
        opts.Keybind = Enum.KeyCode[opts.Keybind]
    end
    local size = opts.Size or UDim2.fromOffset(760, 520)
    local keybind = opts.Keybind or Enum.KeyCode.RightControl

    local self = setmetatable({
        Tabs = {},
        CurrentTab = nil,
        Open = true,
        Keybind = keybind,
        _connections = {},
        _controls = {},
        _inputListeners = { Began = {}, Changed = {}, Ended = {}, Render = {} },
        _frameSteps = {},
        _destroyed = false,
        _identity = { Names = {}, Avatars = {} },
        _pinned = {},
        Minimized = false,
        _hideName = false,
        _hideAvatar = false,
        Title = opts.Title or opts.Name or "Noir",
        _logoIcon = opts.Icon or Assets.Logo,
        _sessionStart = os.clock(),
        _islandLocked = opts.IslandDraggable == false,
    }, Window)
    local saving = type(opts.ConfigurationSaving) == "table" and opts.ConfigurationSaving or {}
    self.ConfigFolder = saving.FolderName or "NoirUI"
    self.ConfigName = saving.FileName
    self._configListeners = {}
    self._pendingFlags = {}

    local startTheme = opts.DefaultTheme or opts.Theme
    if startTheme ~= nil then
        Library.DefaultTheme = startTheme
    end
    self:_applyDefaultTheme()
    self._uiScale = math.clamp(tonumber(opts.UIScale) or 1, 0.6, 1.5)
    self._adaptive = opts.AdaptiveSize ~= false
    self.UIScale = self._uiScale
    if opts.Density ~= nil then
        Library:SetDensity(opts.Density)
    end
    if opts.CornerRadius ~= nil then
        Library:SetCornerRadius(opts.CornerRadius, true)
    end
    local function dispatch(kind)
        return function(...)
            for _, handler in ipairs(self._inputListeners[kind]) do
                handler(...)
            end
        end
    end
    local renderDispatch = dispatch("Render")
    table.insert(self._connections, RunService.RenderStepped:Connect(function(deltaTime)
        renderDispatch(deltaTime)
        for _, step in ipairs(self._frameSteps) do
            step(deltaTime)
        end
    end))
    table.insert(self._connections, UserInputService.InputBegan:Connect(dispatch("Began")))
    table.insert(self._connections, UserInputService.InputChanged:Connect(dispatch("Changed")))
    table.insert(self._connections, UserInputService.InputEnded:Connect(dispatch("Ended")))

    local gui = create("ScreenGui", {
        Name = opts.Name or "NoirUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    self.Gui = gui

    local root = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundTransparency = 1,
        Parent = gui,
    })
    self.Root = root
    local scale = create("UIScale", { Parent = root })
    self.Scale = scale

    local shadow = create("ImageLabel", {
        Position = UDim2.fromOffset(-25, -25),
        Size = UDim2.new(1, 50, 1, 50),
        BackgroundTransparency = 1,
        Image = Assets.Shadow,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = root,
    })
    self.Shadow = shadow
    self._shadowRest = 0.6

    -- The body is a plain Frame so resizing never re-renders the window into a
    -- texture. It only moves into the fader CanvasGroup while fading.
    local fader = create("CanvasGroup", {
        Name = "Fader",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        ZIndex = 2,
        Parent = root,
    })
    self._fader = fader
    self._bodyAlpha = 1
    local body = create("Frame", {
        Name = "Body",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = fader,
    })
    self.Body = body
    corner(body, UDim.new(0, 10))
    self.BodyStroke = stroke(body, Theme.Stroke)
    edgeHighlight(body)
    -- Background image: made first so everything else in the body draws over it.
    self._backgroundImage = create("ImageLabel", {
        Name = "BackgroundImage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 1,
        Visible = false,
        ZIndex = 0,
        Parent = body,
    })
    corner(self._backgroundImage, UDim.new(0, 10))
    self.BackgroundTransparency = math.clamp(tonumber(opts.BackgroundTransparency) or 0.35, 0, 1)
    self._backgroundGeneration = 0

    -- The sidebar is a flush, solid rail down the left edge, split from the
    -- content by a single hairline.
    local sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = body,
    })
    self.Sidebar = sidebar
    -- One rounded fill that runs past the rail's right edge, where the rail
    -- clips it: the left corners round with the window, the right edge is
    -- square, and nothing overlaps, so it fades evenly when see-through.
    local sidebarFill = create("Frame", {
        Name = "Fill",
        Size = UDim2.new(1, 24, 1, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = sidebar,
    })
    corner(sidebarFill, UDim.new(0, 10))
    self.SidebarFill = sidebarFill
    create("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = sidebar,
    })

    local header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    local logo = create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(32, 32),
        BackgroundTransparency = 1,
        Image = "",
        ImageColor3 = Color3.new(1, 1, 1),
        ScaleType = Enum.ScaleType.Fit,
        Parent = header,
    })
    applyIcon(logo, opts.Icon or Assets.Logo, true)
    local subtitle = opts.Version or opts.Subtitle
    label({
        Position = UDim2.new(0, 56, 0.5, subtitle and -15 or -9),
        Size = UDim2.new(1, -68, 0, 18),
        Text = self.Title,
        TextSize = 14,
        FontFace = Fonts.Bold,
        Parent = header,
    })
    if subtitle then
        label({
            Position = UDim2.new(0, 56, 0.5, 3),
            Size = UDim2.new(1, -68, 0, 14),
            Text = tostring(subtitle),
            TextSize = 11,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = header,
        })
    end

    local profileEnabled = opts.Profile ~= false
    local tabList = create("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(0, HEADER_HEIGHT),
        Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + (profileEnabled and PROFILE_HEIGHT + 4 or 12))),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Parent = sidebar,
    })
    self.TabList = tabList
    -- The highlight sits beside the stack of buttons, so it scrolls and clips
    -- with them and glides between tiles.
    local indicator = create("Frame", {
        Position = UDim2.fromOffset(8, 2),
        Size = UDim2.new(1, -16, 0, TAB_TILE_HEIGHT),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Visible = false,
        Parent = tabList,
    })
    corner(indicator, UDim.new(0, 7))
    -- The active tab is just a quiet neutral fill with white text; the bar
    -- is kept for callers but stays hidden.
    local pill = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(2, 14),
        BackgroundColor3 = Theme.Accent,
        Visible = false,
        BorderSizePixel = 0,
        Parent = indicator,
    })
    corner(pill, UDim.new(1, 0))
    self._indicatorPill = pill
    self.Indicator = indicator
    local stack = create("Frame", {
        Name = "Stack",
        Position = UDim2.fromOffset(8, 2),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = tabList,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = stack,
    })
    self._tabStack = stack

    -- More tabs than fit: a fade and a small "more" chip at the hidden end.
    self:_overflowHint(sidebar, tabList, stack, true, Theme.Surface)

    if profileEnabled then
        self:_buildProfile(sidebar)
    end

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(SIDEBAR_WIDTH + 1, 0),
        Size = UDim2.new(1, -(SIDEBAR_WIDTH + 1), 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = body,
    })
    self.Content = content
    self:_sidebarResize(sidebar, tonumber(opts.SidebarWidth) or SIDEBAR_WIDTH)
    self._outLayer = create("CanvasGroup", {
        Name = "TransitionOut",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 2,
        Parent = content,
    })
    self._inLayer = create("CanvasGroup", {
        Name = "TransitionIn",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 3,
        Parent = content,
    })

    local minimizeButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = content,
    })
    minimizeButton:SetAttribute("NoDrag", true)
    -- A bare "minimize" arrows glyph, no box: muted at rest, full text
    -- colour and a touch smaller on hover, as if pulling in.
    local minimizeGlyph = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Parent = minimizeButton,
    })
    applyIcon(minimizeGlyph, "minimize-2")
    minimizeButton.MouseEnter:Connect(function()
        tween(minimizeGlyph, { ImageColor3 = Theme.Text, Size = UDim2.fromOffset(18, 18) }, 0.2, Enum.EasingStyle.Quint)
    end)
    minimizeButton.MouseLeave:Connect(function()
        tween(minimizeGlyph, { ImageColor3 = Theme.Muted, Size = UDim2.fromOffset(20, 20) }, 0.25, Enum.EasingStyle.Quint)
    end)
    minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    self.MinimizeButton = minimizeButton

    if opts.Search ~= false then
        self:_buildSearch(content)
    end

    local notifyHolder = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 280, 1, -40),
        BackgroundTransparency = 1,
        Parent = gui,
    })
    local function fitToasts()
        notifyHolder.Size = UDim2.new(0, math.min(280, gui.AbsoluteSize.X - 40), 1, -40)
    end
    table.insert(self._connections, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToasts))
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 4),
        Parent = notifyHolder,
    })
    self.NotifyHolder = notifyHolder
    self._notifyOrder = 0
    self._toasts = {}
    self.MaxNotifications = opts.MaxNotifications or 4

    self._controlsDirty = true
    table.insert(self._connections, body.DescendantAdded:Connect(function()
        self._controlsDirty = true
    end))
    table.insert(self._connections, body.DescendantRemoving:Connect(function()
        self._controlsDirty = true
    end))

    self:SetDragStyle(opts.DragStyle or (opts.DragSkeleton == false and "Off" or "Outline"))
    self:SetIslandStyle(opts.IslandStyle)
    if opts.Transparent then
        self:SetTransparent(true)
    end
    if opts.Background then
        task.spawn(self.SetBackground, self, opts.Background)
    end
    self:_enableDrag()
    self.MaxSize = opts.MaxSize
    self.KeepOnScreen = opts.KeepOnScreen ~= false
    self:_enableResize(opts.MinSize or Vector2.new(480, 360))
    -- The window's exact size rides along in configs as a hidden flag.
    if opts.SaveSize ~= false then
        local window = self
        local sizeFlag = { _type = "WindowSize", _listeners = {} }
        function sizeFlag:Get()
            local current = window:GetSize()
            return { Width = current.X, Height = current.Y }
        end
        function sizeFlag:Set(value)
            if type(value) == "table" and tonumber(value.Width) and tonumber(value.Height) then
                window:SetSize(Vector2.new(tonumber(value.Width), tonumber(value.Height)))
            end
        end
        local flag = type(opts.SaveSize) == "string" and opts.SaveSize or "__WindowSize"
        Library.Flags[flag] = sizeFlag
        self:_flagCreated(flag, sizeFlag)
    end

    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.Keybind then
            task.defer(function()
                local consumed = self._consumedKey == input.KeyCode and os.clock() - (self._consumedAt or 0) < 0.2
                self._consumedKey = nil
                if not consumed and not self._destroyed then
                    if self.Minimized then
                        self:Restore()
                    else
                        self:Toggle(not self.Open)
                    end
                end
            end)
        end
    end))

    pcall(function()
        if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
            syn.protect_gui(gui)
        end
    end)
    gui.Parent = opts.Parent or defaultParent()

    scale.Scale = 0.9
    shadow.ImageTransparency = 1
    self.BodyStroke.Transparency = 1
    root.Visible = false
    self:_fitToScreen(true)
    table.insert(self._connections, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:_fitToScreen()
        self:_clampToScreen()
    end))
    local toggleOpts = opts.ToggleButton
    if toggleOpts == nil or toggleOpts == true then
        toggleOpts = {}
    end
    if type(toggleOpts) == "table" then
        self:_createToggleButton(toggleOpts)
    end
    -- The toggle button already brings a hidden window back.
    local toggleShown = self.ToggleButton ~= nil and self:_toggleButtonAllowed()
    if (opts.OpenButton ~= nil and opts.OpenButton ~= false) or (opts.OpenButton == nil and TOUCH and not toggleShown) then
        self:_createOpenButton(type(opts.OpenButton) == "table" and opts.OpenButton or {})
    end
    if opts.Backdrop ~= false then
        self:_buildBackdrop(type(opts.Backdrop) == "table" and opts.Backdrop or {})
    end
    self._introDone = false

    table.insert(Library.Windows, self)

    if opts.Home ~= false then
        self:_buildHome(type(opts.Home) == "table" and opts.Home or {})
    end

    local loading = opts.Loading
    if type(loading) == "table" then
        opts.LoadingDuration = loading.Duration or opts.LoadingDuration
        opts.LoadingText = loading.Text or loading.Subtitle or opts.LoadingText
        opts.LoadingSteps = loading.Steps or opts.LoadingSteps
        opts.LoadingTitle = loading.Title or opts.LoadingTitle
        loading = loading.Enabled ~= false
    end
    -- An executor off the supported list (or missing the file / asset API)
    -- stops at a warning card before the window opens.
    local prompts = {}
    local gate = opts.UnsupportedExecutor
    if gate ~= false then
        gate = type(gate) == "table" and gate or {}
        local list = opts.SupportedExecutors or (type(opts.Home) == "table" and opts.Home.SupportedExecutors or nil)
        local executor, supported, message = executorReport({ SupportedExecutors = list })
        if not supported and not UnsupportedSkip.Saved(self.ConfigFolder, executor) then
            local block = gate.Block == true
            local folder = self.ConfigFolder
            table.insert(prompts, {
                Title = gate.Title or "Unsupported executor",
                Subtitle = executor,
                Text = block and ((gate.Text or message) .. " This script can't run here.") or (gate.Text or message),
                Icon = "shield-alert",
                Color = Theme.Warning,
                ContinueText = "Continue anyway",
                ExitText = "Exit",
                Block = block,
                RememberText = "Don't ask again on this executor",
                Remember = function()
                    UnsupportedSkip.Save(folder, executor)
                end,
            })
        end
    end
    -- Custom disclaimers queue up after the executor warning, in order. Each
    -- one must be accepted (or skipped by an earlier "Don't show again").
    local disclaimers = opts.Disclaimer or opts.Disclaimers
    if type(disclaimers) == "string" or (type(disclaimers) == "table" and (disclaimers.Title ~= nil or disclaimers.Text ~= nil)) then
        disclaimers = { disclaimers }
    end
    if type(disclaimers) == "table" then
        for _, entry in ipairs(disclaimers) do
            if type(entry) == "string" then
                entry = { Text = entry }
            end
            if type(entry) == "table" then
                local key = UnsupportedSkip.DisclaimerKey(entry)
                local folder = self.ConfigFolder
                local block = entry.Block == true
                local rememberable = entry.Remember ~= false and not block
                if not (rememberable and UnsupportedSkip.DisclaimerAccepted(folder, key)) then
                    local callback = entry.Callback
                    table.insert(prompts, {
                        Title = entry.Title or "Disclaimer",
                        Subtitle = entry.Subtitle,
                        Text = entry.Text or "",
                        Icon = entry.Icon or "info",
                        Color = entry.Color or Theme.Accent,
                        ContinueText = entry.AcceptText or "I understand",
                        ExitText = entry.DeclineText == nil and "Exit" or entry.DeclineText,
                        RememberText = rememberable and (entry.RememberText or "Don't show again") or nil,
                        Remember = function()
                            UnsupportedSkip.AcceptDisclaimer(folder, key)
                        end,
                        Callback = type(callback) == "function" and callback or nil,
                        Block = block,
                    })
                end
            end
        end
    end
    if #prompts > 0 then
        opts._prompts = prompts
    end
    if loading == false and opts._prompts then
        opts.LoadingDuration = opts.LoadingDuration or 0.5
        loading = true
    end
    if loading == false then
        task.defer(function()
            self:_playIntro()
        end)
    else
        self:_showLoader(opts)
    end
    return self
end

Library.CreateWindow = Library.Window



function Library:Notify(opts)
    local window = Library.Windows[#Library.Windows]
    if window then
        return window:Notify(opts)
    end
end

function Library:Confirm(opts)
    local window = Library.Windows[#Library.Windows]
    if window then
        return window:Confirm(opts)
    end
end

function Library:Dialog(opts)
    local window = Library.Windows[#Library.Windows]
    if window then
        return window:Dialog(opts)
    end
end

local function isShown(object, stopAt, point)
    local child = object
    while child and child ~= stopAt and child:IsA("GuiObject") do
        if not child.Visible then
            return false
        end
        local parent = child.Parent
        if parent and parent ~= stopAt and parent:IsA("GuiObject") and (parent.ClipsDescendants or parent:IsA("ScrollingFrame")) and not pointInside(point, parent) then
            return false
        end
        child = parent
    end
    return true
end

function Window:_refreshControls()
    local controls = {}
    for _, object in ipairs(self.Body:GetDescendants()) do
        if object:IsA("GuiButton") or object:IsA("TextBox") or object:GetAttribute("NoDrag") then
            table.insert(controls, object)
        end
    end
    self._controls = controls
    self._controlsDirty = false
end

function Window:_overControl(point)
    if self._dialog or self:_overPopout(point) then
        return true
    end
    if self._controlsDirty then
        self:_refreshControls()
    end
    for _, object in ipairs(self._controls) do
        if object.Parent and pointInside(point, object) and isShown(object, self.Body, point) then
            return true
        end
    end
    return false
end

-- Tooltips: one shared card per window that follows the pointer over any
-- element built with Tooltip = "..." or { Title, Text, Icon }. It appears
-- after a short hover (straight away when moving from one tooltip to the
-- next), hides on press, and shows on a long press on touch screens.
function Window:_tooltipCard()
    if self._tip then
        return self._tip
    end
    local holder = create("CanvasGroup", {
        Name = "Tooltip",
        Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 60,
        Parent = self.Gui,
    })
    local tipScale = create("UIScale", { Parent = holder })
    -- Bare text, no card: a dark outline keeps it readable over anything.
    -- The holder is sized from the text by hand, since scale sizes inside an
    -- automatic size would stretch it across the screen.
    local PAD = 4
    local panel = create("Frame", {
        Position = UDim2.fromOffset(PAD, PAD),
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Parent = holder,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = panel,
    })
    local function outline(object)
        create("UIStroke", {
            Color = Color3.new(0, 0, 0),
            Transparency = 0.35,
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Parent = object,
        })
    end
    local head = create("Frame", {
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = panel,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = head,
    })
    local icon = create("ImageLabel", {
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        LayoutOrder = 1,
        Parent = head,
    })
    local title = label({
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        TextSize = 13,
        FontFace = Fonts.Bold,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = head,
    })
    outline(title)
    local body = label({
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        TextSize = 12,
        FontFace = Fonts.Medium,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        TextYAlignment = Enum.TextYAlignment.Top,
        LineHeight = 1.1,
        LayoutOrder = 2,
        Parent = panel,
    })
    outline(body)
    create("UISizeConstraint", { MaxSize = Vector2.new(240, math.huge), Parent = body })
    local function fit()
        local scale = math.max(tipScale.Scale, 0.01)
        local size = panel.AbsoluteSize / scale
        holder.Size = UDim2.fromOffset(size.X + PAD * 2, size.Y + PAD * 2)
    end
    panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    local tip = {
        Holder = holder,
        Scale = tipScale,
        Pad = PAD,
        Head = head,
        Icon = icon,
        Title = title,
        Body = body,
        Shown = false,
        Fit = fit,
    }
    self._tip = tip
    -- Follow the pointer, and drop the card once its element is gone or off
    -- screen (tab switched, window hidden or minimized).
    self:_listen("Render", function(deltaTime)
        local owner = self._tipOwner
        if not owner then
            return
        end
        local frame = owner._frame
        if owner._destroyed or not self.Open or self.Minimized or not frame or not frame.Parent
            or (owner._isShown and not owner:_isShown()) or not isShown(frame, self.Body, frame.AbsolutePosition + frame.AbsoluteSize / 2) then
            self:_hideTooltip()
            return
        end
        local pointer = pointerPosition() - self.Gui.AbsolutePosition
        local pad = tip.Pad * tipScale.Scale
        local size = holder.AbsoluteSize - Vector2.one * pad * 2
        local view = self.Gui.AbsoluteSize
        local x, y
        if tip.Touch then
            x, y = pointer.X - size.X / 2, pointer.Y - size.Y - 30
        else
            x, y = pointer.X + 14, pointer.Y + 20
            if x + size.X > view.X - 8 then
                x = pointer.X - size.X - 10
            end
            if y + size.Y > view.Y - 8 then
                y = pointer.Y - size.Y - 12
            end
        end
        local target = Vector2.new(
            math.clamp(x, 8, math.max(8, view.X - size.X - 8)),
            math.clamp(y, 8, math.max(8, view.Y - size.Y - 8))
        )
        local current = tip.Position
        if not current or tip.Snap then
            -- Rises a few pixels into place as it fades in.
            current = target + Vector2.new(0, 6)
            tip.Snap = false
        else
            current = current:Lerp(target, math.min(deltaTime * 22, 1))
        end
        tip.Position = current
        holder.Position = UDim2.fromOffset(math.floor(current.X - pad + 0.5), math.floor(current.Y - pad + 0.5))
    end)
    -- A press anywhere (a dropdown chip inside the card, a key) hides it.
    self:_listen("Began", function(input)
        if self._tipOwner and not tip.Touch and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Keyboard) then
            self:_hideTooltip()
        end
    end)
    return tip
end

function Window:_showTooltip(element, touch)
    local value = element._tooltip
    local text, titleText, iconName
    if type(value) == "table" then
        text, titleText, iconName = value.Text or value.Content or value.Desc, value.Title or value.Name, value.Icon
    elseif value ~= nil and value ~= false then
        text = tostring(value)
    end
    if (text == nil or text == "") and (titleText == nil or titleText == "") then
        return
    end
    local tip = self:_tooltipCard()
    tip.Title.Text = titleText or ""
    tip.Title.Visible = titleText ~= nil and titleText ~= ""
    tip.Icon.Visible = iconName ~= nil
    if iconName ~= nil then
        applyIcon(tip.Icon, iconName)
    end
    tip.Head.Visible = tip.Title.Visible or iconName ~= nil
    tip.Body.Text = text or ""
    tip.Body.Visible = text ~= nil and text ~= ""
    tip.Fit()
    tip.Body.TextColor3 = Theme.Text
    tip.Scale.Scale = math.max(self.Scale.Scale, 0.75)
    tip.Touch = touch == true
    local wasShown = tip.Shown
    self._tipOwner = element
    tip.Shown = true
    tip.Generation = (tip.Generation or 0) + 1
    local holder = tip.Holder
    if not wasShown then
        tip.Snap = true
        holder.Visible = true
        holder.GroupTransparency = 1
        tip.Scale.Scale = tip.Scale.Scale * 0.96
    end
    tween(holder, { GroupTransparency = 0 }, 0.14, Enum.EasingStyle.Quad)
    tween(tip.Scale, { Scale = math.max(self.Scale.Scale, 0.75) }, 0.18, Enum.EasingStyle.Back)
end

function Window:_hideTooltip(element)
    local tip = self._tip
    if not tip or not tip.Shown or (element and self._tipOwner ~= element) then
        return
    end
    self._tipOwner = nil
    self._tipHiddenAt = os.clock()
    tip.Shown = false
    tip.Generation = (tip.Generation or 0) + 1
    local generation = tip.Generation
    tween(tip.Holder, { GroupTransparency = 1 }, 0.1, Enum.EasingStyle.Quad)
    task.delay(0.1, function()
        if tip.Generation == generation then
            tip.Holder.Visible = false
        end
    end)
end

function Window:_attachTooltip(element, frame)
    local hovering, token, pressAt = false, 0, nil
    local function begin(delay, touch)
        token += 1
        local mine = token
        task.delay(delay, function()
            if token ~= mine or not hovering or element._destroyed or self._destroyed then
                return
            end
            -- A finger that moved was scrolling, not holding.
            if touch and pressAt and (pointerPosition() - pressAt).Magnitude > 10 then
                return
            end
            self:_showTooltip(element, touch)
        end)
    end
    table.insert(element._listeners, (function()
        local connections = {
            frame.MouseEnter:Connect(function()
                if usingTouch() then
                    return
                end
                hovering = true
                local recent = os.clock() - (self._tipHiddenAt or 0) < 0.35 or self._tipOwner ~= nil
                begin(recent and 0 or 0.45, false)
            end),
            frame.MouseLeave:Connect(function()
                hovering = false
                token += 1
                self:_hideTooltip(element)
            end),
            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    hovering = true
                    pressAt = pointerPosition()
                    begin(0.5, true)
                end
            end),
            frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    hovering = false
                    token += 1
                    self:_hideTooltip(element)
                end
            end),
        }
        return function()
            for _, connection in ipairs(connections) do
                connection:Disconnect()
            end
        end
    end)())
end

-- While dragging, a stand-in follows the pointer while the window stays put,
-- and the window glides into its spot on release. The look is the player's
-- Drag Style; "Off" drags the window itself.
Library.DragStyles = { "Outline", "Brackets", "Ghost", "Frame", "Off" }

local function makeSkeleton(window)
    local root = window.Root
    local style = window.DragStyle or "Outline"
    local skeleton = create("Frame", {
        AnchorPoint = root.AnchorPoint,
        Position = root.Position,
        Size = UDim2.fromOffset(root.AbsoluteSize.X, root.AbsoluteSize.Y),
        BackgroundColor3 = style == "Ghost" and Theme.Background or Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 40,
        Parent = window.Gui,
    })
    corner(skeleton, UDim.new(0, 10))
    -- Each part fades from hidden to its shown values, and back on release.
    local parts = {}
    local function part(object, shown)
        local hidden = {}
        for key in pairs(shown) do
            hidden[key] = 1
        end
        table.insert(parts, { Object = object, Shown = shown, Hidden = hidden })
    end
    local function brackets(length, inset)
        for _, spot in ipairs({ Vector2.new(0, 0), Vector2.new(1, 0), Vector2.new(0, 1), Vector2.new(1, 1) }) do
            local at = UDim2.new(spot.X, spot.X == 0 and inset or -inset, spot.Y, spot.Y == 0 and inset or -inset)
            for _, size in ipairs({ UDim2.fromOffset(length, 2), UDim2.fromOffset(2, length) }) do
                local bracket = create("Frame", {
                    AnchorPoint = spot,
                    Position = at,
                    Size = size,
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = skeleton,
                })
                corner(bracket, UDim.new(1, 0))
                part(bracket, { BackgroundTransparency = 0 })
            end
        end
    end
    if style == "Brackets" then
        -- Just the four corners of the window, a little longer.
        brackets(22, 0)
    elseif style == "Ghost" then
        -- A see-through copy of the window's panel.
        part(skeleton, { BackgroundTransparency = 0.35 })
        part(stroke(skeleton, Theme.Stroke, 1, 1), { Transparency = 0 })
    elseif style == "Frame" then
        -- A single quiet line, nothing else.
        part(stroke(skeleton, Theme.StrokeHover, 1, 1), { Transparency = 0 })
    else
        -- Outline: a faint accent wash, an outline and corner brackets.
        part(skeleton, { BackgroundTransparency = 0.92 })
        part(stroke(skeleton, Theme.Accent, 1, 1.5), { Transparency = 0.2 })
        brackets(16, 6)
    end
    local scale = create("UIScale", { Scale = 1.02, Parent = skeleton })
    for _, item in ipairs(parts) do
        tween(item.Object, item.Shown, 0.15, Enum.EasingStyle.Quad)
    end
    tween(scale, { Scale = 1 }, 0.25, Enum.EasingStyle.Quint)
    local function fade()
        for _, item in ipairs(parts) do
            tween(item.Object, item.Hidden, 0.2, Enum.EasingStyle.Quad)
        end
        task.delay(0.22, function()
            skeleton:Destroy()
        end)
    end
    return skeleton, fade
end

function Window:_enableDrag()
    local dragging, moved = false, false
    local grabOffset, pressPoint = Vector2.zero, Vector2.zero
    local target = nil
    local skeleton, fadeSkeleton = nil, nil

    local function centre()
        local root = self.Root
        return root.AbsolutePosition + root.AbsoluteSize * root.AnchorPoint - self.Gui.AbsolutePosition
    end

    local function dropSkeleton()
        if not skeleton then
            return
        end
        local spot = Vector2.new(skeleton.Position.X.Offset, skeleton.Position.Y.Offset)
        if self.KeepOnScreen then
            spot = self:_clampedCentre(spot)
        end
        if self._clampTween then
            self._clampTween:Cancel()
        end
        self._clampTween = tween(self.Root, { Position = UDim2.fromOffset(spot.X, spot.Y) }, 0.3, Enum.EasingStyle.Quint)
        fadeSkeleton()
        skeleton, fadeSkeleton = nil, nil
    end

    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input)
        if not isPress(input) then
            return
        end
        if not self.Open or not self.Root.Visible then
            return
        end
        local point = pointerPosition()
        if self._resizeActive or (self._grip and pointInside(point, self._grip)) then
            return
        end
        if not pointInside(point, self.Body) or self:_overControl(point) then
            return
        end
        if self._clampTween then
            self._clampTween:Cancel()
            self._clampTween = nil
        end
        dragging, moved = true, false
        pressPoint = point
        grabOffset = point - centre()
    end))

    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
        if not dragging then
            return
        end
        if isPress(input) then
            dragging = false
            target = nil
            if skeleton then
                dropSkeleton()
            else
                self:_clampToScreen()
            end
        end
    end))

    table.insert(self._frameSteps, function(deltaTime)
        if not dragging then
            return
        end
        local point = pointerPosition()
        if not moved and (point - pressPoint).Magnitude > 3 then
            moved = true
            if self.DragSkeleton then
                skeleton, fadeSkeleton = makeSkeleton(self)
            end
        end
        if not moved then
            return
        end
        -- Hidden or minimized mid-drag: land it where the outline is.
        if skeleton and (not self.Open or not self.Root.Visible) then
            dragging = false
            dropSkeleton()
            return
        end
        target = point - grabOffset
        local alpha = 1 - math.exp(-deltaTime * 45)
        if skeleton then
            local current = Vector2.new(skeleton.Position.X.Offset, skeleton.Position.Y.Offset)
            local step = current:Lerp(target, alpha)
            skeleton.Position = UDim2.fromOffset(step.X, step.Y)
        else
            local step = centre():Lerp(target, alpha)
            self.Root.Position = UDim2.fromOffset(step.X, step.Y)
        end
    end)
end

-- One of Library.DragStyles; anything else falls back to "Outline".
-- Returns the style it settled on.
function Window:SetDragStyle(style)
    style = table.find(Library.DragStyles, style) and style or "Outline"
    self.DragStyle = style
    self.DragSkeleton = style ~= "Off"
    return style
end

function Window:GetDragStyle()
    return self.DragStyle
end

-- How the minimized island shows the session card: opening it while
-- hovered, or keeping it open the whole time it's minimized.
Library.IslandStyles = { "Show on Hover", "Always Show" }

-- One of Library.IslandStyles; anything else falls back to "Show on Hover".
-- Returns the style it settled on.
function Window:SetIslandStyle(style)
    style = table.find(Library.IslandStyles, style) and style or "Show on Hover"
    self.IslandStyle = style
    if self._islandSettle then
        self._islandSettle()
    end
    return style
end

function Window:GetIslandStyle()
    return self.IslandStyle
end

-- The older on/off switch: off is the "Off" style, on brings back the
-- default style if it was off.
function Window:SetDragSkeleton(enabled)
    if enabled == false then
        self:SetDragStyle("Off")
    elseif self.DragStyle == "Off" or not self.DragStyle then
        self:SetDragStyle("Outline")
    end
end

-- The sidebar's divider is a grab strip: dragging it sets the rail's width,
-- kept between a usable minimum and enough room for the content.
function Window:_sidebarResize(sidebar, width)
    local divider = sidebar:FindFirstChild("Divider")
    local want = width
    local function apply(value, remember)
        if remember ~= false then
            want = value
        end
        local room = self.Body.AbsoluteSize.X / self.Scale.Scale - 300
        value = math.floor(math.clamp(value, 150, math.max(math.min(300, room), 150)))
        self.SidebarWidth = value
        sidebar.Size = UDim2.new(0, value, 1, 0)
        self.Content.Position = UDim2.fromOffset(value + 1, 0)
        self.Content.Size = UDim2.new(1, -(value + 1), 1, 0)
    end
    self.SetSidebarWidth = function(_, value)
        apply(tonumber(value) or SIDEBAR_WIDTH)
    end
    apply(width)
    local grip = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 6, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
        Parent = sidebar,
    })
    grip:SetAttribute("NoDrag", true)
    local dragging, startX, startWidth = false, 0, width
    local function light(on)
        if divider then
            tween(divider, { BackgroundColor3 = on and Theme.Accent or Theme.Stroke }, 0.15)
        end
    end
    grip.MouseEnter:Connect(function()
        light(true)
    end)
    grip.MouseLeave:Connect(function()
        if not dragging then
            light(false)
        end
    end)
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, startX, startWidth = true, input.Position.X, self.SidebarWidth
            want = startWidth
            light(true)
        end
    end)
    self:_listen("Changed", function(input)
        if dragging and isMove(input) then
            apply(startWidth + (input.Position.X - startX) / self.Scale.Scale)
        end
    end)
    self:_listen("Ended", function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            light(false)
        end
    end)
    -- Shrinking the window pulls an over-wide rail back in.
    self.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not dragging then
            apply(want, false)
        end
    end)
end

-- See-through window: the body and sidebar let the game show through, and the
-- shadow lightens so it doesn't smudge behind them.
function Window:SetTransparent(enabled)
    self.Transparent = enabled == true
    local on = self.Transparent
    self._shadowRest = on and 0.85 or 0.6
    tween(self.Body, { BackgroundTransparency = on and 0.35 or 0 }, 0.25)
    -- See-through, the rail stays a touch more solid than the body so the
    -- tabs keep their contrast; over a background image it lets more through.
    local railAlpha = on and 0.5 or (self.Background and 0.45 or 0)
    tween(self.SidebarFill, { BackgroundTransparency = railAlpha }, 0.25)
    if self.Open and not self.Minimized and self.Root.Visible then
        tween(self.Shadow, { ImageTransparency = self._shadowRest }, 0.25)
    end
end

local function orderedChildren(parent)
    local children = {}
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") then
            table.insert(children, child)
        end
    end
    table.sort(children, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    return children
end

local function popIn(object, delay, force)
    if not object.Visible and not force then
        return
    end
    object.Visible = false
    task.delay(delay, function()
        if not object.Parent then
            return
        end
        local scaleObject = create("UIScale", { Scale = 0.94, Parent = object })
        object.Visible = true
        tween(scaleObject, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
        task.delay(0.4, function()
            scaleObject:Destroy()
        end)
    end)
end

function Window:_revealCards(tab, baseDelay)
    local container = tab.CurrentSubTab or tab
    if container._revealed then
        return
    end
    container._revealed = true
    local index = 0
    local function reveal(object)
        popIn(object, (baseDelay or 0) + index * 0.035)
        index += 1
    end
    local columns = container._columnSet
    for _, child in ipairs(orderedChildren(container.List)) do
        if columns and child == columns.Holder then
            local left, right = orderedChildren(columns.Left), orderedChildren(columns.Right)
            for row = 1, math.max(#left, #right) do
                if left[row] then
                    reveal(left[row])
                end
                if right[row] then
                    reveal(right[row])
                end
            end
        else
            reveal(child)
        end
    end
end

function Window:_playIntro(morph)
    if self._introDone or self._destroyed then
        return
    end
    self._introDone = true
    self:_refreshBackdrop(true)
    task.delay(0.4, function()
        self:_refreshToggleButton()
    end)
    -- Build the minimized bar ahead of time so the first minimize doesn't
    -- pay for it mid-click.
    task.delay(1.5, function()
        if not self._destroyed and not self.MiniBar then
            self:_buildMiniBar()
        end
    end)
    local root, shadow, scale = self.Root, self.Shadow, self.Scale
    if self.CurrentTab then
        self:_revealCards(self.CurrentTab, morph and 0.15 or 0.25)
    end
    root.Visible = true
    if morph then
        scale.Scale = self._fitScale or 1
        root.Position = UDim2.fromScale(0.5, 0.5)
        self:_fade(0, 0.3)
        tween(self.BodyStroke, { Transparency = 0 }, 0.3)
        tween(shadow, { ImageTransparency = 0.6 }, 0.3)
    else
        root.Position = UDim2.new(0.5, 0, 0.5, 24)
        tween(scale, { Scale = self._fitScale or 1 }, 0.5, Enum.EasingStyle.Back)
        tween(root, { Position = UDim2.fromScale(0.5, 0.5) }, 0.5, Enum.EasingStyle.Quint)
        self:_fade(0, 0.35)
        tween(self.BodyStroke, { Transparency = 0 }, 0.35)
    end
    if not morph then
        tween(shadow, { ImageTransparency = 0.6 }, 0.5)
    end

    for index, tab in ipairs(self.Tabs) do
        popIn(tab._button, 0.1 + index * 0.05, true)
    end
    self.Indicator.Visible = false
    task.delay(0.15 + #self.Tabs * 0.05, function()
        if self.CurrentTab then
            self:_placeIndicator(self.CurrentTab)
        end
    end)
end

function Window:_showLoader(opts)
    local duration = opts.LoadingDuration or 1.6
    local gui = self.Gui
    -- A compact card: logo, title and subtitle on top, a checklist of the
    -- loading steps under a hairline, and a thin progress line along the
    -- bottom edge. Everything but the prompt cards lives in one canvas group
    -- so it can fade as a unit.
    local steps = opts.LoadingSteps or { "Preparing interface", "Loading icons", "Almost there" }
    local WIDTH, PAD, STEP = 340, 22, 24
    local listTop = 80
    local height = listTop + #steps * STEP + 18
    local loader = create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 10),
        Size = UDim2.fromOffset(WIDTH, height),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ZIndex = 10,
        Parent = gui,
    })
    local loaderCorner = corner(loader, UDim.new(0, 12))
    local loaderStroke = stroke(loader, Theme.Stroke, 1)
    local loaderScale = create("UIScale", { Scale = 0.97, Parent = loader })
    local loaderShadow = create("ImageLabel", {
        Position = UDim2.fromOffset(-25, -25),
        Size = UDim2.new(1, 50, 1, 50),
        BackgroundTransparency = 1,
        Image = Assets.Shadow,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = loader,
    })
    local content = create("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = loader,
    })

    local logo = create("ImageLabel", {
        Position = UDim2.fromOffset(PAD, PAD),
        Size = UDim2.fromOffset(30, 30),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.new(1, 1, 1),
        ScaleType = Enum.ScaleType.Fit,
        Parent = content,
    })
    applyIcon(logo, opts.Icon or Assets.Logo, true)
    local TEXT_X = PAD + 42
    local titleLabel = label({
        Position = UDim2.fromOffset(TEXT_X, PAD - 2),
        Size = UDim2.new(1, -(TEXT_X + 70), 0, 18),
        Text = opts.LoadingTitle or opts.Title or "Noir",
        TextSize = 15,
        FontFace = Fonts.Bold,
        Parent = content,
    })
    local statusLabel = label({
        Position = UDim2.fromOffset(TEXT_X, PAD + 17),
        Size = UDim2.new(1, -(TEXT_X + 70), 0, 15),
        Text = opts.LoadingText or opts.Subtitle or "Loading",
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = content,
    })
    local percentLabel = label({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -PAD, 0, PAD + 6),
        Size = UDim2.fromOffset(56, 16),
        Text = "0%",
        TextSize = 13,
        FontFace = Fonts.Medium,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = content,
    })
    create("Frame", {
        Position = UDim2.fromOffset(PAD, listTop - 14),
        Size = UDim2.new(1, -PAD * 2, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = content,
    })

    -- Each step: a marker and its text. Pending is a dim dot, the running
    -- step a turning arc, and a finished one a check.
    local rows = {}
    for index, text in ipairs(steps) do
        local row = create("Frame", {
            Position = UDim2.fromOffset(PAD, listTop + (index - 1) * STEP),
            Size = UDim2.new(1, -PAD * 2, 0, STEP),
            BackgroundTransparency = 1,
            Parent = content,
        })
        local dot = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 7, 0.5, 0),
            Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = Theme.Surface3,
            BorderSizePixel = 0,
            Parent = row,
        })
        corner(dot, UDim.new(1, 0))
        local spinner = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 7, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = row,
        })
        corner(spinner, UDim.new(1, 0))
        local spinnerStroke = create("UIStroke", {
            Color = Theme.Accent,
            Thickness = 2,
            Parent = spinner,
        })
        create("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(0.501, 1),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = spinnerStroke,
        })
        local check = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 7, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Accent,
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            Parent = row,
        })
        applyIcon(check, "check")
        local stepLabel = label({
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Text = tostring(text),
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextTransparency = 1,
            Parent = row,
        })
        rows[index] = { Dot = dot, Spinner = spinner, Check = check, Label = stepLabel, State = "pending" }
        -- The rows fade in one after another once the card is up.
        task.delay(0.15 + index * 0.06, function()
            if loader.Parent and rows[index].State == "pending" then
                tween(stepLabel, { TextTransparency = 0.45 }, 0.3)
            end
        end)
    end
    local function setStep(index, state)
        local row = rows[index]
        if not row or row.State == state then
            return
        end
        row.State = state
        row.Dot.Visible = state == "pending"
        row.Spinner.Visible = state == "active"
        tween(row.Check, { ImageTransparency = state == "done" and 0 or 1 }, 0.2)
        tween(row.Label, {
            TextTransparency = state == "pending" and 0.45 or 0,
            TextColor3 = state == "active" and Theme.Text or Theme.Muted,
        }, 0.2)
    end

    local track = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = content,
    })
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })

    tween(loader, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) }, 0.45, Enum.EasingStyle.Quint)
    tween(loaderScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Quint)
    tween(loaderShadow, { ImageTransparency = 0.55 }, 0.4)
    tween(fill, { Size = UDim2.fromScale(0.85, 1) }, duration * 0.8, Enum.EasingStyle.Quart)
    -- The percentage follows the bar and the running step's arc turns.
    local percentStep
    percentStep = RunService.RenderStepped:Connect(function(deltaTime)
        if not loader.Parent then
            percentStep:Disconnect()
            return
        end
        percentLabel.Text = math.floor(fill.Size.X.Scale * 100 + 0.5) .. "%"
        for _, row in ipairs(rows) do
            if row.State == "active" then
                row.Spinner.Rotation = (row.Spinner.Rotation + deltaTime * 360) % 360
            end
        end
    end)

    task.spawn(loadLucide)

    for index in ipairs(steps) do
        task.delay(duration * (index - 1) / #steps, function()
            if not loader.Parent then
                return
            end
            if index > 1 then
                setStep(index - 1, "done")
            end
            setStep(index, "active")
        end)
    end
    local function completeSteps()
        for index in ipairs(rows) do
            setStep(index, "done")
        end
    end

    local function finish()
        completeSteps()
        tween(content, { GroupTransparency = 1 }, 0.18)

        local fit = self._fitScale or 1
        local target = self.Root.Size
        tween(loader, {
            Size = UDim2.fromOffset(target.X.Offset * fit, target.Y.Offset * fit),
            Position = UDim2.fromScale(0.5, 0.5),
        }, 0.5, Enum.EasingStyle.Quint)
        tween(loaderCorner, { CornerRadius = UDim.new(0, Library._radius(10)) }, 0.5, Enum.EasingStyle.Quint)
        tween(loaderScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Quint)

        task.delay(0.28, function()
            self:_playIntro(true)
            tween(loader, { GroupTransparency = 1 }, 0.25)
            tween(loaderStroke, { Transparency = 1 }, 0.2)
            tween(loaderShadow, { ImageTransparency = 1 }, 0.2)
        end)
        task.delay(0.6, function()
            loader:Destroy()
        end)
    end

    -- Prompt cards (unsupported executor, custom disclaimers): the checklist
    -- gives way to one card at a time, each with Exit and Continue, before
    -- the window opens.
    local function hideBar()
        completeSteps()
        tween(content, { GroupTransparency = 1 }, 0.18)
    end

    local function showCard(info, onContinue)
        local WIDTH, PAD, MAX_BODY = 360, 24, 220
        local tone = info.Color or Theme.Accent
        -- Fixed width from the start, so the body wraps at its final width
        -- while the loader is still resizing.
        local warnCard = create("CanvasGroup", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, WIDTH, 1, 0),
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            ZIndex = 5,
            Parent = loader,
        })
        local badge = create("Frame", {
            Position = UDim2.fromOffset(PAD, PAD),
            Size = UDim2.fromOffset(44, 44),
            BackgroundColor3 = tone,
            BackgroundTransparency = 0.86,
            BorderSizePixel = 0,
            Parent = warnCard,
        })
        corner(badge, UDim.new(0, 12))
        stroke(badge, tone, 1).Transparency = 0.6
        local badgeIcon = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(22, 22),
            BackgroundTransparency = 1,
            ImageColor3 = tone,
            ScaleType = Enum.ScaleType.Fit,
            Parent = badge,
        })
        applyIcon(badgeIcon, info.Icon or "info")
        label({
            Position = UDim2.fromOffset(PAD + 58, info.Subtitle and PAD + 3 or PAD + 12),
            Size = UDim2.new(1, -(PAD * 2 + 58), 0, 20),
            Text = info.Title,
            TextSize = 17,
            Parent = warnCard,
        })
        if info.Subtitle then
            label({
                Position = UDim2.fromOffset(PAD + 58, PAD + 25),
                Size = UDim2.new(1, -(PAD * 2 + 58), 0, 16),
                Text = tostring(info.Subtitle),
                TextSize = 13,
                TextColor3 = tone,
                Parent = warnCard,
            })
        end
        -- Long text scrolls past MAX_BODY instead of pushing the card off screen.
        local scroller = create("ScrollingFrame", {
            Position = UDim2.fromOffset(PAD, PAD + 60),
            Size = UDim2.new(1, -PAD * 2, 0, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = TOUCH and 4 or 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(),
            Parent = warnCard,
        })
        local body = label({
            Size = UDim2.new(1, -8, 0, 0),
            Text = tostring(info.Text),
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = scroller,
        })
        local row = create("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, PAD, 1, -PAD + 4),
            Size = UDim2.new(1, -PAD * 2, 0, 34),
            BackgroundTransparency = 1,
            Parent = warnCard,
        })
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = row,
        })

        -- Don't ask again: only offered when Continue is, and the executor
        -- can write the file that remembers it.
        local remember = false
        local rememberRow = nil
        if not info.Block and info.RememberText and UnsupportedSkip.Available() then
            local boxSize = TOUCH and 20 or 16
            rememberRow = create("TextButton", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, PAD, 1, -PAD + 4 - 34 - 12),
                Size = UDim2.new(1, -PAD * 2, 0, TOUCH and 28 or 22),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = warnCard,
            })
            local box = create("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(boxSize, boxSize),
                BackgroundColor3 = Theme.Surface2,
                BorderSizePixel = 0,
                Parent = rememberRow,
            })
            corner(box, UDim.new(0, 4))
            local boxStroke = stroke(box, Theme.Stroke, 1)
            local check = create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(boxSize - 4, boxSize - 4),
                BackgroundTransparency = 1,
                ImageColor3 = Theme.AccentDark,
                ImageTransparency = 1,
                ScaleType = Enum.ScaleType.Fit,
                Parent = box,
            })
            applyIcon(check, "check")
            local rememberLabel = label({
                Position = UDim2.fromOffset(boxSize + 8, 0),
                Size = UDim2.new(1, -(boxSize + 8), 1, 0),
                Text = info.RememberText,
                TextSize = 12,
                FontFace = Fonts.Regular,
                TextColor3 = Theme.Muted,
                Parent = rememberRow,
            })
            rememberRow.MouseEnter:Connect(function()
                tween(boxStroke, { Color = remember and Theme.Accent or Theme.StrokeHover }, 0.12)
                tween(rememberLabel, { TextColor3 = Theme.Text }, 0.12)
            end)
            rememberRow.MouseLeave:Connect(function()
                tween(boxStroke, { Color = remember and Theme.Accent or Theme.Stroke }, 0.2)
                tween(rememberLabel, { TextColor3 = remember and Theme.Text or Theme.Muted }, 0.2)
            end)
            rememberRow.MouseButton1Click:Connect(function()
                remember = not remember
                tween(box, { BackgroundColor3 = remember and Theme.Accent or Theme.Surface2 }, 0.15)
                tween(boxStroke, { Color = remember and Theme.Accent or Theme.Stroke }, 0.15)
                tween(check, { ImageTransparency = remember and 0 or 1 }, 0.15)
                tween(rememberLabel, { TextColor3 = remember and Theme.Text or Theme.Muted }, 0.15)
            end)
        end

        local chosen = false
        local function button(text, primary, order, callback)
            local frame = create("TextButton", {
                Size = UDim2.fromOffset(0, 34),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = primary and Theme.Accent or Theme.Surface2,
                BackgroundTransparency = primary and 0.12 or 0,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = order,
                Parent = row,
            })
            corner(frame, UDim.new(0, 7))
            local frameStroke = stroke(frame, primary and Theme.Accent or Theme.Stroke, 1)
            frameStroke.Transparency = primary and 0.4 or 0
            padding(frame, 14, 14)
            label({
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = text,
                TextSize = 13,
                TextColor3 = primary and Theme.AccentDark or Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = frame,
            })
            frame.MouseEnter:Connect(function()
                if primary then
                    tween(frame, { BackgroundTransparency = 0 }, 0.12)
                    tween(frameStroke, { Transparency = 0 }, 0.12)
                else
                    tween(frameStroke, { Color = Theme.StrokeHover }, 0.12)
                end
            end)
            frame.MouseLeave:Connect(function()
                if primary then
                    tween(frame, { BackgroundTransparency = 0.12 }, 0.2)
                    tween(frameStroke, { Transparency = 0.4 }, 0.2)
                else
                    tween(frameStroke, { Color = Theme.Stroke }, 0.2)
                end
            end)
            frame.MouseButton1Click:Connect(function()
                if chosen then
                    return
                end
                chosen = true
                callback()
            end)
        end
        if info.ExitText ~= false then
            button(info.ExitText or "Exit", info.Block, 1, function()
                if info.Callback then
                    task.spawn(info.Callback, false)
                end
                tween(loader, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 12) }, 0.25, Enum.EasingStyle.Quint)
                tween(loaderShadow, { ImageTransparency = 1 }, 0.2)
                task.delay(0.25, function()
                    self:Destroy()
                end)
            end)
        end
        if not info.Block then
            button(info.ContinueText or "Continue", true, 2, function()
                if remember and info.Remember then
                    info.Remember()
                end
                if info.Callback then
                    task.spawn(info.Callback, true)
                end
                tween(warnCard, { GroupTransparency = 1 }, 0.15)
                task.delay(0.15, function()
                    warnCard:Destroy()
                    onContinue()
                end)
            end)
        end

        -- The card grows to fit the message, then it fades in. The wrapped
        -- height can land a few frames late (font loading, the scroller's
        -- layout), so the card refits whenever it changes.
        local laidOut = false
        -- TextBounds of wrapped text stops at the label's current height, so
        -- the card would fit to its own clipped text; the full wrapped height
        -- is measured at the body's width instead.
        local function measure()
            local ok, size = pcall(function()
                local params = Instance.new("GetTextBoundsParams")
                params.Text = body.Text
                params.Font = body.FontFace
                params.Size = body.TextSize
                params.Width = WIDTH - PAD * 2 - 8
                return game:GetService("TextService"):GetTextBoundsAsync(params)
            end)
            return ok and size and math.ceil(size.Y) + 2 or body.TextBounds.Y
        end
        local function fit(duration)
            local textHeight = math.max(measure(), 16)
            local bodyHeight = math.min(textHeight, MAX_BODY)
            body.Size = UDim2.new(1, -8, 0, textHeight)
            scroller.Size = UDim2.new(1, -PAD * 2, 0, bodyHeight)
            scroller.CanvasSize = UDim2.fromOffset(0, textHeight)
            local height = PAD + 60 + bodyHeight + 18 + 34 + PAD - 4
            if rememberRow then
                height += rememberRow.Size.Y.Offset + 10
            end
            tween(loader, { Size = UDim2.fromOffset(WIDTH, height) }, duration, Enum.EasingStyle.Quint)
        end
        body:GetPropertyChangedSignal("TextBounds"):Connect(function()
            if laidOut and loader.Parent and warnCard.Parent then
                fit(0.2)
            end
        end)
        task.delay(0.15, function()
            if not loader.Parent then
                return
            end
            laidOut = true
            fit(0.35)
            task.delay(0.12, function()
                tween(warnCard, { GroupTransparency = 0 }, 0.3)
                badge.Size = UDim2.fromOffset(34, 34)
                badge.Position = UDim2.fromOffset(PAD + 5, PAD + 5)
                tween(badge, { Size = UDim2.fromOffset(44, 44), Position = UDim2.fromOffset(PAD, PAD) }, 0.45, Enum.EasingStyle.Back)
            end)
        end)
    end

    local function runPrompts(queue, index)
        if not loader.Parent then
            return
        end
        local info = queue[index]
        if not info then
            finish()
            return
        end
        showCard(info, function()
            runPrompts(queue, index + 1)
        end)
    end

    task.delay(duration, function()
        tween(fill, { Size = UDim2.fromScale(1, 1) }, 0.25, Enum.EasingStyle.Quint)
        task.delay(0.25, function()
            if not loader.Parent then
                return
            end
            if opts._prompts then
                hideBar()
                runPrompts(opts._prompts, 1)
            else
                finish()
            end
        end)
    end)
end

function Window:_fitToScreen(instant)
    local viewport = self.Gui.AbsoluteSize
    if viewport.X == 0 or viewport.Y == 0 then
        return
    end
    local size = self.Root.Size
    -- The player's UI scale, times the adaptive factor for this screen, shrunk
    -- further when the window wouldn't fit.
    local wanted = (self._uiScale or 1) * (self._adaptive ~= false and Library._adaptiveFactor(viewport) or 1)
    local scale = math.min(wanted, (viewport.X - 24) / math.max(size.X.Offset, 1), (viewport.Y - 24) / math.max(size.Y.Offset, 1))
    self._fitScale = math.max(scale, 0.45)
    if self._introDone and self.Open then
        if instant then
            self.Scale.Scale = self._fitScale
        else
            tween(self.Scale, { Scale = self._fitScale }, 0.2)
        end
    end
end

-- Adaptive size: the window is drawn for a 1080p screen and grows on larger
-- ones (up to 1.75x on 4K) or shrinks a little on small laptops, so it covers
-- about the same share of any screen. 1080p-class screens, windowed or with
-- the topbar inset, stay at exactly 1. Touch screens only use the fit.
function Library._adaptiveFactor(viewport)
    if TOUCH then
        return 1
    end
    local factor = math.min(viewport.X / 1920, viewport.Y / 1020)
    if factor > 0.9 and factor < 1.15 then
        return 1
    end
    return math.clamp(math.floor(factor * 20 + 0.5) / 20, 0.85, 1.75)
end

function Window:SetAdaptiveSize(enabled)
    self._adaptive = enabled ~= false
    self:_fitToScreen()
    task.delay(0.22, function()
        if not self._destroyed then
            self:_clampToScreen()
        end
    end)
end

function Window:GetAdaptiveSize()
    return self._adaptive ~= false
end

-- UI scale: 0.6 to 1.5 on top of the automatic fit to small screens.
function Window:SetUIScale(value)
    value = math.clamp(tonumber(value) or 1, 0.6, 1.5)
    self.UIScale = value
    self._uiScale = value
    self:_fitToScreen()
    task.delay(0.22, function()
        if not self._destroyed then
            self:_clampToScreen()
        end
    end)
end

function Window:GetUIScale()
    return self._uiScale or 1
end

-- Density: the spacing between cards, groupboxes and rows. Shared by every
-- window, like the theme. Anything built with Library._space follows it.
Library.DensityModes = { Compact = 0.55, Default = 1, Comfortable = 1.45 }
Library.Density = "Default"

-- Small gaps (a groupbox's 2px rows) still move visibly between modes.
function Library._spaced(base, factor)
    if base <= 0 then
        return 0
    end
    return math.max(math.floor(base * factor + (factor - 1) * 4 + 0.5), 0)
end

function Library._space(object, base)
    local factor = Library.DensityModes[Library.Density] or 1
    if object:IsA("UIListLayout") or object:IsA("UIGridLayout") then
        object:SetAttribute("Space", base)
        object.Padding = UDim.new(0, Library._spaced(base, factor))
    elseif object:IsA("UIPadding") then
        -- base is { left, right, top, bottom }
        object:SetAttribute("SpaceL", base[1])
        object:SetAttribute("SpaceR", base[2])
        object:SetAttribute("SpaceT", base[3])
        object:SetAttribute("SpaceB", base[4])
        object.PaddingLeft = UDim.new(0, math.floor(base[1] * math.sqrt(factor) + 0.5))
        object.PaddingRight = UDim.new(0, math.floor(base[2] * math.sqrt(factor) + 0.5))
        object.PaddingTop = UDim.new(0, Library._spaced(base[3], factor))
        object.PaddingBottom = UDim.new(0, Library._spaced(base[4], factor))
    end
    return object
end

function Library:SetDensity(mode)
    if type(mode) == "string" then
        for name in pairs(Library.DensityModes) do
            if name:lower() == mode:lower() then
                mode = name
                break
            end
        end
    end
    if not Library.DensityModes[mode] then
        mode = "Default"
    end
    Library.Density = mode
    for _, window in ipairs(Library.Windows) do
        if window.Gui and window.Gui.Parent then
            for _, object in ipairs(window.Gui:GetDescendants()) do
                local base = object:GetAttribute("Space")
                if base then
                    Library._space(object, base)
                elseif object:GetAttribute("SpaceL") then
                    Library._space(object, {
                        object:GetAttribute("SpaceL"), object:GetAttribute("SpaceR"),
                        object:GetAttribute("SpaceT"), object:GetAttribute("SpaceB"),
                    })
                end
            end
        end
    end
    return mode
end

function Window:SetDensity(mode)
    return Library:SetDensity(mode)
end

function Window:GetDensity()
    return Library.Density
end

-- Nearest centre that keeps the whole window inside the viewport.
function Window:_clampedCentre(centre)
    local viewport = self.Gui.AbsoluteSize
    local half = self.Root.AbsoluteSize / 2
    return Vector2.new(
        math.clamp(centre.X, math.min(half.X, viewport.X / 2), math.max(viewport.X - half.X, viewport.X / 2)),
        math.clamp(centre.Y, math.min(half.Y, viewport.Y / 2), math.max(viewport.Y - half.Y, viewport.Y / 2))
    )
end

function Window:_clampToScreen()
    if not self.KeepOnScreen or self._resizeActive then
        return
    end
    local root = self.Root
    local centre = root.AbsolutePosition + root.AbsoluteSize / 2 - self.Gui.AbsolutePosition
    local clamped = self:_clampedCentre(centre)
    if (clamped - centre).Magnitude > 0.5 then
        self._clampTween = tween(root, { Position = UDim2.fromOffset(clamped.X, clamped.Y) }, 0.25, Enum.EasingStyle.Quint)
    end
end

function Window:_createOpenButton(opts)
    local gui = self.Gui
    local pill = create("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 14),
        Size = UDim2.fromOffset(0, 40),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 30,
        Parent = gui,
    })
    corner(pill, UDim.new(1, 0))
    stroke(pill, Theme.Stroke)
    padding(pill, 12, 16)
    local icon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        ImageColor3 = Color3.new(1, 1, 1),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 31,
        Parent = pill,
    })
    applyIcon(icon, opts.Icon or Assets.Logo, true)
    label({
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = opts.Title or "Noir",
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.None,
        ZIndex = 31,
        Parent = pill,
    })
    self.OpenButton = pill

    local dragging, moved = false, false
    local grab = Vector2.zero
    pill.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            moved = false
            grab = pointerPosition() - pill.AbsolutePosition
        end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if isMove(input) then
            local point = pointerPosition() - grab - gui.AbsolutePosition
            if (point - (pill.AbsolutePosition - gui.AbsolutePosition)).Magnitude > 3 then
                moved = true
            end
            pill.AnchorPoint = Vector2.new(0, 0)
            pill.Position = UDim2.fromOffset(
                math.clamp(point.X, 0, math.max(gui.AbsoluteSize.X - pill.AbsoluteSize.X, 0)),
                math.clamp(point.Y, 0, math.max(gui.AbsoluteSize.Y - pill.AbsoluteSize.Y, 0))
            )
        end
    end))
    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
        if dragging and isPress(input) then
            dragging = false
            if not moved then
                self:Toggle()
            end
        end
    end))
end

-- Square floating button that minimizes and restores the window. Shown on
-- touch devices only, or everywhere with Platform = "Both".
function Window:_toggleButtonAllowed()
    return self._toggleEnabled and (TOUCH or self._togglePlatform == "Both")
end

function Window:_refreshToggleButton()
    local button = self.ToggleButton
    if not button then
        return
    end
    local shown = self._introDone and not self._destroyed and self:_toggleButtonAllowed()
    if shown and not button.Visible then
        button.Visible = true
        button.Size = UDim2.fromOffset(0, 0)
        tween(button, { Size = UDim2.fromOffset(self._toggleSize, self._toggleSize) }, 0.45, Enum.EasingStyle.Quint)
    elseif not shown then
        button.Visible = false
    end
    -- Folded (window minimized or hidden): the outline takes the accent.
    local folded = self.Minimized or not self.Open
    tween(self._toggleStroke, { Color = folded and Theme.Accent or Theme.Stroke, Transparency = folded and 0.3 or 0 }, 0.35)
    local icon = self._toggleIcon
    tween(icon, { Rotation = folded and 180 or 0 }, 0.5, Enum.EasingStyle.Quint)
    if not icon:GetAttribute("CustomIcon") then
        tween(icon, { ImageColor3 = folded and Theme.Text or Theme.Accent }, 0.35)
    end
end

function Window:_createToggleButton(opts)
    local gui = self.Gui
    local size = tonumber(opts.Size) or (TOUCH and 56 or 50)
    local iconSize = math.floor(size * 0.46)
    self._toggleEnabled = opts.Enabled ~= false
    self._togglePlatform = opts.Platform == "Both" and "Both" or "Mobile"
    self._toggleSize = size
    local button = create("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = opts.Position or UDim2.new(0, 18 + size / 2, 0.5, 0),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 30,
        Parent = gui,
    })
    corner(button, UDim.new(0, 12))
    local buttonStroke = stroke(button, Theme.Stroke)
    local icon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(iconSize, iconSize),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 31,
        Parent = button,
    })
    local buttonScale = create("UIScale", { Parent = button })
    self.ToggleButton = button
    self._toggleStroke = buttonStroke
    self._toggleIcon = icon
    self:SetToggleButtonIcon(opts.Icon or "layout-grid")

    local dragging, moved = false, false
    local grab = Vector2.zero
    button.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            moved = false
            grab = pointerPosition() - button.AbsolutePosition
            tween(buttonScale, { Scale = 0.94 }, 0.18, Enum.EasingStyle.Quint)
        end
    end)
    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging or not isMove(input) then
            return
        end
        local point = pointerPosition() - grab - gui.AbsolutePosition
        if (point - (button.AbsolutePosition - gui.AbsolutePosition)).Magnitude > 3 then
            moved = true
        end
        if moved then
            button.AnchorPoint = Vector2.zero
            button.Position = UDim2.fromOffset(
                math.clamp(point.X, 0, math.max(gui.AbsoluteSize.X - button.AbsoluteSize.X, 0)),
                math.clamp(point.Y, 0, math.max(gui.AbsoluteSize.Y - button.AbsoluteSize.Y, 0))
            )
        end
    end))
    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
        if not dragging or not isPress(input) then
            return
        end
        dragging = false
        tween(buttonScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Quint)
        if moved then
            return
        end
        ripple(button)
        if not self.Open then
            self:Toggle(true)
        elseif self.Minimized then
            self:Restore()
        else
            self:Minimize()
        end
    end))
end

function Window:SetToggleButton(enabled)
    self._toggleEnabled = enabled ~= false
    self:_refreshToggleButton()
end

function Window:SetToggleButtonPlatform(platform)
    self._togglePlatform = platform == "Both" and "Both" or "Mobile"
    self:_refreshToggleButton()
end

function Window:SetToggleButtonIcon(icon)
    local image = self._toggleIcon
    if not image then
        return
    end
    image.Image = ""
    applyIcon(image, icon)
    if image.Image == "" then
        applyIcon(image, Assets.Logo)
    end
    if not image:GetAttribute("CustomIcon") then
        tween(image, { ImageColor3 = (self.Minimized or not self.Open) and Theme.Text or Theme.Accent }, 0)
    end
end

function Window:_enableResize(minSize)
    local maxSize = self.MaxSize or Vector2.new(math.huge, math.huge)
    self._minSize = minSize
    local root = self.Root
    local grip = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 4, 1, 4),
        Size = UDim2.fromOffset(32, 32),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 20,
        Parent = root,
    })
    self._grip = grip
    -- An arc that traces the window's own rounded corner: a rounded square
    -- laid over the corner whose outline fades out away from it, so only the
    -- curve and a short run of each edge show. Faint at rest, accent in use.
    local gripArc = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = grip,
    })
    corner(gripArc, UDim.new(0, 10))
    local gripStroke = create("UIStroke", {
        Color = Theme.Muted,
        Thickness = 2,
        Transparency = 0.55,
        Parent = gripArc,
    })
    create("UIGradient", {
        Rotation = 45,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.55, 1),
            NumberSequenceKeypoint.new(0.85, 0),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = gripStroke,
    })
    local function lightGrip(on)
        tween(gripStroke, {
            Color = on and Theme.Accent or Theme.Muted,
            Transparency = on and 0 or 0.55,
        }, on and 0.15 or 0.3, Enum.EasingStyle.Quint)
    end

    -- The size follows the pointer through a critically damped spring, so it
    -- glides after the cursor and eases to rest when released instead of
    -- snapping. While resizing, the window is anchored at its top-left corner
    -- so only the right and bottom edges move and nothing jitters on half pixels.
    local STIFFNESS = 20
    local resizing = false
    local startSize = Vector2.zero
    local startPointer = Vector2.zero
    local current = Vector2.zero
    local velocity = Vector2.zero
    local target = Vector2.zero
    local applied = Vector2.zero

    local function readSize()
        return Vector2.new(root.Size.X.Offset, root.Size.Y.Offset)
    end

    local function pin()
        if root.AnchorPoint == Vector2.zero then
            return
        end
        -- A clamp tween still writing centre coordinates would fight the new anchor.
        if self._clampTween then
            self._clampTween:Cancel()
            self._clampTween = nil
        end
        local topLeft = root.AbsolutePosition - self.Gui.AbsolutePosition
        root.AnchorPoint = Vector2.zero
        root.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
    end

    local function unpin()
        local topLeft = root.AbsolutePosition - self.Gui.AbsolutePosition
        local half = root.AbsoluteSize / 2
        root.AnchorPoint = Vector2.new(0.5, 0.5)
        root.Position = UDim2.fromOffset(topLeft.X + half.X, topLeft.Y + half.Y)
    end

    local function clampSize(size)
        return Vector2.new(
            math.floor(math.clamp(size.X, minSize.X, maxSize.X) + 0.5),
            math.floor(math.clamp(size.Y, minSize.Y, maxSize.Y) + 0.5)
        )
    end

    grip.InputBegan:Connect(function(input)
        if not isPress(input) or not self.Open then
            return
        end
        if not self._resizeActive then
            pin()
            current = readSize()
            velocity = Vector2.zero
            applied = current
        end
        self._resizeActive = true
        resizing = true
        startSize = current
        startPointer = pointerPosition()
        target = clampSize(startSize)
        lightGrip(true)
    end)
    grip.MouseEnter:Connect(function()
        if not resizing then
            lightGrip(true)
        end
    end)
    grip.MouseLeave:Connect(function()
        if not resizing then
            lightGrip(false)
        end
    end)
    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
        if resizing and isPress(input) then
            resizing = false
            lightGrip(false)
        end
    end))

    table.insert(self._frameSteps, function(deltaTime)
        if not self._resizeActive then
            return
        end
        if resizing then
            local delta = (pointerPosition() - startPointer) / self.Scale.Scale
            target = clampSize(startSize + delta)
        end
        local dt = math.min(deltaTime, 1 / 30)
        local decay = math.exp(-STIFFNESS * dt)
        local offset = current - target
        local drift = (velocity + offset * STIFFNESS) * dt
        velocity = (velocity - drift * STIFFNESS) * decay
        current = target + (offset + drift) * decay

        local rounded = Vector2.new(math.floor(current.X + 0.5), math.floor(current.Y + 0.5))
        if rounded ~= applied then
            applied = rounded
            root.Size = UDim2.fromOffset(rounded.X, rounded.Y)
        end

        if not resizing and (current - target).Magnitude < 0.3 and velocity.Magnitude < 3 then
            current = target
            velocity = Vector2.zero
            applied = target
            root.Size = UDim2.fromOffset(target.X, target.Y)
            unpin()
            self._resizeActive = false
            self:_fitToScreen()
            self:_clampToScreen()
        end
    end)
end

-- The window's own size in pixels, before the UI scale and screen fit.
function Window:GetSize()
    return Vector2.new(self.Root.Size.X.Offset, self.Root.Size.Y.Offset)
end

-- Resizes to an exact size, kept within MinSize and MaxSize. Ignored while the
-- player is dragging the grip.
function Window:SetSize(size, instant)
    if typeof(size) == "UDim2" then
        size = Vector2.new(size.X.Offset, size.Y.Offset)
    end
    if typeof(size) ~= "Vector2" or self._resizeActive then
        return
    end
    local minSize = self._minSize or Vector2.zero
    local maxSize = self.MaxSize or Vector2.new(math.huge, math.huge)
    size = Vector2.new(
        math.floor(math.clamp(size.X, minSize.X, maxSize.X) + 0.5),
        math.floor(math.clamp(size.Y, minSize.Y, maxSize.Y) + 0.5)
    )
    if size == self:GetSize() then
        return
    end
    local duration = (instant or not self.Root.Visible) and 0 or 0.3
    tween(self.Root, { Size = UDim2.fromOffset(size.X, size.Y) }, duration, Enum.EasingStyle.Quint)
    task.delay(duration + 0.02, function()
        if not self._destroyed then
            self:_fitToScreen()
            self:_clampToScreen()
        end
    end)
end

-- Configs are plain JSON, one file per config, in the same shape as a share code:
--   {"Folder":"MyHub","Name":"farm","Version":1,"Config":"{\"AutoFarm\":{\"Value\":true,\"Type\":\"Toggle\"}}"}
-- Config holds the flags as their own JSON string, each one {"Value":...,"Type":...}.
-- Colours are {"Hex":"ff5a5a"}, keybinds are key names, an empty dropdown has no Value.

local CONFIG_VERSION = 1
local LEGACY_SHARE_PREFIX = "airflow:"

local function configPath(self, name)
    return self.ConfigFolder .. "/" .. name .. ".json"
end

local function fileApiAvailable()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

-- Makes every missing folder along the path, so FolderName can be "Hub/Game".
local function ensureFolder(folder)
    if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
        return
    end
    local path = ""
    for segment in tostring(folder):gmatch("[^/\\]+") do
        path = path == "" and segment or path .. "/" .. segment
        if not isfolder(path) then
            makefolder(path)
        end
    end
end

local function colorToHex(color)
    return string.format("%02x%02x%02x",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5))
end

local function colorFromValue(value)
    if type(value) == "table" then
        if type(value.Hex) == "string" then
            value = value.Hex
        elseif type(value[1]) == "number" then
            -- Older configs stored { r, g, b } in 0-1.
            return Color3.new(value[1], value[2] or 0, value[3] or 0)
        end
    end
    if type(value) == "string" then
        local r, g, b = value:match("^%s*#?(%x%x)(%x%x)(%x%x)%s*$")
        if r then
            return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
        end
    end
    return nil
end

local function serializeFlag(element)
    local kind = element._type
    local value = element:Get()
    if type(element._saveValue) == "function" then
        value = element:_saveValue()
    end
    if kind == "Keybind" then
        return { Type = kind, Value = value and value.Name or nil }
    elseif kind == "ColorPicker" then
        return { Type = kind, Value = typeof(value) == "Color3" and { Hex = colorToHex(value) } or nil }
    end
    return { Type = kind, Value = value }
end

local function deserializeFlag(element, entry, silent)
    local kind = element._type
    local value = entry.Value
    if kind == "Keybind" then
        element:Set(type(value) == "string" and Enum.KeyCode[value] or nil, silent)
    elseif kind == "ColorPicker" then
        local color = colorFromValue(value)
        if color then
            element:Set(color, silent)
        end
    elseif kind == "Dropdown" then
        -- A dropdown saved with nothing picked has no Value at all.
        element:Set(value, silent)
    elseif kind == "Toggle" then
        if type(value) == "boolean" then
            element:Set(value, silent)
        end
    elseif kind == "Slider" or kind == "Stepper" or kind == "Progress" then
        local number = tonumber(value)
        if number then
            element:Set(number, silent)
        end
    elseif value ~= nil then
        element:Set(value, silent)
    end
end

local function entryMatches(element, entry)
    return type(entry) == "table" and (entry.Type == nil or entry.Type == element._type)
end

-- Flags a config holds but no element has claimed yet are kept here. They are
-- applied when an element with that flag is created and written back on save,
-- so a config survives elements that only exist some of the time.
local function collectFlags(self)
    local data = {}
    if self and self._pendingFlags then
        for flag, pending in pairs(self._pendingFlags) do
            data[flag] = pending.Entry
        end
    end
    for flag, element in pairs(Library.Flags) do
        if element._type and type(element.Get) == "function" then
            local ok, entry = pcall(serializeFlag, element)
            if ok then
                data[flag] = entry
            end
        end
    end
    return data
end

function Window:_applyFlags(data, silent)
    silent = silent == true
    self._pendingFlags = {}
    for flag, entry in pairs(data) do
        local element = Library.Flags[flag]
        if element and type(element.Set) == "function" then
            if entryMatches(element, entry) then
                pcall(deserializeFlag, element, entry, silent)
            end
        elseif type(entry) == "table" then
            self._pendingFlags[flag] = { Entry = entry, Silent = silent }
        end
    end
end

-- Every flagged element reports here: its starting value becomes its default,
-- and a value waiting from an earlier load is applied once the constructor returns.
function Window:_flagCreated(flag, element)
    local ok, entry = pcall(serializeFlag, element)
    if ok then
        element._defaultEntry = entry
    end
    local pending = self._pendingFlags and self._pendingFlags[flag]
    if not pending then
        return
    end
    task.defer(function()
        if self._pendingFlags[flag] ~= pending or Library.Flags[flag] ~= element or element._destroyed then
            return
        end
        self._pendingFlags[flag] = nil
        if entryMatches(element, pending.Entry) then
            pcall(deserializeFlag, element, pending.Entry, pending.Silent)
        end
    end)
end

-- Anything listening for config changes (the config manager's status line).
function Window:_configChanged()
    for _, handler in ipairs(self._configListeners) do
        safeCall(handler)
    end
end

function Window:OnConfigChanged(handler)
    table.insert(self._configListeners, handler)
    return function()
        local index = table.find(self._configListeners, handler)
        if index then
            table.remove(self._configListeners, index)
        end
    end
end

local function validConfigName(name)
    return type(name) == "string" and name ~= "" and not name:find('[\\/:%*%?"<>|]')
end

local function encodeConfig(self, name, flags)
    return HttpService:JSONEncode({
        Folder = self.ConfigFolder,
        Name = name,
        Version = CONFIG_VERSION,
        Config = HttpService:JSONEncode(flags),
    })
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64_INDEX = {}
for index = 1, #B64 do
    B64_INDEX[B64:byte(index)] = index - 1
end

-- Only for reading the old "airflow:<base64>" share codes.
local function base64Decode(text)
    if #text % 4 ~= 0 then
        return nil
    end
    local out = {}
    for index = 1, #text, 4 do
        local n, pad = 0, 0
        for offset = 0, 3 do
            local byte = text:byte(index + offset)
            local value = B64_INDEX[byte]
            if byte == 61 and index + 3 >= #text then
                pad += 1
                value = 0
            elseif value == nil or pad > 0 then
                return nil
            end
            n = n * 64 + value
        end
        if pad > 2 then
            return nil
        end
        local chunk = string.char(bit32.extract(n, 16, 8), bit32.extract(n, 8, 8), bit32.extract(n, 0, 8))
        table.insert(out, chunk:sub(1, 3 - pad))
    end
    return table.concat(out)
end

-- Reads a config file or a pasted code: the JSON above (Config as a string or
-- a table), a bare flag table, or an old "airflow:" code. Returns flags, info.
local function decodeConfig(text)
    text = tostring(text or ""):match("^%s*(.-)%s*$")
    if text:sub(1, #LEGACY_SHARE_PREFIX) == LEGACY_SHARE_PREFIX then
        text = base64Decode((text:sub(#LEGACY_SHARE_PREFIX + 1):gsub("%s", "")))
        if not text then
            return nil, "invalid config code"
        end
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    if not ok or type(data) ~= "table" then
        return nil, "invalid config code"
    end
    local info = {}
    -- A bare flag table could have a flag named Config, but its entry carries a Type.
    if type(data.Config) == "string" or (type(data.Config) == "table" and data.Config.Type == nil) then
        info.Folder = type(data.Folder) == "string" and data.Folder or nil
        info.Name = type(data.Name) == "string" and data.Name or nil
        info.Version = tonumber(data.Version)
        local flags = data.Config
        if type(flags) == "string" then
            ok, flags = pcall(function()
                return HttpService:JSONDecode(data.Config)
            end)
            if not ok then
                return nil, "invalid config code"
            end
        end
        if type(flags) ~= "table" then
            return nil, "invalid config code"
        end
        data = flags
    end
    for flag, entry in pairs(data) do
        if type(flag) ~= "string" or type(entry) ~= "table" then
            return nil, "invalid config code"
        end
    end
    return data, info
end

local function writeConfig(self, name, data)
    if not validConfigName(name) then
        return false, "invalid config name"
    end
    if not fileApiAvailable() then
        return false, "file API unavailable"
    end
    local encoded, text = pcall(encodeConfig, self, name, data)
    if not encoded then
        return false, "could not encode config"
    end
    ensureFolder(self.ConfigFolder)
    return pcall(writefile, configPath(self, name), text)
end

local function readConfig(self, name)
    if not fileApiAvailable() then
        return nil, "file API unavailable"
    end
    if not validConfigName(name) then
        return nil, "invalid config name"
    end
    local path = configPath(self, name)
    if not isfile(path) then
        return nil, "no config named " .. tostring(name)
    end
    local ok, text = pcall(readfile, path)
    if not ok or type(text) ~= "string" then
        return nil, "could not read " .. name
    end
    local data, info = decodeConfig(text)
    if not data then
        return nil, "config is not valid JSON"
    end
    return data, info
end

function Window:ConfigExists(name)
    return validConfigName(name) and fileApiAvailable() and isfile(configPath(self, name)) or false
end

function Window:SaveConfig(name)
    name = name or self.ConfigName
    if not name then
        return false, "no config name"
    end
    local ok, err = writeConfig(self, name, collectFlags(self))
    if ok then
        self.ConfigName = name
    end
    return ok, err
end

function Window:LoadConfig(name, silent)
    name = name or self.ConfigName
    if not name then
        return false, "no config name"
    end
    local data, err = readConfig(self, name)
    if not data then
        return false, err
    end
    self:_applyFlags(data, silent)
    self.ConfigName = name
    self.LoadedConfig = name
    self:_configChanged()
    return true
end

function Window:DeleteConfig(name)
    if not fileApiAvailable() or type(delfile) ~= "function" then
        return false, "file API unavailable"
    end
    if not validConfigName(name) then
        return false, "invalid config name"
    end
    local path = configPath(self, name)
    if not isfile(path) then
        return false, "no config named " .. name
    end
    local ok, err = pcall(delfile, path)
    if not ok then
        return false, err
    end
    if self.LoadedConfig == name then
        self.LoadedConfig = nil
    end
    self:_configChanged()
    return true
end

-- Moves the file and anything pointing at it: the loaded name and both autoloads.
function Window:RenameConfig(name, newName)
    if not validConfigName(newName) then
        return false, "invalid config name"
    end
    if name == newName then
        return true
    end
    if self:ConfigExists(newName) then
        return false, newName .. " already exists"
    end
    local data, err = readConfig(self, name)
    if not data then
        return false, err
    end
    local ok
    ok, err = writeConfig(self, newName, data)
    if not ok then
        return false, err
    end
    if type(delfile) == "function" then
        pcall(delfile, configPath(self, name))
    end
    if self.LoadedConfig == name then
        self.LoadedConfig = newName
    end
    if self.ConfigName == name then
        self.ConfigName = newName
    end
    for _, scope in ipairs({ "Global", "Account" }) do
        if self:GetAutoload(scope) == name then
            self:SetAutoload(newName, scope)
        end
    end
    self:_configChanged()
    return true
end

function Window:ListConfigs()
    local names = {}
    if type(listfiles) ~= "function" or type(isfolder) ~= "function" or not isfolder(self.ConfigFolder) then
        return names
    end
    local ok, paths = pcall(listfiles, self.ConfigFolder)
    if not ok or type(paths) ~= "table" then
        return names
    end
    for _, path in ipairs(paths) do
        local name = path:match("([^/\\]+)%.json$")
        if name then
            table.insert(names, name)
        end
    end
    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)
    return names
end

-- Puts every flagged element back to the value it was created with.
function Window:ResetConfig(silent)
    self._pendingFlags = {}
    for _, element in pairs(Library.Flags) do
        if element._defaultEntry and type(element.Set) == "function" then
            pcall(deserializeFlag, element, element._defaultEntry, silent == true)
        end
    end
    self:_configChanged()
    return true
end

-- Empties a folder and removes it, one file at a time when the executor has
-- no delfolder or it refuses a folder that still has files in it.
local function wipeFolder(path)
    if type(isfolder) ~= "function" or not isfolder(path) then
        return true
    end
    if type(delfolder) == "function" and pcall(delfolder, path) and not isfolder(path) then
        return true
    end
    if type(listfiles) == "function" then
        local ok, entries = pcall(listfiles, path)
        for _, entry in ipairs(ok and entries or {}) do
            if isfolder(entry) then
                wipeFolder(entry)
            elseif type(delfile) == "function" then
                pcall(delfile, entry)
            end
        end
    end
    if type(delfolder) == "function" then
        pcall(delfolder, path)
    end
    return not isfolder(path)
end

-- Deletes the script's whole workspace folder: configs, themes, the default
-- theme, autoload, settings and the execution count.
function Window:ClearWorkspace()
    local ok = wipeFolder(self.ConfigFolder)
    self.LoadedConfig = nil
    for _, handler in ipairs(self._workspaceListeners or {}) do
        safeCall(handler)
    end
    self:_configChanged()
    return ok
end

-- Share codes are the same JSON a config file holds.

function Window:ExportConfig(name)
    local data, err
    if name then
        data, err = readConfig(self, name)
        if not data then
            return nil, err
        end
    else
        data = collectFlags(self)
        name = self.LoadedConfig or self.ConfigName
    end
    local ok, code = pcall(encodeConfig, self, name, data)
    if not ok then
        return nil, "could not encode config"
    end
    return code
end

-- Reads a code without applying it. Returns flags and { Folder, Name, Version }.
function Window:DecodeConfig(code)
    return decodeConfig(code)
end

-- saveAs: a name to save under, true for the name inside the code, or nil to
-- only apply it. Codes made for another folder are refused unless force is set.
function Window:ImportConfig(code, saveAs, force)
    local data, info = decodeConfig(code)
    if not data then
        return false, info
    end
    if not force and info.Folder and info.Folder ~= self.ConfigFolder then
        return false, "config is for " .. info.Folder
    end
    if saveAs == true then
        saveAs = info.Name
        if not validConfigName(saveAs) then
            return false, "config has no usable name"
        end
    end
    if saveAs then
        local ok, err = writeConfig(self, saveAs, data)
        if not ok then
            return false, err
        end
    end
    self:_applyFlags(data)
    if saveAs then
        self.ConfigName = saveAs
        self.LoadedConfig = saveAs
    end
    self:_configChanged()
    return true, nil, saveAs
end

local function readText(path)
    if not fileApiAvailable() or not isfile(path) then
        return nil
    end
    local ok, text = pcall(readfile, path)
    if ok and type(text) == "string" and text ~= "" then
        return text
    end
    return nil
end

local function removeFile(path)
    if fileApiAvailable() and type(delfile) == "function" and isfile(path) then
        pcall(delfile, path)
    end
end

-- Manager settings (autoload mode) live beside the configs, apart
-- from the flags, so loading a config never changes them.

local function settingsPath(self)
    return self.ConfigFolder .. "/configsettings.txt"
end

function Window:_readConfigSettings()
    local text = readText(settingsPath(self))
    if text then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(text)
        end)
        if ok and type(data) == "table" then
            return data
        end
    end
    return {}
end

function Window:_writeConfigSettings(changes)
    if not fileApiAvailable() then
        return false, "file API unavailable"
    end
    local data = self:_readConfigSettings()
    for key, value in pairs(changes) do
        data[key] = value
    end
    ensureFolder(self.ConfigFolder)
    return pcall(writefile, settingsPath(self), HttpService:JSONEncode(data))
end

-- Autoload: one config name kept next to the configs, either for every
-- account ("Global") or only the local player ("Account").

local function autoloadPath(self, scope)
    if scope == "Account" then
        return self.ConfigFolder .. "/autoload_" .. tostring(LocalPlayer and LocalPlayer.UserId or 0) .. ".txt"
    end
    return self.ConfigFolder .. "/autoload.txt"
end

function Window:GetAutoloadMode()
    return self:_readConfigSettings().AutoloadMode == "Account" and "Account" or "Global"
end

function Window:GetAutoload(scope)
    if scope then
        return readText(autoloadPath(self, scope))
    end
    return readText(autoloadPath(self, "Account")) or readText(autoloadPath(self, "Global"))
end

function Window:SetAutoload(name, scope)
    if not fileApiAvailable() then
        return false, "file API unavailable"
    end
    scope = scope or self:GetAutoloadMode()
    local ok, err = true, nil
    if name == nil or name == "" then
        removeFile(autoloadPath(self, scope))
        if scope == "Global" then
            removeFile(autoloadPath(self, "Account"))
        end
    else
        ensureFolder(self.ConfigFolder)
        ok, err = pcall(writefile, autoloadPath(self, scope), tostring(name))
        if ok and scope == "Global" then
            removeFile(autoloadPath(self, "Account"))
        end
    end
    self:_configChanged()
    return ok, err
end

-- Switching the mode moves the current autoload so only one stays active.
function Window:SetAutoloadMode(mode)
    mode = mode == "Account" and "Account" or "Global"
    if mode == self:GetAutoloadMode() then
        return true
    end
    local current = self:GetAutoload()
    local ok, err = self:_writeConfigSettings({ AutoloadMode = mode })
    if not ok then
        return false, err
    end
    removeFile(autoloadPath(self, mode == "Account" and "Global" or "Account"))
    if current then
        return self:SetAutoload(current, mode)
    end
    self:_configChanged()
    return true
end

function Window:LoadAutoload(silent)
    local name = self:GetAutoload()
    if not name then
        return false, "no autoload config"
    end
    return self:LoadConfig(name, silent)
end

-- Themes

Library._themeListeners = {}

local function toColor(value)
    if typeof(value) == "Color3" then
        return value
    elseif type(value) == "string" then
        local r, g, b = value:match("^%s*#?(%x%x)(%x%x)(%x%x)%s*$")
        if r then
            return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
        end
    elseif type(value) == "table" then
        local r, g, b = value[1] or value.R, value[2] or value.G, value[3] or value.B
        if tonumber(r) and tonumber(g) and tonumber(b) then
            return Color3.fromRGB(r, g, b)
        end
    end
    return nil
end

local function hexOf(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5))
end

-- Coloured text for statuses, metrics, table cells and labels. A theme key
-- used as a tag, <Success>online</Success>, follows theme changes; plain
-- rich text such as <font color="#ff5a5a"> works too. Library.Colorize wraps
-- text for you. Table fields, not locals: the chunk is at Luau's 200 limit.
Library._toneTags = {}
for _, name in ipairs(THEME_KEYS) do
    Library._toneTags[string.lower(name)] = name
end

-- A theme key, a Color3, "#rrggbb" or { r, g, b } as a Color3.
function Library._color(value)
    if type(value) == "string" then
        local key = Library._toneTags[string.lower(value)]
        if key then
            return Theme[key]
        end
    end
    return toColor(value)
end

function Library._rich(text)
    text = tostring(text == nil and "" or text)
    if not string.find(text, "<", 1, true) then
        return text
    end
    return (string.gsub(text, "<(/?)(%a+%d*)>", function(slash, name)
        local key = Library._toneTags[string.lower(name)]
        if not key then
            return nil
        end
        if slash == "/" then
            return "</font>"
        end
        return '<font color="' .. hexOf(Theme[key]) .. '">'
    end))
end

-- Library.Colorize("12 ms", "Success") or Library:Colorize(text, Color3).
function Library.Colorize(...)
    local args = { ... }
    if args[1] == Library then
        table.remove(args, 1)
    end
    local text, color = tostring(args[1] == nil and "" or args[1]), args[2]
    local key = type(color) == "string" and Library._toneTags[string.lower(color)]
    if key then
        return "<" .. key .. ">" .. text .. "</" .. key .. ">"
    end
    local resolved = toColor(color)
    if not resolved then
        return text
    end
    return '<font color="' .. hexOf(resolved) .. '">' .. text .. "</font>"
end

-- The window's corner radius in pixels, 0 (square) to 20; every other
-- rounded corner scales with it. The default is 10. Corners ease to the new
-- radius instead of jumping. Returns the radius it settled on.
function Library:SetCornerRadius(pixels, instant)
    pixels = math.clamp(math.floor((tonumber(pixels) or 10) + 0.5), 0, 20)
    Library.Roundness = pixels / 10
    for object, base in pairs(Library._cornerBases) do
        if not object.Parent then
            Library._cornerBases[object] = nil
        else
            local radius = UDim.new(0, math.floor(base * Library.Roundness + 0.5))
            if instant then
                object.CornerRadius = radius
            else
                tween(object, { CornerRadius = radius }, 0.25, Enum.EasingStyle.Quint)
            end
        end
    end
    return pixels
end

function Library:GetCornerRadius()
    return math.floor(Library.Roundness * 10 + 0.5)
end

function Library:SetTheme(theme, instant)
    if type(theme) == "string" then
        local found = Library.ThemePresets[theme]
        if not found then
            return false
        end
        Library.ThemeName = theme
        theme = found
    elseif type(theme) ~= "table" then
        return false
    end
    local changed = false
    for _, name in ipairs(THEME_KEYS) do
        local color = toColor(theme[name])
        if color and color ~= Theme[name] then
            Theme[name] = color
            changed = true
        end
    end
    if not changed then
        return true
    end
    rebuildThemeLookup()
    sweepBindings()
    driveTheme(instant and 0 or 0.3)
    for owner, fn in pairs(themeHooks) do
        if owner.Parent then
            pcall(fn)
        end
    end
    for _, fn in ipairs(Library._themeListeners) do
        pcall(fn)
    end
    return true
end

function Library:GetTheme()
    local copy = {}
    for _, name in ipairs(THEME_KEYS) do
        copy[name] = Theme[name]
    end
    return copy
end

-- The script's starting theme: a preset name or a colour table. A default the
-- player picked in the theme manager still wins over it.
function Library:SetDefaultTheme(theme)
    Library.DefaultTheme = theme
    if theme == nil then
        return true
    end
    local live = false
    for _, window in ipairs(Library.Windows) do
        if not window._destroyed then
            if window:GetDefaultTheme() then
                return true
            end
            live = true
        end
    end
    return Library:SetTheme(theme, not live)
end

function Library:GetDefaultTheme()
    return Library.DefaultTheme
end

local function themeFolder(self)
    return self.ConfigFolder .. "/themes"
end

function Window:SaveTheme(name)
    if not fileApiAvailable() then
        return false, "file API unavailable"
    end
    if type(name) ~= "string" or name == "" then
        return false, "theme needs a name"
    end
    ensureFolder(self.ConfigFolder)
    ensureFolder(themeFolder(self))
    local data = {}
    for _, key in ipairs(THEME_KEYS) do
        data[key] = hexOf(Theme[key])
    end
    return pcall(function()
        writefile(themeFolder(self) .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
end

function Window:LoadTheme(name, instant)
    if Library.ThemePresets[name] then
        return Library:SetTheme(name, instant)
    end
    local text = readText(themeFolder(self) .. "/" .. tostring(name) .. ".json")
    if not text then
        return false, "no theme named " .. tostring(name)
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    if not ok or type(data) ~= "table" then
        return false, "theme is not valid JSON"
    end
    Library.ThemeName = name
    return Library:SetTheme(data, instant)
end

function Window:DeleteTheme(name)
    if not fileApiAvailable() or type(delfile) ~= "function" then
        return false, "file API unavailable"
    end
    local path = themeFolder(self) .. "/" .. tostring(name) .. ".json"
    if not isfile(path) then
        return false, "no theme named " .. tostring(name)
    end
    delfile(path)
    if self:GetDefaultTheme() == name then
        self:SetDefaultTheme(nil)
    end
    return true
end

function Window:ListThemes()
    local names = {}
    if type(listfiles) ~= "function" or type(isfolder) ~= "function" or not isfolder(themeFolder(self)) then
        return names
    end
    for _, path in ipairs(listfiles(themeFolder(self))) do
        local name = path:match("([^/\\]+)%.json$")
        if name then
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

function Window:GetDefaultTheme()
    return readText(themeFolder(self) .. "/default.txt")
end

function Window:SetDefaultTheme(name)
    if not fileApiAvailable() then
        return false, "file API unavailable"
    end
    ensureFolder(self.ConfigFolder)
    ensureFolder(themeFolder(self))
    local path = themeFolder(self) .. "/default.txt"
    if name == nil or name == "" then
        if isfile(path) and type(delfile) == "function" then
            pcall(delfile, path)
        end
        return true
    end
    return pcall(writefile, path, tostring(name))
end

function Window:_applyDefaultTheme()
    local name = self:GetDefaultTheme()
    if name then
        local ok, loaded = pcall(self.LoadTheme, self, name, true)
        if ok and loaded then
            return
        end
    end
    if Library.DefaultTheme ~= nil then
        pcall(Library.SetTheme, Library, Library.DefaultTheme, true)
    end
end

-- Background images

-- Image assets anyone can use, from Fluent-modded's themes.
Library.BackgroundPresets = {
    ["Deep Violet"] = "rbxassetid://136310484943077",
    ["Blood Red"] = "rbxassetid://121343473918667",
    ["Cyanic"] = "rbxassetid://95656189244173",
    ["Amber Glow"] = "rbxassetid://107795771598485",
    ["Bloomings"] = "rbxassetid://133541508207801",
    ["Lavender Pink"] = "rbxassetid://126107479485287",
}
Library.BackgroundPresetOrder = { "Deep Violet", "Blood Red", "Cyanic", "Amber Glow", "Bloomings", "Lavender Pink" }

-- Table fields, not locals: the library chunk is at Luau's 200 local limit.
Library._imageExtensions = { png = true, jpg = true, jpeg = true, webp = true, gif = true, bmp = true }

function Window:_backgroundFolder()
    return self.ConfigFolder .. "/backgrounds"
end

function Window:_trimBackground(source)
    return (tostring(source or ""):match("^%s*(.-)%s*$"))
end

-- Turns a background source into something ImageLabel.Image takes. Web images
-- are downloaded once into backgrounds/cache and loaded with getcustomasset,
-- so this yields the first time a URL is used.
function Window:_resolveBackground(source)
    source = self:_trimBackground(source)
    local preset = Library.BackgroundPresets[source]
    if preset then
        return preset
    end
    if source:match("^%d+$") then
        return "rbxassetid://" .. source
    end
    if source:match("^rbxassetid://%d+") or source:match("^rbxasset://") or source:match("^rbxthumb://")
        or source:match("^https?://www%.roblox%.com/asset") then
        return source
    end
    local canLoad = fileApiAvailable() and typeof(getcustomasset) == "function"
    if source:match("^https?://") then
        if not canLoad then
            return nil, "web images need writefile and getcustomasset"
        end
        local clean = source:match("^[^?#]+") or source
        local ext = (clean:match("%.(%w+)$") or "png"):lower()
        if not Library._imageExtensions[ext] then
            ext = "png"
        end
        local key = (clean:gsub("^https?://", ""):gsub("[^%w]", "_")):sub(-60)
        local folder = self:_backgroundFolder() .. "/cache"
        local path = folder .. "/" .. key .. "_" .. #source .. "." .. ext
        if not isfile(path) then
            local ok, body = pcall(function()
                local request = (syn and syn.request) or http_request or request
                if request then
                    local response = request({ Url = source, Method = "GET" })
                    return response and response.Body
                end
                return game:HttpGet(source, true)
            end)
            if not ok or type(body) ~= "string" or #body < 128 then
                return nil, "could not download the image"
            end
            local head = body:sub(1, 64):lower()
            if head:find("<!doctype") or head:find("<html") then
                return nil, "that link is a web page, not an image"
            end
            ensureFolder(folder)
            if not pcall(writefile, path, body) then
                return nil, "could not save the image"
            end
        end
        local ok, asset = pcall(getcustomasset, path)
        if ok and type(asset) == "string" and asset ~= "" then
            return asset
        end
        pcall(delfile, path)
        return nil, "the downloaded file is not an image"
    end
    -- A file in the backgrounds folder, or any path in the workspace.
    if canLoad then
        for _, path in ipairs({ self:_backgroundFolder() .. "/" .. source, source }) do
            if isfile(path) then
                local ok, asset = pcall(getcustomasset, path)
                if ok and type(asset) == "string" and asset ~= "" then
                    return asset
                end
                return nil, "could not load " .. source
            end
        end
    end
    return nil, "no image called " .. source
end

-- source: a preset name, an image asset id, an rbxassetid:// link, an http(s)
-- image URL, or an image file in <ConfigFolder>/backgrounds. nil or "None"
-- removes it. May yield while a web image downloads.
function Window:SetBackground(source)
    self._backgroundGeneration += 1
    local generation = self._backgroundGeneration
    local image = self._backgroundImage
    source = source ~= false and self:_trimBackground(source) or ""
    if source == "" or source == "None" then
        self.Background = nil
        tween(image, { ImageTransparency = 1 }, 0.25)
        task.delay(0.25, function()
            if self._backgroundGeneration == generation then
                image.Visible = false
                image.Image = ""
            end
        end)
        self:SetTransparent(self.Transparent)
        return true
    end
    local asset, err = self:_resolveBackground(source)
    if self._backgroundGeneration ~= generation or self._destroyed then
        return false, "replaced by a newer background"
    end
    if not asset then
        return false, err
    end
    self.Background = source
    image.Image = asset
    image.Visible = true
    tween(image, { ImageTransparency = self.BackgroundTransparency }, 0.3)
    self:SetTransparent(self.Transparent)
    return true
end

function Window:GetBackground()
    return self.Background
end

-- 0 shows the image fully, 1 hides it behind the theme background colour.
function Window:SetBackgroundTransparency(value)
    self.BackgroundTransparency = math.clamp(tonumber(value) or 0.35, 0, 1)
    if self.Background then
        tween(self._backgroundImage, { ImageTransparency = self.BackgroundTransparency }, 0.15)
    end
end

-- Preset names, then the image files in <ConfigFolder>/backgrounds.
function Window:ListBackgrounds()
    local names = table.clone(Library.BackgroundPresetOrder)
    local folder = self:_backgroundFolder()
    if type(listfiles) == "function" and type(isfolder) == "function" and isfolder(folder) then
        local files = {}
        for _, path in ipairs(listfiles(folder)) do
            local name = path:match("([^/\]+)$")
            local ext = name and name:match("%.(%w+)$")
            if ext and Library._imageExtensions[ext:lower()] then
                table.insert(files, name)
            end
        end
        table.sort(files)
        for _, name in ipairs(files) do
            table.insert(names, name)
        end
    end
    return names
end

local function emptyState(parent, icon, text)
    local holder = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -10),
        Size = UDim2.fromOffset(200, 70),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local image = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ImageTransparency = 0.15,
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    applyIcon(image, icon)
    local caption = label({
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 16),
        Text = text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = holder,
    })
    return holder, caption, image
end

local function fadeSlideIn(group, restY)
    restY = restY or 0
    group.GroupTransparency = 1
    group.Position = UDim2.fromOffset(0, restY + 14)
    group.Visible = true
    tween(group, { GroupTransparency = 0, Position = UDim2.fromOffset(0, restY) }, 0.32, Enum.EasingStyle.Quint)
end

local function formatDuration(seconds)
    seconds = math.max(math.floor(seconds), 0)
    local days = math.floor(seconds / 86400)
    local hours = math.floor(seconds / 3600) % 24
    local minutes = math.floor(seconds / 60) % 60
    if days > 0 then
        return string.format("%dd %dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, seconds % 60)
    end
    return string.format("%ds", seconds)
end

local function shortId(id)
    if type(id) ~= "string" or id == "" then
        return "Studio"
    end
    if #id > 16 then
        return id:sub(1, 8) .. "..." .. id:sub(-4)
    end
    return id
end

local function copyToClipboard(text)
    local setter = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if type(setter) ~= "function" then
        return false
    end
    return (pcall(setter, tostring(text)))
end

local function fetchServers(order)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100&excludeFullGames=true",
        game.PlaceId,
        order
    )
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(body) ~= "string" then
        return nil
    end
    local decoded, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not decoded or type(data) ~= "table" or type(data.data) ~= "table" then
        return nil
    end
    return data.data
end

-- Small on/off pill used on the home card for the privacy switches.
local function miniSwitch(parent, initial, order, callback)
    local pill = create("TextButton", {
        Size = UDim2.fromOffset(30, 16),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        Parent = parent,
    })
    corner(pill, UDim.new(1, 0))
    stroke(pill)
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = Theme.Muted,
        BorderSizePixel = 0,
        Parent = pill,
    })
    corner(knob, UDim.new(1, 0))
    local on = initial == true
    local function render(animate)
        local duration = animate and 0.22 or 0
        tween(pill, { BackgroundColor3 = on and Theme.Accent or Theme.Surface3 }, duration)
        tween(knob, {
            Position = on and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BackgroundColor3 = on and Theme.AccentDark or Theme.Muted,
        }, duration, Enum.EasingStyle.Back)
    end
    pill.MouseButton1Click:Connect(function()
        on = not on
        render(true)
        safeCall(callback, on)
    end)
    render(false)
    return pill
end

local function softButton(parent, text, props, callback)
    local button = create("TextButton", {
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = parent,
    })
    for key, value in pairs(props) do
        button[key] = value
    end
    corner(button, UDim.new(0, 6))
    local buttonStroke = stroke(button)
    local text_ = label({
        Size = UDim2.fromScale(1, 1),
        Text = text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = button,
    })
    if button.AutomaticSize == Enum.AutomaticSize.X then
        text_.Size = UDim2.new(0, 0, 1, 0)
        text_.AutomaticSize = Enum.AutomaticSize.X
        text_.TextTruncate = Enum.TextTruncate.None
        padding(button, 14, 14)
    end
    button.MouseEnter:Connect(function()
        tween(button, { BackgroundTransparency = 0.15 }, 0.12)
        tween(buttonStroke, { Color = Theme.StrokeHover }, 0.12)
    end)
    button.MouseLeave:Connect(function()
        tween(button, { BackgroundTransparency = 0.45 }, 0.25)
        tween(buttonStroke, { Color = Theme.Stroke }, 0.25)
    end)
    button.MouseButton1Click:Connect(function()
        ripple(button)
        safeCall(callback)
    end)
    return button, text_
end

local function panelCard(parent, height, order)
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = parent,
    })
    frame:SetAttribute("NoDrag", true)
    corner(frame, UDim.new(0, 10))
    stroke(frame)
    return frame
end

local STAT_TYPES = {
    Players = { "users", "Players" },
    Friends = { "user-check", "Friends" },
    Execs = { "zap", "Execs" },
    Session = { "timer", "Session" },
    Uptime = { "timer", "Session" },
    FPS = { "gauge", "FPS" },
    Ping = { "wifi", "Ping" },
    Executor = { "terminal", "Executor" },
    Game = { "gamepad-2", "Game" },
    Region = { "globe", "Region" },
    Time = { "clock", "Time" },
    ServerAge = { "server", "Server age" },
    Memory = { "cpu", "Memory" },
}

-- Health colour for a live metric: Success under good, Warning under bad,
-- Error past it. lowerIsBetter flips the scale (ping, memory).
function Library._healthColor(value, good, bad, lowerIsBetter)
    if type(value) ~= "number" then
        return Theme.Text
    end
    if lowerIsBetter then
        return value <= good and Theme.Success or value <= bad and Theme.Warning or Theme.Error
    end
    return value >= good and Theme.Success or value >= bad and Theme.Warning or Theme.Error
end

local function bumpExecutions(folder)
    if not fileApiAvailable() then
        return nil
    end
    local path = folder .. "/executions.txt"
    local count = 0
    pcall(function()
        ensureFolder(folder)
        if isfile(path) then
            count = tonumber(readfile(path)) or 0
        end
    end)
    count += 1
    pcall(writefile, path, tostring(count))
    return count
end

-- Containers: a tab or sub tab owns a scrolling list. Elements added straight
-- to it stack full width, groupboxes go into two columns underneath.

local function buildContainer(owner, parent, top, emptyIcon, emptyText)
    local list = create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, top),
        Size = UDim2.new(1, 0, 1, -top),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Parent = parent,
    })
    Library._space(padding(list, 24, 24, 2, 24), { 24, 24, 2, 24 })
    Library._space(create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = list,
    }), 8)
    owner.List = list
    owner._items = {}
    owner._groupboxes = {}
    owner._childCount = 0
    owner._emptyText = emptyText
    owner._empty, owner._emptyCaption = emptyState(parent, emptyIcon, emptyText)
    list.ChildAdded:Connect(function(child)
        if child:IsA("GuiObject") then
            owner._childCount += 1
            owner:_refreshEmpty()
        end
    end)
    list.ChildRemoved:Connect(function(child)
        if child:IsA("GuiObject") then
            owner._childCount = math.max(owner._childCount - 1, 0)
            owner:_refreshEmpty()
        end
    end)
    owner:_refreshEmpty()
    return list
end

function Tab:_refreshEmpty()
    local empty = self._empty
    if not empty then
        return
    end
    if self._subTabs then
        empty.Visible = false
    else
        empty.Visible = self._childCount == 0
    end
end

function Tab:_columns()
    if self._columnSet then
        return self._columnSet
    end
    local holder = create("Frame", {
        Name = "Columns",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 100000,
        Parent = self.List,
    })
    local layout = Library._space(create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = holder,
    }), 10)
    local function column(order)
        local frame = create("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = order,
            Parent = holder,
        })
        Library._space(create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = frame,
        }), 10)
        return frame
    end
    local set = { Holder = holder, Left = column(1), Right = column(2), Counts = { 0, 0 }, Stacked = false }
    local window = self.Window
    -- Narrow windows stack the right column under the left one.
    local function relayout()
        local width = holder.AbsoluteSize.X / window.Scale.Scale
        if width <= 0 then
            return
        end
        local stacked = width < STACK_BELOW
        local gap = layout.Padding.Offset
        if stacked == set.Stacked and gap == set.Gap then
            return
        end
        set.Stacked = stacked
        set.Gap = gap
        layout.FillDirection = stacked and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
        local size = stacked and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -gap / 2, 0, 0)
        set.Left.Size = size
        set.Right.Size = size
    end
    holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
    layout:GetPropertyChangedSignal("Padding"):Connect(relayout)
    task.defer(relayout)
    self._columnSet = set
    return set
end

function Tab:Groupbox(opts, icon)
    if self._groupbox then
        return self.Parent:Groupbox(opts, icon)
    end
    opts = normalize(opts, { Title = "Name" })
    if icon ~= nil and opts.Icon == nil then
        opts.Icon = icon
    end
    local window = self.Window
    local set = self:_columns()
    local side = opts.Side
    if side == "Left" or side == 1 then
        side = 1
    elseif side == "Right" or side == 2 then
        side = 2
    else
        side = set.Counts[1] <= set.Counts[2] and 1 or 2
    end
    set.Counts[side] += 1

    local box = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = set.Counts[side],
        Parent = side == 1 and set.Left or set.Right,
    })
    box:SetAttribute("NoDrag", true)
    corner(box, UDim.new(0, 10))
    stroke(box)
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = box,
    })

    -- The header is a filled strip: icon and bold title on the left, a
    -- chevron on the right. Pressing anywhere on it folds the box.
    local header = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = box,
    })
    corner(header, UDim.new(0, 10))
    -- Squares the strip's lower corners so it meets the body flat.
    local headerFill = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = header,
    })
    local titleX = 14
    if opts.Icon then
        local headerIcon = create("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Accent,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 2,
            Parent = header,
        })
        applyIcon(headerIcon, opts.Icon)
        titleX = 37
    end
    local collapseButton = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 2,
        Parent = header,
    })
    applyIcon(collapseButton, "chevron-down")
    -- Beside the chevron, a button that pops the box out into a floating
    -- panel (and docks it back once it's out). PopOut = false leaves it off.
    local canPop = opts.PopOut ~= false
    local popButton, popIcon
    if canPop then
        popButton = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -34, 0.5, 0),
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = Theme.Surface2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = header,
        })
        corner(popButton, UDim.new(0, 6))
        popIcon = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(13, 13),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Muted,
            ImageTransparency = TOUCH and 0 or 0.45,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 3,
            Parent = popButton,
        })
        applyIcon(popIcon, "picture-in-picture-2")
    end
    local title = label({
        Position = UDim2.fromOffset(titleX, 0),
        Size = UDim2.new(1, -(titleX + (canPop and 66 or 40)), 1, 0),
        Text = opts.Name or "Groupbox",
        TextSize = 13,
        FontFace = Fonts.Bold,
        ZIndex = 2,
        Parent = header,
    })

    local rule = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Parent = box,
    })
    local body = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        LayoutOrder = 3,
        Parent = box,
    })
    local inner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = body,
    })
    Library._space(padding(inner, 0, 0, 6, 8), { 0, 0, 6, 8 })
    Library._space(create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = inner,
    }), 2)

    local group = setmetatable({
        Name = opts.Name or "Groupbox",
        Window = window,
        Parent = self,
        List = inner,
        Frame = box,
        _frame = box,
        _order = 0,
        _groupbox = true,
        _metrics = METRICS.Row,
        _items = {},
    }, Tab)
    table.insert(self._groupboxes, group)

    local collapsed = false
    local generation = 0
    local function setCollapsed(value, instant)
        value = value == true
        if value == collapsed then
            return
        end
        collapsed = value
        generation += 1
        local current = generation
        local duration = instant and 0 or 0.32
        -- Anything open inside the box (a dropdown list, a picker, a focused
        -- box) closes with it, rather than floating over a folded header.
        if value then
            for _, element in ipairs(group._items) do
                if element._onHide then
                    element._onHide()
                end
                if element.Open and type(element.SetOpen) == "function" then
                    element:SetOpen(false)
                end
            end
        end
        window._controlsDirty = true
        local scale = window.Scale.Scale
        if value then
            body.AutomaticSize = Enum.AutomaticSize.None
            body.Size = UDim2.new(1, 0, 0, body.AbsoluteSize.Y / scale)
            tween(body, { Size = UDim2.new(1, 0, 0, 0) }, duration, Enum.EasingStyle.Quint)
        else
            tween(body, { Size = UDim2.new(1, 0, 0, inner.AbsoluteSize.Y / scale) }, duration, Enum.EasingStyle.Quint)
            local function settle()
                if generation == current and not collapsed then
                    body.AutomaticSize = Enum.AutomaticSize.Y
                    body.Size = UDim2.new(1, 0, 0, 0)
                end
            end
            if duration > 0 then
                task.delay(duration, settle)
            else
                settle()
            end
        end
        local motion = instant and 0 or 0.3
        -- Folded, the strip is the whole box: the hairline under it drops out
        -- of the layout once the body has closed, so the box ends exactly at
        -- the strip and both share the same rounded corners.
        if value then
            local function fold()
                if generation == current and collapsed then
                    rule.Visible = false
                    headerFill.Visible = false
                end
            end
            if duration > 0 then
                task.delay(duration, fold)
            else
                fold()
            end
        else
            rule.Visible = true
            headerFill.Visible = true
        end
        tween(collapseButton, { Rotation = value and -90 or 0 }, motion, Enum.EasingStyle.Quint)
    end

    local function hover(on)
        local duration = on and 0.15 or 0.25
        tween(collapseButton, { ImageColor3 = on and Theme.Text or Theme.Muted }, duration)
        if popIcon and not TOUCH then
            tween(popIcon, { ImageTransparency = on and 0 or 0.45 }, duration)
        end
    end
    header.MouseEnter:Connect(function()
        hover(true)
    end)
    header.MouseLeave:Connect(function()
        hover(false)
    end)
    local isTap = tapGuard(header, function()
        return box:FindFirstAncestorWhichIsA("ScrollingFrame")
    end)
    -- Popping out: the box itself is lifted out of its column into a panel
    -- on the window's pop-out layer, and a slot holds its place in the column
    -- (pressing the slot docks it back). The header drags the panel; a drop
    -- is clamped on screen and the spot is remembered for the next pop-out.
    local popped, popGeneration = false, 0
    local panel, panelScale, panelShadow, slot, stopPanel
    local dragStart, dragOrigin, dragMoved, suppressClick = nil, nil, false, false
    local animating = false

    local function layerScale()
        return math.max(window.Scale.Scale, 0.05)
    end
    local function toLayer(point)
        return (point - window._popLayer.AbsolutePosition) / layerScale()
    end
    -- Keeps a panel's top-centre spot on screen, header always reachable.
    local function clampSpot(spot, width, height)
        local view = window._popLayer.AbsoluteSize / layerScale()
        local margin = 8
        local x = math.clamp(spot.X, width / 2 + margin, math.max(view.X - width / 2 - margin, width / 2 + margin))
        local y = math.clamp(spot.Y, margin, math.max(view.Y - math.min(height, 120) - margin, margin))
        return Vector2.new(x, y)
    end
    local function closeInner()
        for _, element in ipairs(group._items) do
            if element._onHide then
                element._onHide()
            end
            if element.Open and type(element.SetOpen) == "function" then
                element:SetOpen(false)
            end
        end
    end
    local function setPopIcon(out)
        if popIcon then
            applyIcon(popIcon, out and "minimize-2" or "picture-in-picture-2")
        end
    end

    local function popOut()
        if popped or not canPop or not box.Parent or group._destroyed then
            return
        end
        -- A dock still in flight lands first, so the box is back in its column.
        if group._settleDock then
            group._settleDock()
        end
        local layer = window:_popoutLayer()
        popped = true
        group._popped = true
        popGeneration += 1
        local current = popGeneration
        closeInner()
        window:_closePopups()
        local scale = layerScale()
        local column = box.Parent
        local from = toLayer(box.AbsolutePosition)
        local width = box.AbsoluteSize.X / scale
        local height = box.AbsoluteSize.Y / scale

        -- The slot left behind: starts at the box's height so nothing below
        -- jumps, then eases down to a slim bar.
        slot = create("TextButton", {
            Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = Theme.Surface2,
            BackgroundTransparency = 0.6,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true,
            LayoutOrder = box.LayoutOrder,
            Parent = column,
        })
        slot:SetAttribute("NoDrag", true)
        corner(slot, UDim.new(0, 10))
        stroke(slot, Theme.Stroke, 1).Transparency = 0.3
        local slotLabel = label({
            Size = UDim2.new(1, -24, 0, 40),
            Position = UDim2.fromOffset(12, 0),
            Text = Library._rich(group.Name) .. '<font transparency="0.4">  ·  popped out, click to dock</font>',
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Center,
            RichText = true,
            TextTransparency = 1,
            Parent = slot,
        })
        local thisSlot = slot
        slot.MouseEnter:Connect(function()
            tween(thisSlot, { BackgroundTransparency = 0.35 }, 0.15)
        end)
        slot.MouseLeave:Connect(function()
            tween(thisSlot, { BackgroundTransparency = 0.6 }, 0.25)
        end)
        slot.MouseButton1Click:Connect(function()
            if slot == thisSlot then
                group:Dock()
            end
        end)
        tween(slot, { Size = UDim2.new(1, 0, 0, 40) }, 0.42, Enum.EasingStyle.Quint)
        tween(slotLabel, { TextTransparency = 0 }, 0.3)
        slot.Visible = box.Visible

        panel = create("Frame", {
            Name = "PopOut",
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromOffset(from.X + width / 2, from.Y),
            Size = UDim2.fromOffset(width, height),
            BackgroundTransparency = 1,
            Parent = layer,
        })
        panel:SetAttribute("NoDrag", true)
        panelScale = create("UIScale", { Parent = panel })
        panelShadow = create("ImageLabel", {
            Position = UDim2.fromOffset(-24, -18),
            Size = UDim2.new(1, 48, 1, 44),
            BackgroundTransparency = 1,
            Image = Assets.Shadow,
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = 0,
            Parent = panel,
        })
        table.insert(window._popPanels, panel)
        box.Parent = panel
        window._controlsDirty = true
        setPopIcon(true)

        -- Lifts off the column: a spring up and out to its float spot, with
        -- the shadow deepening under it.
        local spot = clampSpot(group._popSpot or Vector2.new(from.X + width / 2 + 22, from.Y - 14), width, height)
        animating = true
        panelScale.Scale = 0.97
        tween(panel, { Position = UDim2.fromOffset(spot.X, spot.Y) }, 0.5, Enum.EasingStyle.Quint)
        tween(panelScale, { Scale = 1 }, 0.55, Enum.EasingStyle.Back)
        tween(panelShadow, { ImageTransparency = 0.35 }, 0.4)
        task.delay(0.5, function()
            if popGeneration == current then
                animating = false
            end
        end)

        -- Each frame: the panel follows the box's height (folding, rows
        -- coming and going), mirrors its visibility, and stays on screen.
        local thisPanel = panel
        stopPanel = window:_listen("Render", function()
            if panel ~= thisPanel or not thisPanel.Parent then
                return
            end
            local boxHeight = box.AbsoluteSize.Y / layerScale()
            if math.abs(thisPanel.Size.Y.Offset - boxHeight) > 0.5 then
                thisPanel.Size = UDim2.fromOffset(thisPanel.Size.X.Offset, boxHeight)
            end
            thisPanel.Visible = box.Visible
            if slot then
                slot.Visible = box.Visible
            end
            if not animating and not dragStart then
                local position = Vector2.new(thisPanel.Position.X.Offset, thisPanel.Position.Y.Offset)
                local clamped = clampSpot(position, thisPanel.Size.X.Offset, boxHeight)
                if (clamped - position).Magnitude > 0.5 then
                    thisPanel.Position = UDim2.fromOffset(clamped.X, clamped.Y)
                end
            end
        end)
    end

    local function dock(instant)
        if not popped then
            return
        end
        popped = false
        group._popped = false
        popGeneration += 1
        dragStart, dragMoved, suppressClick = nil, false, false
        closeInner()
        window:_closePopups()
        local oldPanel, oldSlot, oldStop, oldScale, oldShadow = panel, slot, stopPanel, panelScale, panelShadow
        panel, slot, stopPanel = nil, nil, nil
        setPopIcon(false)
        group._popSpot = Vector2.new(oldPanel.Position.X.Offset, oldPanel.Position.Y.Offset)
        local settled = false
        local function settle()
            if settled then
                return
            end
            settled = true
            if group._settleDock == settle then
                group._settleDock = nil
            end
            if oldStop then
                oldStop()
            end
            local index = table.find(window._popPanels, oldPanel)
            if index then
                table.remove(window._popPanels, index)
            end
            -- Back into the column, unless it was popped again meanwhile.
            if box.Parent == oldPanel then
                if oldSlot and oldSlot.Parent and not group._destroyed then
                    box.Parent = oldSlot.Parent
                    box.LayoutOrder = oldSlot.LayoutOrder
                end
            end
            if oldSlot then
                oldSlot:Destroy()
            end
            if box.Parent ~= oldPanel then
                oldPanel:Destroy()
            end
            animating = false
            window._controlsDirty = true
        end
        group._settleDock = settle
        -- Flies home only when its slot is on screen; otherwise (another tab,
        -- the window hidden) it just drops back into place.
        local canFly = not instant and oldSlot and oldSlot.Parent and window.Root.Visible and box.Visible
            and oldSlot.AbsoluteSize.X > 0 and isShown(oldSlot, window.Body, oldSlot.AbsolutePosition + oldSlot.AbsoluteSize / 2)
        if not canFly then
            settle()
            return
        end
        animating = true
        local scale = layerScale()
        local height = box.AbsoluteSize.Y / scale
        local width = oldSlot.AbsoluteSize.X / scale
        tween(oldSlot, { Size = UDim2.new(1, 0, 0, height) }, 0.36, Enum.EasingStyle.Quint)
        local oldLabel = oldSlot:FindFirstChildWhichIsA("TextLabel")
        if oldLabel then
            tween(oldLabel, { TextTransparency = 1 }, 0.12)
        end
        -- The slot's top stays put as it grows, so its spot is the landing.
        local target = toLayer(oldSlot.AbsolutePosition)
        tween(oldPanel, {
            Position = UDim2.fromOffset(target.X + width / 2, target.Y),
            Size = UDim2.fromOffset(width, height),
        }, 0.36, Enum.EasingStyle.Quint)
        tween(oldScale, { Scale = 1 }, 0.2)
        tween(oldShadow, { ImageTransparency = 1 }, 0.3)
        task.delay(0.37, settle)
    end

    -- Dragging the floating panel by its header.
    header.InputBegan:Connect(function(input)
        if not popped or not isPress(input) or not panel then
            return
        end
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        dragOrigin = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
        dragMoved = false
        suppressClick = false
    end)
    window:_listen("Changed", function(input)
        if not dragStart or not panel or not isMove(input) then
            return
        end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        if not dragMoved then
            if delta.Magnitude < (TOUCH and 8 or 5) then
                return
            end
            dragMoved, suppressClick = true, true
            animating = false
            closeInner()
            window:_closePopups()
            tween(panelScale, { Scale = 1.025 }, 0.18, Enum.EasingStyle.Quint)
            tween(panelShadow, { ImageTransparency = 0.15 }, 0.18)
        end
        local spot = clampSpot(dragOrigin + delta / layerScale(), panel.Size.X.Offset, panel.Size.Y.Offset)
        panel.Position = UDim2.fromOffset(spot.X, spot.Y)
    end, group)
    window:_listen("Ended", function(input)
        if not dragStart or not isPress(input) then
            return
        end
        dragStart = nil
        if dragMoved and panel then
            dragMoved = false
            tween(panelScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
            tween(panelShadow, { ImageTransparency = 0.35 }, 0.3)
            group._popSpot = Vector2.new(panel.Position.X.Offset, panel.Position.Y.Offset)
        end
    end, group)
    if popButton then
        popButton.MouseEnter:Connect(function()
            tween(popButton, { BackgroundTransparency = 0 }, 0.15)
            tween(popIcon, { ImageColor3 = Theme.Text }, 0.15)
        end)
        popButton.MouseLeave:Connect(function()
            tween(popButton, { BackgroundTransparency = 1 }, 0.25)
            tween(popIcon, { ImageColor3 = Theme.Muted }, 0.25)
        end)
        popButton.MouseButton1Click:Connect(function()
            if popped then
                dock()
            else
                popOut()
            end
        end)
    end

    header.MouseButton1Click:Connect(function()
        if suppressClick then
            suppressClick = false
            return
        end
        if isTap() then
            setCollapsed(not collapsed)
        end
    end)

    function group:PopOut()
        popOut()
    end
    function group:Dock()
        dock()
    end
    function group:IsPoppedOut()
        return popped
    end
    function group:SetCollapsed(value)
        setCollapsed(value)
    end
    function group:Collapse()
        setCollapsed(true)
    end
    function group:Expand()
        setCollapsed(false)
    end
    function group:IsCollapsed()
        return collapsed
    end
    function group:SetTitle(text)
        group.Name = tostring(text)
        title.Text = group.Name
    end
    group._userVisible = opts.Visible ~= false
    function group:IsVisible()
        return group._userVisible
    end
    function group:SetVisible(visible)
        visible = visible and true or false
        if visible == group._userVisible then
            return
        end
        group._userVisible = visible
        if not visible then
            for _, element in ipairs(group._items) do
                if element._onHide then
                    element._onHide()
                end
                if element.Open and type(element.SetOpen) == "function" then
                    element:SetOpen(false)
                end
            end
        end
        box.Visible = visible
        window._controlsDirty = true
    end
    if not group._userVisible then
        box.Visible = false
    end
    function group:Destroy()
        for index = #group._items, 1, -1 do
            local element = group._items[index]
            if type(element.Destroy) == "function" then
                element:Destroy()
            end
        end
        local owner = group.Parent
        local index = table.find(owner._groupboxes, group)
        if index then
            table.remove(owner._groupboxes, index)
        end
        set.Counts[side] = math.max(set.Counts[side] - 1, 0)
        dock(true)
        group._destroyed = true
        window._controlsDirty = true
        box:Destroy()
    end

    if opts.Collapsed then
        setCollapsed(true, true)
    end
    if opts.PoppedOut then
        task.defer(popOut)
    end
    return group
end

local function sideGroupbox(side)
    return function(self, opts, icon)
        opts = normalize(opts, { Title = "Name" })
        opts.Side = side
        return self:Groupbox(opts, icon)
    end
end

Tab.CreateGroupbox = Tab.Groupbox
Tab.AddGroupbox = Tab.Groupbox
Tab.AddLeftGroupbox = sideGroupbox("Left")
Tab.AddRightGroupbox = sideGroupbox("Right")

-- Button rows: equal-width buttons side by side.

function Tab:ButtonRow(opts)
    local specs = type(opts) == "table" and (opts.Buttons or opts) or {}
    local compact = metricsOf(self).Compact
    local boxHeight = TOUCH and 34 or 30
    local frame = card(self, "Frame", boxHeight + (compact and 4 or 14), {})
    local inset = compact and 14 or 7
    local holder = create("Frame", {
        Position = UDim2.fromOffset(inset, compact and 2 or 7),
        Size = UDim2.new(1, -inset * 2, 0, boxHeight),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    local count = math.max(#specs, 1)
    local handle = { Buttons = {} }
    local names = {}
    for index, spec in ipairs(specs) do
        if type(spec) == "string" then
            spec = { Name = spec }
        end
        local text = spec.Name or spec.Title or "Button"
        table.insert(names, text)
        local button, text_ = softButton(holder, text, {
            Position = UDim2.new((index - 1) / count, (index - 1) * 6 / count, 0, 0),
            Size = UDim2.new(1 / count, -6 * (count - 1) / count, 1, 0),
        }, function()
            safeCall(spec.Callback)
        end)
        text_.TextSize = 13
        if spec.Style == "Primary" then
            tween(button, { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.12 }, 0)
            tween(text_, { TextColor3 = Theme.AccentDark }, 0)
        elseif spec.Style == "Danger" then
            tween(text_, { TextColor3 = Theme.Error }, 0)
        end
        handle.Buttons[index] = { Button = button, Label = text_ }
    end
    function handle:SetText(index, text)
        local entry = handle.Buttons[index]
        if entry then
            entry.Label.Text = tostring(text)
        end
    end
    return finishElement(self, { Name = table.concat(names, " "), Visible = not (type(opts) == "table" and opts.Visible == false) }, handle, frame, "ButtonRow")
end

-- A text box with an action button beside it, for naming new configs and themes.
-- Without buttonText the box spans the row on its own.
local function actionInput(tab, placeholder, buttonText, callback)
    local boxHeight = TOUCH and 34 or 30
    local frame = card(tab, "Frame", boxHeight + 4, {})
    local inset = metricsOf(tab).Compact and 14 or 7
    local box
    local button = buttonText and softButton(frame, buttonText, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -inset, 0, 2),
        Size = UDim2.fromOffset(0, boxHeight),
        AutomaticSize = Enum.AutomaticSize.X,
    }, function()
        safeCall(callback, box.Text)
    end)
    local holder = create("Frame", {
        Position = UDim2.fromOffset(inset, 2),
        Size = UDim2.new(1, -(inset * 2 + (button and 70 or 0)), 0, boxHeight),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = frame,
    })
    corner(holder, UDim.new(0, 6))
    local holderStroke = stroke(holder)
    box = create("TextBox", {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = false,
        Parent = holder,
    })
    box.Focused:Connect(function()
        tween(holderStroke, { Color = Theme.StrokeHover }, 0.15)
    end)
    box.FocusLost:Connect(function(enterPressed)
        tween(holderStroke, { Color = Theme.Stroke }, 0.2)
        if enterPressed and box.Text ~= "" then
            safeCall(callback, box.Text)
        end
    end)
    if button then
        local function fit()
            local width = button.AbsoluteSize.X / tab.Window.Scale.Scale
            holder.Size = UDim2.new(1, -(inset * 2 + width + 6), 0, boxHeight)
        end
        button:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
        task.defer(fit)
    end
    return finishElement(tab, { Name = placeholder }, {
        Get = function()
            return box.Text
        end,
        Set = function(_, value)
            box.Text = tostring(value or "")
        end,
    }, frame, "ActionInput")
end

local function trim(text)
    return (tostring(text or ""):match("^%s*(.-)%s*$"))
end

-- Managers go in their own groupbox when added straight to a tab.
local function managerHost(tab, opts, name, icon)
    if tab._groupbox then
        return tab
    end
    local host = tab:Groupbox({ Name = opts.Name or name, Icon = opts.Icon or icon, Side = opts.Side })
    -- Library chrome, not a script feature: the feature list skips it.
    host._manager = true
    return host
end

function Tab:ConfigManager(opts)
    opts = normalize(opts, { Title = "Name" })
    local host = managerHost(self, opts, "Configs", "folder")
    local window = self.Window
    local manager = {}
    local list, status, modeList

    local function notify(ok, title, detail)
        window:Notify({ Title = title, Content = detail, Type = ok and "Success" or "Error", Duration = 3 })
    end

    local function refreshStatus()
        status:Set(("loaded: %s   |   autoload: %s"):format(window.LoadedConfig or "none", window:GetAutoload() or "none"))
    end

    local function pickedName()
        local name = list:Get()
        if not name then
            notify(false, "No config selected", "Pick one from the list first")
        end
        return name
    end

    local nameInput = actionInput(host, opts.Placeholder or "config name", nil, function(text)
        manager:Create(text)
    end)
    local names = window:ListConfigs()
    local initial = window.LoadedConfig or window:GetAutoload()
    list = host:Dropdown({
        Stacked = true,
        Options = names,
        Default = table.find(names, initial) and initial or nil,
        EmptyText = "--",
        NoneText = "--",
    })
    host:ButtonRow({
        { Name = "Create", Callback = function() manager:Create(nameInput:Get()) end },
        { Name = "Save", Callback = function() manager:Save() end },
    })
    host:ButtonRow({
        { Name = "Load", Callback = function() manager:Load() end },
        { Name = "Delete", Style = "Danger", Callback = function() manager:Delete() end },
    })
    host:ButtonRow({
        { Name = "Set autoload", Callback = function() manager:SetAutoload() end },
        { Name = "Clear autoload", Callback = function() manager:ClearAutoload() end },
    })
    host:ButtonRow({
        { Name = "Rename", Callback = function() manager:Rename(nil, nameInput:Get()) end },
        { Name = "Reset", Style = "Danger", Callback = function() manager:Reset() end },
    })
    status = host:Label("loaded: none   |   autoload: none")
    modeList = host:Dropdown({
        Name = "Autoload mode",
        Stacked = true,
        Options = { "All accounts", "This account" },
        Default = window:GetAutoloadMode() == "Account" and "This account" or "All accounts",
        AllowNone = false,
        Callback = function(choice)
            manager:SetAutoloadMode(choice == "This account" and "Account" or "Global")
        end,
    })
    host:Button({ Name = "Refresh list", Callback = function() manager:Refresh() end })
    host:Divider({ Text = "share" })
    host:Button({ Name = "Copy code", Callback = function() manager:Export() end })
    local codeInput = actionInput(host, "paste a config code...", nil, function(text)
        manager:Import(text)
    end)
    host:Button({ Name = "Import code", Callback = function() manager:Import(codeInput:Get()) end })

    function manager:Refresh()
        local names = window:ListConfigs()
        local keep = list:Get()
        list:Refresh(names, true)
        if keep and not table.find(names, keep) then
            list:Set(window.LoadedConfig and table.find(names, window.LoadedConfig) and window.LoadedConfig or nil, true)
        end
        refreshStatus()
    end

    local function select(name)
        manager:Refresh()
        list:Set(name, true)
    end

    function manager:Create(name)
        name = trim(name)
        if name == "" then
            notify(false, "Name the config", "Type a name before creating it")
            return
        end
        if not validConfigName(name) then
            notify(false, "Invalid name", 'Names cannot contain \\ / : * ? " < > |')
            return
        end
        local ok, err = window:SaveConfig(name)
        if ok then
            window.LoadedConfig = name
            nameInput:Set("")
            select(name)
        end
        notify(ok, ok and "Config created" or "Create failed", ok and name or tostring(err))
    end

    function manager:Save(name)
        name = name or list:Get()
        if not name then
            local typed = trim(nameInput:Get())
            if typed == "" then
                notify(false, "No config selected", "Pick one from the list or type a name")
                return
            end
            return manager:Create(typed)
        end
        local ok, err = window:SaveConfig(name)
        if ok then
            window.LoadedConfig = name
            refreshStatus()
        end
        notify(ok, ok and "Config saved" or "Save failed", ok and name or tostring(err))
    end

    function manager:Load(name)
        name = name or pickedName()
        if not name then
            return
        end
        local ok, err = window:LoadConfig(name)
        notify(ok, ok and "Config loaded" or "Load failed", ok and name or tostring(err))
    end

    function manager:Delete(name)
        name = name or pickedName()
        if not name then
            return
        end
        window:Confirm({
            Title = "Delete config",
            Content = "Remove " .. name .. "? This cannot be undone.",
            Icon = "trash-2",
            ConfirmText = "Delete",
            Callback = function()
                local ok, err = window:DeleteConfig(name)
                if ok then
                    if window:GetAutoload("Account") == name then
                        window:SetAutoload(nil, "Account")
                    end
                    if window:GetAutoload("Global") == name then
                        window:SetAutoload(nil, "Global")
                    end
                    list:Set(nil, true)
                end
                manager:Refresh()
                notify(ok, ok and "Config deleted" or "Delete failed", ok and name or tostring(err))
            end,
        })
    end

    function manager:Rename(name, newName)
        name = name or pickedName()
        if not name then
            return
        end
        newName = trim(newName)
        if newName == "" then
            notify(false, "Name the config", "Type the new name in the name box")
            return
        end
        if not validConfigName(newName) then
            notify(false, "Invalid name", 'Names cannot contain \\ / : * ? " < > |')
            return
        end
        local ok, err = window:RenameConfig(name, newName)
        if ok then
            nameInput:Set("")
            select(newName)
        end
        notify(ok, ok and "Config renamed" or "Rename failed", ok and (name .. " -> " .. newName) or tostring(err))
    end

    function manager:Reset()
        window:Confirm({
            Title = "Reset settings",
            Content = "Put every setting back to its default and delete this script's folder? Saved configs, themes and autoload are removed for good.",
            Icon = "rotate-ccw",
            ConfirmText = "Reset",
            Callback = function()
                window:ResetConfig()
                local wiped = window:ClearWorkspace()
                window:_applyDefaultTheme()
                list:Set(nil, true)
                manager:Refresh()
                modeList:Set("All accounts", true)
                notify(wiped, wiped and "Settings reset" or "Reset incomplete",
                    wiped and "Everything is back to its default" or "Some files in " .. window.ConfigFolder .. " could not be deleted")
            end,
        })
    end

    function manager:SetAutoload(name)
        name = name or pickedName()
        if not name then
            return
        end
        local ok, err = window:SetAutoload(name)
        notify(ok, ok and "Autoload set" or "Autoload failed", ok and name or tostring(err))
    end

    function manager:ClearAutoload()
        local current = window:GetAutoload()
        if not current then
            notify(false, "No autoload", "Nothing is set to autoload")
            return
        end
        local ok, err = window:SetAutoload(nil)
        notify(ok, ok and "Autoload cleared" or "Clear failed", ok and current or tostring(err))
    end

    function manager:ToggleAutoload(name)
        name = name or pickedName()
        if not name then
            return
        end
        if window:GetAutoload() == name then
            manager:ClearAutoload()
        else
            manager:SetAutoload(name)
        end
    end

    function manager:SetAutoloadMode(mode)
        local ok, err = window:SetAutoloadMode(mode)
        local label_ = mode == "Account" and "This account" or "All accounts"
        if modeList:Get() ~= label_ then
            modeList:Set(label_, true)
        end
        notify(ok ~= false, ok ~= false and "Autoload mode" or "Mode change failed", ok ~= false and label_ or tostring(err))
    end

    function manager:Export(name)
        local code, err = window:ExportConfig(name)
        if not code then
            notify(false, "Export failed", tostring(err))
            return nil
        end
        window:CopyToClipboard(code, "Config code")
        return code
    end

    function manager:Import(code)
        code = trim(code)
        if code == "" then
            notify(false, "Nothing to import", "Paste a config code first")
            return
        end
        local data, info = window:DecodeConfig(code)
        if not data then
            notify(false, "Import failed", "Invalid config code")
            return
        end
        -- The typed name wins; otherwise the code's own name, never overwriting a config.
        local saveAs = trim(nameInput:Get())
        if saveAs == "" then
            saveAs = nil
            if validConfigName(info.Name) then
                saveAs = info.Name
                local index = 2
                while window:ConfigExists(saveAs) do
                    saveAs = ("%s (%d)"):format(info.Name, index)
                    index += 1
                end
            end
        elseif not validConfigName(saveAs) then
            notify(false, "Invalid name", 'Names cannot contain \\ / : * ? " < > |')
            return
        end
        local function run()
            local ok, err = window:ImportConfig(code, saveAs, true)
            if ok then
                codeInput:Set("")
                if saveAs then
                    nameInput:Set("")
                    select(saveAs)
                end
            end
            notify(ok, ok and "Config imported" or "Import failed", ok and (saveAs or "Applied to current settings") or tostring(err))
        end
        if info.Folder and info.Folder ~= window.ConfigFolder then
            window:Confirm({
                Title = "Different script",
                Content = ("This config was made for %s. Import it anyway? Only matching settings are applied."):format(info.Folder),
                Icon = "triangle-alert",
                ConfirmText = "Import",
                Callback = run,
            })
            return
        end
        run()
    end

    local disconnect = window:OnConfigChanged(function()
        -- Configs can arrive from elsewhere (a cloud install), so the list is reread.
        manager:Refresh()
        if window.LoadedConfig and list:Get() == nil then
            list:Set(window.LoadedConfig, true)
        end
    end)
    status._listeners = status._listeners or {}
    table.insert(status._listeners, disconnect)

    refreshStatus()
    return manager
end

local PRESET_ORDER = {
    "Noir", "Cybrion", "Midnight", "Nebula", "Synthwave", "Sakura", "Velvet", "Rose", "Crimson", "Sunset", "Amber", "Gold",
    "Cyber", "Toxic", "Matcha", "Emerald", "Aurora", "Ocean", "Frost", "Abyss", "Mono",
    "Halloween", "Haunted", "Christmas", "Valentine", "Lunar", "Tropical", "Dracula", "Coffee",
}

local function presetNames()
    local names, seen = {}, {}
    for _, name in ipairs(PRESET_ORDER) do
        if Library.ThemePresets[name] then
            table.insert(names, name)
            seen[name] = true
        end
    end
    local extra = {}
    for name in pairs(Library.ThemePresets) do
        if not seen[name] then
            table.insert(extra, name)
        end
    end
    table.sort(extra)
    for _, name in ipairs(extra) do
        table.insert(names, name)
    end
    return names
end

function Tab:ThemeManager(opts)
    opts = normalize(opts, { Title = "Name" })
    local host = managerHost(self, opts, "Themes", "palette")
    local window = self.Window
    local manager = {}
    local themes, status, defaultRow, presets
    local weather, weatherMode, dim, transparent, dragSkeleton, islandStyle
    local background, backgroundInput, backgroundOpacity, backgroundLabel
    local uiScale, density, adaptive, cornerRadius

    local function notify(ok, title, detail)
        window:Notify({ Title = title, Content = detail, Type = ok and "Success" or "Error", Duration = 3 })
    end

    local function refreshStatus()
        local current = window:GetDefaultTheme()
        status:Set("Default theme: " .. (current or "none"))
        local picked = themes:Get() or presets:Get()
        defaultRow:SetText(2, (picked and picked == current) and "Clear Default" or "Set Default")
    end

    local function pickedTheme()
        local name = themes:Get()
        if not name then
            notify(false, "No theme selected", "Pick one from the list first")
        end
        return name
    end

    presets = host:Dropdown({
        Name = "Preset",
        Options = presetNames(),
        Default = Library.ThemePresets[Library.ThemeName or ""] and Library.ThemeName or nil,
        NoneText = "custom",
        AllowNone = false,
        Callback = function(name)
            if name then
                Library:SetTheme(name)
                themes:Set(nil, true)
                refreshStatus()
            end
        end,
    })
    local labels = { None = "None", Snow = "Snow", Rain = "Rain", Ember = "Hell Fire", Sakura = "Sakura", Fireflies = "Fireflies", Matrix = "Matrix" }
    if window._backdrop and opts.Weather ~= false then
        weather = host:Dropdown({
            Name = "Weather",
            Options = { "Snow", "Rain", "Hell Fire", "Sakura", "Fireflies", "Matrix", "None" },
            Default = labels[window.Weather] or "Matrix",
            AllowNone = false,
            Callback = function(name)
                if name then
                    window:SetWeather(name)
                end
            end,
        })
    end
    if window._backdrop and opts.Weather ~= false then
        weatherMode = host:Dropdown({
            Name = "Weather Mode",
            Options = { "Screen", "UI" },
            Default = window.WeatherMode,
            AllowNone = false,
            Callback = function(mode)
                if mode then
                    window:SetWeatherMode(mode)
                end
            end,
        })
    end
    if window._backdrop and opts.Dim ~= false then
        dim = host:Toggle({
            Name = "Dim",
            Default = window._backdropDim,
            Callback = function(value)
                window:SetDim(value)
            end,
        })
    end
    if opts.Transparent ~= false then
        transparent = host:Toggle({
            Name = "Transparent",
            Default = window.Transparent == true,
            Callback = function(value)
                window:SetTransparent(value)
            end,
        })
    end
    if opts.DragSkeleton ~= false and opts.DragStyle ~= false then
        dragSkeleton = host:Dropdown({
            Name = "Drag Style",
            Options = Library.DragStyles,
            Default = window.DragStyle,
            AllowNone = false,
            Callback = function(style)
                if style then
                    window:SetDragStyle(style)
                end
            end,
        })
    end
    if opts.IslandStyle ~= false then
        islandStyle = host:Dropdown({
            Name = "Dynamic Island",
            Options = Library.IslandStyles,
            Default = window.IslandStyle,
            AllowNone = false,
            Callback = function(style)
                if style then
                    window:SetIslandStyle(style)
                end
            end,
        })
    end
    if opts.AdaptiveSize ~= false then
        adaptive = host:Toggle({
            Name = "Adaptive Size",
            Default = window:GetAdaptiveSize(),
            Callback = function(value)
                window:SetAdaptiveSize(value)
            end,
        })
    end
    if opts.Scale ~= false then
        uiScale = host:Slider({
            Name = "UI Scale",
            Min = 60,
            Max = 150,
            Increment = 5,
            Default = math.floor(window:GetUIScale() * 100 + 0.5),
            Suffix = "%",
            -- Rescaling mid-drag would move the slider out from under the
            -- pointer, so a drag applies on release.
            Callback = function(value)
                if not (uiScale and uiScale.Dragging) then
                    window:SetUIScale(value / 100)
                end
            end,
            OnRelease = function(value)
                window:SetUIScale(value / 100)
            end,
        })
    end
    if opts.Density ~= false then
        density = host:Dropdown({
            Name = "Density",
            Options = { "Compact", "Default", "Comfortable" },
            Default = Library.Density,
            AllowNone = false,
            Callback = function(mode)
                if mode then
                    Library:SetDensity(mode)
                end
            end,
        })
    end
    if opts.CornerRadius ~= false then
        cornerRadius = host:Slider({
            Name = "Corner Radius",
            Min = 0,
            Max = 20,
            Increment = 1,
            Default = Library:GetCornerRadius(),
            Suffix = "px",
            Callback = function(value)
                Library:SetCornerRadius(value)
            end,
        })
    end
    if opts.Background ~= false then
        -- The dropdown shows listed images by name, "custom" for ids and links.
        backgroundLabel = function(source)
            if source == nil or source == "" then
                return "None"
            end
            return table.find(window:ListBackgrounds(), source) and source or nil
        end
        local function applyBackground(source, fromList)
            task.spawn(function()
                local ok, err = window:SetBackground(source)
                if ok and not fromList then
                    background:Set(backgroundLabel(window.Background), true)
                elseif not ok and err ~= "replaced by a newer background" then
                    notify(false, "Background failed", tostring(err))
                end
            end)
        end
        local options = window:ListBackgrounds()
        table.insert(options, 1, "None")
        background = host:Dropdown({
            Name = "Background",
            Options = options,
            Default = backgroundLabel(window.Background),
            NoneText = "custom",
            AllowNone = false,
            Callback = function(name)
                if name then
                    applyBackground(name, true)
                end
            end,
        })
        backgroundInput = actionInput(host, "image id or url", "Set", function(text)
            text = trim(text)
            if text == "" then
                notify(false, "No image", "Paste an image id or link first")
                return
            end
            applyBackground(text)
        end)
        backgroundOpacity = host:Slider({
            Name = "Background Opacity",
            Min = 0,
            Max = 100,
            Default = math.floor((1 - window.BackgroundTransparency) * 100 + 0.5),
            Suffix = "%",
            Callback = function(value)
                window:SetBackgroundTransparency(1 - value / 100)
            end,
        })
    end
    local nameInput = actionInput(host, opts.Placeholder or "theme name", "Create", function(text)
        manager:Create(text)
    end)
    themes = host:Dropdown({
        Name = "Theme",
        Options = window:ListThemes(),
        Default = (function()
            local current = window:GetDefaultTheme()
            return current and not Library.ThemePresets[current] and current or nil
        end)(),
        EmptyText = "no themes",
        NoneText = "select",
        Callback = function()
            refreshStatus()
        end,
    })
    host:ButtonRow({
        { Name = "Save", Callback = function() manager:Save() end },
        { Name = "Load", Callback = function() manager:Load() end },
    })
    defaultRow = host:ButtonRow({
        { Name = "Delete", Callback = function() manager:Delete() end },
        { Name = "Set Default", Callback = function() manager:ToggleDefault() end },
    })
    status = host:Label("Default theme: none")

    function manager:Refresh()
        themes:Refresh(window:ListThemes(), true)
        if background then
            local options = window:ListBackgrounds()
            table.insert(options, 1, "None")
            background:Refresh(options, true, true)
        end
        refreshStatus()
    end

    function manager:Create(name)
        name = trim(name)
        if name == "" then
            notify(false, "Name the theme", "Type a name before creating it")
            return
        end
        if Library.ThemePresets[name] then
            notify(false, "Name taken", name .. " is a built-in preset")
            return
        end
        local ok, err = window:SaveTheme(name)
        manager:Refresh()
        if ok then
            themes:Set(name, true)
            nameInput:Set("")
            refreshStatus()
        end
        notify(ok, ok and "Theme created" or "Create failed", ok and name or tostring(err))
    end

    function manager:Save(name)
        name = name or pickedTheme()
        if not name then
            return
        end
        local ok, err = window:SaveTheme(name)
        notify(ok, ok and "Theme saved" or "Save failed", ok and name or tostring(err))
    end

    function manager:Load(name)
        name = name or pickedTheme()
        if not name then
            return
        end
        local ok, err = window:LoadTheme(name)
        if ok then
            presets:Set(nil, true)
        end
        notify(ok ~= false, ok and "Theme loaded" or "Load failed", ok and name or tostring(err))
    end

    function manager:Delete(name)
        name = name or pickedTheme()
        if not name then
            return
        end
        window:Confirm({
            Title = "Delete theme",
            Content = "Remove " .. name .. "? This cannot be undone.",
            Icon = "trash-2",
            ConfirmText = "Delete",
            Callback = function()
                local ok, err = window:DeleteTheme(name)
                manager:Refresh()
                notify(ok, ok and "Theme deleted" or "Delete failed", ok and name or tostring(err))
            end,
        })
    end

    function manager:ToggleDefault(name)
        name = name or themes:Get() or presets:Get()
        if not name then
            notify(false, "Nothing selected", "Pick a theme or a preset first")
            return
        end
        local clearing = window:GetDefaultTheme() == name
        local ok, err = window:SetDefaultTheme(not clearing and name or nil)
        refreshStatus()
        notify(ok ~= false, clearing and "Default cleared" or "Default theme set", ok ~= false and name or tostring(err))
    end

    if opts.Customize ~= false then
        host:Divider()
        local fields = opts.Colors or {
            { "Accent", "Accent" },
            { "Background", "Background" },
            { "Surface2", "Surface" },
            { "Text", "Text" },
            { "Muted", "Muted text" },
        }
        for _, field in ipairs(fields) do
            local key, title = field[1], field[2] or field[1]
            local pending, scheduled = nil, false
            local picker
            picker = host:ColorPicker({
                Name = title,
                Default = Theme[key],
                Callback = function(color)
                    -- Dragging the picker fires every frame; repaint at most
                    -- a dozen times a second.
                    pending = color
                    if scheduled then
                        return
                    end
                    scheduled = true
                    task.delay(0.08, function()
                        scheduled = false
                        Library:SetTheme({ [key] = pending }, true)
                        presets:Set(nil, true)
                    end)
                end,
            })
            table.insert(Library._themeListeners, function()
                if picker.Value ~= Theme[key] then
                    picker:Set(Theme[key], true)
                end
            end)
        end
    end

    -- One hidden flag carries the palette and the look settings above, so
    -- configs save and load the theme. Not a flag per toggle: flagged toggles
    -- would count as running features on the minimized island.
    if opts.Flag ~= false then
        local flag = type(opts.Flag) == "string" and opts.Flag or "__Theme"
        local look = { _type = "Theme", _searchName = "Theme", _searchKey = "theme", _listeners = {} }

        function look:Get()
            local colors = {}
            for _, key in ipairs(THEME_KEYS) do
                colors[key] = colorToHex(Theme[key])
            end
            return {
                Name = presets:Get() or themes:Get(),
                Colors = colors,
                Weather = weather and window.Weather or nil,
                WeatherMode = weatherMode and window.WeatherMode or nil,
                -- if-expressions, not and/or: a switched-off value is false, not nil.
                Dim = if dim then window._backdropDim == true else nil,
                Transparent = if transparent then window.Transparent == true else nil,
                DragStyle = dragSkeleton and window.DragStyle or nil,
                IslandStyle = islandStyle and window.IslandStyle or nil,
                CornerRadius = cornerRadius and Library:GetCornerRadius() or nil,
                UIScale = uiScale and window:GetUIScale() or nil,
                AdaptiveSize = if adaptive then window:GetAdaptiveSize() else nil,
                Density = density and Library.Density or nil,
                -- "" is no background; a missing field leaves it alone on load.
                Background = background and (window.Background or "") or nil,
                BackgroundTransparency = background and window.BackgroundTransparency or nil,
            }
        end

        function look:Set(value)
            if type(value) ~= "table" then
                return
            end
            if type(value.Colors) == "table" then
                Library:SetTheme(value.Colors)
            end
            local name = type(value.Name) == "string" and value.Name or nil
            if name and Library.ThemePresets[name] then
                Library.ThemeName = name
                presets:Set(name, true)
                themes:Set(nil, true)
            else
                if name then
                    Library.ThemeName = name
                end
                presets:Set(nil, true)
                themes:Set(name and table.find(window:ListThemes(), name) and name or nil, true)
            end
            if weather and type(value.Weather) == "string" then
                window:SetWeather(value.Weather)
                weather:Set(labels[window.Weather] or "None", true)
            end
            if weatherMode and type(value.WeatherMode) == "string" then
                window:SetWeatherMode(value.WeatherMode)
                weatherMode:Set(window.WeatherMode, true)
            end
            if dim and type(value.Dim) == "boolean" then
                window:SetDim(value.Dim)
                dim:Set(value.Dim, true)
            end
            if transparent and type(value.Transparent) == "boolean" then
                window:SetTransparent(value.Transparent)
                transparent:Set(value.Transparent, true)
            end
            if dragSkeleton and type(value.DragStyle) == "string" then
                dragSkeleton:Set(window:SetDragStyle(value.DragStyle), true)
            elseif dragSkeleton and type(value.DragSkeleton) == "boolean" then
                -- Configs saved before drag styles.
                window:SetDragSkeleton(value.DragSkeleton)
                dragSkeleton:Set(window.DragStyle, true)
            end
            if islandStyle and type(value.IslandStyle) == "string" then
                islandStyle:Set(window:SetIslandStyle(value.IslandStyle), true)
            end
            if cornerRadius and tonumber(value.CornerRadius) then
                cornerRadius:Set(Library:SetCornerRadius(value.CornerRadius), true)
            end
            if adaptive and type(value.AdaptiveSize) == "boolean" then
                window:SetAdaptiveSize(value.AdaptiveSize)
                adaptive:Set(value.AdaptiveSize, true)
            end
            if uiScale and tonumber(value.UIScale) then
                window:SetUIScale(tonumber(value.UIScale))
                uiScale:Set(math.floor(window:GetUIScale() * 100 + 0.5), true)
            end
            if density and type(value.Density) == "string" then
                density:Set(Library:SetDensity(value.Density), true)
            end
            if background and tonumber(value.BackgroundTransparency) then
                window:SetBackgroundTransparency(tonumber(value.BackgroundTransparency))
                backgroundOpacity:Set(math.floor((1 - window.BackgroundTransparency) * 100 + 0.5), true)
            end
            if background and type(value.Background) == "string" and value.Background ~= (window.Background or "") then
                local source = value.Background
                background:Set(backgroundLabel(source), true)
                -- A web image may download first; don't hold up the rest of the config.
                task.spawn(window.SetBackground, window, source)
            end
            refreshStatus()
        end

        Library.Flags[flag] = look
        window:_flagCreated(flag, look)
    end

    -- A reset wipes the themes folder, so drop the stale list.
    window._workspaceListeners = window._workspaceListeners or {}
    table.insert(window._workspaceListeners, function()
        themes:Set(nil, true)
        manager:Refresh()
    end)

    refreshStatus()
    return manager
end

Tab.CreateButtonRow = Tab.ButtonRow
Tab.CreateConfigManager = Tab.ConfigManager
Tab.CreateThemeManager = Tab.ThemeManager

-- Status: read-only key/value lines, mostly for groupboxes, in several styles.

local STATUS_HEIGHT = { Plain = 22, Row = 24, Badge = 28, Dot = 24, Bar = 38, Stat = 46 }

-- Tone: a theme key, a Color3 or "#rrggbb".
local function toneColor(tone)
    return Library._color(tone) or Theme.Accent
end

local function formatNumber(value)
    if value == math.floor(value) then
        return tostring(math.floor(value))
    end
    return string.format("%.1f", value)
end

local function parseFraction(value, max)
    if type(value) == "number" and type(max) == "number" then
        return value, max
    end
    if type(value) == "string" then
        local cleaned = (value:gsub(",", ""))
        local current, total = cleaned:match("^%s*(%-?[%d%.]+)%s*/%s*(%-?[%d%.]+)")
        if current then
            return tonumber(current), tonumber(total)
        end
    end
    return nil, nil
end

function Tab:Status(opts)
    opts = normalize(opts, { Title = "Name", Text = "Value", Content = "Value", CurrentValue = "Value", Default = "Value" })
    local style = STATUS_HEIGHT[opts.Style] and opts.Style or "Plain"
    local compact = metricsOf(self).Compact
    local window = self.Window
    local height = STATUS_HEIGHT[style]
    local pad = compact and 0 or 8
    local frame = card(self, "Frame", height + pad * 2, opts)
    local holder = create("Frame", {
        Position = UDim2.fromOffset(14, pad),
        Size = UDim2.new(1, -28, 0, height),
        BackgroundTransparency = 1,
        Parent = frame,
    })

    local handle = { Value = opts.Value, Max = opts.Max, Tone = opts.Tone or "Accent", Name = opts.Name or "", Color = opts.Color or opts.ValueColor }
    local keyLabel, valueLabel, chip, chipStroke, dot, pulse, fill
    local tinted = false

    local function keyText()
        return style == "Plain" and (handle.Name .. ":") or handle.Name
    end

    if style == "Plain" then
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
            Parent = holder,
        })
        keyLabel = label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 1,
            Parent = holder,
        })
        valueLabel = label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            TextSize = 12,
            TextColor3 = Theme.Text,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 2,
            Parent = holder,
        })
    elseif style == "Stat" then
        keyLabel = label({
            Position = UDim2.fromOffset(0, 3),
            Size = UDim2.new(1, 0, 0, 14),
            TextSize = 11,
            TextColor3 = Theme.Muted,
            Parent = holder,
        })
        valueLabel = label({
            Position = UDim2.fromOffset(0, 18),
            Size = UDim2.new(1, 0, 0, 24),
            TextSize = 20,
            FontFace = Fonts.Bold,
            TextColor3 = Theme.Text,
            Parent = holder,
        })
    else
        local keyX = 0
        if style == "Dot" then
            keyX = 18
            pulse = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 5, 0.5, 0),
                Size = UDim2.fromOffset(8, 8),
                BackgroundColor3 = toneColor(handle.Tone),
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Parent = holder,
            })
            corner(pulse, UDim.new(1, 0))
            dot = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 5, 0.5, 0),
                Size = UDim2.fromOffset(8, 8),
                BackgroundColor3 = toneColor(handle.Tone),
                BorderSizePixel = 0,
                Parent = holder,
            })
            corner(dot, UDim.new(1, 0))
            if opts.Pulse ~= false then
                TweenService:Create(pulse, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1), {
                    Size = UDim2.fromOffset(20, 20),
                    BackgroundTransparency = 1,
                }):Play()
            else
                pulse.Visible = false
            end
        end
        local rowHeight = style == "Bar" and 18 or height
        keyLabel = label({
            Position = UDim2.fromOffset(keyX, 0),
            Size = UDim2.new(0.55, -keyX, 0, rowHeight),
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = holder,
        })
        if style == "Badge" then
            tinted = true
            chip = create("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(0, 22),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = toneColor(handle.Tone),
                BackgroundTransparency = 0.86,
                BorderSizePixel = 0,
                Parent = holder,
            })
            corner(chip, UDim.new(1, 0))
            chipStroke = stroke(chip, toneColor(handle.Tone), 0.6)
            padding(chip, 10, 10)
            valueLabel = label({
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                TextColor3 = toneColor(handle.Tone),
                TextTruncate = Enum.TextTruncate.None,
                Parent = chip,
            })
        else
            valueLabel = label({
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0.45, 0, 0, rowHeight),
                TextSize = 12,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = holder,
            })
        end
        if style == "Bar" then
            local track = create("Frame", {
                Position = UDim2.fromOffset(0, 25),
                Size = UDim2.new(1, 0, 0, 5),
                BackgroundColor3 = Theme.Surface3,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = holder,
            })
            corner(track, UDim.new(1, 0))
            fill = create("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = toneColor(handle.Tone),
                BorderSizePixel = 0,
                Parent = track,
            })
            corner(fill, UDim.new(1, 0))
        end
    end

    local lastText = nil
    local function render(animate)
        keyLabel.Text = Library._rich(keyText())
        local value = handle.Value
        local text = value == nil and (opts.Placeholder or "-") or tostring(value)
        if style == "Bar" then
            local current, total = parseFraction(value, handle.Max)
            if current and total then
                handle.Max = total
                text = formatNumber(current) .. " / " .. formatNumber(total)
                local fraction = total > 0 and math.clamp(current / total, 0, 1) or 0
                tween(fill, { Size = UDim2.new(fraction, 0, 1, 0) }, animate and 0.4 or 0, Enum.EasingStyle.Quint)
            elseif type(value) == "number" and value <= 1 then
                text = string.format("%d%%", math.floor(value * 100 + 0.5))
                tween(fill, { Size = UDim2.new(math.clamp(value, 0, 1), 0, 1, 0) }, animate and 0.4 or 0, Enum.EasingStyle.Quint)
            end
        end
        text = Library._rich((opts.Prefix or "") .. text .. (opts.Suffix or ""))
        local changed = lastText ~= nil and text ~= lastText
        lastText = text
        valueLabel.Text = text
        local tone = toneColor(handle.Tone)
        local duration = animate and 0.25 or 0
        -- Color paints the whole value; inline tags still win over it.
        local valueColor = not tinted and Library._color(handle.Color) or Theme.Text
        if not tinted and not (changed and animate and opts.Flash ~= false) then
            tween(valueLabel, { TextColor3 = valueColor }, duration)
        end
        if chip then
            tween(chip, { BackgroundColor3 = tone }, duration)
            tween(chipStroke, { Color = tone }, duration)
            tween(valueLabel, { TextColor3 = tone }, duration)
        end
        if dot then
            tween(dot, { BackgroundColor3 = tone }, duration)
            tween(pulse, { BackgroundColor3 = tone }, 0)
        end
        if fill then
            tween(fill, { BackgroundColor3 = tone }, duration)
        end
        -- A brief accent flash marks a changed value.
        if changed and animate and not tinted and opts.Flash ~= false then
            tween(valueLabel, { TextColor3 = Theme.Accent }, 0.08)
            task.delay(0.1, function()
                if valueLabel.Parent then
                    tween(valueLabel, { TextColor3 = Library._color(handle.Color) or Theme.Text }, 0.45)
                end
            end)
        end
    end

    keyLabel.RichText = true
    valueLabel.RichText = true
    -- Theme tags in the text are baked to colours, so repaint on theme change.
    onTheme(holder, function()
        if lastText ~= nil then
            render(false)
        end
    end)

    function handle:Set(value, max)
        handle.Value = value
        if max ~= nil then
            handle.Max = max
        end
        render(true)
    end
    function handle:Get()
        return handle.Value
    end
    function handle:SetTone(tone)
        handle.Tone = tone
        render(true)
    end
    -- nil goes back to the normal text colour.
    function handle:SetColor(color)
        handle.Color = color
        render(true)
    end
    function handle:SetName(name)
        handle.Name = tostring(name)
        render(false)
    end
    function handle:Text()
        return valueLabel.Text
    end
    -- The value's resting colour, for the copy pinned on the minimized island.
    function handle._shownColor()
        if handle.Color ~= nil then
            return Library._color(handle.Color) or Theme.Text
        end
        if style == "Badge" or style == "Dot" or style == "Bar" then
            return toneColor(handle.Tone)
        end
        return Theme.Text
    end

    handle._listeners = {}
    if type(opts.Update) == "function" then
        local rate = math.max(tonumber(opts.UpdateRate) or 1, 0.05)
        local running = true
        table.insert(handle._listeners, function()
            running = false
        end)
        task.spawn(function()
            while running and frame.Parent do
                local ok, value, extra = isolatedCall(opts.Update)
                if ok then
                    if value ~= nil then
                        handle.Value = value
                    end
                    if type(extra) == "number" then
                        handle.Max = extra
                    elseif type(extra) == "string" or typeof(extra) == "Color3" then
                        handle.Tone = extra
                    end
                    render(true)
                else
                    warn("[Noir] status update error: " .. tostring(value))
                end
                task.wait(rate)
            end
        end)
        function handle:SetUpdateRate(seconds)
            rate = math.max(tonumber(seconds) or rate, 0.05)
        end
    end
    if opts.Pin then
        table.insert(window._pinned, handle)
        table.insert(handle._listeners, function()
            local index = table.find(window._pinned, handle)
            if index then
                table.remove(window._pinned, index)
            end
        end)
    end

    render(false)
    return finishElement(self, opts, handle, frame, "Status")
end

function Tab:Statuses(entries, shared)
    local handles = {}
    for index, entry in ipairs(entries or {}) do
        local entryOpts = type(entry) == "table" and table.clone(entry) or { Name = tostring(entry) }
        for key, value in pairs(shared or {}) do
            if entryOpts[key] == nil then
                entryOpts[key] = value
            end
        end
        local handle = self:Status(entryOpts)
        handles[entryOpts.Name or entryOpts.Title or index] = handle
    end
    return handles
end

-- Status list: a read-only block of rows that grows up to MaxRows, then
-- scrolls inside itself. Rows are reused between refreshes so nothing flickers.
function Tab:StatusList(opts)
    opts = normalize(opts, { Title = "Name" })
    local compact = metricsOf(self).Compact
    local window = self.Window
    local maxRows = math.max(math.floor(tonumber(opts.MaxRows) or 5), 1)
    local frame = card(self, "Frame", 0, opts)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    if compact then
        padding(frame, 14, 14, 6, 8)
    else
        padding(frame, 14, 14, 11, 12)
    end
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = frame,
    })
    local heading = label({
        Size = UDim2.new(1, 0, 0, 16),
        Text = string.upper(tostring(opts.Name or "")),
        TextSize = 11,
        TextColor3 = Theme.Muted,
        Visible = tostring(opts.Name or "") ~= "",
        LayoutOrder = 1,
        Parent = frame,
    })
    local scroller = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollingEnabled = false,
        LayoutOrder = 2,
        Parent = frame,
    })
    scroller:SetAttribute("NoDrag", true)
    local content = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = scroller,
    })
    local contentPadding = padding(content, 0, 0, 0, 0)
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = content,
    })
    local empty = label({
        Size = UDim2.new(1, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = tostring(opts.EmptyText or "Nothing yet"),
        TextSize = 13,
        LineHeight = 1.1,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 0,
        Parent = content,
    })

    local rowObjects, rows, signature, raw = {}, {}, nil, {}
    local handle = { _listeners = {} }

    -- Fits the list to its first MaxRows rows, measured, so wrapped rows count
    -- at their real height. Past MaxRows the list scrolls.
    local function fit()
        if handle._destroyed then
            return
        end
        local scale = window.Scale.Scale
        local count = #rows
        local height = 0
        if count == 0 then
            height = empty.AbsoluteSize.Y / scale
        else
            local shown = math.min(count, maxRows)
            for index = 1, shown do
                height += rowObjects[index].Frame.AbsoluteSize.Y / scale
            end
            height += (shown - 1) * 2
        end
        height = math.ceil(height)
        local scrolling = count > maxRows
        scroller.ScrollingEnabled = scrolling
        contentPadding.PaddingRight = UDim.new(0, scrolling and 8 or 0)
        if scroller.Size.Y.Offset ~= height then
            scroller.Size = UDim2.new(1, 0, 0, height)
        end
        local maxScroll = math.max(scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y, 0) / scale
        if scroller.CanvasPosition.Y > maxScroll then
            scroller.CanvasPosition = Vector2.new(0, maxScroll)
        end
    end

    local function fitText(row)
        if row.Value.Visible then
            row.Text.Size = UDim2.new(1, -(math.ceil(row.Value.AbsoluteSize.X / window.Scale.Scale) + 12), 0, 24)
        else
            row.Text.Size = UDim2.new(1, 0, 0, 24)
        end
    end

    local function newRow(order)
        local holder = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = order,
            Parent = content,
        })
        local row = {
            Frame = holder,
            Text = label({
                Size = UDim2.new(1, 0, 0, 24),
                AutomaticSize = Enum.AutomaticSize.Y,
                Text = "",
                TextSize = 13,
                LineHeight = 1.1,
                FontFace = Fonts.Regular,
                TextColor3 = Theme.Muted,
                TextWrapped = true,
                TextTruncate = Enum.TextTruncate.None,
                RichText = true,
                Parent = holder,
            }),
            Value = label({
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 24),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = "",
                TextSize = 12,
                FontFace = Fonts.Medium,
                TextColor3 = Theme.Text,
                RichText = true,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.None,
                Visible = false,
                Parent = holder,
            }),
        }
        row.Connections = {
            holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit),
            row.Value:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                fitText(row)
            end),
        }
        return row
    end

    local function normalizeRow(entry)
        if type(entry) == "table" then
            local text = entry.Text or entry.Name or entry[1]
            local tone = entry.Tone or entry.Color
            return {
                Text = tostring(text == nil and "" or text),
                Value = entry.Value ~= nil and tostring(entry.Value) or nil,
                Tone = (type(tone) == "string" or typeof(tone) == "Color3") and tone or nil,
            }
        end
        return { Text = tostring(entry) }
    end

    local function rowKey(entry)
        return entry.Text .. "\0" .. (entry.Value or "\1") .. "\0" .. tostring(entry.Tone or "")
    end

    -- Tone tints the value, or the text when there is no value.
    local function paint(row, entry)
        local key = rowKey(entry)
        if row.Key == key then
            return
        end
        row.Key = key
        row.Text.Text = Library._rich(entry.Text)
        local tone = entry.Tone and Library._color(entry.Tone) or nil
        if entry.Value then
            row.Value.Text = Library._rich(entry.Value)
            row.Value.Visible = true
            tween(row.Value, { TextColor3 = tone or Theme.Text }, 0)
            tween(row.Text, { TextColor3 = Theme.Muted }, 0)
        else
            row.Value.Visible = false
            tween(row.Text, { TextColor3 = tone or Theme.Muted }, 0)
        end
        fitText(row)
    end

    local function dropRow(row)
        for _, connection in ipairs(row.Connections) do
            connection:Disconnect()
        end
        row.Frame:Destroy()
    end

    function handle:Set(list)
        if type(list) ~= "table" or handle._destroyed then
            return
        end
        local nextRows, keys = {}, {}
        raw = {}
        for index, entry in ipairs(list) do
            raw[index] = type(entry) == "table" and table.clone(entry) or entry
            local row = normalizeRow(entry)
            nextRows[index] = row
            keys[index] = rowKey(row)
        end
        local nextSignature = table.concat(keys, "\2") .. "#" .. #nextRows
        if nextSignature == signature then
            return
        end
        signature = nextSignature
        rows = nextRows
        for index, entry in ipairs(rows) do
            local row = rowObjects[index]
            if not row then
                row = newRow(index)
                rowObjects[index] = row
            end
            paint(row, entry)
        end
        for index = #rowObjects, #rows + 1, -1 do
            dropRow(rowObjects[index])
            rowObjects[index] = nil
        end
        empty.Visible = #rows == 0
        fit()
    end
    function handle:Get()
        local copy = {}
        for index, entry in ipairs(raw) do
            copy[index] = type(entry) == "table" and table.clone(entry) or entry
        end
        return copy
    end
    function handle:Clear()
        handle:Set({})
    end
    function handle:SetName(text)
        text = tostring(text or "")
        heading.Text = string.upper(text)
        heading.Visible = text ~= ""
        handle._searchName = text
        handle._searchKey = string.lower(text)
    end
    local rate = math.max(tonumber(opts.UpdateRate) or 1, 0.05)
    function handle:SetUpdateRate(seconds)
        rate = math.max(tonumber(seconds) or rate, 0.05)
    end

    -- Theme tags are baked into the text, so a theme change repaints the rows.
    onTheme(content, function()
        for index, row in ipairs(rowObjects) do
            if rows[index] then
                row.Key = nil
                paint(row, rows[index])
            end
        end
    end)

    local emptyConnection = empty:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    table.insert(handle._listeners, function()
        handle._destroyed = true
        emptyConnection:Disconnect()
        for _, row in ipairs(rowObjects) do
            for _, connection in ipairs(row.Connections) do
                connection:Disconnect()
            end
        end
    end)

    -- Refreshes only while someone can see it: window open and not minimized,
    -- its tab and sub tab showing, and neither it nor its groupbox hidden.
    local function onScreen()
        if window._destroyed or not window.Open or window.Minimized or not handle._userVisible then
            return false
        end
        local page = self
        if page._groupbox then
            if page._userVisible == false then
                return false
            end
            page = page.Parent
        end
        if page._isSubTab then
            if page.Parent.CurrentSubTab ~= page then
                return false
            end
            page = page.Parent
        end
        return window.CurrentTab == page
    end

    if type(opts.Update) == "function" then
        local alive = true
        table.insert(handle._listeners, function()
            alive = false
        end)
        task.defer(function()
            local first = true
            while alive and frame.Parent do
                if first or onScreen() then
                    first = false
                    local ok, result = isolatedCall(opts.Update)
                    if ok then
                        if result ~= nil then
                            handle:Set(result)
                        end
                    else
                        warn("[Noir] status list update error: " .. tostring(result))
                    end
                end
                task.wait(rate)
            end
        end)
    end

    handle:Set(opts.Rows or {})
    return finishElement(self, opts, handle, frame, "StatusList")
end

Tab.CreateStatus = Tab.Status
Tab.AddStatus = Tab.Status
Tab.CreateStatuses = Tab.Statuses
Tab.CreateStatusList = Tab.StatusList
Tab.AddStatusList = Tab.StatusList

-- Image and Viewport: media cards. Image shows a picture from the same sources
-- as window backgrounds, plus "Avatar" for the player's headshot. Viewport
-- shows a 3D model or the player's avatar, turning slowly; drag it to spin it
-- by hand.

function Tab:_mediaCard(opts, defaultHeight)
    opts = normalize(opts, { Title = "Name", Description = "Desc" })
    local metrics = metricsOf(self)
    local compact = metrics.Compact
    local mediaHeight = math.clamp(tonumber(opts.Height) or defaultHeight, 40, 600)
    local inset = compact and 14 or 8
    local hasHead = type(opts.Name) == "string" and opts.Name ~= ""
    local titleTop = compact and 4 or 10
    local mediaTop = hasHead and (titleTop + (opts.Desc and 38 or 22)) or (compact and 4 or inset)
    local height = mediaTop + mediaHeight + (compact and 6 or inset)
    local frame, frameStroke = card(self, "Frame", height, opts)
    hoverStroke(frame, frameStroke)
    local title, descLabel
    if hasHead then
        title = label({
            Position = UDim2.fromOffset(14, titleTop),
            Size = UDim2.new(1, -28, 0, metrics.TitleHeight),
            Text = opts.Name,
            TextSize = metrics.TextSize,
            Parent = frame,
        })
        if opts.Desc then
            descLabel = label({
                Position = UDim2.fromOffset(14, titleTop + metrics.TitleHeight + 1),
                Size = UDim2.new(1, -28, 0, metrics.DescLine),
                Text = opts.Desc,
                TextSize = metrics.DescSize,
                FontFace = Fonts.Regular,
                TextColor3 = Theme.Muted,
                Parent = frame,
            })
        end
    end
    local media = create("Frame", {
        Position = UDim2.fromOffset(inset, mediaTop),
        Size = UDim2.new(1, -inset * 2, 0, mediaHeight),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = frame,
    })
    corner(media, UDim.new(0, 6))
    stroke(media, Theme.Stroke)
    local placeholder = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Fit,
        Parent = media,
    })
    -- A caption over the bottom of the picture, on a dark fade.
    local captionHolder = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 3,
        Parent = media,
    })
    create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new(1, 0),
        Parent = captionHolder,
    })
    local caption = label({
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 1, -10),
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        ZIndex = 4,
        Parent = captionHolder,
    })
    local function setCaption(text)
        text = text ~= nil and tostring(text) or ""
        caption.Text = text
        captionHolder.Visible = text ~= ""
    end
    setCaption(opts.Caption)
    return opts, {
        Frame = frame,
        Stroke = frameStroke,
        Media = media,
        Placeholder = placeholder,
        Title = title,
        Desc = descLabel,
        SetCaption = setCaption,
    }
end

function Tab:Image(opts)
    local parts
    opts, parts = self:_mediaCard(opts, 160)
    local window = self.Window
    local media = parts.Media
    applyIcon(parts.Placeholder, "image")
    -- Enum lookups throw on unknown names.
    local function scaleType(name, fallback)
        local ok, value = pcall(function()
            return Enum.ScaleType[tostring(name)]
        end)
        return ok and value or fallback
    end
    local image = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        ScaleType = scaleType(opts.ScaleType or "Crop", Enum.ScaleType.Crop),
        ZIndex = 2,
        Parent = media,
    })
    corner(image, UDim.new(0, 6))
    if opts.Color then
        image.ImageColor3 = opts.Color
    end

    local handle = { Value = nil }
    local generation = 0

    -- Yields while a web image downloads. Returns ok, err like SetBackground.
    function handle:SetImage(source)
        generation += 1
        local current = generation
        handle.Value = source
        if source == nil or source == "" or source == "None" then
            tween(image, { ImageTransparency = 1 }, 0.2)
            tween(parts.Placeholder, { ImageTransparency = 0.3 }, 0.2)
            return true
        end
        local asset, err
        if type(source) == "number" then
            asset = "rbxassetid://" .. math.floor(source)
        elseif type(source) == "string" and ({ avatar = true, headshot = true })[source:lower()] then
            asset = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
        else
            local ok, result, message = pcall(window._resolveBackground, window, tostring(source))
            if ok then
                asset, err = result, message
            else
                err = tostring(result)
            end
        end
        if generation ~= current then
            return false, "replaced by a newer image"
        end
        if not asset then
            warn("[Noir] image: " .. tostring(err))
            return false, err
        end
        image.ImageTransparency = 1
        image.Image = asset
        -- Fade in once it has loaded, or after a few seconds regardless.
        task.spawn(function()
            local waited = 0
            while not image.IsLoaded and waited < 4 and generation == current and image.Parent do
                waited += task.wait(0.05)
            end
            if generation == current and image.Parent then
                tween(image, { ImageTransparency = 0 }, 0.35)
                tween(parts.Placeholder, { ImageTransparency = 1 }, 0.2)
            end
        end)
        return true
    end
    handle.Set = handle.SetImage

    function handle:Get()
        return handle.Value
    end

    function handle:SetCaption(text)
        parts.SetCaption(text)
    end

    function handle:SetScaleType(name)
        image.ScaleType = scaleType(name, image.ScaleType)
    end

    function handle:SetColor(color)
        image.ImageColor3 = typeof(color) == "Color3" and color or Color3.new(1, 1, 1)
    end

    function handle:SetTitle(text)
        if parts.Title then
            parts.Title.Text = tostring(text)
        end
    end

    if opts.Image ~= nil then
        task.spawn(handle.SetImage, handle, opts.Image)
    end
    return finishElement(self, opts, handle, parts.Frame, "Image")
end

function Tab:Viewport(opts)
    local parts
    opts, parts = self:_mediaCard(opts, 180)
    local window = self.Window
    local media = parts.Media
    applyIcon(parts.Placeholder, "box")

    local viewport = create("ViewportFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Ambient = opts.Ambient or Color3.fromRGB(165, 160, 175),
        LightColor = opts.LightColor or Color3.fromRGB(255, 250, 245),
        LightDirection = Vector3.new(-0.6, -1, -0.8),
        ZIndex = 2,
        Parent = media,
    })
    local camera = Instance.new("Camera")
    camera.FieldOfView = math.clamp(tonumber(opts.FieldOfView) or 35, 10, 90)
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    local world = Instance.new("WorldModel")
    world.Parent = viewport

    local handle = {
        Model = nil,
        Spin = opts.Spin ~= false,
        SpinSpeed = tonumber(opts.SpinSpeed) or 25,
    }
    local angle = math.rad(tonumber(opts.Angle) or 0)
    local pitch = math.rad(tonumber(opts.Pitch) or 10)
    local distanceScale = tonumber(opts.Distance) or 1
    local center, distance, basis = nil, 10, CFrame.new()
    local source = nil
    local generation = 0
    local dragging, lastX, resumeAt = false, 0, 0

    local function place()
        if not center then
            return
        end
        local direction = basis:VectorToWorldSpace(Vector3.new(
            math.sin(angle) * math.cos(pitch),
            math.sin(pitch),
            -math.cos(angle) * math.cos(pitch)
        ))
        camera.CFrame = CFrame.lookAt(center + direction * distance, center)
    end

    local function fit(model)
        local cf, size
        if model:IsA("Model") then
            cf, size = model:GetBoundingBox()
            basis = model:GetPivot().Rotation
        elseif model:IsA("BasePart") then
            cf, size = model.CFrame, model.Size
            basis = model.CFrame.Rotation
        else
            return false
        end
        center = cf.Position
        local radius = math.max(size.Magnitude / 2, 0.5)
        distance = radius / math.tan(math.rad(camera.FieldOfView / 2)) * distanceScale
        place()
        return true
    end

    -- A copy with its scripts and sounds stripped and every part anchored.
    local function prepare(instance)
        local copy = instance
        if opts.Clone ~= false then
            local archivable = instance.Archivable
            pcall(function()
                instance.Archivable = true
            end)
            local ok, result = pcall(instance.Clone, instance)
            pcall(function()
                instance.Archivable = archivable
            end)
            copy = ok and result or nil
        end
        if not copy then
            return nil
        end
        local function clean(object)
            if object:IsA("LuaSourceContainer") or object:IsA("Sound") or object:IsA("ForceField") then
                object:Destroy()
            elseif object:IsA("BasePart") then
                object.Anchored = true
                object.CanCollide = false
            end
        end
        for _, object in ipairs(copy:GetDescendants()) do
            pcall(clean, object)
        end
        if copy:IsA("BasePart") then
            copy.Anchored = true
        end
        local humanoid = copy:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
        return copy
    end

    local function resolve(value)
        if type(value) == "function" then
            local ok, result = pcall(value)
            value = ok and result or nil
        end
        if type(value) == "string" and ({ avatar = true, player = true, character = true })[value:lower()] then
            value = LocalPlayer
        end
        if typeof(value) == "Instance" and value:IsA("Player") then
            local character = value.Character
            if not character then
                character = value.CharacterAdded:Wait()
                -- Let the body parts and accessories load in.
                task.wait(0.5)
            end
            value = character
        end
        return typeof(value) == "Instance" and value or nil
    end

    -- Yields while waiting for a character to spawn.
    function handle:SetModel(value)
        generation += 1
        local current = generation
        source = value
        if handle.Model then
            handle.Model:Destroy()
            handle.Model = nil
        end
        center = nil
        if value == nil then
            tween(viewport, { ImageTransparency = 1 }, 0.2)
            tween(parts.Placeholder, { ImageTransparency = 0.3 }, 0.2)
            return true
        end
        local instance = resolve(value)
        if generation ~= current then
            return false, "replaced by a newer model"
        end
        if not instance then
            return false, "no model to show"
        end
        local copy = prepare(instance)
        if not copy then
            return false, "could not copy the model"
        end
        copy.Parent = world
        handle.Model = copy
        if not fit(copy) then
            copy:Destroy()
            handle.Model = nil
            return false, "not a Model or a part"
        end
        viewport.ImageTransparency = 1
        tween(viewport, { ImageTransparency = 0 }, 0.35)
        tween(parts.Placeholder, { ImageTransparency = 1 }, 0.2)
        return true
    end
    handle.Set = handle.SetModel

    function handle:Get()
        return handle.Model
    end

    -- Copies the source again, e.g. after the character respawned or changed.
    function handle:Refresh()
        return handle:SetModel(source)
    end

    function handle:SetSpin(enabled)
        handle.Spin = enabled ~= false
    end

    function handle:SetSpinSpeed(degrees)
        handle.SpinSpeed = tonumber(degrees) or handle.SpinSpeed
    end

    function handle:SetAngle(degrees)
        angle = math.rad(tonumber(degrees) or 0)
        place()
    end

    function handle:SetCaption(text)
        parts.SetCaption(text)
    end

    function handle:SetTitle(text)
        if parts.Title then
            parts.Title.Text = tostring(text)
        end
    end

    media.InputBegan:Connect(function(input)
        if isPress(input) and handle.Model then
            dragging = true
            lastX = pointerPosition().X
        end
    end)
    window:_listen("Changed", function(input)
        if dragging and isMove(input) then
            local x = pointerPosition().X
            angle -= (x - lastX) * 0.012
            lastX = x
            place()
        end
    end, handle)
    window:_listen("Ended", function(input)
        if dragging and isPress(input) then
            dragging = false
            resumeAt = os.clock() + 1.5
        end
    end, handle)
    window:_listen("Render", function(deltaTime)
        if handle.Spin and center and not dragging and os.clock() >= resumeAt and window.Open and not window.Minimized
            and parts.Frame.Visible then
            angle += math.rad(handle.SpinSpeed) * deltaTime
            place()
        end
    end, handle)

    if opts.Model ~= nil then
        task.spawn(handle.SetModel, handle, opts.Model)
    end
    return finishElement(self, opts, handle, parts.Frame, "Viewport")
end

-- Table: rows under a header, sortable by clicking a column. Rank = true adds
-- a # column with medals for the top three, for leaderboards.

function Tab:Table(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc", Data = "Rows", OnRowClick = "Callback" })
    local window = self.Window
    local metrics = metricsOf(self)
    local compact = metrics.Compact
    local rowHeight = tonumber(opts.RowHeight) or (TOUCH and 32 or 26)
    local maxRows = math.max(math.floor(tonumber(opts.MaxRows) or 8), 1)
    local headerHeight = TOUCH and 28 or 24
    local textSize = compact and 12 or 13
    local inset = compact and 14 or 8
    local hasHead = type(opts.Name) == "string" and opts.Name ~= ""
    local titleTop = compact and 4 or 10
    local searchable = opts.Search ~= false
    local searchHeight = TOUCH and 30 or 26
    local searchTop = hasHead and (titleTop + (opts.Desc and 38 or 22)) or (compact and 4 or inset)
    local gridTop = searchTop + (searchable and searchHeight + 6 or 0)
    local bottom = compact and 6 or inset

    local frame, frameStroke = card(self, "Frame", gridTop + headerHeight + rowHeight + bottom, opts)
    hoverStroke(frame, frameStroke)
    local title
    if hasHead then
        title = label({
            Position = UDim2.fromOffset(14, titleTop),
            Size = UDim2.new(1, -28, 0, metrics.TitleHeight),
            Text = opts.Name,
            TextSize = metrics.TextSize,
            Parent = frame,
        })
        if opts.Desc then
            label({
                Position = UDim2.fromOffset(14, titleTop + metrics.TitleHeight + 1),
                Size = UDim2.new(1, -28, 0, metrics.DescLine),
                Text = opts.Desc,
                TextSize = metrics.DescSize,
                FontFace = Fonts.Regular,
                TextColor3 = Theme.Muted,
                Parent = frame,
            })
        end
    end
    -- Search: filters rows by any cell's text as you type. A count of what
    -- matches shows on the right while it filters.
    local query = ""
    local searchBox, searchCount
    if searchable then
        local holder = create("Frame", {
            Position = UDim2.fromOffset(inset, searchTop),
            Size = UDim2.new(1, -inset * 2, 0, searchHeight),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Parent = frame,
        })
        holder:SetAttribute("NoDrag", true)
        corner(holder, UDim.new(0, 6))
        local searchStroke = stroke(holder)
        local iconHolder, searchIcon = glowIcon(holder, "search", Theme.Muted, UDim2.new(0, 9, 0.5, 0))
        iconHolder.Size = UDim2.fromOffset(13, 13)
        searchCount = label({
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -9, 0, 0),
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            TextSize = 11,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextTruncate = Enum.TextTruncate.None,
            Visible = false,
            Parent = holder,
        })
        searchBox = create("TextBox", {
            Position = UDim2.fromOffset(29, 0),
            Size = UDim2.new(1, -90, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = opts.SearchPlaceholder or "Search",
            PlaceholderColor3 = Theme.Muted,
            TextColor3 = Theme.Text,
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ClearTextOnFocus = false,
            Parent = holder,
        })
        searchBox.Focused:Connect(function()
            tween(searchStroke, { Color = Theme.StrokeHover }, 0.15)
            tween(searchIcon, { ImageColor3 = Theme.Accent }, 0.15)
        end)
        searchBox.FocusLost:Connect(function()
            tween(searchStroke, { Color = Theme.Stroke }, 0.2)
            tween(searchIcon, { ImageColor3 = Theme.Muted }, 0.2)
        end)
    end

    local grid = create("Frame", {
        Position = UDim2.fromOffset(inset, gridTop),
        Size = UDim2.new(1, -inset * 2, 0, headerHeight + rowHeight),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = frame,
    })
    corner(grid, UDim.new(0, 6))
    stroke(grid, Theme.Stroke)
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, headerHeight),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Parent = grid,
    })
    create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = header,
    })
    local body = create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 1, -headerHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Parent = grid,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })
    local empty = label({
        Position = UDim2.fromOffset(0, headerHeight),
        Size = UDim2.new(1, 0, 0, rowHeight),
        Text = opts.EmptyText or "Nothing here yet",
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = grid,
    })

    local handle = { Rows = {} }
    local shownCount = nil
    local columns, headerCells = {}, {}
    local pool = {}
    local sortKey, sortDescending = nil, false
    local shownHeight = nil
    local MEDALS = {
        Color3.fromRGB(245, 200, 90),
        Color3.fromRGB(200, 206, 218),
        Color3.fromRGB(214, 146, 96),
    }

    local function alignment(column)
        local align = type(column.Align) == "string" and column.Align:lower() or nil
        if align == "right" then
            return Enum.TextXAlignment.Right
        elseif align == "center" or align == "centre" then
            return Enum.TextXAlignment.Center
        end
        return Enum.TextXAlignment.Left
    end

    -- Widths: a number above 1 is pixels, up to 1 is a share of what the pixel
    -- columns leave, and the rest split whatever share is left.
    local function layoutColumns()
        local pixels, shares, autos = 0, 0, 0
        for _, column in ipairs(columns) do
            local width = tonumber(column.Width)
            if width and width > 1 then
                pixels += width
            elseif width and width > 0 then
                shares += width
            else
                autos += 1
            end
        end
        local left = math.max(1 - shares, 0)
        for _, column in ipairs(columns) do
            local width = tonumber(column.Width)
            local share
            if width and width > 1 then
                column.UDim = UDim.new(0, width)
            else
                share = (width and width > 0) and width or (autos > 0 and left / autos or 0)
                column.UDim = UDim.new(share, -pixels * share)
            end
        end
    end

    local function columnValue(row, column)
        if column.Rank then
            return nil
        end
        if row[1] ~= nil or column.Key == nil then
            return row[column.Index]
        end
        return row[column.Key]
    end

    local function display(value, column, row)
        if type(column.Format) == "function" then
            local ok, text = pcall(column.Format, value, row)
            if ok and text ~= nil then
                return tostring(text)
            end
        end
        if type(value) == "number" then
            local whole = value == math.floor(value)
            local text = whole and string.format("%d", value) or string.format("%.2f", value)
            -- Thousands separators on the whole part.
            local sign, int, rest = text:match("^(%-?)(%d+)(.*)$")
            if int then
                int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                return sign .. int .. rest
            end
            return text
        end
        if value == nil then
            return ""
        end
        return tostring(value)
    end

    local function paintHeader()
        for _, cell in ipairs(headerCells) do
            local column = cell.Column
            local active = sortKey ~= nil and sortKey == column
            tween(cell.Label, { TextColor3 = active and Theme.Text or Theme.Muted }, 0.15)
            cell.Arrow.Visible = active
            if active then
                tween(cell.Arrow, { Rotation = sortDescending and 0 or 180 }, 0.2, Enum.EasingStyle.Quint)
            end
        end
    end

    local function sortedRows()
        local list = {}
        for index, row in ipairs(handle.Rows) do
            list[index] = { Row = row, Index = index }
        end
        if sortKey then
            local column = sortKey
            table.sort(list, function(a, b)
                local x, y = columnValue(a.Row, column), columnValue(b.Row, column)
                local nx, ny = tonumber(x), tonumber(y)
                if nx and ny then
                    if nx ~= ny then
                        if sortDescending then
                            return nx > ny
                        end
                        return nx < ny
                    end
                elseif x ~= nil and y ~= nil then
                    local sx, sy = string.lower(tostring(x)), string.lower(tostring(y))
                    if sx ~= sy then
                        if sortDescending then
                            return sx > sy
                        end
                        return sx < sy
                    end
                elseif x ~= y then
                    -- Empty cells sink to the bottom either way.
                    return x ~= nil
                end
                return a.Index < b.Index
            end)
        end
        -- Ranks come from the full order, so filtering never renumbers them.
        for position, item in ipairs(list) do
            item.Rank = position
        end
        if query == "" then
            return list
        end
        local shown = {}
        for _, item in ipairs(list) do
            for _, column in ipairs(columns) do
                if not column.Rank then
                    local text = display(columnValue(item.Row, column), column, item.Row)
                    text = string.lower((string.gsub(text, "<[^>]->", "")))
                    if string.find(text, query, 1, true) then
                        table.insert(shown, item)
                        break
                    end
                end
            end
        end
        return shown
    end

    local function newRow()
        local rowFrame = create("TextButton", {
            Size = UDim2.new(1, 0, 0, rowHeight),
            BackgroundColor3 = Theme.Surface3,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Parent = body,
        })
        -- The accent bar on a highlighted row sits beside the cells, outside
        -- their layout.
        local marker = create("Frame", {
            Position = UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 2, 1, -10),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = rowFrame,
        })
        corner(marker, UDim.new(1, 0))
        local cellsFrame = create("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Parent = rowFrame,
        })
        padding(cellsFrame, 10, 10)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = cellsFrame,
        })
        local entry = { Frame = rowFrame, Marker = marker, Cells = {}, Hover = false }
        for order, column in ipairs(columns) do
            local cell = create("Frame", {
                Size = UDim2.new(column.UDim.Scale, column.UDim.Offset, 1, 0),
                BackgroundTransparency = 1,
                LayoutOrder = order,
                Parent = cellsFrame,
            })
            local text = label({
                Size = UDim2.new(1, -6, 1, 0),
                TextSize = textSize,
                FontFace = column.Rank and Fonts.Bold or Fonts.Regular,
                TextColor3 = Theme.Text,
                TextXAlignment = alignment(column),
                RichText = not column.Rank,
                Parent = cell,
            })
            local badge
            if column.Rank then
                text.Size = UDim2.fromScale(1, 1)
                text.TextXAlignment = Enum.TextXAlignment.Center
                badge = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(rowHeight - 8, rowHeight - 8),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 0,
                    Parent = cell,
                })
                corner(badge, UDim.new(1, 0))
            end
            entry.Cells[order] = { Label = text, Badge = badge }
        end
        local canTap = tapGuard(rowFrame, function()
            return body
        end)
        rowFrame.MouseEnter:Connect(function()
            entry.Hover = true
            tween(rowFrame, { BackgroundTransparency = 0.35 }, 0.1)
        end)
        rowFrame.MouseLeave:Connect(function()
            entry.Hover = false
            tween(rowFrame, {
                BackgroundColor3 = entry.Highlighted and Theme.Accent or Theme.Surface3,
                BackgroundTransparency = entry.Rest or 1,
            }, 0.2)
        end)
        rowFrame.MouseButton1Click:Connect(function()
            if entry.Data and canTap() then
                safeCall(opts.Callback, entry.Data, entry.Index)
            end
        end)
        return entry
    end

    local function fitHeight(instant)
        local count = shownCount or #handle.Rows
        local visible = math.clamp(count, 1, maxRows)
        local gridHeight = headerHeight + visible * rowHeight
        local total = gridTop + gridHeight + bottom
        if shownHeight == total then
            return
        end
        local duration = (instant or shownHeight == nil) and 0 or 0.25
        shownHeight = total
        tween(grid, { Size = UDim2.new(1, -inset * 2, 0, gridHeight) }, duration, Enum.EasingStyle.Quint)
        tween(frame, { Size = UDim2.new(1, 0, 0, total) }, duration, Enum.EasingStyle.Quint)
    end

    local function render()
        local list = sortedRows()
        for position, item in ipairs(list) do
            local entry = pool[position]
            if not entry then
                entry = newRow()
                pool[position] = entry
            end
            local row = item.Row
            entry.Data = row
            entry.Index = item.Index
            entry.Frame.LayoutOrder = position
            entry.Frame.Visible = true
            local highlighted = row.Highlight == true
            if not highlighted and type(opts.Highlight) == "function" then
                local ok, result = pcall(opts.Highlight, row, item.Index)
                highlighted = ok and result == true
            end
            entry.Highlighted = highlighted
            entry.Rest = highlighted and 0.86 or (position % 2 == 0 and 0.78 or 1)
            if not entry.Hover then
                entry.Frame.BackgroundColor3 = highlighted and Theme.Accent or Theme.Surface3
                entry.Frame.BackgroundTransparency = entry.Rest
                bindColors(entry.Frame, { BackgroundColor3 = entry.Frame.BackgroundColor3 })
            end
            entry.Marker.BackgroundTransparency = highlighted and 0 or 1
            for order, column in ipairs(columns) do
                local cell = entry.Cells[order]
                if column.Rank then
                    local medal = MEDALS[item.Rank]
                    cell.Label.Text = tostring(item.Rank)
                    cell.Label.TextColor3 = medal and Color3.fromRGB(28, 22, 18) or Theme.Muted
                    bindColors(cell.Label, { TextColor3 = cell.Label.TextColor3 })
                    cell.Badge.BackgroundColor3 = medal or Theme.Surface3
                    cell.Badge.BackgroundTransparency = medal and 0.05 or 1
                else
                    local value = columnValue(row, column)
                    cell.Label.Text = Library._rich(display(value, column, row))
                    -- Column Color: a colour, a theme key or a function(value, row)
                    -- returning either. A row's Colors[key or index] beats it.
                    local wanted = column.Color
                    if type(wanted) == "function" then
                        local ok, result = pcall(wanted, value, row)
                        wanted = ok and result or nil
                    end
                    if type(row.Colors) == "table" then
                        local own = row.Colors[column.Key or column.Index]
                        if own == nil then
                            own = row.Colors[column.Index]
                        end
                        if own ~= nil then
                            wanted = own
                        end
                    end
                    local color = Library._color(wanted) or (highlighted and Theme.Accent or Theme.Text)
                    cell.Label.TextColor3 = color
                    bindColors(cell.Label, { TextColor3 = color })
                end
            end
        end
        for position = #list + 1, #pool do
            pool[position].Frame.Visible = false
            pool[position].Data = nil
        end
        shownCount = #list
        empty.Visible = #list == 0
        empty.Text = (#list == 0 and query ~= "" and #handle.Rows > 0) and (opts.NoMatchText or "No rows match")
            or (opts.EmptyText or "Nothing here yet")
        if searchCount then
            searchCount.Visible = query ~= ""
            searchCount.Text = #list .. " / " .. #handle.Rows
        end
        fitHeight()
    end

    local function buildHeader()
        for _, cell in ipairs(headerCells) do
            cell.Frame:Destroy()
        end
        table.clear(headerCells)
        for _, entry in ipairs(pool) do
            entry.Frame:Destroy()
        end
        table.clear(pool)
        local row = header:FindFirstChild("Cells") or create("Frame", {
            Name = "Cells",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Parent = header,
        })
        if not row:FindFirstChildOfClass("UIListLayout") then
            padding(row, 10, 10)
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = row,
            })
        end
        for order, column in ipairs(columns) do
            local cell = create("TextButton", {
                Size = UDim2.new(column.UDim.Scale, column.UDim.Offset, 1, 0),
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                LayoutOrder = order,
                Parent = row,
            })
            local align = column.Rank and Enum.TextXAlignment.Center or alignment(column)
            local right = align == Enum.TextXAlignment.Right
            local text = label({
                Size = UDim2.new(1, align == Enum.TextXAlignment.Center and 0 or -16, 1, 0),
                Position = UDim2.fromOffset(right and 16 or 0, 0),
                Text = string.upper(column.Name),
                TextSize = 11,
                FontFace = Fonts.Bold,
                TextColor3 = Theme.Muted,
                TextXAlignment = align,
                Parent = cell,
            })
            local arrow = create("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),
                BackgroundTransparency = 1,
                ImageColor3 = Theme.Accent,
                ScaleType = Enum.ScaleType.Fit,
                Visible = false,
                Parent = cell,
            })
            applyIcon(arrow, "chevron-down")
            -- The arrow sits just after the header text (before it when the
            -- column is right aligned).
            local function placeArrow()
                local width = text.TextBounds.X
                if right then
                    arrow.Position = UDim2.new(1, -(width + 15), 0.5, 0)
                elseif align == Enum.TextXAlignment.Center then
                    arrow.Position = UDim2.new(0.5, width / 2 + 3, 0.5, 0)
                else
                    local cellWidth = cell.AbsoluteSize.X / math.max(window.Scale.Scale, 0.01)
                    arrow.Position = UDim2.new(0, math.clamp(width + 4, 0, math.max(cellWidth - 12, 0)), 0.5, 0)
                end
            end
            text:GetPropertyChangedSignal("TextBounds"):Connect(placeArrow)
            cell:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeArrow)
            task.defer(placeArrow)
            local sortable = column.Sortable and not column.Rank
            if sortable then
                cell.MouseEnter:Connect(function()
                    if sortKey ~= column then
                        tween(text, { TextColor3 = Theme.Text }, 0.12)
                    end
                end)
                cell.MouseLeave:Connect(function()
                    if sortKey ~= column then
                        tween(text, { TextColor3 = Theme.Muted }, 0.2)
                    end
                end)
                cell.MouseButton1Click:Connect(function()
                    -- Numbers sort high to low first, text A to Z; the second
                    -- click flips it and the third goes back to the given order.
                    if sortKey ~= column then
                        local numeric = false
                        for _, data in ipairs(handle.Rows) do
                            local value = columnValue(data, column)
                            if value ~= nil then
                                numeric = tonumber(value) ~= nil
                                break
                            end
                        end
                        sortKey, sortDescending = column, numeric
                        column.FirstDescending = numeric
                    elseif sortDescending == column.FirstDescending then
                        sortDescending = not sortDescending
                    else
                        sortKey = nil
                    end
                    paintHeader()
                    render()
                end)
            end
            table.insert(headerCells, { Frame = cell, Label = text, Arrow = arrow, Column = column })
        end
        paintHeader()
    end

    function handle:SetColumns(list)
        table.clear(columns)
        if opts.Rank then
            table.insert(columns, { Name = "#", Rank = true, Width = TOUCH and 40 or 36, Sortable = false })
        end
        for index, column in ipairs(type(list) == "table" and list or {}) do
            if type(column) ~= "table" then
                column = { Name = tostring(column) }
            end
            local name = column.Name or column.Title or ("Column " .. index)
            table.insert(columns, {
                Name = name,
                Key = column.Key or name,
                Index = index,
                Width = column.Width,
                Align = column.Align,
                Format = column.Format,
                Color = column.Color,
                Sortable = column.Sortable ~= false and opts.Sortable ~= false,
            })
        end
        sortKey = nil
        layoutColumns()
        buildHeader()
        render()
    end

    local function findColumn(key)
        if type(key) == "number" then
            return columns[key + (opts.Rank and 1 or 0)]
        end
        for _, column in ipairs(columns) do
            if not column.Rank and (column.Key == key or column.Name == key) then
                return column
            end
        end
        return nil
    end

    function handle:SetRows(rows)
        handle.Rows = {}
        for index, row in ipairs(type(rows) == "table" and rows or {}) do
            handle.Rows[index] = type(row) == "table" and row or { row }
        end
        render()
    end
    handle.Set = handle.SetRows

    function handle:GetRows()
        return handle.Rows
    end
    handle.Get = handle.GetRows

    function handle:AddRow(row, position)
        row = type(row) == "table" and row or { row }
        if tonumber(position) then
            table.insert(handle.Rows, math.clamp(math.floor(position), 1, #handle.Rows + 1), row)
        else
            table.insert(handle.Rows, row)
        end
        render()
        return #handle.Rows
    end

    -- Replaces a row (by its index in the list you gave) and flashes it.
    function handle:UpdateRow(index, row)
        if not handle.Rows[index] then
            return false
        end
        handle.Rows[index] = type(row) == "table" and row or { row }
        render()
        for _, entry in ipairs(pool) do
            if entry.Index == index and entry.Frame.Visible then
                local restColor = entry.Highlighted and Theme.Accent or Theme.Surface3
                tween(entry.Frame, { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.7 }, 0.08)
                task.delay(0.1, function()
                    if not entry.Hover then
                        tween(entry.Frame, { BackgroundColor3 = restColor, BackgroundTransparency = entry.Rest }, 0.5)
                    end
                end)
                break
            end
        end
        return true
    end

    function handle:RemoveRow(index)
        if not handle.Rows[index] then
            return false
        end
        table.remove(handle.Rows, index)
        render()
        return true
    end

    function handle:Clear()
        handle:SetRows({})
    end

    -- Sort(nil) goes back to the given order.
    function handle:Sort(key, descending)
        sortKey = key ~= nil and findColumn(key) or nil
        sortDescending = descending == true
        if sortKey then
            sortKey.FirstDescending = sortDescending
        end
        paintHeader()
        render()
    end

    function handle:SetTitle(text)
        if title then
            title.Text = tostring(text)
        end
    end

    function handle:SetMaxRows(count)
        maxRows = math.max(math.floor(tonumber(count) or maxRows), 1)
        fitHeight()
    end

    handle:SetColumns(opts.Columns or {})
    handle:SetRows(opts.Rows or {})
    if opts.SortBy ~= nil then
        handle:Sort(opts.SortBy, opts.SortDescending ~= false)
    end
    fitHeight(true)
    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = string.lower(trim(searchBox.Text))
            if text ~= query then
                query = text
                body.CanvasPosition = Vector2.zero
                render()
            end
        end)
    end
    function handle:SetSearch(text)
        if searchBox then
            searchBox.Text = tostring(text or "")
        end
    end
    -- Theme tags in cells are baked to colours; repaint them on theme change.
    onTheme(grid, render)
    return finishElement(self, opts, handle, frame, "Table")
end

Tab.CreateImage = Tab.Image
Tab.AddImage = Tab.Image
Tab.CreateViewport = Tab.Viewport
Tab.AddViewport = Tab.Viewport
Tab.CreateTable = Tab.Table
Tab.AddTable = Tab.Table
Tab.CreateLeaderboard = Tab.Table

local function settleSubOut(ui)
    if ui.OutFrame then
        ui.OutFrame.Parent = ui.Area
        ui.OutFrame.Visible = false
        ui.OutFrame = nil
    end
    ui.Out.Visible = false
end

local function settleSubIn(ui)
    if ui.InFrame then
        ui.InFrame.Parent = ui.Area
        ui.InFrame.Position = UDim2.fromOffset(0, 0)
        ui.InFrame = nil
    end
    ui.In.Visible = false
end

function Tab:_setupSubTabs()
    local top = self._headerBottom
    local page = self._page
    local strip = create("ScrollingFrame", {
        Name = "SubTabs",
        Position = UDim2.fromOffset(24, top - 4),
        Size = UDim2.new(1, -48, 0, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(),
        Parent = page,
    })
    strip:SetAttribute("NoDrag", true)
    local highlight = create("Frame", {
        Size = UDim2.fromOffset(0, 32),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Visible = false,
        Parent = strip,
    })
    corner(highlight, UDim.new(0, 8))
    stroke(highlight, Theme.Stroke)
    local row = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = strip,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = row,
    })
    self.Window:_overflowHint(page, strip, row, false, Theme.Background)
    local areaTop = top + 36
    local area = create("Frame", {
        Name = "SubPages",
        Position = UDim2.fromOffset(0, areaTop),
        Size = UDim2.new(1, 0, 1, -areaTop),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = page,
    })
    local ui = {
        Strip = strip,
        Row = row,
        Highlight = highlight,
        Area = area,
        Out = create("CanvasGroup", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 2,
            Parent = area,
        }),
        In = create("CanvasGroup", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 3,
            Parent = area,
        }),
        Generation = 0,
    }
    self._sub = ui
    self._subTabs = {}
    self.List.Visible = false
    self:_refreshEmpty()
    -- Keep the pill under the selected tab when widths change after layout.
    row:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if self.CurrentSubTab and not ui.Moving then
            self:_placeSubHighlight(self.CurrentSubTab, true)
        end
    end)
end

function Tab:_placeSubHighlight(sub, instant)
    local ui = self._sub
    local scale = self.Window.Scale.Scale
    local button = sub._button
    local width = button.AbsoluteSize.X / scale
    if width <= 0 then
        return
    end
    local x = (button.AbsolutePosition.X - ui.Row.AbsolutePosition.X) / scale
    local props = { Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(width, 32) }
    if instant or not ui.Highlight.Visible then
        ui.Highlight.Visible = true
        ui.Highlight.Position = props.Position
        ui.Highlight.Size = props.Size
    else
        ui.Moving = true
        tween(ui.Highlight, props, 0.35, Enum.EasingStyle.Quint)
        task.delay(0.36, function()
            ui.Moving = false
        end)
    end
    local view = ui.Strip.AbsoluteSize.X / scale
    local canvasX = ui.Strip.CanvasPosition.X
    if x < canvasX then
        tween(ui.Strip, { CanvasPosition = Vector2.new(math.max(x - 8, 0), 0) }, 0.3, Enum.EasingStyle.Quint)
    elseif x + width > canvasX + view then
        tween(ui.Strip, { CanvasPosition = Vector2.new(x + width - view + 8, 0) }, 0.3, Enum.EasingStyle.Quint)
    end
end

function Tab:SubTab(opts, icon)
    if self._groupbox or self._isSubTab then
        return self.Parent:SubTab(opts, icon)
    end
    opts = normalize(opts, { Title = "Name", Description = "Desc" })
    if icon ~= nil and opts.Icon == nil then
        opts.Icon = icon
    end
    if not self._subTabs then
        self:_setupSubTabs()
    end
    local ui = self._sub
    local index = #self._subTabs + 1
    local sub = setmetatable({
        Name = opts.Name or ("Page " .. index),
        Window = self.Window,
        Parent = self,
        _order = 0,
        _isSubTab = true,
        _index = index,
        _iconName = opts.Icon,
    }, Tab)
    local frame = create("Frame", {
        Name = sub.Name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = ui.Area,
    })
    sub._frame = frame
    buildContainer(sub, frame, 0, opts.Icon or self._iconName or "layout-grid", opts.EmptyText or "Nothing here yet")

    local button = create("TextButton", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = index,
        Parent = ui.Row,
    })
    padding(button, 14, 14)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = button,
    })
    if opts.Icon then
        local image = create("ImageLabel", {
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Muted,
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 1,
            Parent = button,
        })
        applyIcon(image, opts.Icon)
        if image:GetAttribute("CustomIcon") then
            image.ImageTransparency = 0.4
        end
        sub._iconImage = image
    end
    sub._label = label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = sub.Name,
        TextSize = 13,
        TextColor3 = Theme.Muted,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = button,
    })
    sub._button = button
    button.MouseEnter:Connect(function()
        if self.CurrentSubTab ~= sub then
            tween(sub._label, { TextColor3 = Theme.Text }, 0.12)
        end
    end)
    button.MouseLeave:Connect(function()
        if self.CurrentSubTab ~= sub then
            tween(sub._label, { TextColor3 = Theme.Muted }, 0.2)
        end
    end)
    button.MouseButton1Click:Connect(function()
        self:SelectSubTab(sub)
    end)

    table.insert(self._subTabs, sub)
    if index == 1 then
        self:SelectSubTab(sub, true)
    end
    return sub
end

Tab.CreateSubTab = Tab.SubTab
Tab.AddSubTab = Tab.SubTab

function Tab:SelectSubTab(sub, instant)
    if type(sub) ~= "table" then
        for index, entry in ipairs(self._subTabs or {}) do
            if entry.Name == sub or index == sub then
                sub = entry
                break
            end
        end
    end
    if type(sub) ~= "table" or not self._sub then
        return
    end
    local previous = self.CurrentSubTab
    if previous == sub then
        return
    end
    self.Window:_resetSearch()
    self.Window:_closePopups()
    self.CurrentSubTab = sub
    local ui = self._sub
    settleSubOut(ui)
    settleSubIn(ui)
    ui.Generation += 1
    local generation = ui.Generation

    local fade = instant and 0 or 0.2
    if previous then
        tween(previous._label, { TextColor3 = Theme.Muted }, fade)
        if previous._iconImage then
            tintIcon(previous._iconImage, Theme.Muted, false, fade)
        end
    end
    tween(sub._label, { TextColor3 = Theme.Text }, fade)
    if sub._iconImage then
        tintIcon(sub._iconImage, Theme.Accent, true, fade)
    end
    self:_placeSubHighlight(sub, instant)

    if instant or not previous then
        if previous then
            previous._frame.Visible = false
        end
        sub._frame.Visible = true
        return
    end

    local direction = sub._index > previous._index and 1 or -1
    ui.OutFrame = previous._frame
    previous._frame.Parent = ui.Out
    ui.Out.GroupTransparency = 0
    ui.Out.Position = UDim2.fromOffset(0, 0)
    ui.Out.Visible = true
    tween(ui.Out, { GroupTransparency = 1, Position = UDim2.fromOffset(-direction * 28, 0) }, 0.2)

    ui.InFrame = sub._frame
    sub._frame.Visible = true
    sub._frame.Parent = ui.In
    ui.In.GroupTransparency = 1
    ui.In.Position = UDim2.fromOffset(direction * 28, 0)
    ui.In.Visible = true
    tween(ui.In, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, 0.34, Enum.EasingStyle.Quint)

    task.delay(0.2, function()
        if ui.Generation == generation then
            settleSubOut(ui)
        end
    end)
    task.delay(0.34, function()
        if ui.Generation == generation then
            settleSubIn(ui)
        end
    end)
end

-- Search: one box over the whole window. Typing lists matching tabs, pages,
-- groupboxes and controls from every tab; picking one opens its tab and page,
-- scrolls it into view and flashes it.

Window._searchIcons = {
    Tab = "app-window",
    Page = "panels-top-left",
    Groupbox = "layout-grid",
    Button = "mouse-pointer-click",
    ButtonRow = "mouse-pointer-click",
    Toggle = "toggle-right",
    Slider = "sliders-horizontal",
    Dropdown = "list",
    Input = "text-cursor-input",
    Keybind = "keyboard",
    ColorPicker = "palette",
    Stepper = "chevrons-up-down",
    Progress = "activity",
    Status = "activity",
    StatusList = "activity",
    Label = "type",
    Paragraph = "type",
    OrderList = "list-ordered",
}

function Window:_searchResults(query)
    local results = {}
    local function consider(name, entry)
        if type(name) ~= "string" or name == "" then
            return
        end
        local at = string.find(string.lower(name), query, 1, true)
        if not at then
            return
        end
        entry.Name = name
        entry.At = at
        -- Name starts first, then word starts, then anywhere inside a word.
        entry.Rank = at == 1 and 0 or (string.find(string.sub(name, at - 1, at - 1), "[%s%p]") and 1 or 2)
        entry.Order = #results + 1
        table.insert(results, entry)
    end
    local function shown(element)
        return not element._destroyed
            and element._type ~= "Section" and element._type ~= "Divider"
            and (element._isShown == nil or element:_isShown())
    end
    for _, tab in ipairs(self.Tabs) do
        consider(tab.Name, { Kind = "Tab", Tab = tab, Icon = tab._iconName })
        for _, page in ipairs(tab._subTabs or { tab }) do
            local sub = page._isSubTab and page or nil
            local path = tab.Name
            if sub then
                consider(sub.Name, { Kind = "Page", Tab = tab, Sub = sub, Path = tab.Name })
                path = tab.Name .. "  ›  " .. sub.Name
            end
            if not page._noSearch then
                for _, element in ipairs(page._items or {}) do
                    if shown(element) then
                        consider(element._searchName, { Kind = element._type, Tab = tab, Sub = sub, Target = element, Path = path })
                    end
                end
                for _, group in ipairs(page._groupboxes or {}) do
                    if group._userVisible ~= false then
                        consider(group.Name, { Kind = "Groupbox", Tab = tab, Sub = sub, Target = group, Path = path })
                        local groupPath = path .. "  ›  " .. group.Name
                        for _, element in ipairs(group._items) do
                            if shown(element) then
                                consider(element._searchName, { Kind = element._type, Tab = tab, Sub = sub, Target = element, Group = group, Path = groupPath })
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(results, function(a, b)
        if a.Rank ~= b.Rank then
            return a.Rank < b.Rank
        end
        return a.Order < b.Order
    end)
    return results
end

-- Marks a found control: it pops, a soft accent glow blooms around it, a
-- sheen of light sweeps across it and a bright spot runs round its border,
-- then everything breathes once more and fades.
function Window:_flash(frame, radius)
    for _, name in ipairs({ "SearchFlash", "SearchGlow" }) do
        local old = frame:FindFirstChild(name)
        if old then
            old:Destroy()
        end
    end
    radius = radius or 8
    local accent = Theme.Accent
    local bright = accent:Lerp(Color3.new(1, 1, 1), 0.65)

    -- Outer glow: a wide, faint stroke around a second outline.
    local halo = create("Frame", {
        Name = "SearchGlow",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 10,
        Parent = frame,
    })
    corner(halo, UDim.new(0, radius))
    local haloStroke = create("UIStroke", {
        Color = accent,
        Thickness = 1,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = halo,
    })

    -- Wash with a moving sheen: a brighter diagonal band crosses it once.
    local wash = create("Frame", {
        Name = "SearchFlash",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10,
        Parent = frame,
    })
    corner(wash, UDim.new(0, radius))
    local sheen = create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(0.4, 0.55),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(0.6, 0.55),
            NumberSequenceKeypoint.new(1, 0.7),
        }),
        Rotation = 18,
        Offset = Vector2.new(-1, 0),
        Parent = wash,
    })

    -- Border light: the ring's gradient turns, so a bright spot runs round it.
    local ring = create("UIStroke", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1.6,
        Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = wash,
    })
    local runner = create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(0.5, bright),
            ColorSequenceKeypoint.new(1, accent),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.45),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.45),
        }),
        Parent = ring,
    })

    -- Groupboxes clip their rows, so anything drawn outside a control is cut
    -- off at its corners. The strokes go on the inside of the control where
    -- the engine supports it; otherwise everything is inset by its width.
    local inside = pcall(function()
        haloStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
        ring.BorderStrokePosition = Enum.BorderStrokePosition.Inner
    end)
    local glowWidth = inside and 6 or 3
    if not inside then
        halo.Position = UDim2.fromOffset(glowWidth + 1, glowWidth + 1)
        halo.Size = UDim2.new(1, -(glowWidth + 1) * 2, 1, -(glowWidth + 1) * 2)
        wash.Position = UDim2.fromOffset(2, 2)
        wash.Size = UDim2.new(1, -4, 1, -4)
    end

    -- A small pop, unless something else is scaling the control already. It
    -- never grows past full size, which would be clipped as well.
    local pop
    if not frame:FindFirstChildOfClass("UIScale") then
        pop = create("UIScale", { Scale = 0.975, Parent = frame })
        tween(pop, { Scale = 1 }, 0.4, Enum.EasingStyle.Quint)
    end

    tween(wash, { BackgroundTransparency = 0.8 }, 0.2, Enum.EasingStyle.Quad)
    tween(ring, { Transparency = 0 }, 0.2, Enum.EasingStyle.Quad)
    tween(haloStroke, { Thickness = glowWidth, Transparency = 0.72 }, 0.35, Enum.EasingStyle.Quint)
    tween(sheen, { Offset = Vector2.new(1, 0) }, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    tween(runner, { Rotation = 540 }, 2.2, Enum.EasingStyle.Quad)
    task.spawn(function()
        task.wait(0.75)
        -- One softer breath, then fade out.
        tween(wash, { BackgroundTransparency = 0.9 }, 0.35, Enum.EasingStyle.Sine)
        tween(haloStroke, { Thickness = glowWidth / 2, Transparency = 0.85 }, 0.35, Enum.EasingStyle.Sine)
        task.wait(0.35)
        tween(wash, { BackgroundTransparency = 0.84 }, 0.3, Enum.EasingStyle.Sine)
        tween(haloStroke, { Thickness = glowWidth * 0.85, Transparency = 0.76 }, 0.3, Enum.EasingStyle.Sine)
        task.wait(0.4)
        tween(wash, { BackgroundTransparency = 1 }, 0.55, Enum.EasingStyle.Quad)
        tween(ring, { Transparency = 1 }, 0.65, Enum.EasingStyle.Quad)
        tween(haloStroke, { Thickness = glowWidth, Transparency = 1 }, 0.65, Enum.EasingStyle.Quad)
        task.wait(0.7)
        wash:Destroy()
        halo:Destroy()
        if pop then
            pop:Destroy()
        end
    end)
end

function Window:_revealResult(result)
    local tab, sub, target, group = result.Tab, result.Sub, result.Target, result.Group
    if self.CurrentTab ~= tab then
        self:SelectTab(tab)
    end
    if sub then
        tab:SelectSubTab(sub)
    end
    if not target then
        local button = sub and sub._button or tab._button
        task.delay(0.1, function()
            if button.Parent then
                self:_flash(button, sub and 8 or 10)
            end
        end)
        return
    end
    local expanding = group ~= nil and group:IsCollapsed()
    if expanding then
        group:Expand()
    end
    local list = (sub or tab).List
    task.spawn(function()
        -- Let the freshly shown page lay out before measuring it.
        task.wait()
        task.wait()
        if expanding then
            task.wait(0.3)
        end
        local frame = target._frame
        if self._destroyed or target._destroyed or not frame or not frame.Parent or not list then
            return
        end
        local scale = self.Scale.Scale
        local top = (frame.AbsolutePosition.Y - list.AbsolutePosition.Y) / scale + list.CanvasPosition.Y
        local height = frame.AbsoluteSize.Y / scale
        local view = list.AbsoluteWindowSize.Y / scale
        local limit = math.max(list.AbsoluteCanvasSize.Y / scale - view, 0)
        local y = math.clamp(top + height / 2 - view / 2, 0, limit)
        if math.abs(y - list.CanvasPosition.Y) > 2 then
            tween(list, { CanvasPosition = Vector2.new(0, y) }, 0.45, Enum.EasingStyle.Quint)
            task.wait(0.25)
        end
        if frame.Parent then
            self:_flash(frame, target._groupbox and 10 or 8)
        end
    end)
end

function Window:_resetSearch()
    if self.SearchBox and self.SearchBox.Text ~= "" then
        self.SearchBox.Text = ""
    end
end

-- Page titles stop short of the search box and close button.
function Window:_fitTitle(tab)
    local right = self.SearchBox and (self._searchWidth or SEARCH_WIDTH) + 72 or 56
    local reserve = tab._titleX + right
    tab._title.Size = UDim2.new(1, -reserve, 0, 24)
    if tab._desc then
        tab._desc.Size = UDim2.new(1, -reserve, 0, 16)
    end
end

function Window:_buildSearch(content)
    -- No box: the icon and text sit on a thin baseline. Focus draws an
    -- accent line out from the middle of it.
    local holder = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -56, 0, 14),
        Size = UDim2.fromOffset(SEARCH_WIDTH, 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = content,
    })
    holder:SetAttribute("NoDrag", true)
    local baseline = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = holder,
    })
    local focusLine = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -1),
        Size = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = holder,
    })
    corner(focusLine, UDim.new(1, 0))
    -- Kept for the focus handlers below, which recolour it.
    local _, icon = glowIcon(holder, "search", Theme.Muted, UDim2.new(0, 2, 0.5, -1))
    icon.Parent.Size = UDim2.fromOffset(15, 15)
    local box = create("TextBox", {
        Position = UDim2.fromOffset(26, 0),
        Size = UDim2.new(1, -28, 1, -2),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = false,
        Parent = holder,
    })
    holder.MouseEnter:Connect(function()
        if not box:IsFocused() then
            tween(baseline, { BackgroundColor3 = Theme.StrokeHover }, 0.15)
        end
    end)
    holder.MouseLeave:Connect(function()
        tween(baseline, { BackgroundColor3 = Theme.Stroke }, 0.25)
    end)
    self.SearchBox = box

    -- Results float over the window under the box, like a dropdown popup.
    local rowHeight = TOUCH and 40 or 34
    local maxRows = 8
    local popup = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.fromOffset(300, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 45,
        Parent = self.Body,
    })
    popup:SetAttribute("NoDrag", true)
    local popupShadow = create("ImageLabel", {
        Position = UDim2.fromOffset(-18, -12),
        Size = UDim2.new(1, 36, 1, 36),
        BackgroundTransparency = 1,
        Image = Assets.Shadow,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = popup,
    })
    local panel = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = popup,
    })
    corner(panel, UDim.new(0, 10))
    local panelStroke = stroke(panel, Theme.Stroke, 1)
    edgeHighlight(panel)
    local list = create("ScrollingFrame", {
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 1, -12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = TOUCH and 4 or 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(),
        Parent = panel,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = list,
    })
    local noResults = label({
        Size = UDim2.new(1, 0, 0, rowHeight),
        Text = "No results",
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 0,
        Visible = false,
        Parent = list,
    })

    local rows = {}
    local results = {}
    local selected = 1
    local open = false
    local generation = 0
    local shownSize = Vector2.new(300, 0)
    local stopFollowing = nil
    local closeResults

    local function place()
        local scale = self.Scale.Scale
        local bodyPosition = self.Body.AbsolutePosition
        local bodyWidth = self.Body.AbsoluteSize.X / scale
        local right = (holder.AbsolutePosition.X + holder.AbsoluteSize.X - bodyPosition.X) / scale
        local top = (holder.AbsolutePosition.Y + holder.AbsoluteSize.Y - bodyPosition.Y) / scale + 6
        right = math.clamp(right, shownSize.X + 8, math.max(bodyWidth - 8, shownSize.X + 8))
        popup.Position = UDim2.fromOffset(right, top)
    end

    local function measure()
        local scale = self.Scale.Scale
        local bodySize = self.Body.AbsoluteSize / scale
        local below = (holder.AbsolutePosition.Y + holder.AbsoluteSize.Y - self.Body.AbsolutePosition.Y) / scale + 6
        local count = math.max(#rows, 1)
        local height = math.min(count, maxRows) * (rowHeight + 2) - 2 + 12
        height = math.max(math.min(height, bodySize.Y - below - 12), rowHeight + 12)
        local width = math.min(math.max(holder.AbsoluteSize.X / scale, 300), math.max(bodySize.X - 16, 160))
        shownSize = Vector2.new(width, height)
    end

    local function paintSelection()
        for index, row in ipairs(rows) do
            local on = index == selected
            tween(row.Button, { BackgroundTransparency = on and 0.35 or 1 }, 0.12)
            tintIcon(row.Icon, on and Theme.Accent or Theme.Muted, on, 0.12)
        end
    end

    local function keepSelectionInView()
        local rowTop = (selected - 1) * (rowHeight + 2)
        local view = list.AbsoluteWindowSize.Y / self.Scale.Scale
        local y = list.CanvasPosition.Y
        if rowTop < y then
            y = rowTop
        elseif rowTop + rowHeight > y + view then
            y = rowTop + rowHeight - view
        else
            return
        end
        list.CanvasPosition = Vector2.new(0, math.max(y, 0))
    end

    local function setOpen(value)
        if value == open then
            return
        end
        open = value
        generation += 1
        local current = generation
        if value then
            if self._closePopup and self._closePopup ~= closeResults then
                self._closePopup()
            end
            self._closePopup = closeResults
            place()
            popup.Size = UDim2.fromOffset(shownSize.X, 0)
            popup.Visible = true
            tween(popup, { Size = UDim2.fromOffset(shownSize.X, shownSize.Y) }, 0.26, Enum.EasingStyle.Quint)
            tween(panelStroke, { Transparency = 0 }, 0.12)
            tween(popupShadow, { ImageTransparency = 0.55 }, 0.26)
            if not stopFollowing then
                stopFollowing = self:_listen("Render", place)
            end
        else
            if self._closePopup == closeResults then
                self._closePopup = nil
            end
            tween(popup, { Size = UDim2.fromOffset(shownSize.X, 0) }, 0.18, Enum.EasingStyle.Quint)
            tween(popupShadow, { ImageTransparency = 1 }, 0.14)
            task.delay(0.19, function()
                if generation == current and not open then
                    popup.Visible = false
                    panelStroke.Transparency = 1
                    if stopFollowing then
                        stopFollowing()
                        stopFollowing = nil
                    end
                end
            end)
        end
    end
    closeResults = function()
        setOpen(false)
    end

    local function choose(result)
        if not result then
            return
        end
        setOpen(false)
        box.Text = ""
        if box:IsFocused() then
            box:ReleaseFocus()
        end
        self:_revealResult(result)
    end

    local function escape(text)
        return (string.gsub(string.gsub(string.gsub(text, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
    end

    local function render(query)
        for _, row in ipairs(rows) do
            row.Button:Destroy()
        end
        table.clear(rows)
        results = self:_searchResults(query)
        selected = 1
        local accent = colorToHex(Theme.Accent)
        for index, result in ipairs(results) do
            if index > 50 then
                break
            end
            local button = create("TextButton", {
                Size = UDim2.new(1, 0, 0, rowHeight),
                BackgroundColor3 = Theme.Surface3,
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = index,
                Parent = list,
            })
            corner(button, UDim.new(0, 7))
            -- One line of breadcrumbs: tab, sub tab and groupbox in muted
            -- text, each split by a chevron, ending on the match in accent.
            local crumbs = create("Frame", {
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Parent = button,
            })
            create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                Parent = crumbs,
            })
            local part = 0
            local firstIcon = nil
            local function crumbIcon(icon)
                if not icon then
                    return
                end
                part += 1
                local image = create("ImageLabel", {
                    Size = UDim2.fromOffset(14, 14),
                    BackgroundTransparency = 1,
                    ImageColor3 = Theme.Muted,
                    ScaleType = Enum.ScaleType.Fit,
                    LayoutOrder = part,
                    Parent = crumbs,
                })
                applyIcon(image, icon)
                firstIcon = firstIcon or image
            end
            local function crumbText(text, color, rich)
                part += 1
                return label({
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Text = text,
                    RichText = rich == true,
                    TextSize = 13,
                    FontFace = color and Fonts.Medium or Fonts.Regular,
                    TextColor3 = color or Theme.Muted,
                    TextTruncate = Enum.TextTruncate.None,
                    LayoutOrder = part,
                    Parent = crumbs,
                })
            end
            local function chevron()
                crumbText(">")
            end
            local tab, sub, group = result.Tab, result.Sub, result.Group
            local onTab = result.Kind == "Tab"
            local onSub = result.Kind == "Page"
            local onGroup = result.Kind == "Groupbox"
            crumbIcon(tab._iconName or "layout-grid")
            if not onTab then
                crumbText(tab.Name)
                if sub then
                    chevron()
                    crumbIcon(sub._iconName or "layers")
                    if not onSub then
                        crumbText(sub.Name)
                    end
                end
                if group and not onGroup then
                    chevron()
                    crumbText(group.Name)
                end
                if not onSub then
                    chevron()
                end
            end
            -- The match itself: accent, with the typed part in bold.
            local name = result.Name
            local stop = result.At + #query
            local marked = escape(string.sub(name, 1, result.At - 1))
                .. "<b>" .. escape(string.sub(name, result.At, stop - 1)) .. "</b>"
                .. escape(string.sub(name, stop))
            crumbText(marked, Theme.Accent, true)
            local image = firstIcon
            local isTap = tapGuard(button, function()
                return list
            end)
            button.MouseEnter:Connect(function()
                if not usingTouch() then
                    selected = index
                    paintSelection()
                end
            end)
            button.MouseButton1Click:Connect(function()
                if isTap() then
                    choose(result)
                end
            end)
            table.insert(rows, { Button = button, Icon = image })
        end
        noResults.Visible = #rows == 0
        list.CanvasSize = UDim2.fromOffset(0, math.max(#rows, 1) * (rowHeight + 2) - 2)
        list.CanvasPosition = Vector2.zero
        paintSelection()
        measure()
        if open then
            place()
            tween(popup, { Size = UDim2.fromOffset(shownSize.X, shownSize.Y) }, 0.2, Enum.EasingStyle.Quint)
        end
    end

    local function update()
        local query = string.match(string.lower(box.Text), "^%s*(.-)%s*$")
        if query == "" then
            setOpen(false)
            return
        end
        render(query)
        setOpen(true)
    end

    box.Focused:Connect(function()
        tween(focusLine, { Size = UDim2.new(1, 0, 0, 2) }, 0.35, Enum.EasingStyle.Quint)
        tween(icon, { ImageColor3 = Theme.Accent }, 0.15)
        if box.Text ~= "" then
            update()
        end
    end)
    box.FocusLost:Connect(function(enterPressed)
        tween(focusLine, { Size = UDim2.new(0, 0, 0, 2) }, 0.3, Enum.EasingStyle.Quint)
        tween(icon, { ImageColor3 = Theme.Muted }, 0.2)
        if enterPressed and open then
            choose(results[selected])
        end
    end)
    box:GetPropertyChangedSignal("Text"):Connect(update)
    self:_listen("Began", function(input)
        if not open then
            return
        end
        if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down then
            if #rows > 0 then
                local step = input.KeyCode == Enum.KeyCode.Up and -1 or 1
                selected = math.clamp(selected + step, 1, #rows)
                paintSelection()
                keepSelectionInView()
            end
        elseif input.KeyCode == Enum.KeyCode.Escape then
            setOpen(false)
        elseif isPress(input) then
            local point = pointerPosition()
            if not pointInside(point, popup) and not pointInside(point, holder) then
                setOpen(false)
            end
        end
    end)

    local function fit()
        local width = content.AbsoluteSize.X / self.Scale.Scale
        local searchWidth = math.clamp(math.floor(width * 0.32), 110, SEARCH_WIDTH)
        holder.Size = UDim2.fromOffset(searchWidth, 34)
        if searchWidth ~= self._searchWidth then
            self._searchWidth = searchWidth
            for _, tab in ipairs(self.Tabs) do
                self:_fitTitle(tab)
            end
        end
    end
    content:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    task.defer(fit)
end

-- Identity: the player's name and headshot shown in the sidebar and on the
-- home tab. The privacy switches hide them everywhere at once.

function Window:_trackName(textLabel, kind)
    table.insert(self._identity.Names, { Label = textLabel, Kind = kind })
    self:_renderIdentity()
end

function Window:_trackAvatar(image, placeholder)
    table.insert(self._identity.Avatars, { Image = image, Placeholder = placeholder })
    self:_renderIdentity(true)
end

function Window:_renderIdentity(instant)
    for _, entry in ipairs(self._identity.Names) do
        if entry.Kind == "User" then
            entry.Label.Text = self._hideName and "@hidden" or ("@" .. LocalPlayer.Name)
        else
            entry.Label.Text = self._hideName and "Hidden" or LocalPlayer.DisplayName
        end
    end
    local duration = instant and 0 or 0.2
    for _, entry in ipairs(self._identity.Avatars) do
        tween(entry.Image, { ImageTransparency = self._hideAvatar and 1 or 0 }, duration)
        tween(entry.Placeholder, { ImageTransparency = self._hideAvatar and 0.2 or 1 }, duration)
    end
end

function Window:SetHideName(hidden)
    self._hideName = hidden == true
    self:_renderIdentity()
end

function Window:SetHideAvatar(hidden)
    self._hideAvatar = hidden == true
    self:_renderIdentity()
end

local function avatar(window, parent, props, ringColor, ringTransparency, ringThickness)
    local holder = create("Frame", {
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = parent,
    })
    for key, value in pairs(props) do
        holder[key] = value
    end
    corner(holder, UDim.new(1, 0))
    stroke(holder, ringColor or Theme.Stroke, ringTransparency or 0, ringThickness or 1)
    local image = create("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
        Parent = holder,
    })
    corner(image, UDim.new(1, 0))
    local placeholder = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.45, 0.45),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    applyIcon(placeholder, "user")
    window:_trackAvatar(image, placeholder)
    return holder
end

function Window:_buildProfile(sidebar)
    create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -PROFILE_HEIGHT),
        Size = UDim2.new(1, -20, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    local card = create("TextButton", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -8),
        Size = UDim2.new(1, -16, 0, PROFILE_HEIGHT - 16),
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = sidebar,
    })
    corner(card, UDim.new(0, 8))
    local cardStroke = stroke(card, Theme.Stroke, 0)
    local head = avatar(self, card, {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 8, 0.5, 0),
        Size = UDim2.fromOffset(32, 32),
    })
    local online = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 1, 1, 1),
        Size = UDim2.fromOffset(9, 9),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = head,
    })
    corner(online, UDim.new(1, 0))
    stroke(online, Theme.Surface2, 0, 2)
    local name = label({
        Position = UDim2.new(0, 48, 0.5, -15),
        Size = UDim2.new(1, -74, 0, 15),
        TextSize = 12,
        FontFace = Fonts.Bold,
        Parent = card,
    })
    self:_trackName(name, "Display")
    local gameLabel = label({
        Position = UDim2.new(0, 48, 0.5, 1),
        Size = UDim2.new(1, -74, 0, 13),
        Text = "…",
        TextSize = 11,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = card,
    })
    local chevron = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Parent = card,
    })
    applyIcon(chevron, "chevron-right")
    task.spawn(function()
        gameLabel.Text = detectGameName()
    end)
    card.MouseEnter:Connect(function()
        if usingTouch() then
            return
        end
        tween(cardStroke, { Color = Theme.StrokeHover }, 0.12)
        tween(chevron, { ImageColor3 = Theme.Text, Position = UDim2.new(1, -6, 0.5, 0) }, 0.15)
    end)
    card.MouseLeave:Connect(function()
        tween(cardStroke, { Color = Theme.Stroke }, 0.2)
        tween(chevron, { ImageColor3 = Theme.Muted, Position = UDim2.new(1, -8, 0.5, 0) }, 0.2)
    end)
    card.MouseButton1Click:Connect(function()
        if self.Home then
            self:SelectTab(self.Home)
        end
    end)
    self.Profile = card
end

-- Server actions

function Window:Rejoin()
    self:Notify({ Title = "Rejoining", Content = "Teleporting back into this server", Icon = "refresh-cw", Duration = 3 })
    task.spawn(function()
        local ok, err = pcall(function()
            if #Players:GetPlayers() <= 1 or game.JobId == "" then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
        if not ok then
            self:Notify({ Title = "Rejoin failed", Content = tostring(err), Type = "Error", Duration = 4 })
        end
    end)
end

local function hopServers(window, order, pick, title)
    task.spawn(function()
        local servers = fetchServers(order)
        if not servers then
            window:Notify({ Title = title .. " failed", Content = "Could not load the server list", Type = "Error", Duration = 4 })
            return
        end
        local candidates = {}
        for _, server in ipairs(servers) do
            if type(server) == "table" and server.id ~= game.JobId then
                local playing, capacity = tonumber(server.playing), tonumber(server.maxPlayers)
                if playing and capacity and playing < capacity then
                    table.insert(candidates, server)
                end
            end
        end
        local target = #candidates > 0 and pick(candidates) or nil
        if not target then
            window:Notify({ Title = title .. " failed", Content = "No other open server found", Type = "Warning", Duration = 4 })
            return
        end
        window:Notify({
            Title = title,
            Content = string.format("Joining a server with %d/%d players", target.playing, target.maxPlayers),
            Icon = "server",
            Duration = 3,
        })
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
        end)
        if not ok then
            window:Notify({ Title = title .. " failed", Content = tostring(err), Type = "Error", Duration = 4 })
        end
    end)
end

function Window:ServerHop()
    hopServers(self, "Desc", function(list)
        return list[math.random(1, #list)]
    end, "Server hop")
end

function Window:JoinLowestServer()
    hopServers(self, "Asc", function(list)
        table.sort(list, function(a, b)
            return a.playing < b.playing
        end)
        return list[1]
    end, "Lowest server")
end

function Window:CopyToClipboard(text, what)
    local ok = copyToClipboard(text)
    self:Notify({
        Title = ok and "Copied" or "Clipboard unavailable",
        Content = ok and (what or tostring(text)) or "Your executor has no setclipboard",
        Type = ok and "Success" or "Error",
        Icon = ok and "clipboard-check" or nil,
        Duration = 2.5,
    })
    return ok
end

-- Home

-- Home reads top to bottom: a banner greeting the player, a performance card
-- with live graphs, the server and links side by side, and a status line.

-- A Home card that grows with its stacked contents.
function Window:_homeCard(parent, order)
    local card = panelCard(parent, 0, order)
    card.AutomaticSize = Enum.AutomaticSize.Y
    padding(card, 16, 16, 14, 14)
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
    return card
end

-- A small caps heading at the top of a Home card.
function Window:_homeCaption(parent, text, order)
    return label({
        Size = UDim2.new(1, 0, 0, 22),
        Text = string.upper(text),
        TextSize = 10,
        TextColor3 = Theme.Muted,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = order,
        Parent = parent,
    })
end

-- A rounded chip of an icon and short text. Returns the chip, its label and
-- its icon so callers can recolour them.
function Window:_homeChip(parent, order, icon, text, color)
    local chip = create("TextButton", {
        Size = UDim2.fromOffset(0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
        Parent = parent,
    })
    corner(chip, UDim.new(0, 6))
    local chipStroke = stroke(chip)
    padding(chip, 8, 9)
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = chip,
    })
    local image = create("ImageLabel", {
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        ImageColor3 = color or Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        LayoutOrder = 1,
        Parent = chip,
    })
    applyIcon(image, icon)
    local text_ = label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = text,
        TextSize = 12,
        TextColor3 = color or Theme.Muted,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = chip,
    })
    return chip, text_, image, chipStroke
end

-- A chip that flips on press: on, it takes the accent; off, it sits muted.
function Window:_homeToggleChip(parent, order, icon, text, initial, callback)
    local chip, text_, image, chipStroke = self:_homeChip(parent, order, icon, text)
    local on = initial == true
    local function paint(duration)
        tween(chip, { BackgroundColor3 = on and Theme.Accent or Theme.Surface3, BackgroundTransparency = on and 0.85 or 0.2 }, duration)
        tween(chipStroke, { Color = on and Theme.Accent or Theme.Stroke, Transparency = on and 0.6 or 0 }, duration)
        tween(text_, { TextColor3 = on and Theme.Accent or Theme.Muted }, duration)
        tween(image, { ImageColor3 = on and Theme.Accent or Theme.Muted }, duration)
    end
    paint(0)
    chip.MouseButton1Click:Connect(function()
        on = not on
        paint(0.2)
        safeCall(callback, on)
    end)
    return chip
end

function Window:_homeProfile(list, opts, order)
    local banner = panelCard(list, 140, order)
    banner.ClipsDescendants = true

    -- The avatar bust stands on the banner's right edge and fades in from
    -- the left, so it reads as part of the card rather than a framed photo.
    local bust = create("ImageLabel", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, 0),
        Size = UDim2.fromOffset(140, 140),
        BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarBust&id=" .. tostring(LocalPlayer.UserId) .. "&w=420&h=420",
        ScaleType = Enum.ScaleType.Fit,
        Parent = banner,
    })
    create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.45, 0),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = bust,
    })
    local bustPlaceholder = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.6, 0.55),
        Size = UDim2.fromOffset(40, 40),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Parent = bust,
    })
    applyIcon(bustPlaceholder, "user")
    self:_trackAvatar(bust, bustPlaceholder)

    local textWidth = UDim2.new(1, -190, 0, 0)
    label({
        Position = UDim2.fromOffset(22, 20),
        Size = textWidth + UDim2.fromOffset(0, 14),
        Text = string.upper(opts.Welcome or "Welcome back"),
        TextSize = 10,
        TextColor3 = Theme.Muted,
        Parent = banner,
    })
    local nameLabel = label({
        Position = UDim2.fromOffset(22, 35),
        Size = textWidth + UDim2.fromOffset(0, 32),
        TextSize = 26,
        FontFace = Fonts.Bold,
        Parent = banner,
    })
    self:_trackName(nameLabel, "Display")
    local userLabel = label({
        Position = UDim2.fromOffset(22, 67),
        Size = textWidth + UDim2.fromOffset(0, 16),
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = banner,
    })
    self:_trackName(userLabel, "User")

    -- Chips along the bottom: tier, time left, then the privacy toggles.
    local chips = create("Frame", {
        Position = UDim2.new(0, 22, 1, -40),
        Size = UDim2.new(1, -44, 0, 24),
        BackgroundTransparency = 1,
        Parent = banner,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = chips,
    })
    local tier = opts.Tier
    if tier == nil then
        tier = "Free"
    end
    if tier then
        local tierChip, tierText, tierIcon = self:_homeChip(chips, 1, opts.TierIcon or self._logoIcon, tostring(tier), Theme.Accent)
        tierChip.Active = false
        tierText.FontFace = Fonts.Bold
        tierIcon.Size = UDim2.fromOffset(13, 13)
        self.TierLabel = tierText
    end
    local expiryChip, expiryText = self:_homeChip(chips, 2, "clock", "")
    expiryChip.Active = false
    expiryChip.Visible = false
    self:_homeToggleChip(chips, 3, "eye-off", "Name", self._hideName, function(on)
        self:SetHideName(on)
    end)
    self:_homeToggleChip(chips, 4, "user-x", "Avatar", self._hideAvatar, function(on)
        self:SetHideAvatar(on)
    end)

    return function()
        local value = opts.Expiry
        if type(value) == "function" then
            local ok, result = pcall(value)
            value = ok and result or nil
        end
        if type(value) == "number" then
            local left = value - os.time()
            expiryText.Text = left > 0 and (formatDuration(left) .. " left") or "Expired"
        elseif value ~= nil then
            expiryText.Text = tostring(value)
        end
        expiryChip.Visible = expiryText.Text ~= ""
    end
end

-- A large live readout with a short bar history under it. Returns the value
-- label and a push(value, color) that adds a sample.
function Window:_homeGraph(parent, order, icon, title, ceiling)
    local cell = create("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = parent,
    })
    local holder = glowIcon(cell, icon, Theme.Muted, UDim2.new(0, 0, 0, 7))
    holder.Size = UDim2.fromOffset(12, 12)
    label({
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -18, 0, 14),
        Text = string.upper(title),
        TextSize = 10,
        TextColor3 = Theme.Muted,
        Parent = cell,
    })
    local value = label({
        Position = UDim2.fromOffset(0, 16),
        Size = UDim2.new(1, 0, 0, 28),
        Text = "…",
        TextSize = 24,
        FontFace = Fonts.Bold,
        RichText = true,
        Parent = cell,
    })
    local track = create("Frame", {
        Position = UDim2.fromOffset(0, 50),
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = cell,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = track,
    })
    local COUNT = 24
    local bars, samples = {}, {}
    for index = 1, COUNT do
        local bar = create("Frame", {
            Size = UDim2.new(1 / COUNT, -2, 0, 2),
            BackgroundColor3 = Theme.Surface3,
            BorderSizePixel = 0,
            LayoutOrder = index,
            Parent = track,
        })
        corner(bar, UDim.new(0, 2))
        bars[index] = bar
    end
    local function push(sample, color)
        table.insert(samples, sample)
        if #samples > COUNT then
            table.remove(samples, 1)
        end
        local top = ceiling or 1
        for _, s in ipairs(samples) do
            top = math.max(top, s)
        end
        local offset = COUNT - #samples
        for index, bar in ipairs(bars) do
            local s = samples[index - offset]
            local latest = index == COUNT
            local height = s and math.max(s / top, 0.08) or 0
            tween(bar, {
                Size = UDim2.new(1 / COUNT, -2, height, s and 0 or 2),
                BackgroundColor3 = (latest and color) or (s and Theme.Muted or Theme.Surface3),
                BackgroundTransparency = latest and 0 or (s and 0.6 or 0),
            }, 0.35, Enum.EasingStyle.Quint)
        end
    end
    return value, push
end

-- A small figure: value over a caps caption.
function Window:_homeFigure(parent, order, title)
    local cell = create("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = parent,
    })
    local value = label({
        Size = UDim2.new(1, -8, 0, 20),
        Text = "…",
        TextSize = 15,
        FontFace = Fonts.Bold,
        RichText = true,
        Parent = cell,
    })
    label({
        Position = UDim2.fromOffset(0, 21),
        Size = UDim2.new(1, -8, 0, 14),
        Text = string.upper(title),
        TextSize = 10,
        TextColor3 = Theme.Muted,
        Parent = cell,
    })
    return value
end

-- A square tile button: an icon over a short label.
function Window:_homeAction(parent, order, icon, text, callback)
    local button = create("TextButton", {
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        LayoutOrder = order,
        Parent = parent,
    })
    corner(button, UDim.new(0, 8))
    local buttonStroke = stroke(button)
    local image = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 11),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Text,
        ScaleType = Enum.ScaleType.Fit,
        Parent = button,
    })
    applyIcon(image, icon)
    label({
        Position = UDim2.new(0, 4, 0, 32),
        Size = UDim2.new(1, -8, 0, 14),
        Text = text,
        TextSize = 11,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = button,
    })
    button.MouseEnter:Connect(function()
        tween(button, { BackgroundTransparency = 0 }, 0.15, Enum.EasingStyle.Quint)
        tween(buttonStroke, { Color = Theme.StrokeHover }, 0.15)
        tween(image, { ImageColor3 = Theme.Accent }, 0.15)
    end)
    button.MouseLeave:Connect(function()
        tween(button, { BackgroundTransparency = 0.5 }, 0.25, Enum.EasingStyle.Quint)
        tween(buttonStroke, { Color = Theme.Stroke }, 0.25)
        tween(image, { ImageColor3 = Theme.Text }, 0.25)
    end)
    button.MouseButton1Click:Connect(function()
        ripple(button)
        safeCall(callback)
    end)
    return button
end

function Window:_homeGame(parent, order)
    local card = self:_homeCard(parent, order)
    local head = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = card,
    })
    local icon = create("ImageLabel", {
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150",
        Parent = head,
    })
    corner(icon, UDim.new(0, 10))
    stroke(icon)
    local gameName = label({
        Position = UDim2.fromOffset(56, 3),
        Size = UDim2.new(1, -56, 0, 20),
        Text = "Loading",
        TextSize = 15,
        FontFace = Fonts.Bold,
        Parent = head,
    })
    local detail = label({
        Position = UDim2.fromOffset(56, 24),
        Size = UDim2.new(1, -56, 0, 16),
        Text = "",
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = head,
    })
    local owner = nil
    task.spawn(function()
        local info = fetchGameInfo()
        gameName.Text = info and info.Name or detectGameName()
        owner = info and type(info.Creator) == "table" and info.Creator.Name or nil
    end)

    local actions = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = card,
    })
    padding(actions, 0, 0, 12, 0)
    create("UIGridLayout", {
        CellPadding = UDim2.fromOffset(6, 6),
        CellSize = UDim2.new(0.25, -5, 0, 54),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actions,
    })
    self:_homeAction(actions, 1, "refresh-cw", "Rejoin", function()
        self:Rejoin()
    end)
    self:_homeAction(actions, 2, "shuffle", "Hop", function()
        self:ServerHop()
    end)
    self:_homeAction(actions, 3, "users", "Lowest", function()
        self:JoinLowestServer()
    end)
    self:_homeAction(actions, 4, "copy", "Job ID", function()
        self:CopyToClipboard(game.JobId, "Job ID")
    end)

    label({
        Size = UDim2.new(1, 0, 0, 26),
        Text = "Job " .. shortId(game.JobId) .. "  ·  Place " .. tostring(game.PlaceId),
        TextSize = 11,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        LayoutOrder = 3,
        Parent = card,
    })

    -- The detail line keeps the player count live.
    return function()
        local count = #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. " players"
        detail.Text = owner and ("by " .. owner .. "  ·  " .. count) or count
    end
end

-- One row of the links card: icon, title and text, and a round icon button.
function Window:_homeLink(card, order, icon, title, text, buttonIcon, callback)
    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = card,
    })
    create("Frame", {
        Name = "Rule",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = row,
    })
    local holder = glowIcon(row, icon, Theme.Accent, UDim2.new(0, 0, 0.5, 0))
    holder.Size = UDim2.fromOffset(16, 16)
    local titleLabel = label({
        Position = UDim2.fromOffset(28, 6),
        Size = UDim2.new(1, -68, 0, 18),
        Text = title,
        TextSize = 13,
        Parent = row,
    })
    local textLabel = label({
        Position = UDim2.fromOffset(28, 24),
        Size = UDim2.new(1, -68, 0, 15),
        Text = text,
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = row,
    })
    local button = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    corner(button, UDim.new(0, 8))
    local buttonStroke = stroke(button)
    local image = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Parent = button,
    })
    applyIcon(image, buttonIcon)
    button.MouseEnter:Connect(function()
        tween(button, { BackgroundTransparency = 0 }, 0.15, Enum.EasingStyle.Quint)
        tween(buttonStroke, { Color = Theme.StrokeHover }, 0.15)
        tween(image, { ImageColor3 = Theme.Accent }, 0.15)
    end)
    button.MouseLeave:Connect(function()
        tween(button, { BackgroundTransparency = 0.5 }, 0.25, Enum.EasingStyle.Quint)
        tween(buttonStroke, { Color = Theme.Stroke }, 0.25)
        tween(image, { ImageColor3 = Theme.Muted }, 0.25)
    end)
    button.MouseButton1Click:Connect(function()
        safeCall(callback)
    end)
    return row, titleLabel, textLabel
end

-- Builds the links card into parent, or nothing when there are no links and
-- the feature list is off. Returns the card (or nil) and the feature refresh.
function Window:_homeLinks(parent, opts, order)
    local links = {}
    if opts.Discord then
        table.insert(links, {
            Icon = opts.DiscordIcon or "message-circle",
            Title = opts.DiscordTitle or "Community",
            Text = opts.Discord,
        })
    end
    if opts.Website then
        table.insert(links, {
            Icon = opts.WebsiteIcon or "globe",
            Title = opts.WebsiteTitle or "Website",
            Text = opts.Website,
        })
    end
    for _, link in ipairs(opts.Links or {}) do
        table.insert(links, link)
    end
    local features = opts.Features
    if #links == 0 and features == false then
        return nil, function() end
    end
    local card = self:_homeCard(parent, order)
    self:_homeCaption(card, "Links", 0)
    for index, link in ipairs(links) do
        local action = type(link.Callback) == "function"
        self:_homeLink(card, index, link.Icon or "link", link.Title or "", link.Text or "", action and "arrow-up-right" or "copy", function()
            if action then
                safeCall(link.Callback)
            else
                self:CopyToClipboard(link.Copy or link.Text, link.Title)
            end
        end)
    end
    local refresh = function() end
    if features ~= false then
        if type(features) == "table" then
            self._featuresTitle = features.Title
            self._features = features.List or (#features > 0 and features or nil)
        end
        local _, _, text_ = self:_homeLink(card, 100,
            type(features) == "table" and features.Icon or "list-checks",
            type(features) == "table" and features.Title or "Feature list",
            "", "chevron-right", function()
                self:ShowFeatures()
            end)
        refresh = function()
            local desc = type(features) == "table" and features.Desc
            text_.Text = desc or (self:_featureSummary())
        end
        task.defer(refresh)
    end
    -- The first row needs no rule above it.
    local first = nil
    for _, child in ipairs(card:GetChildren()) do
        if child:IsA("Frame") and child:FindFirstChild("Rule") and (not first or child.LayoutOrder < first.LayoutOrder) then
            first = child
        end
    end
    if first then
        first.Rule.Visible = false
    end
    return card, refresh
end

-- A quiet status line under the cards: executor support on the left, the
-- hide key on the right.
function Window:_homeExecutor(list, opts, order)
    local line = create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = list,
    })
    local executor, supported, message = executorReport(opts)
    local dot = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 4, 0.5, 0),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = supported and Theme.Success or Theme.Warning,
        BorderSizePixel = 0,
        Parent = line,
    })
    corner(dot, UDim.new(1, 0))
    local left = create("Frame", {
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -170, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = line,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = left,
    })
    label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = executor,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 1,
        Parent = left,
    })
    label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = message,
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = supported and Theme.Muted or Theme.Warning,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = left,
    })

    local hint = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -2, 0.5, 0),
        Size = UDim2.fromOffset(0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = line,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = hint,
    })
    label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = TOUCH and "Tap the pill or" or "Hide with",
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 1,
        Parent = hint,
    })
    local chip = create("Frame", {
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Parent = hint,
    })
    corner(chip, UDim.new(0, 5))
    stroke(chip)
    padding(chip, 6, 6)
    self._keyChipLabel = label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = keyName(self.Keybind),
        TextSize = 11,
        FontFace = Fonts.Bold,
        TextTruncate = Enum.TextTruncate.None,
        Parent = chip,
    })
end

-- Feature list: every control the script adds, grouped by tab, or a list the
-- script writes itself. Items that match a control jump to it when picked.

Window._featureKinds = {
    Toggle = true,
    Slider = true,
    Dropdown = true,
    Input = true,
    Keybind = true,
    ColorPicker = true,
    Stepper = true,
    Button = true,
    ButtonRow = true,
    OrderList = true,
}

function Window:_featureGroups()
    local found, byName = {}, {}
    for _, tab in ipairs(self.Tabs) do
        if tab ~= self.Home and tab._userVisible ~= false then
            local group = { Name = tab.Name, Icon = tab._iconName, Items = {} }
            for _, page in ipairs(tab._subTabs or { tab }) do
                local sub = page._isSubTab and page or nil
                local function add(name, element, box, path)
                    if type(name) ~= "string" or name == "" then
                        return
                    end
                    local item = {
                        Name = name,
                        Kind = element._type == "ButtonRow" and "Button" or element._type,
                        Path = path,
                        Result = { Tab = tab, Sub = sub, Target = element, Group = box },
                    }
                    table.insert(group.Items, item)
                    byName[string.lower(name)] = byName[string.lower(name)] or item
                end
                local function addElement(element, box, path)
                    if element._destroyed or not self._featureKinds[element._type] or (element._isShown and not element:_isShown()) then
                        return
                    end
                    if element._type == "ButtonRow" and element.Buttons then
                        for _, button in ipairs(element.Buttons) do
                            add(button.Label.Text, element, box, path)
                        end
                    else
                        add(element._searchName, element, box, path)
                    end
                end
                if not page._noSearch then
                    for _, element in ipairs(page._items or {}) do
                        addElement(element, nil, sub and sub.Name or nil)
                    end
                    for _, box in ipairs(page._groupboxes or {}) do
                        if box._userVisible ~= false and not box._manager then
                            for _, element in ipairs(box._items) do
                                addElement(element, box, sub and (sub.Name .. "  ›  " .. box.Name) or box.Name)
                            end
                        end
                    end
                end
            end
            if #group.Items > 0 then
                table.insert(found, group)
            end
        end
    end
    local custom = self._features
    if type(custom) ~= "table" then
        return found
    end
    -- A written list: groups of items, or bare items, which gather into one
    -- group where the first one appears.
    local function customItem(entry)
        if type(entry) ~= "table" then
            entry = { Name = entry }
        end
        local name = tostring(entry.Name or entry.Title or entry[1] or "")
        local link = byName[string.lower(name)]
        return {
            Name = name,
            Desc = entry.Desc or entry.Description,
            Tag = entry.Tag,
            Icon = entry.Icon,
            Kind = link and link.Kind,
            Path = link and link.Path,
            Result = link and link.Result,
            Callback = entry.Callback,
        }
    end
    local groups, loose = {}, nil
    for _, entry in ipairs(custom) do
        if type(entry) == "table" and type(entry.Items) == "table" then
            local group = { Name = tostring(entry.Name or entry.Title or "Features"), Icon = entry.Icon, Items = {} }
            for _, item in ipairs(entry.Items) do
                table.insert(group.Items, customItem(item))
            end
            table.insert(groups, group)
        else
            if not loose then
                loose = { Name = self._featuresTitle or "Features", Items = {} }
                table.insert(groups, loose)
            end
            table.insert(loose.Items, customItem(entry))
        end
    end
    return groups
end

function Window:_featureSummary()
    local groups = self:_featureGroups()
    local count = 0
    for _, group in ipairs(groups) do
        count += #group.Items
    end
    local text = count .. (count == 1 and " feature" or " features")
    if type(self._features) ~= "table" and #groups > 0 then
        text ..= " across " .. #groups .. (#groups == 1 and " tab" or " tabs")
    end
    return text, groups, count
end

-- Opens the feature list over the window. Search filters it; picking an item
-- linked to a control closes the list and jumps to that control.
function Window:ShowFeatures()
    if self._dialog then
        self._dialog.Close()
    end
    local summary, groups, total = self:_featureSummary()
    local PAD = 16
    local ROW = TOUCH and 44 or 38
    local body = self.Body

    local overlay = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 40,
        Parent = body,
    })
    -- A canvas group so the whole list fades as one on open and close.
    local card_ = create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 10),
        Size = UDim2.fromOffset(420, 460),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Active = true,
        Parent = overlay,
    })
    corner(card_, UDim.new(0, 12))
    local cardStroke = stroke(card_, Theme.Stroke, 1)
    local cardScale = create("UIScale", { Scale = 0.94, Parent = card_ })
    local function fit()
        local scale = self.Scale.Scale
        local size = body.AbsoluteSize / scale
        card_.Size = UDim2.fromOffset(math.min(440, size.X - 24), math.min(480, size.Y - 24))
    end
    fit()
    local fitConnection = body:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

    local iconHolder = glowIcon(card_, "list-checks", Theme.Accent, UDim2.new(0, PAD, 0, PAD + 10))
    iconHolder.Size = UDim2.fromOffset(18, 18)
    label({
        Position = UDim2.fromOffset(PAD + 28, PAD),
        Size = UDim2.new(1, -(PAD * 2 + 28 + 36), 0, 18),
        Text = self._featuresTitle or "Features",
        TextSize = 15,
        Parent = card_,
    })
    label({
        Position = UDim2.fromOffset(PAD + 28, PAD + 19),
        Size = UDim2.new(1, -(PAD * 2 + 28 + 36), 0, 14),
        Text = summary,
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = card_,
    })
    local closeButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -(PAD - 6), 0, PAD - 6),
        Size = TOUCH and UDim2.fromOffset(40, 40) or UDim2.fromOffset(32, 32),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = card_,
    })
    corner(closeButton, UDim.new(0, 8))
    local closeIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Parent = closeButton,
    })
    applyIcon(closeIcon, "x")
    if closeIcon.Image == "" then
        closeIcon:Destroy()
        label({ Size = UDim2.fromScale(1, 1), Text = "×", TextSize = 20, TextColor3 = Theme.Muted, TextXAlignment = Enum.TextXAlignment.Center, Parent = closeButton })
    end
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, { BackgroundTransparency = 0.5 }, 0.12)
    end)
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, { BackgroundTransparency = 1 }, 0.2)
    end)

    local top = PAD + 44
    local searchHolder = create("Frame", {
        Position = UDim2.fromOffset(PAD, top),
        Size = UDim2.new(1, -PAD * 2, 0, TOUCH and 36 or 32),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = card_,
    })
    corner(searchHolder, UDim.new(0, 7))
    local searchStroke = stroke(searchHolder)
    local _, searchIcon = glowIcon(searchHolder, "search", Theme.Muted, UDim2.new(0, 10, 0.5, 0))
    searchIcon.Parent.Size = UDim2.fromOffset(14, 14)
    local searchBox = create("TextBox", {
        Position = UDim2.fromOffset(32, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search features",
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClearTextOnFocus = false,
        Parent = searchHolder,
    })
    searchBox.Focused:Connect(function()
        tween(searchStroke, { Color = Theme.StrokeHover }, 0.15)
        tween(searchIcon, { ImageColor3 = Theme.Accent }, 0.15)
    end)
    searchBox.FocusLost:Connect(function()
        tween(searchStroke, { Color = Theme.Stroke }, 0.2)
        tween(searchIcon, { ImageColor3 = Theme.Muted }, 0.2)
    end)
    top += (TOUCH and 36 or 32) + 10

    local scroller = create("ScrollingFrame", {
        Position = UDim2.fromOffset(PAD, top),
        Size = UDim2.new(1, -PAD * 2 + 6, 1, -(top + PAD - 4)),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = TOUCH and 4 or 3,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarImageTransparency = 0.4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(),
        Parent = card_,
    })
    local content = create("Frame", {
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = scroller,
    })
    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = content,
    })
    -- Canvas sized by hand, as elsewhere, so it scrolls under UIScale.
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y / self.Scale.Scale + 4)
    end)
    local noResults = label({
        Size = UDim2.new(1, 0, 0, 60),
        Text = total == 0 and "No features yet" or "No matches",
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        LayoutOrder = 0,
        Visible = total == 0,
        Parent = content,
    })

    local dialog = {}
    local closed = false
    local stopEscape = nil
    function dialog.Close()
        if closed then
            return
        end
        closed = true
        if self._dialog == dialog then
            self._dialog = nil
        end
        fitConnection:Disconnect()
        if stopEscape then
            -- Deferred: Close can run from inside the input dispatch loop.
            task.defer(stopEscape)
        end
        if searchBox:IsFocused() then
            searchBox:ReleaseFocus()
        end
        tween(overlay, { BackgroundTransparency = 1 }, 0.18)
        tween(card_, { Position = UDim2.new(0.5, 0, 0.5, 8), GroupTransparency = 1 }, 0.18, Enum.EasingStyle.Quint)
        tween(cardScale, { Scale = 0.96 }, 0.18, Enum.EasingStyle.Quint)
        tween(cardStroke, { Transparency = 1 }, 0.12)
        task.delay(0.2, function()
            overlay:Destroy()
        end)
    end

    local sections = {}
    local order = 0
    for _, group in ipairs(groups) do
        order += 1
        local header = create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            Parent = content,
        })
        local headIcon = glowIcon(header, group.Icon or "layout-grid", Theme.Accent, UDim2.new(0, 2, 0, 18))
        headIcon.Size = UDim2.fromOffset(14, 14)
        label({
            Position = UDim2.fromOffset(24, 10),
            Size = UDim2.new(1, -70, 0, 16),
            Text = string.upper(group.Name),
            TextSize = 11,
            TextColor3 = Theme.Muted,
            Parent = header,
        })
        local countLabel = label({
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -4, 0, 10),
            Size = UDim2.new(0, 40, 0, 16),
            Text = tostring(#group.Items),
            TextSize = 11,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = header,
        })
        local section = { Header = header, Count = countLabel, Rows = {} }
        for _, item in ipairs(group.Items) do
            order += 1
            local sub = item.Desc or item.Path
            local clickable = item.Result ~= nil or type(item.Callback) == "function"
            local row = create("TextButton", {
                Size = UDim2.new(1, 0, 0, sub and ROW + 4 or ROW - 4),
                BackgroundColor3 = Theme.Surface2,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = order,
                Parent = content,
            })
            corner(row, UDim.new(0, 8))
            local rowIcon = glowIcon(row, item.Icon or self._searchIcons[item.Kind] or "check", Theme.Muted, UDim2.new(0, 10, 0.5, 0))
            rowIcon.Size = UDim2.fromOffset(14, 14)
            local right = 12 + (clickable and 22 or 0)
            local tag
            if item.Tag then
                tag = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -(clickable and 30 or 10), 0.5, 0),
                    Size = UDim2.fromOffset(0, 20),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 0.85,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                corner(tag, UDim.new(0, 5))
                padding(tag, 7, 7)
                label({
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Text = tostring(item.Tag),
                    TextSize = 11,
                    TextColor3 = Theme.Accent,
                    TextTruncate = Enum.TextTruncate.None,
                    Parent = tag,
                })
            end
            local nameLabel = label({
                Position = UDim2.fromOffset(34, sub and 5 or 0),
                Size = UDim2.new(1, -(34 + right), 0, sub and 18 or ROW - 4),
                Text = item.Name,
                TextSize = 13,
                Parent = row,
            })
            local subLabel
            if sub then
                subLabel = label({
                    Position = UDim2.fromOffset(34, 23),
                    Size = UDim2.new(1, -(34 + right), 0, 14),
                    Text = sub,
                    TextSize = 11,
                    FontFace = Fonts.Regular,
                    TextColor3 = Theme.Muted,
                    Parent = row,
                })
            end
            if tag then
                local function reserveTag()
                    local width = 34 + right + tag.AbsoluteSize.X / self.Scale.Scale + 8
                    nameLabel.Size = UDim2.new(1, -width, 0, nameLabel.Size.Y.Offset)
                    if subLabel then
                        subLabel.Size = UDim2.new(1, -width, 0, 14)
                    end
                end
                tag:GetPropertyChangedSignal("AbsoluteSize"):Connect(reserveTag)
                task.defer(reserveTag)
            end
            if clickable then
                local go = create("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    BackgroundTransparency = 1,
                    ImageColor3 = Theme.Muted,
                    ImageTransparency = 0.4,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = row,
                })
                applyIcon(go, "arrow-up-right")
            end
            local isTap = tapGuard(row, function()
                return scroller
            end)
            row.MouseEnter:Connect(function()
                if not usingTouch() then
                    tween(row, { BackgroundTransparency = 0.3 }, 0.12)
                end
            end)
            row.MouseLeave:Connect(function()
                tween(row, { BackgroundTransparency = 1 }, 0.2)
            end)
            row.MouseButton1Click:Connect(function()
                if not clickable or not isTap() then
                    return
                end
                dialog.Close()
                if item.Result then
                    self:_revealResult(item.Result)
                end
                safeCall(item.Callback)
            end)
            table.insert(section.Rows, { Frame = row, Key = string.lower(item.Name .. " " .. (sub or "")) })
        end
        table.insert(sections, section)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        local any = false
        for _, section in ipairs(sections) do
            local shown = 0
            for _, row in ipairs(section.Rows) do
                local match = query == "" or string.find(row.Key, query, 1, true) ~= nil
                row.Frame.Visible = match
                if match then
                    shown += 1
                end
            end
            section.Header.Visible = shown > 0
            section.Count.Text = tostring(shown)
            any = any or shown > 0
        end
        noResults.Visible = not any
        scroller.CanvasPosition = Vector2.zero
    end)
    closeButton.MouseButton1Click:Connect(dialog.Close)
    overlay.MouseButton1Click:Connect(dialog.Close)
    stopEscape = self:_listen("Began", function(input)
        if input.KeyCode == Enum.KeyCode.Escape then
            dialog.Close()
        end
    end)

    self._dialog = dialog
    tween(overlay, { BackgroundTransparency = 0.45 }, 0.25)
    tween(card_, { Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0 }, 0.3, Enum.EasingStyle.Quint)
    tween(cardScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
    return dialog
end

function Window:_homeStats(list, opts, order, tab)
    local show = opts.Stats or { "Players", "Execs", "Session", "FPS", "Ping" }
    -- FPS and ping get large readouts with a bar history; every other stat
    -- is a small figure in the row under them.
    local card = self:_homeCard(list, order)
    local graphs = create("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = card,
    })
    create("UIGridLayout", {
        CellPadding = UDim2.fromOffset(24, 0),
        CellSize = UDim2.new(0.5, -12, 0, 76),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = graphs,
    })
    local rule = create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Parent = card,
    })
    local figures = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        Parent = card,
    })
    padding(figures, 0, 0, 12, 0)
    local figureGrid = create("UIGridLayout", {
        CellPadding = UDim2.fromOffset(0, 8),
        CellSize = UDim2.new(0.25, 0, 0, 36),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = figures,
    })
    local values, sparks = {}, {}
    local graphCount, figureCount = 0, 0
    for index, name in ipairs(show) do
        local kind = STAT_TYPES[name]
        if kind and not values[name] then
            if name == "FPS" or name == "Ping" then
                graphCount += 1
                values[name], sparks[name] = self:_homeGraph(graphs, index, kind[1], kind[2], name == "FPS" and 60 or 100)
            else
                figureCount += 1
                values[name] = self:_homeFigure(figures, index, kind[2])
            end
        end
    end
    graphs.Visible = graphCount > 0
    figures.Visible = figureCount > 0
    rule.Visible = graphCount > 0 and figureCount > 0
    if graphCount == 0 then
        padding(figures, 0, 0, 0, 0)
    end
    local function fitFigures()
        local width = figures.AbsoluteSize.X / self.Scale.Scale
        local columns = math.clamp(figureCount, 1, width >= 440 and 5 or 3)
        figureGrid.CellSize = UDim2.new(1 / columns, 0, 0, 36)
    end
    figures:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitFigures)
    task.defer(fitFigures)

    if values.Executor then
        values.Executor.Text = detectExecutor()
    end
    if values.Game then
        values.Game.Text = "Loading"
        task.spawn(function()
            values.Game.Text = detectGameName()
        end)
    end
    if values.Region then
        values.Region.Text = "Loading"
        detectRegion(function(region)
            values.Region.Text = region
        end)
    end
    if values.Execs then
        local executions = bumpExecutions(opts.StatsFolder or self.ConfigFolder)
        values.Execs.Text = executions and tostring(executions) or "—"
    end
    if values.Friends then
        local friends = {}
        local function recount()
            local total = 0
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local known = friends[player.UserId]
                    if known == nil then
                        local ok, result = pcall(function()
                            return LocalPlayer:IsFriendsWith(player.UserId)
                        end)
                        known = ok and result == true
                        friends[player.UserId] = known
                    end
                    if known then
                        total += 1
                    end
                end
            end
            values.Friends.Text = tostring(total)
        end
        task.spawn(recount)
        table.insert(self._connections, Players.PlayerAdded:Connect(function()
            task.spawn(recount)
        end))
        table.insert(self._connections, Players.PlayerRemoving:Connect(function()
            task.defer(recount)
        end))
    end

    local session = values.Session or values.Uptime
    local started = os.clock()
    local frames = 0
    self:_listen("Render", function()
        frames += 1
    end)
    -- FPS, ping and memory are tinted by how healthy they are, unless the
    -- script turns that off with StatColors = false.
    local tinted = opts.StatColors ~= false
    local function tint(valueLabel, color)
        if tinted and valueLabel.TextColor3 ~= color then
            tween(valueLabel, { TextColor3 = color }, 0.3)
        end
    end
    return function()
        if values.FPS then
            values.FPS.Text = tostring(frames)
            tint(values.FPS, Library._healthColor(frames, 50, 30))
            sparks.FPS(frames, Library._healthColor(frames, 50, 30))
        end
        frames = 0
        if values.Ping then
            local ok, ping = pcall(function()
                return math.floor(LocalPlayer:GetNetworkPing() * 1000)
            end)
            ping = ok and ping or 0
            values.Ping.Text = ping .. "ms"
            tint(values.Ping, Library._healthColor(ping, 90, 180, true))
            sparks.Ping(ping, Library._healthColor(ping, 90, 180, true))
        end
        if values.Players then
            values.Players.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        end
        if session then
            session.Text = formatDuration(os.clock() - started)
        end
        if values.Time then
            values.Time.Text = os.date(opts.TimeFormat or "%H:%M")
        end
        if values.ServerAge then
            values.ServerAge.Text = formatDuration(workspace.DistributedGameTime)
        end
        if values.Memory then
            local ok, memory = pcall(function()
                return StatsService:GetTotalMemoryUsageMb()
            end)
            values.Memory.Text = ok and string.format("%d MB", memory) or "—"
            tint(values.Memory, ok and Library._healthColor(memory, 1500, 3000, true) or Theme.Text)
        end
    end, function()
        frames = 0
    end
end

local function homePage(sub, page)
    local list = sub.List
    if type(page.Content) == "string" then
        local card_ = panelCard(list, 0, 1)
        card_.AutomaticSize = Enum.AutomaticSize.Y
        padding(card_, 16, 16, 14, 16)
        label({
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = page.Content,
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = card_,
        })
    end
    if type(page.Entries) == "table" then
        for index, entry in ipairs(page.Entries) do
            local card_ = panelCard(list, 0, index + 1)
            card_.AutomaticSize = Enum.AutomaticSize.Y
            padding(card_, 16, 16, 14, 16)
            create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
                Parent = card_,
            })
            local head = create("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Parent = card_,
            })
            label({
                Size = UDim2.new(1, -90, 1, 0),
                Text = entry.Title or entry.Version or "Update",
                TextSize = 15,
                Parent = head,
            })
            if entry.Date or entry.Tag then
                local chip = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(0, 20),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Parent = head,
                })
                corner(chip, UDim.new(0, 5))
                stroke(chip)
                padding(chip, 8, 8)
                label({
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Text = entry.Tag or entry.Date,
                    TextSize = 11,
                    TextColor3 = Theme.Muted,
                    TextTruncate = Enum.TextTruncate.None,
                    Parent = chip,
                })
            end
            local body = entry.Content or entry.Body
            if type(entry.Changes) == "table" then
                body = "• " .. table.concat(entry.Changes, "\n• ")
            end
            if body then
                label({
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = body,
                    TextSize = 13,
                    FontFace = Fonts.Regular,
                    TextColor3 = Theme.Muted,
                    TextWrapped = true,
                    TextTruncate = Enum.TextTruncate.None,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    LayoutOrder = 2,
                    Parent = card_,
                })
            end
        end
    end
    if type(page.Build) == "function" then
        safeCall(page.Build, sub, list)
    else
        sub._noSearch = true
    end
end

function Window:_buildHome(opts)
    self._hideName = opts.HideName == true
    self._hideAvatar = opts.HideAvatar == true
    self:_renderIdentity(true)
    local tab = self:Tab({
        Name = opts.Name or "Home",
        Desc = opts.Desc,
        Icon = opts.Icon or "house",
        PageTitle = opts.Title or "Home",
    })
    tab._order = 100
    self.Home = tab

    local pages = opts.Pages or opts.Tabs
    local overview = tab
    if type(pages) == "table" and #pages > 0 then
        overview = tab:SubTab({ Name = opts.OverviewName or "Overview", Icon = opts.TabIcon or "layout-grid" })
    end
    overview._noSearch = true
    overview._order = 100
    local list = overview.List

    local refreshExpiry = self:_homeProfile(list, opts, 1)
    local refreshStats, resetStats = self:_homeStats(list, opts, 2, tab)

    -- Server and links side by side, stacked when narrow.
    local split = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        Parent = list,
    })
    local splitLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = split,
    })
    local function column(order_)
        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = order_,
            Parent = split,
        })
        create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
        return frame
    end
    local leftColumn, rightColumn = column(1), column(2)
    local refreshGame = self:_homeGame(leftColumn, 1)
    local linksCard, refreshFeatures = self:_homeLinks(rightColumn, opts, 1)
    if not linksCard then
        rightColumn:Destroy()
    end
    local function fitSplit()
        local wide = linksCard ~= nil and split.AbsoluteSize.X / self.Scale.Scale >= 540
        splitLayout.FillDirection = wide and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
        local size = wide and UDim2.new(0.5, -5, 0, 0) or UDim2.new(1, 0, 0, 0)
        leftColumn.Size = size
        if linksCard then
            rightColumn.Size = size
        end
    end
    split:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitSplit)
    task.defer(fitSplit)

    self:_homeExecutor(list, opts, 4)

    if type(pages) == "table" then
        for _, page in ipairs(pages) do
            homePage(tab:SubTab({ Name = page.Name or page.Title or "Page", Icon = page.Icon }), page)
        end
    end

    refreshExpiry()
    refreshStats()
    refreshGame()
    task.spawn(function()
        while not self._destroyed and tab._page.Parent do
            task.wait(1)
            if self.Open and self.CurrentTab == tab then
                refreshStats()
                refreshExpiry()
                refreshGame()
                refreshFeatures()
            else
                resetStats()
            end
        end
    end)
    return tab
end

function Window:Tab(opts, icon)
    opts = normalize(opts, { Title = "Name", Description = "Desc" })
    if icon ~= nil and opts.Icon == nil then
        opts.Icon = icon
    end
    local tab = setmetatable({
        Name = opts.Name or "Tab",
        Window = self,
        _order = 0,
    }, Tab)

    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, TAB_TILE_HEIGHT),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #self.Tabs + 1,
        Parent = self._tabStack,
    })
    corner(button, UDim.new(0, 7))
    local buttonStroke = stroke(button, Theme.Stroke, 1)
    buttonStroke.Enabled = false
    tab._button = button

    local hasIcon = opts.Icon ~= nil
    if hasIcon then
        local iconImage = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 20, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Muted,
            ScaleType = Enum.ScaleType.Fit,
            Parent = button,
        })
        applyIcon(iconImage, opts.Icon)
        if iconImage:GetAttribute("CustomIcon") then
            iconImage.ImageTransparency = 0.4
        end
        tab._icon = iconImage
    end
    tab._label = label({
        Position = UDim2.fromOffset(hasIcon and 38 or 14, 0),
        Size = UDim2.new(1, hasIcon and -46 or -22, 1, 0),
        Text = tab.Name,
        TextSize = 13,
        TextColor3 = Theme.Muted,
        Parent = button,
    })

    local page = create("Frame", {
        Name = tab.Name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Content,
    })
    tab._page = page
    local titleX = 24
    if hasIcon then
        local holder = glowIcon(page, opts.Icon, Theme.Accent, UDim2.new(0, 24, 0, 32))
        holder.Size = UDim2.fromOffset(20, 20)
        titleX = 54
    end
    tab._titleX = titleX
    tab._title = label({
        Position = UDim2.fromOffset(titleX, 20),
        Size = UDim2.new(1, -titleX, 0, 24),
        Text = opts.PageTitle or tab.Name,
        TextSize = 22,
        Parent = page,
    })
    if opts.Desc then
        tab._desc = label({
            Position = UDim2.fromOffset(titleX, 44),
            Size = UDim2.new(1, -titleX, 0, 16),
            Text = opts.Desc,
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = page,
        })
    end
    local listTop = opts.Desc and 70 or 58
    tab._headerBottom = listTop
    tab._iconName = opts.Icon
    buildContainer(tab, page, listTop, opts.Icon or "layout-grid", opts.EmptyText or "Nothing here yet")

    local pressScale = create("UIScale", { Parent = button })
    local function release()
        tween(pressScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Quint)
    end
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab and not usingTouch() then
            tween(button, { BackgroundTransparency = 0.75 }, 0.2, Enum.EasingStyle.Quint)
            tween(tab._label, { TextColor3 = Theme.Text }, 0.2)
            if tab._icon then
                tintIcon(tab._icon, Theme.Text, true, 0.2)
            end
        end
    end)
    button.MouseLeave:Connect(function()
        release()
        if self.CurrentTab ~= tab then
            tween(button, { BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Quint)
            tween(tab._label, { TextColor3 = Theme.Muted }, 0.3)
            if tab._icon then
                tintIcon(tab._icon, Theme.Muted, false, 0.3)
            end
        end
    end)
    button.MouseButton1Down:Connect(function()
        tween(pressScale, { Scale = 0.97 }, 0.15, Enum.EasingStyle.Quint)
    end)
    button.MouseButton1Up:Connect(release)
    local isTap = tapGuard(button, function()
        return self.TabList
    end)
    button.MouseButton1Click:Connect(function()
        release()
        if isTap() then
            self:SelectTab(tab)
        end
    end)
    tab._stroke = buttonStroke
    self:_fitTitle(tab)

    if not self._introDone then
        button.Visible = false
    end
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        task.defer(function()
            if not self.CurrentTab then
                self:SelectTab(tab)
            end
        end)
    end
    return tab
end

Window.CreateTab = Window.Tab

-- Cloud configs: a tab for browsing, previewing, installing and publishing
-- configs other players shared. The library draws it; OnFetch, OnPublish and
-- the other callbacks are the script's backend. Favorites, installs and the
-- sort order are remembered in the script's settings file.
function Window:CloudConfigs(opts)
    opts = normalize(opts, { Title = "Name", Description = "Desc" })
    local window = self
    local tab = self:Tab({
        Name = opts.Name or "Cloud",
        Desc = opts.Desc,
        Icon = opts.Icon or "cloud",
        PageTitle = opts.PageTitle,
    })
    tab._noSearch = true
    tab.List.Visible = false
    if tab._empty then
        tab._empty:Destroy()
        tab._empty = nil
    end

    local CARD = 116
    local ROW = TOUCH and 36 or 32
    local CHIP = TOUCH and 30 or 26
    local SORTS = { "Popular", "New", "Top", "Installs" }
    local SORT_NAMES = { Popular = "Popular", New = "Newest", Top = "Top rated", Installs = "Most installed" }
    local FILTERS = { "All", "Favorites", "Mine", "Installed" }
    local NAME_LIMIT = 40
    local DESC_LIMIT = math.max(math.floor(tonumber(opts.DescriptionLimit) or 300), 20)
    local pageSize = math.max(math.floor(tonumber(opts.PageSize) or 20), 1)
    local tagList = type(opts.Tags) == "table" and opts.Tags or {}
    local maxTags = math.max(math.floor(tonumber(opts.MaxTags) or 3), 0)
    local anonName = tostring(opts.StreamerName or "Ouroboros User")

    local cloud = { Tab = tab }
    local records, byId = {}, {}
    local cards = {}
    local hasMore, page, token = false, 0, 0
    local loading = false
    local query = { Search = "", Sort = "Popular", Filter = "All", Tag = nil }
    local views, currentView = {}, nil
    local detail, detailRecord, detailToken = {}, nil, 0

    local stored = window:_readConfigSettings()
    local favorites = type(stored.CloudFavorites) == "table" and stored.CloudFavorites or {}
    local installed = type(stored.CloudInstalled) == "table" and stored.CloudInstalled or {}
    if table.find(SORTS, stored.CloudSort) then
        query.Sort = stored.CloudSort
    elseif table.find(SORTS, opts.Sort) then
        query.Sort = opts.Sort
    end
    local function persist(key, value)
        window:_writeConfigSettings({ [key] = value })
    end

    local function notify(ok, title, detail_)
        window:Notify({ Title = title, Content = detail_, Type = ok and "Success" or "Error", Duration = 3 })
    end

    -- The Home tab's hide-name switch doubles as streamer mode.
    local function streamerOn()
        return window._hideName == true
    end

    -- Records

    local function countFlags(code)
        local data = type(code) == "string" and window:DecodeConfig(code)
        if not data then
            return nil
        end
        local count = 0
        for _ in pairs(data) do
            count += 1
        end
        return count
    end

    local function compact(number)
        number = math.max(math.floor(tonumber(number) or 0), 0)
        if number >= 1e6 then
            return (("%.1f"):format(number / 1e6):gsub("%.0$", "")) .. "m"
        elseif number >= 1e3 then
            return (("%.1f"):format(number / 1e3):gsub("%.0$", "")) .. "k"
        end
        return tostring(number)
    end

    local function ago(stamp)
        stamp = tonumber(stamp)
        if not stamp then
            return nil
        end
        local delta = os.time() - stamp
        if delta < 60 then
            return "just now"
        elseif delta < 3600 then
            return math.floor(delta / 60) .. "m ago"
        elseif delta < 86400 then
            return math.floor(delta / 3600) .. "h ago"
        elseif delta < 604800 then
            return math.floor(delta / 86400) .. "d ago"
        elseif delta < 2592000 then
            return math.floor(delta / 604800) .. "w ago"
        end
        return os.date("%d %b %Y", stamp)
    end

    local function escape(text)
        return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
    end

    -- Rich text with every match of the search drawn in the accent.
    local function highlight(text)
        local needle = string.lower(query.Search)
        if needle == "" then
            return escape(text)
        end
        local lower = string.lower(text)
        local hex = colorToHex(Theme.Accent)
        local out, from = {}, 1
        while true do
            local first, last = string.find(lower, needle, from, true)
            if not first then
                break
            end
            table.insert(out, escape(text:sub(from, first - 1)))
            table.insert(out, ('<font color="#%s"><b>%s</b></font>'):format(hex, escape(text:sub(first, last))))
            from = last + 1
        end
        table.insert(out, escape(text:sub(from)))
        return table.concat(out)
    end

    local function normalizeRecord(raw)
        if type(raw) ~= "table" then
            return nil
        end
        local id = raw.Id ~= nil and tostring(raw.Id) or HttpService:GenerateGUID(false)
        local record = byId[id] or { Id = id }
        for key, value in pairs(raw) do
            if key ~= "Id" then
                record[key] = value
            end
        end
        record.Name = tostring(record.Name or "Untitled")
        record.Author = tostring(record.Author or "Unknown")
        record.Description = record.Description ~= nil and tostring(record.Description) or ""
        local tags = {}
        for _, tag in ipairs(type(record.Tags) == "table" and record.Tags or {}) do
            table.insert(tags, tostring(tag))
        end
        record.Tags = tags
        record.Installs = tonumber(record.Installs) or 0
        record.Likes = tonumber(record.Likes) or 0
        record.Updated = tonumber(record.Updated or record.Created)
        record.Liked = record.Liked == true
        if type(record.Code) ~= "string" or record.Code == "" then
            record.Code = nil
        end
        record.Count = tonumber(record.Count) or countFlags(record.Code)
        record.Mine = record.Mine == true or tonumber(record.AuthorId) == LocalPlayer.UserId or tonumber(record.OwnerId) == LocalPlayer.UserId
        byId[id] = record
        return record
    end

    local function publicRecord(record)
        return {
            Id = record.Id,
            Name = record.Name,
            Description = record.Description,
            Author = record.Author,
            AuthorId = record.AuthorId,
            Tags = table.clone(record.Tags),
            Installs = record.Installs,
            Likes = record.Likes,
            Liked = record.Liked,
            Updated = record.Updated,
            Code = record.Code,
            Count = record.Count,
            Folder = record.Folder,
            Mine = record.Mine,
        }
    end

    -- What is kept locally for favorites and installs: no code, it is refetched.
    local function summary(record)
        local kept = publicRecord(record)
        kept.Code = nil
        kept.Liked = nil
        return kept
    end

    local function installState(record)
        local mark = installed[record.Id]
        if type(mark) ~= "table" then
            return nil
        end
        if record.Updated and tonumber(mark.Updated) and record.Updated > tonumber(mark.Updated) then
            return "Update"
        end
        return "Installed"
    end

    local function otherScript(record)
        return type(record.Folder) == "string" and record.Folder ~= window.ConfigFolder
    end

    -- Small pieces

    local function iconButton(parent, icon, glyph, size, plain)
        local button = create("TextButton", {
            Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = Theme.Surface2,
            BackgroundTransparency = plain and 1 or 0,
            Text = "",
            AutoButtonColor = false,
            Parent = parent,
        })
        corner(button, UDim.new(0, 8))
        if not plain then
            hoverStroke(button, stroke(button))
        end
        local image = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(15, 15),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Muted,
            ScaleType = Enum.ScaleType.Fit,
            Parent = button,
        })
        applyIcon(image, icon)
        if image.Image == "" then
            image:Destroy()
            image = label({
                Size = UDim2.fromScale(1, 1),
                Text = glyph,
                TextSize = 15,
                TextColor3 = Theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.None,
                Parent = button,
            })
        end
        return button, image
    end

    local function primary(button, text_)
        tween(button, { BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.12 }, 0)
        tween(text_, { TextColor3 = Theme.AccentDark }, 0)
        text_.FontFace = Fonts.Bold
    end

    local function clear(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
    end

    local function chip(parent, text, order, onClick)
        local button = create("TextButton", {
            Size = UDim2.fromOffset(0, CHIP),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Surface2,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = parent,
        })
        button:SetAttribute("NoDrag", true)
        corner(button, UDim.new(1, 0))
        local chipStroke = stroke(button)
        padding(button, 12, 12)
        local text_ = label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = text,
            TextSize = 12,
            TextColor3 = Theme.Muted,
            TextTruncate = Enum.TextTruncate.None,
            Parent = button,
        })
        local object = { Button = button, Label = text_ }
        function object.Set(on, instant)
            local duration = instant and 0 or 0.15
            tween(button, { BackgroundColor3 = on and Theme.Accent or Theme.Surface2 }, duration)
            tween(text_, { TextColor3 = on and Theme.AccentDark or Theme.Muted }, duration)
            tween(chipStroke, { Transparency = on and 1 or 0 }, duration)
        end
        if onClick then
            button.MouseButton1Click:Connect(onClick)
        else
            button.Active = false
        end
        return object
    end

    local function tagPill(parent, text, order)
        local pill = label({
            Size = UDim2.fromOffset(0, 18),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Surface3,
            BackgroundTransparency = 0.2,
            Text = text,
            TextSize = 11,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = order,
            Parent = parent,
        })
        corner(pill, UDim.new(0, 5))
        padding(pill, 7, 7)
        return pill
    end

    local function hlist(parent, gap, wraps)
        return create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, gap),
            Wraps = wraps == true,
            Parent = parent,
        })
    end

    local function vlist(parent, gap)
        return create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, gap),
            Parent = parent,
        })
    end

    local function wrapped(parent, text, size, color, order, font)
        return label({
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = text,
            TextSize = size,
            FontFace = font or Fonts.Regular,
            TextColor3 = color or Theme.Text,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            TextYAlignment = Enum.TextYAlignment.Top,
            LayoutOrder = order,
            Parent = parent,
        })
    end

    local function scroller(parent, visible)
        local frame = create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            ScrollBarImageTransparency = 0.4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            Visible = visible ~= false,
            Parent = parent,
        })
        frame:SetAttribute("NoDrag", true)
        return frame
    end

    -- A text box on the surface colour. Multi-line boxes show a counter.
    local function field(parent, order, placeholder, height, limit)
        local multi = height > ROW
        local holder = create("Frame", {
            Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            LayoutOrder = order,
            Parent = parent,
        })
        corner(holder, UDim.new(0, 8))
        local holderStroke = stroke(holder)
        local box = create("TextBox", {
            Position = UDim2.fromOffset(10, multi and 8 or 0),
            Size = UDim2.new(1, -20, 1, multi and -24 or 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = placeholder,
            PlaceholderColor3 = Theme.Muted,
            TextColor3 = Theme.Text,
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = multi and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            MultiLine = multi,
            TextWrapped = multi,
            ClearTextOnFocus = false,
            Parent = holder,
        })
        local counter = multi and label({
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -10, 1, -4),
            Size = UDim2.fromOffset(0, 14),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            TextSize = 11,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextTruncate = Enum.TextTruncate.None,
            Parent = holder,
        })
        box.Focused:Connect(function()
            tween(holderStroke, { Color = Theme.StrokeHover }, 0.15)
        end)
        box.FocusLost:Connect(function()
            tween(holderStroke, { Color = Theme.Stroke }, 0.2)
        end)
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local text = box.Text
            local length = utf8.len(text) or #text
            if limit and length > limit then
                local cut = utf8.offset(text, limit + 1)
                box.Text = cut and text:sub(1, cut - 1) or text:sub(1, limit)
                return
            end
            if counter then
                counter.Text = limit and (length .. "/" .. limit) or ""
            end
        end)
        if counter and limit then
            counter.Text = "0/" .. limit
        end
        return box, holderStroke
    end

    local function uniqueName(base)
        base = trim((tostring(base or ""):gsub('[\\/:%*%?"<>|]', "")))
        if base == "" then
            base = "Cloud config"
        end
        local name, index = base, 2
        while window:ConfigExists(name) do
            name = ("%s (%d)"):format(base, index)
            index += 1
        end
        return name
    end

    -- Layout: the page holds three views that slide over each other.

    local top = tab._headerBottom
    -- One pixel wider than the content on every side: root clips the slide,
    -- and the strokes along its edges would be clipped with it.
    local root = create("Frame", {
        Position = UDim2.fromOffset(23, top - 1),
        Size = UDim2.new(1, -46, 1, -(top + 14)),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = tab._page,
    })
    for _, name in ipairs({ "Browse", "Detail", "Publish" }) do
        views[name] = create("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = root,
        })
        padding(views[name], 1, 1, 1, 1)
    end

    local function showView(view)
        if currentView == view then
            return
        end
        local previous = currentView
        currentView = view
        if previous then
            previous.Visible = false
        end
        local fromX = view == views.Browse and -24 or 24
        view.Position = UDim2.fromOffset(fromX, 0)
        view.Visible = true
        tween(view, { Position = UDim2.fromOffset(0, 0) }, 0.3, Enum.EasingStyle.Quint)
    end

    -- Browse: search, publish and refresh, the filter strip, then results.

    local browse = views.Browse
    local toolbar = create("Frame", {
        Size = UDim2.new(1, 0, 0, ROW),
        BackgroundTransparency = 1,
        Parent = browse,
    })
    local publishButton, publishText = softButton(toolbar, "Publish", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
    }, function()
        cloud:OpenPublish()
    end)
    primary(publishButton, publishText)
    publishButton.Visible = type(opts.OnPublish) == "function"
    local refreshButton, refreshIcon = iconButton(toolbar, "refresh-cw", "R", ROW)
    refreshButton.AnchorPoint = Vector2.new(1, 0)
    local searchHolder = create("Frame", {
        Size = UDim2.new(1, -(ROW + 8), 1, 0),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Parent = toolbar,
    })
    corner(searchHolder, UDim.new(0, 8))
    local searchStroke = stroke(searchHolder)
    local searchIcon, searchImage = glowIcon(searchHolder, "search", Theme.Muted, UDim2.new(0, 10, 0.5, 0))
    searchIcon.Size = UDim2.fromOffset(14, 14)
    local searchBox = create("TextBox", {
        Position = UDim2.fromOffset(32, 0),
        Size = UDim2.new(1, -62, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = opts.SearchPlaceholder or (TOUCH and "Search configs..." or "Search configs...   ( / )"),
        PlaceholderColor3 = Theme.Muted,
        TextColor3 = Theme.Text,
        TextSize = 13,
        FontFace = Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        Parent = searchHolder,
    })
    local searchClear = iconButton(searchHolder, "x", "x", 24, true)
    searchClear.AnchorPoint = Vector2.new(1, 0.5)
    searchClear.Position = UDim2.new(1, -4, 0.5, 0)
    searchClear.Visible = false

    local fetch
    local searchToken = 0
    local recent = type(stored.CloudRecent) == "table" and stored.CloudRecent or {}
    local recentFrame = create("Frame", {
        Position = UDim2.fromOffset(0, ROW + 4),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
        Parent = browse,
    })
    corner(recentFrame, UDim.new(0, 8))
    stroke(recentFrame)
    padding(recentFrame, 6, 6, 6, 6)
    vlist(recentFrame, 2)

    local function rememberSearch(text)
        text = trim(text)
        if #text < 2 then
            return
        end
        for index = #recent, 1, -1 do
            if string.lower(recent[index]) == string.lower(text) then
                table.remove(recent, index)
            end
        end
        table.insert(recent, 1, text)
        while #recent > 6 do
            table.remove(recent)
        end
        persist("CloudRecent", recent)
    end

    local function showRecent(show)
        show = show and #recent > 0 and searchBox.Text == ""
        if show == recentFrame.Visible then
            return
        end
        recentFrame.Visible = show
        if not show then
            return
        end
        clear(recentFrame)
        local header = create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = recentFrame,
        })
        label({
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Text = "Recent searches",
            TextSize = 11,
            TextColor3 = Theme.Muted,
            Parent = header,
        })
        local wipe = create("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -6, 0, 0),
            Size = UDim2.fromOffset(0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "Clear",
            TextSize = 11,
            FontFace = Fonts.Medium,
            TextColor3 = Theme.Accent,
            AutoButtonColor = false,
            Parent = header,
        })
        wipe.MouseButton1Down:Connect(function()
            recent = {}
            persist("CloudRecent", recent)
            showRecent(false)
        end)
        for index, text in ipairs(recent) do
            local row = create("TextButton", {
                Size = UDim2.new(1, 0, 0, TOUCH and 32 or 28),
                BackgroundColor3 = Theme.Surface3,
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = index,
                Parent = recentFrame,
            })
            corner(row, UDim.new(0, 6))
            local icon = glowIcon(row, "history", Theme.Muted, UDim2.new(0, 8, 0.5, 0))
            icon.Size = UDim2.fromOffset(13, 13)
            label({
                Position = UDim2.fromOffset(28, 0),
                Size = UDim2.new(1, -34, 1, 0),
                Text = text,
                TextSize = 13,
                FontFace = Fonts.Regular,
                Parent = row,
            })
            row.MouseEnter:Connect(function()
                tween(row, { BackgroundTransparency = 0.5 }, 0.1)
            end)
            row.MouseLeave:Connect(function()
                tween(row, { BackgroundTransparency = 1 }, 0.15)
            end)
            row.MouseButton1Down:Connect(function()
                searchToken += 1
                searchBox.Text = text
                query.Search = text
                rememberSearch(text)
                showRecent(false)
                searchBox:ReleaseFocus()
                fetch(false)
            end)
        end
    end

    local function fitToolbar()
        local scale = window.Scale.Scale
        local publishWidth = publishButton.Visible and (publishButton.AbsoluteSize.X / scale + 8) or 0
        refreshButton.Position = UDim2.new(1, -publishWidth, 0, 0)
        searchHolder.Size = UDim2.new(1, -(publishWidth + ROW + 8), 1, 0)
        recentFrame.Size = UDim2.new(1, -(publishWidth + ROW + 8), 0, 0)
    end
    publishButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToolbar)
    task.defer(fitToolbar)

    -- A pixel taller than the chips on each side, so their strokes aren't clipped.
    local filterRow = create("Frame", {
        Position = UDim2.fromOffset(0, ROW + 7),
        Size = UDim2.new(1, 0, 0, CHIP + 2),
        BackgroundTransparency = 1,
        Parent = browse,
    })
    local sortButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -1, 0, 1),
        Size = UDim2.fromOffset(0, CHIP),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Surface2,
        Text = "",
        AutoButtonColor = false,
        Parent = filterRow,
    })
    corner(sortButton, UDim.new(1, 0))
    hoverStroke(sortButton, stroke(sortButton))
    padding(sortButton, 10, 12)
    hlist(sortButton, 6)
    local sortIcon = glowIcon(sortButton, "arrow-down-up", Theme.Accent, UDim2.new())
    sortIcon.Size = UDim2.fromOffset(13, 13)
    local sortLabel = label({
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = SORT_NAMES[query.Sort],
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 2,
        Parent = sortButton,
    })
    local filterStrip = create("ScrollingFrame", {
        Size = UDim2.new(1, -120, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(),
        Parent = filterRow,
    })
    filterStrip:SetAttribute("NoDrag", true)
    hlist(filterStrip, 6)
    padding(filterStrip, 1, 1, 1, 1)
    local function fitFilters()
        local width = sortButton.AbsoluteSize.X / window.Scale.Scale
        filterStrip.Size = UDim2.new(1, -(width + 8), 1, 0)
    end
    sortButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitFilters)
    task.defer(fitFilters)

    local resultsTop = ROW + 8 + CHIP + 10
    local results = scroller(browse)
    results.Position = UDim2.fromOffset(0, resultsTop)
    results.Size = UDim2.new(1, 0, 1, -resultsTop)
    padding(results, 1, 6, 1, 12)
    vlist(results, 10)
    local summaryRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
        Parent = results,
    })
    local summaryLabel = label({
        Size = UDim2.new(1, -100, 1, 0),
        Text = "",
        RichText = true,
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = summaryRow,
    })
    local resetButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = "Clear filters",
        TextSize = 12,
        FontFace = Fonts.Medium,
        TextColor3 = Theme.Accent,
        AutoButtonColor = false,
        Visible = false,
        Parent = summaryRow,
    })
    local resetFilters

    local function filtered()
        return query.Search ~= "" or query.Tag ~= nil or query.Filter ~= "All"
    end

    -- "12 configs in Favorites, tagged PvP, matching "boss"", or "Searching..."
    local function renderSummary(pending)
        local parts = {}
        if query.Filter ~= "All" then
            table.insert(parts, "in " .. query.Filter)
        end
        if query.Tag then
            table.insert(parts, "tagged " .. escape(query.Tag))
        end
        if query.Search ~= "" then
            table.insert(parts, ('matching <font color="#%s">"%s"</font>'):format(colorToHex(Theme.Accent), escape(query.Search)))
        end
        local context = #parts > 0 and (" " .. table.concat(parts, ", ")) or ""
        if pending or (loading and #records == 0) then
            summaryLabel.Text = "Searching" .. context .. "..."
        else
            local count = #records
            summaryLabel.Text = ("%d%s config%s%s"):format(count, hasMore and "+" or "", (count == 1 and not hasMore) and "" or "s", context)
        end
        resetButton.Visible = filtered()
    end

    local spin = nil
    local function busy(on)
        loading = on
        if on and not spin then
            refreshIcon.Rotation = 0
            spin = TweenService:Create(refreshIcon, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), { Rotation = 360 })
            spin:Play()
        elseif not on and spin then
            spin:Cancel()
            spin = nil
            tween(refreshIcon, { Rotation = 360 }, 0.35, Enum.EasingStyle.Quint)
        end
        renderSummary()
    end
    local grid = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = results,
    })
    local gridLayout = create("UIGridLayout", {
        CellSize = UDim2.new(1, 0, 0, CARD),
        CellPadding = UDim2.fromOffset(8, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = grid,
    })
    local function fitGrid()
        local width = results.AbsoluteSize.X / window.Scale.Scale
        local columns = width >= 620 and 2 or 1
        gridLayout.CellSize = UDim2.new(1 / columns, -(columns - 1) * 8 / columns, 0, CARD)
    end
    results:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitGrid)
    task.defer(fitGrid)
    local moreButton = softButton(results, "Load more", {
        Size = UDim2.new(1, 0, 0, 32),
        LayoutOrder = 2,
        Visible = false,
    }, function()
        cloud:LoadMore()
    end)
    local stateFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 180),
        BackgroundTransparency = 1,
        Visible = false,
        LayoutOrder = 3,
        Parent = results,
    })

    -- Loading placeholders that pulse where cards will land.
    local skeletons = {}
    local function addSkeletons(count)
        for _ = 1, count do
            local cell = create("Frame", {
                BackgroundColor3 = Theme.Surface2,
                BorderSizePixel = 0,
                LayoutOrder = 100000 + #skeletons,
                Parent = grid,
            })
            corner(cell, UDim.new(0, 10))
            stroke(cell)
            for index, spec in ipairs({ { 14, 0.45 }, { 36, 0.3 }, { 58, 0.8 }, { 76, 0.6 } }) do
                local bar = create("Frame", {
                    Position = UDim2.fromOffset(14, spec[1]),
                    Size = UDim2.new(spec[2], -14, 0, index == 1 and 14 or 10),
                    BackgroundColor3 = Theme.Surface3,
                    BorderSizePixel = 0,
                    Parent = cell,
                })
                corner(bar, UDim.new(0, 4))
                TweenService:Create(bar, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    BackgroundTransparency = 0.65,
                }):Play()
            end
            table.insert(skeletons, cell)
        end
    end
    local function clearSkeletons()
        for _, cell in ipairs(skeletons) do
            cell:Destroy()
        end
        skeletons = {}
    end

    -- kind: nil hides it, or "empty" / "error" with a message.
    local function setState(kind, text)
        clear(stateFrame)
        stateFrame.Visible = kind ~= nil
        if not kind then
            return
        end
        local holder, caption = emptyState(stateFrame, kind == "error" and "cloud-off" or "search-x", text)
        holder.Size = UDim2.fromOffset(280, 70)
        holder.Position = UDim2.new(0.5, 0, 0, 60)
        caption.TextWrapped = true
        caption.TextTruncate = Enum.TextTruncate.None
        caption.Size = UDim2.new(1, 0, 0, 32)
        if kind == "error" or filtered() then
            softButton(stateFrame, kind == "error" and "Try again" or "Clear filters", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 132),
                Size = UDim2.fromOffset(0, 30),
                AutomaticSize = Enum.AutomaticSize.X,
            }, function()
                if kind == "error" then
                    cloud:Refresh()
                else
                    resetFilters()
                end
            end)
        end
        renderSummary()
    end

    -- Cards

    local openDetail, installRecord, refreshRecord

    local function renderCard(card)
        local record = card.Record
        card.Title.Text = highlight(record.Name)
        local meta = { "by " .. record.Author }
        local when = ago(record.Updated)
        if when then
            table.insert(meta, when)
        end
        if record.Count then
            table.insert(meta, record.Count .. (record.Count == 1 and " setting" or " settings"))
        end
        card.Meta.Text = table.concat(meta, "  ·  ")
        card.Desc.Text = record.Description ~= "" and highlight(record.Description) or "No description"
        card.Desc.TextTransparency = record.Description ~= "" and 0.2 or 0.55
        card.Likes.Text = compact(record.Likes)
        card.Installs.Text = compact(record.Installs)
        tween(card.Heart, { ImageColor3 = record.Liked and Theme.Accent or Theme.Muted }, 0.15)
        local state = installState(record)
        local badge, color
        if state == "Update" then
            badge, color = "UPDATE", Theme.Accent
        elseif state == "Installed" then
            badge, color = "INSTALLED", Theme.Success
        elseif record.Mine then
            badge, color = "YOURS", Theme.Accent
        elseif otherScript(record) then
            badge, color = "OTHER SCRIPT", Theme.Warning
        end
        card.Badge.Visible = badge ~= nil
        if badge then
            card.Badge.Text = badge
            tween(card.Badge, { TextColor3 = color, BackgroundColor3 = color }, 0)
        end
        card.Star.Visible = favorites[record.Id] ~= nil
        card.InstallText.Text = state == "Update" and "Update" or (state == "Installed" and "Reinstall" or "Install")
        clear(card.TagRow)
        for index, tag in ipairs(record.Tags) do
            if index > 3 then
                tagPill(card.TagRow, "+" .. (#record.Tags - 3), index)
                break
            end
            tagPill(card.TagRow, tag, index)
        end
    end

    local function buildCard(record, order)
        local frame = create("TextButton", {
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = grid,
        })
        frame:SetAttribute("NoDrag", true)
        corner(frame, UDim.new(0, 10))
        hoverStroke(frame, stroke(frame))
        padding(frame, 14, 14, 12, 12)
        local card = { Record = record, Frame = frame }
        card.Title = label({
            Size = UDim2.new(1, -110, 0, 18),
            RichText = true,
            TextSize = 14,
            FontFace = Fonts.Bold,
            Parent = frame,
        })
        local corner_ = create("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(0, 18),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Parent = frame,
        })
        local cornerLayout = hlist(corner_, 6)
        cornerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        card.Star = label({
            Size = UDim2.fromOffset(14, 18),
            Text = "★",
            TextSize = 13,
            TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 1,
            Parent = corner_,
        })
        card.Badge = label({
            Size = UDim2.fromOffset(0, 17),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 0.85,
            TextSize = 10,
            FontFace = Fonts.Bold,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 2,
            Parent = corner_,
        })
        corner(card.Badge, UDim.new(0, 5))
        padding(card.Badge, 6, 6)
        card.Meta = label({
            Position = UDim2.fromOffset(0, 20),
            Size = UDim2.new(1, 0, 0, 16),
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            Parent = frame,
        })
        card.Desc = label({
            Position = UDim2.fromOffset(0, 41),
            RichText = true,
            Size = UDim2.new(1, 0, 0, 30),
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextWrapped = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = frame,
        })
        local bottom = create("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            Parent = frame,
        })
        card.TagRow = create("Frame", {
            Size = UDim2.new(1, -190, 1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = bottom,
        })
        hlist(card.TagRow, 4)
        local install, installText = softButton(bottom, "Install", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(76, 26),
        }, function()
            installRecord(record)
        end)
        primary(install, installText)
        card.InstallText = installText
        local stats = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -86, 0.5, 0),
            Size = UDim2.fromOffset(0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Parent = bottom,
        })
        hlist(stats, 4)
        local function stat(icon, order_)
            local holder, image = glowIcon(stats, icon, Theme.Muted, UDim2.new())
            holder.Size = UDim2.fromOffset(12, 12)
            holder.LayoutOrder = order_
            local text_ = label({
                Size = UDim2.fromOffset(0, 20),
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                TextColor3 = Theme.Muted,
                TextTruncate = Enum.TextTruncate.None,
                LayoutOrder = order_ + 1,
                Parent = stats,
            })
            return text_, image
        end
        card.Likes, card.Heart = stat("heart", 1)
        create("Frame", { Size = UDim2.fromOffset(4, 1), BackgroundTransparency = 1, LayoutOrder = 3, Parent = stats })
        card.Installs = stat("download", 4)
        local isTap = tapGuard(frame, function()
            return results
        end)
        frame.MouseButton1Click:Connect(function()
            if isTap() then
                if query.Search ~= "" then
                    rememberSearch(query.Search)
                end
                openDetail(record)
            end
        end)
        cards[record.Id] = card
        renderCard(card)
        return card
    end

    local function renderList()
        for _, card in pairs(cards) do
            card.Frame:Destroy()
        end
        cards = {}
        for index, record in ipairs(records) do
            buildCard(record, index)
        end
    end

    -- Favorites and Installed are kept on this device, so they filter locally.
    local function localRecords()
        local source = query.Filter == "Favorites" and favorites or installed
        local search = string.lower(query.Search)
        local list = {}
        for id, entry in pairs(source) do
            local kept = query.Filter == "Favorites" and entry or (type(entry) == "table" and entry.Record)
            if type(kept) == "table" then
                kept = table.clone(kept)
                kept.Id = id
                local record = normalizeRecord(kept)
                local matches = search == "" or string.find(string.lower(record.Name), search, 1, true)
                    or string.find(string.lower(record.Description), search, 1, true)
                if matches and query.Tag then
                    matches = table.find(record.Tags, query.Tag) ~= nil
                end
                if matches then
                    table.insert(list, record)
                end
            end
        end
        table.sort(list, function(a, b)
            if query.Sort == "New" then
                return (a.Updated or 0) > (b.Updated or 0)
            elseif query.Sort == "Installs" then
                return a.Installs > b.Installs
            end
            return a.Likes > b.Likes
        end)
        return list
    end

    local function emptyText()
        if query.Filter == "Favorites" then
            return "No favorites yet. Open a config and press Favorite to keep it here."
        elseif query.Filter == "Installed" then
            return "Nothing installed from the cloud yet"
        elseif query.Filter == "Mine" then
            return "You haven't published anything yet"
        elseif query.Search ~= "" or query.Tag then
            return "No configs match your search"
        end
        return tostring(opts.EmptyText or "No configs shared yet. Be the first!")
    end

    function fetch(more)
        token += 1
        local myToken = token
        if query.Filter == "Favorites" or query.Filter == "Installed" then
            busy(false)
            clearSkeletons()
            records = localRecords()
            hasMore = false
            renderList()
            moreButton.Visible = false
            setState(#records == 0 and "empty" or nil, emptyText())
            return
        end
        if type(opts.OnFetch) ~= "function" then
            renderList()
            setState(#records == 0 and "empty" or nil, emptyText())
            return
        end
        if more then
            if not hasMore then
                return
            end
            page += 1
        else
            page = 1
            records = {}
            renderList()
            results.CanvasPosition = Vector2.zero
        end
        busy(true)
        clearSkeletons()
        addSkeletons(more and 2 or 4)
        moreButton.Visible = false
        setState(nil)
        local fetchQuery = {
            Search = query.Search,
            Sort = query.Sort,
            Filter = query.Filter,
            Tag = query.Tag,
            Page = page,
            PageSize = pageSize,
            Folder = window.ConfigFolder,
            UserId = LocalPlayer.UserId,
        }
        task.spawn(function()
            local ok, list, extra = isolatedCall(function()
                return opts.OnFetch(fetchQuery)
            end)
            if myToken ~= token then
                return
            end
            busy(false)
            clearSkeletons()
            if not ok or type(list) ~= "table" then
                if more then
                    page -= 1
                end
                if not ok then
                    warn("[Noir] cloud OnFetch error: " .. tostring(list))
                end
                hasMore = more and hasMore or false
                moreButton.Visible = false
                setState("error", not ok and "Could not load configs" or tostring(extra or "Could not load configs"))
                return
            end
            hasMore = extra == true
            local seen = {}
            for _, record in ipairs(records) do
                seen[record] = true
            end
            for _, raw in ipairs(list) do
                local record = normalizeRecord(raw)
                if record and not seen[record] then
                    seen[record] = true
                    table.insert(records, record)
                    buildCard(record, #records)
                end
            end
            moreButton.Visible = hasMore
            setState(#records == 0 and "empty" or nil, emptyText())
        end)
    end

    -- Near the bottom, the next page loads by itself.
    results:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if not hasMore or loading then
            return
        end
        local scale = window.Scale.Scale
        local remaining = results.AbsoluteCanvasSize.Y / scale - results.AbsoluteWindowSize.Y / scale - results.CanvasPosition.Y
        if remaining < 160 then
            fetch(true)
        end
    end)

    -- Filters and sorting

    local filterChips, tagChips = {}, {}
    local function renderFilters(instant)
        for name, object in pairs(filterChips) do
            object.Set(query.Filter == name, instant)
        end
        for name, object in pairs(tagChips) do
            object.Set(query.Tag == name, instant)
        end
        sortLabel.Text = SORT_NAMES[query.Sort]
    end
    for index, name in ipairs(FILTERS) do
        if not (name == "Mine" and opts.MineFilter == false) then
            filterChips[name] = chip(filterStrip, name, index, function()
                if query.Filter ~= name then
                    query.Filter = name
                    renderFilters()
                    fetch(false)
                end
            end)
        end
    end
    if #tagList > 0 then
        create("Frame", {
            Size = UDim2.fromOffset(1, 16),
            BackgroundColor3 = Theme.Stroke,
            BorderSizePixel = 0,
            LayoutOrder = 10,
            Parent = filterStrip,
        })
    end
    for index, tag in ipairs(tagList) do
        tag = tostring(tag)
        tagChips[tag] = chip(filterStrip, tag, 10 + index, function()
            query.Tag = query.Tag ~= tag and tag or nil
            renderFilters()
            fetch(false)
        end)
    end
    sortButton.MouseButton1Click:Connect(function()
        local index = table.find(SORTS, query.Sort) or 1
        query.Sort = SORTS[index % #SORTS + 1]
        persist("CloudSort", query.Sort)
        renderFilters()
        fetch(false)
    end)

    function resetFilters()
        searchToken += 1
        searchBox.Text = ""
        query.Search, query.Tag, query.Filter = "", nil, "All"
        renderFilters()
        fetch(false)
    end
    resetButton.MouseButton1Click:Connect(resetFilters)

    -- Typing searches after a short pause; Enter searches now.
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchClear.Visible = searchBox.Text ~= ""
        showRecent(searchBox:IsFocused())
        searchToken += 1
        local mine = searchToken
        local text = trim(searchBox.Text)
        if text ~= query.Search then
            renderSummary(true)
        end
        task.delay(0.35, function()
            text = trim(searchBox.Text)
            if mine == searchToken and text ~= query.Search then
                query.Search = text
                fetch(false)
            end
        end)
    end)
    searchBox.Focused:Connect(function()
        tween(searchStroke, { Color = Theme.Accent }, 0.15)
        tween(searchImage, { ImageColor3 = Theme.Accent }, 0.15)
        showRecent(true)
    end)
    searchBox.FocusLost:Connect(function(enterPressed)
        tween(searchStroke, { Color = Theme.Stroke }, 0.2)
        tween(searchImage, { ImageColor3 = Theme.Muted }, 0.2)
        rememberSearch(searchBox.Text)
        -- Late enough for a press on a recent search to land first.
        task.delay(0.15, function()
            if not searchBox:IsFocused() then
                showRecent(false)
            end
        end)
        if enterPressed then
            searchToken += 1
            local text = trim(searchBox.Text)
            if text ~= query.Search then
                query.Search = text
                fetch(false)
            end
        end
    end)
    searchClear.MouseButton1Click:Connect(function()
        searchToken += 1
        searchBox.Text = ""
        if query.Search ~= "" then
            query.Search = ""
            fetch(false)
        end
    end)
    -- "/" jumps to the search box while the list is showing.
    window:_listen("Began", function(input, processed)
        if processed or input.KeyCode ~= Enum.KeyCode.Slash then
            return
        end
        if window.Open and window.CurrentTab == tab and currentView == views.Browse and not UserInputService:GetFocusedTextBox() then
            task.defer(function()
                searchBox:CaptureFocus()
                searchBox.Text = searchBox.Text:gsub("/$", "")
            end)
        end
    end, cloud)
    refreshButton.MouseButton1Click:Connect(function()
        cloud:Refresh()
    end)

    -- Actions on a record

    -- Runs callback with the record's code, asking the backend for it first
    -- when the list came without codes.
    local function withCode(record, callback, onFail)
        if record.Code then
            callback(record.Code)
            return
        end
        local function fail(reason)
            if onFail then
                onFail(reason)
            else
                notify(false, "Could not load config", reason)
            end
        end
        if type(opts.OnFetchCode) ~= "function" then
            fail("This config has no code")
            return
        end
        task.spawn(function()
            local ok, code, reason = isolatedCall(function()
                return opts.OnFetchCode(publicRecord(record))
            end)
            if ok and type(code) == "string" and code ~= "" then
                record.Code = code
                record.Count = record.Count or countFlags(code)
                callback(code)
            else
                fail(tostring(reason or (not ok and "the request failed") or "no code came back"))
            end
        end)
    end

    function installRecord(record)
        if record._busy then
            return
        end
        record._busy = true
        withCode(record, function(code)
            record._busy = nil
            local data, info = window:DecodeConfig(code)
            if not data then
                notify(false, "Install failed", "The config code is invalid")
                return
            end
            local count = 0
            for _ in pairs(data) do
                count += 1
            end
            local mark = installed[record.Id]
            local saveAs = nil
            if fileApiAvailable() then
                -- An update overwrites the config it installed last time.
                saveAs = type(mark) == "table" and type(mark.Name) == "string" and window:ConfigExists(mark.Name) and mark.Name
                    or uniqueName(record.Name)
            end
            local other = info.Folder and info.Folder ~= window.ConfigFolder
            local function apply(save)
                local name = save and saveAs or nil
                local ok, err = window:ImportConfig(code, name, true)
                if not ok then
                    notify(false, "Install failed", tostring(err))
                    return
                end
                installed[record.Id] = { Updated = record.Updated or os.time(), Name = name, At = os.time(), Record = summary(record) }
                persist("CloudInstalled", installed)
                record.Installs += 1
                refreshRecord(record)
                notify(true, "Config installed", name and ("Saved as " .. name) or "Applied to your current settings")
                if opts.OnInstall then
                    task.spawn(safeCall, opts.OnInstall, publicRecord(record), name)
                end
            end
            local content = ("%s by %s changes %d setting%s."):format(record.Name, record.Author, count, count == 1 and "" or "s")
            if other then
                content ..= (" It was made for %s, so only matching settings apply."):format(info.Folder)
            end
            if saveAs then
                content ..= (" Install also saves it as %s; Apply only doesn't."):format(saveAs)
            end
            local buttons = { { Title = "Cancel" } }
            table.insert(buttons, { Title = "Apply only", Variant = not saveAs and "Primary" or nil, Callback = function()
                apply(false)
            end })
            if saveAs then
                table.insert(buttons, { Title = "Install", Variant = "Primary", Callback = function()
                    apply(true)
                end })
            end
            window:Dialog({
                Title = installState(record) == "Update" and "Update config" or "Install config",
                Content = content,
                Icon = other and "triangle-alert" or "download",
                Buttons = buttons,
            })
        end, function(reason)
            record._busy = nil
            notify(false, "Could not load config", reason)
        end)
    end

    local function toggleLike(record)
        if type(opts.OnLike) ~= "function" or record._liking then
            return
        end
        local liked = not record.Liked
        record.Liked = liked
        record.Likes = math.max(record.Likes + (liked and 1 or -1), 0)
        record._liking = true
        refreshRecord(record)
        task.spawn(function()
            local ok, result, reason = isolatedCall(function()
                return opts.OnLike(publicRecord(record), liked)
            end)
            record._liking = nil
            if not ok or result == false then
                record.Liked = not liked
                record.Likes = math.max(record.Likes + (liked and -1 or 1), 0)
                refreshRecord(record)
                notify(false, "Like not saved", tostring(reason or "Try again in a moment"))
            end
        end)
    end

    local function toggleFavorite(record)
        local on = favorites[record.Id] == nil
        favorites[record.Id] = on and summary(record) or nil
        persist("CloudFavorites", favorites)
        refreshRecord(record)
        window:Notify({
            Title = on and "Added to favorites" or "Removed from favorites",
            Content = record.Name,
            Icon = "star",
            Duration = 2,
        })
    end

    local function removeRecord(record)
        local index = table.find(records, record)
        if index then
            table.remove(records, index)
        end
        byId[record.Id] = nil
        local card = cards[record.Id]
        if card then
            card.Frame:Destroy()
            cards[record.Id] = nil
        end
        if #records == 0 and not loading then
            setState("empty", emptyText())
        end
    end

    local function deleteRecord(record)
        window:Confirm({
            Title = "Delete config",
            Content = ("Remove %s from the cloud? People who installed it keep their copy."):format(record.Name),
            Icon = "trash-2",
            ConfirmText = "Delete",
            Callback = function()
                task.spawn(function()
                    local ok, result, reason = isolatedCall(function()
                        return opts.OnDelete(publicRecord(record))
                    end)
                    if not ok or result == false then
                        notify(false, "Delete failed", tostring(reason or "Try again in a moment"))
                        return
                    end
                    favorites[record.Id] = nil
                    persist("CloudFavorites", favorites)
                    removeRecord(record)
                    showView(views.Browse)
                    notify(true, "Config deleted", record.Name)
                end)
            end,
        })
    end

    local function reportRecord(record)
        local reasons = type(opts.ReportReasons) == "table" and opts.ReportReasons or { "Broken", "Spam", "Inappropriate" }
        local buttons = { { Title = "Cancel" } }
        for _, reason in ipairs(reasons) do
            table.insert(buttons, { Title = tostring(reason), Callback = function()
                task.spawn(function()
                    local ok, result = isolatedCall(function()
                        return opts.OnReport(publicRecord(record), tostring(reason))
                    end)
                    local sent = ok and result ~= false
                    notify(sent, sent and "Report sent" or "Report failed", sent and "Thanks for letting us know" or "Try again in a moment")
                end)
            end })
        end
        window:Dialog({
            Title = "Report config",
            Content = ("What's wrong with %s?"):format(record.Name),
            Icon = "flag",
            Buttons = buttons,
        })
    end

    -- Detail view

    local detailList = scroller(views.Detail)
    padding(detailList, 1, 8, 1, 16)
    vlist(detailList, 10)

    local function valueText(entry)
        local value = type(entry) == "table" and entry.Value or nil
        if value == nil then
            return "None"
        elseif type(value) == "boolean" then
            return value and "On" or "Off"
        elseif type(value) == "number" then
            return (("%.2f"):format(value):gsub("%.?0+$", ""))
        elseif type(value) == "table" then
            if type(value.Hex) == "string" then
                return "#" .. string.upper(value.Hex)
            elseif type(value.Colors) == "table" then
                local text = type(value.Name) == "string" and value.Name or "Custom"
                if type(value.Background) == "string" and value.Background ~= "" then
                    text ..= ", image"
                end
                return text
            end
            local parts = {}
            for index, item in ipairs(value) do
                parts[index] = tostring(item)
            end
            return #parts > 0 and table.concat(parts, ", ") or "None"
        end
        return tostring(value)
    end

    local function encoded(entry)
        local ok, text = pcall(HttpService.JSONEncode, HttpService, type(entry) == "table" and entry.Value or nil)
        return ok and text or tostring(entry)
    end

    local function renderDetail()
        local record = detailRecord
        if not record or not detail.Meta then
            return
        end
        detail.Title.Text = record.Name
        local meta = { "by " .. record.Author }
        local when = ago(record.Updated)
        if when then
            table.insert(meta, "updated " .. when)
        end
        if otherScript(record) then
            table.insert(meta, "made for " .. record.Folder)
        end
        detail.Meta.Text = table.concat(meta, "  ·  ")
        detail.Stats.Text = ("%s like%s  ·  %s install%s"):format(
            compact(record.Likes), record.Likes == 1 and "" or "s",
            compact(record.Installs), record.Installs == 1 and "" or "s")
        if detail.BuiltFor ~= record or detail.BuiltMine ~= record.Mine then
            detail.BuiltFor, detail.BuiltMine = record, record.Mine
            local row = detail.Actions
            clear(row)
            local order = 0
            local function action(text, style, callback)
                order += 1
                local button, text_ = softButton(row, text, {
                    Size = UDim2.new(0, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.X,
                    LayoutOrder = order,
                }, callback)
                text_.TextSize = 13
                if style == "Primary" then
                    primary(button, text_)
                elseif style == "Danger" then
                    tween(text_, { TextColor3 = Theme.Error }, 0)
                end
                return text_
            end
            detail.InstallLabel = action("Install", "Primary", function()
                installRecord(record)
            end)
            if type(opts.OnLike) == "function" then
                detail.LikeLabel = action("Like", nil, function()
                    toggleLike(record)
                end)
            end
            detail.FavoriteLabel = action("Favorite", nil, function()
                toggleFavorite(record)
            end)
            action("Copy code", nil, function()
                withCode(record, function(code)
                    window:CopyToClipboard(code, "Config code")
                end)
            end)
            if record.Mine then
                if type(opts.OnUpdate) == "function" then
                    action("Edit", nil, function()
                        cloud:OpenPublish(record)
                    end)
                end
                if type(opts.OnDelete) == "function" then
                    action("Delete", "Danger", function()
                        deleteRecord(record)
                    end)
                end
            elseif type(opts.OnReport) == "function" then
                action("Report", "Danger", function()
                    reportRecord(record)
                end)
            end
        end
        local state = installState(record)
        detail.InstallLabel.Text = state == "Update" and "Update" or (state == "Installed" and "Reinstall" or "Install")
        if detail.LikeLabel then
            detail.LikeLabel.Text = (record.Liked and "Liked" or "Like") .. "  ·  " .. compact(record.Likes)
        end
        detail.FavoriteLabel.Text = favorites[record.Id] and "Favorited" or "Favorite"
    end

    -- Every setting in the config next to the player's own: changed ones
    -- first, then the same ones, then flags this script doesn't have.
    local function fillPreview(record, myToken)
        local function mismatch(text)
            if detailToken == myToken then
                detail.Summary.Text = text
            end
        end
        withCode(record, function(code)
            if detailToken ~= myToken then
                return
            end
            local data = window:DecodeConfig(code)
            if not data then
                mismatch("The config code is invalid")
                return
            end
            local current = collectFlags(window)
            local rows = {}
            local changed = 0
            for flag, entry in pairs(data) do
                local element = Library.Flags[flag]
                local known = element ~= nil
                local differs = known and encoded(entry) ~= encoded(current[flag])
                if differs then
                    changed += 1
                end
                table.insert(rows, {
                    Name = element and element._searchName ~= "" and element._searchName or flag,
                    Value = valueText(entry),
                    Known = known,
                    Changed = differs,
                    Rank = differs and 0 or (known and 1 or 2),
                })
            end
            table.sort(rows, function(a, b)
                if a.Rank ~= b.Rank then
                    return a.Rank < b.Rank
                end
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            record.Count = #rows
            detail.Summary.Text = changed == 0 and ("%d settings, all the same as yours"):format(#rows)
                or ("%d settings, %d different from yours"):format(#rows, changed)
            clear(detail.Rows)
            for index, item in ipairs(rows) do
                if index > 150 then
                    wrapped(detail.Rows, ("and %d more"):format(#rows - 150), 12, Theme.Muted, index)
                    break
                end
                local rowFrame = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Surface2,
                    BackgroundTransparency = item.Changed and 0 or 0.5,
                    BorderSizePixel = 0,
                    LayoutOrder = index,
                    Parent = detail.Rows,
                })
                corner(rowFrame, UDim.new(0, 7))
                if item.Changed then
                    local dot = create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 10, 0.5, 0),
                        Size = UDim2.fromOffset(6, 6),
                        BackgroundColor3 = Theme.Accent,
                        BorderSizePixel = 0,
                        Parent = rowFrame,
                    })
                    corner(dot, UDim.new(1, 0))
                end
                label({
                    Position = UDim2.fromOffset(24, 0),
                    Size = UDim2.new(0.55, -24, 1, 0),
                    Text = item.Known and item.Name or (item.Name .. "  (not in this script)"),
                    TextSize = 12,
                    TextColor3 = item.Known and Theme.Text or Theme.Muted,
                    Parent = rowFrame,
                })
                label({
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -10, 0, 0),
                    Size = UDim2.new(0.45, -10, 1, 0),
                    Text = item.Value,
                    TextSize = 12,
                    FontFace = Fonts.Regular,
                    TextColor3 = item.Changed and Theme.Accent or Theme.Muted,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = rowFrame,
                })
            end
            if cards[record.Id] then
                renderCard(cards[record.Id])
            end
        end, mismatch)
    end

    function openDetail(record)
        detailRecord = record
        detailToken += 1
        local myToken = detailToken
        clear(detailList)
        detail = {}
        detailList.CanvasPosition = Vector2.zero
        softButton(detailList, "Back", {
            Size = UDim2.new(0, 0, 0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 1,
        }, function()
            showView(views.Browse)
        end)
        detail.Title = wrapped(detailList, record.Name, 20, Theme.Text, 2, Fonts.Bold)
        detail.Meta = wrapped(detailList, "", 12, Theme.Muted, 3)
        if record.Description ~= "" then
            wrapped(detailList, record.Description, 13, Theme.Text, 4)
        end
        if #record.Tags > 0 then
            local tagsRow = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 5,
                Parent = detailList,
            })
            hlist(tagsRow, 4, true)
            for index, tag in ipairs(record.Tags) do
                tagPill(tagsRow, tag, index)
            end
        end
        detail.Stats = wrapped(detailList, "", 12, Theme.Muted, 6)
        detail.Actions = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 7,
            Parent = detailList,
        })
        hlist(detail.Actions, 6, true)
        create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = Theme.Stroke,
            BorderSizePixel = 0,
            LayoutOrder = 8,
            Parent = detailList,
        })
        wrapped(detailList, "Settings", 14, Theme.Text, 9, Fonts.Bold)
        detail.Summary = wrapped(detailList, "Loading settings...", 12, Theme.Muted, 10)
        detail.Rows = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 11,
            Parent = detailList,
        })
        vlist(detail.Rows, 4)
        renderDetail()
        showView(views.Detail)
        fillPreview(record, myToken)
    end

    function refreshRecord(record)
        local card = cards[record.Id]
        if card then
            renderCard(card)
        end
        if detailRecord == record and currentView == views.Detail then
            renderDetail()
        end
    end

    -- Publish view: also the edit form for the player's own configs.

    local form = { Mode = "Publish", Record = nil, Source = false, Tags = {}, Busy = false }
    local publishList = scroller(views.Publish)
    padding(publishList, 1, 8, 1, 16)
    vlist(publishList, 8)
    softButton(publishList, "Back", {
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 1,
    }, function()
        showView(form.Mode == "Edit" and form.Record and views.Detail or views.Browse)
    end)
    local formTitle = wrapped(publishList, "Publish a config", 20, Theme.Text, 2, Fonts.Bold)
    wrapped(publishList, "Name", 12, Theme.Muted, 3)
    local nameBox = field(publishList, 4, "What is it for?", ROW, NAME_LIMIT)
    wrapped(publishList, "Description", 12, Theme.Muted, 5)
    local descBox = field(publishList, 6, "What does it do, and how should people use it?", 90, DESC_LIMIT)
    local tagsTitle = wrapped(publishList, "Tags", 12, Theme.Muted, 7)
    local tagsRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 8,
        Parent = publishList,
    })
    hlist(tagsRow, 6, true)
    tagsTitle.Visible = #tagList > 0 and maxTags > 0
    tagsRow.Visible = tagsTitle.Visible
    wrapped(publishList, "Settings to share", 12, Theme.Muted, 9)
    local sourceRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 10,
        Parent = publishList,
    })
    hlist(sourceRow, 6, true)
    local sourceSummary = wrapped(publishList, "", 12, Theme.Muted, 11)
    local identityNote = wrapped(publishList, "", 12, Theme.Muted, 12)
    local formError = wrapped(publishList, "", 12, Theme.Error, 13)
    formError.Visible = false
    local submitRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 14,
        Parent = publishList,
    })
    hlist(submitRow, 6)
    local submitButton, submitText = softButton(submitRow, "Publish", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 1,
    }, function()
        cloud:_submit()
    end)
    primary(submitButton, submitText)
    softButton(submitRow, "Cancel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 2,
    }, function()
        showView(form.Mode == "Edit" and form.Record and views.Detail or views.Browse)
    end)

    local formTagChips = {}
    local function renderFormTags()
        for tag, object in pairs(formTagChips) do
            object.Set(table.find(form.Tags, tag) ~= nil)
        end
        tagsTitle.Text = maxTags > 0 and ("Tags  (%d/%d)"):format(#form.Tags, maxTags) or "Tags"
    end
    for index, tag in ipairs(tagList) do
        tag = tostring(tag)
        formTagChips[tag] = chip(tagsRow, tag, index, function()
            local at = table.find(form.Tags, tag)
            if at then
                table.remove(form.Tags, at)
            elseif #form.Tags < maxTags then
                table.insert(form.Tags, tag)
            else
                notify(false, "Too many tags", ("Pick up to %d"):format(maxTags))
            end
            renderFormTags()
        end)
    end

    -- The code and setting count for the picked source, or nil and why not.
    local function sourceCode(name)
        if form.Source == "Keep" then
            return nil, form.Record and form.Record.Count
        elseif form.Source then
            local code, err = window:ExportConfig(form.Source)
            if not code then
                return nil, nil, err
            end
            return code, countFlags(code)
        end
        local ok, code = pcall(encodeConfig, window, name ~= "" and name or "Cloud config", collectFlags(window))
        if not ok then
            return nil, nil, "could not encode your settings"
        end
        return code, countFlags(code)
    end

    local sourceChips = {}
    local function renderSource()
        for key, object in pairs(sourceChips) do
            object.Set(key == (form.Source or "*current"))
        end
        local _, count, err = sourceCode(trim(nameBox.Text))
        if err then
            sourceSummary.Text = tostring(err)
        elseif form.Source == "Keep" then
            sourceSummary.Text = "Keeps the settings already published" .. (count and (" (" .. count .. ")") or "")
        else
            sourceSummary.Text = ("%d setting%s from %s"):format(count or 0, count == 1 and "" or "s", form.Source or "your current settings")
        end
    end

    local function buildSources()
        clear(sourceRow)
        sourceChips = {}
        local order = 0
        local function add(key, text)
            order += 1
            sourceChips[key] = chip(sourceRow, text, order, function()
                form.Source = key ~= "*current" and key or false
                renderSource()
            end)
        end
        if form.Mode == "Edit" then
            add("Keep", "Keep published settings")
        end
        add("*current", "Current settings")
        for _, name in ipairs(window:ListConfigs()) do
            add(name, name)
        end
        renderSource()
    end

    local function showError(text)
        formError.Text = tostring(text)
        formError.Visible = true
    end

    function cloud:OpenPublish(record)
        local editing = type(record) == "table" and record.Id and byId[record.Id] or nil
        if editing then
            form.Mode, form.Record = "Edit", editing
            form.Source = "Keep"
            form.Tags = table.clone(editing.Tags)
            nameBox.Text = editing.Name
            descBox.Text = editing.Description
        elseif form.Mode == "Edit" then
            -- Leaving an edit starts a fresh draft; a publish draft is kept.
            form.Mode, form.Record, form.Source, form.Tags = "Publish", nil, false, {}
            nameBox.Text = ""
            descBox.Text = ""
        end
        formTitle.Text = editing and "Edit config" or "Publish a config"
        submitText.Text = editing and "Save changes" or "Publish"
        formError.Visible = false
        local streamer = streamerOn()
        identityNote.Text = streamer and ("Your name is hidden, so you publish as " .. anonName)
            or ("You publish as " .. LocalPlayer.DisplayName)
        renderFormTags()
        buildSources()
        publishList.CanvasPosition = Vector2.zero
        showView(views.Publish)
    end

    nameBox:GetPropertyChangedSignal("Text"):Connect(function()
        formError.Visible = false
    end)

    function cloud:_submit()
        if form.Busy then
            return
        end
        local name = trim(nameBox.Text)
        if name == "" then
            showError("Give your config a name")
            return
        end
        local code, count, err = sourceCode(name)
        if err then
            showError(err)
            return
        end
        if form.Source ~= "Keep" and (count or 0) == 0 then
            showError("There are no settings to share")
            return
        end
        local editing = form.Mode == "Edit" and form.Record or nil
        local callback = editing and opts.OnUpdate or opts.OnPublish
        if type(callback) ~= "function" then
            showError(editing and "Editing isn't available" or "Publishing isn't available")
            return
        end
        local streamer = streamerOn()
        local payload = {
            Name = name,
            Description = trim(descBox.Text),
            Tags = table.clone(form.Tags),
            Code = code,
            Count = count,
            Folder = window.ConfigFolder,
            Author = streamer and anonName or LocalPlayer.DisplayName,
            AuthorId = not streamer and LocalPlayer.UserId or nil,
            OwnerId = LocalPlayer.UserId,
            Streamer = streamer,
        }
        form.Busy = true
        submitText.Text = editing and "Saving..." or "Publishing..."
        formError.Visible = false
        task.spawn(function()
            local ok, result, reason = isolatedCall(function()
                if editing then
                    return callback(publicRecord(editing), payload)
                end
                return callback(payload)
            end)
            form.Busy = false
            submitText.Text = editing and "Save changes" or "Publish"
            if not ok or result == false then
                if not ok then
                    warn("[Noir] cloud publish error: " .. tostring(result))
                end
                showError(ok and reason and tostring(reason) or "Something went wrong, try again")
                return
            end
            local merged = table.clone(payload)
            merged.Code = code or (editing and editing.Code)
            merged.Updated = os.time()
            if type(result) == "table" then
                for key, value in pairs(result) do
                    merged[key] = value
                end
            end
            if editing then
                merged.Id = editing.Id
                normalizeRecord(merged)
                if favorites[editing.Id] then
                    favorites[editing.Id] = summary(editing)
                    persist("CloudFavorites", favorites)
                end
                refreshRecord(editing)
                notify(true, "Config updated", name)
                openDetail(editing)
            else
                nameBox.Text = ""
                descBox.Text = ""
                form.Tags = {}
                form.Source = false
                if type(result) == "table" then
                    merged.Mine = true
                    local record = normalizeRecord(merged)
                    if query.Filter == "All" or query.Filter == "Mine" then
                        table.insert(records, 1, record)
                        renderList()
                        setState(nil)
                    end
                    notify(true, "Config published", name)
                    openDetail(record)
                else
                    notify(true, "Config published", name)
                    showView(views.Browse)
                    fetch(false)
                end
            end
        end)
    end

    -- Handle

    function cloud:Refresh()
        fetch(false)
    end

    function cloud:LoadMore()
        if not loading then
            fetch(true)
        end
    end

    -- For backends that push results instead of answering OnFetch.
    function cloud:SetConfigs(list, more)
        token += 1
        busy(false)
        clearSkeletons()
        records = {}
        for _, raw in ipairs(type(list) == "table" and list or {}) do
            local record = normalizeRecord(raw)
            if record then
                table.insert(records, record)
            end
        end
        hasMore = more == true
        renderList()
        moreButton.Visible = hasMore
        setState(#records == 0 and "empty" or nil, emptyText())
    end

    function cloud:AddConfigs(list, more)
        token += 1
        busy(false)
        clearSkeletons()
        for _, raw in ipairs(type(list) == "table" and list or {}) do
            local record = normalizeRecord(raw)
            if record and not table.find(records, record) then
                table.insert(records, record)
                buildCard(record, #records)
            end
        end
        hasMore = more == true
        moreButton.Visible = hasMore
        setState(#records == 0 and "empty" or nil, emptyText())
    end

    function cloud:UpdateConfig(id, changes)
        local record = byId[tostring(id)]
        if record and type(changes) == "table" then
            local merged = table.clone(changes)
            merged.Id = record.Id
            normalizeRecord(merged)
            refreshRecord(record)
        end
    end

    function cloud:RemoveConfig(id)
        local record = byId[tostring(id)]
        if record then
            removeRecord(record)
            if detailRecord == record and currentView == views.Detail then
                showView(views.Browse)
            end
        end
    end

    function cloud:SetLoading(on)
        token += 1
        busy(on == true)
        clearSkeletons()
        if loading then
            addSkeletons(4)
            setState(nil)
        end
    end

    function cloud:SetError(text)
        token += 1
        busy(false)
        clearSkeletons()
        setState(text and "error" or nil, tostring(text or ""))
    end

    function cloud:Open(id)
        local record = byId[tostring(id)]
        if record then
            window:SelectTab(tab)
            openDetail(record)
        end
    end

    function cloud:Back()
        showView(views.Browse)
    end

    function cloud:GetQuery()
        return table.clone(query)
    end

    function cloud:GetFavorites()
        local list = {}
        for id, kept in pairs(favorites) do
            local copy = table.clone(kept)
            copy.Id = id
            table.insert(list, copy)
        end
        return list
    end

    function cloud:GetInstalled()
        local list = {}
        for id, mark in pairs(installed) do
            table.insert(list, { Id = id, Name = mark.Name, Updated = mark.Updated, Record = mark.Record })
        end
        return list
    end

    renderFilters(true)
    showView(views.Browse)
    -- The first fetch waits until the tab is opened, so a hidden tab costs nothing.
    local fetched = false
    local function firstFetch()
        if not fetched and tab._page.Visible then
            fetched = true
            fetch(false)
        end
    end
    tab._page:GetPropertyChangedSignal("Visible"):Connect(firstFetch)
    if type(opts.OnFetch) ~= "function" then
        fetched = true
        setState("empty", emptyText())
    else
        task.defer(firstFetch)
    end
    return cloud
end

Window.CreateCloudConfigs = Window.CloudConfigs
Window.CloudConfig = Window.CloudConfigs
Window.CreateCloudConfig = Window.CloudConfigs

-- Tab badges were removed. These stay as no-ops so older scripts that call
-- them keep running.
function Tab:SetBadge() end

function Tab:GetBadge()
    return nil
end

function Window:Dialog(opts)
    opts = normalize(opts, { Text = "Content", Message = "Content" })
    if self._dialog then
        self._dialog.Close()
    end
    local WIDTH = 300
    local PAD = 18

    local overlay = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 40,
        Parent = self.Body,
    })
    local card = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 10),
        Size = UDim2.fromOffset(WIDTH, 120),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 41,
        Parent = overlay,
    })
    corner(card, UDim.new(0, 10))
    local cardStroke = stroke(card, Theme.Stroke, 1)
    local cardScale = create("UIScale", { Scale = 0.94, Parent = card })
    local fading = {}

    local titleOffset = 0
    if opts.Icon then
        local holder, image = glowIcon(card, opts.Icon, Theme.Accent, UDim2.new(0, PAD, 0, PAD + 9))
        image.ImageTransparency = 1
        holder.ZIndex = 42
        image.ZIndex = 42
        table.insert(fading, { image, "ImageTransparency", 0 })
        titleOffset = 24
    end
    local title = label({
        Position = UDim2.fromOffset(PAD + titleOffset, PAD),
        Size = UDim2.new(1, -(PAD * 2 + titleOffset), 0, 18),
        Text = opts.Title or "Are you sure?",
        TextSize = 15,
        TextTransparency = 1,
        ZIndex = 42,
        Parent = card,
    })
    table.insert(fading, { title, "TextTransparency", 0 })

    local contentHeight = 0
    if opts.Content then
        local content = label({
            Position = UDim2.fromOffset(PAD, PAD + 24),
            Size = UDim2.new(1, -PAD * 2, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = opts.Content,
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextTransparency = 1,
            TextTruncate = Enum.TextTruncate.None,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 42,
            Parent = card,
        })
        table.insert(fading, { content, "TextTransparency", 0 })
        contentHeight = math.max(content.TextBounds.Y, 16) + 6
        content:GetPropertyChangedSignal("TextBounds"):Connect(function()
            local newHeight = math.max(content.TextBounds.Y, 16) + 6
            if newHeight ~= contentHeight then
                contentHeight = newHeight
                card.Size = UDim2.fromOffset(WIDTH, PAD + 24 + contentHeight + 12 + 34 + PAD)
                local rowFrame = card:FindFirstChild("ButtonRow")
                if rowFrame then
                    rowFrame.Position = UDim2.fromOffset(PAD, PAD + 24 + contentHeight + 12)
                end
            end
        end)
    end

    local row = create("Frame", {
        Name = "ButtonRow",
        Position = UDim2.fromOffset(PAD, PAD + 24 + contentHeight + 12),
        Size = UDim2.new(1, -PAD * 2, 0, 34),
        BackgroundTransparency = 1,
        ZIndex = 42,
        Parent = card,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = row,
    })
    card.Size = UDim2.fromOffset(WIDTH, PAD + 24 + contentHeight + 12 + 34 + PAD)

    local dialog = {}
    local closed = false
    function dialog.Close()
        if closed then
            return
        end
        closed = true
        if self._dialog == dialog then
            self._dialog = nil
        end
        tween(overlay, { BackgroundTransparency = 1 }, 0.18)
        tween(card, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 8) }, 0.18, Enum.EasingStyle.Quint)
        tween(cardScale, { Scale = 0.96 }, 0.18, Enum.EasingStyle.Quint)
        tween(cardStroke, { Transparency = 1 }, 0.12)
        for _, entry in ipairs(fading) do
            tween(entry[1], { [entry[2]] = 1 }, 0.12)
        end
        task.delay(0.2, function()
            overlay:Destroy()
        end)
    end

    for index, spec in ipairs(opts.Buttons or {}) do
        local primary = spec.Variant == "Primary"
        local buttonFrame = create("TextButton", {
            Size = UDim2.fromOffset(0, 34),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = primary and Theme.Accent or Theme.Surface2,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true,
            LayoutOrder = index,
            ZIndex = 43,
            Parent = row,
        })
        corner(buttonFrame, UDim.new(0, 7))
        local buttonStroke = stroke(buttonFrame, primary and Theme.Accent or Theme.Stroke, 1)
        padding(buttonFrame, 14, 14)
        local text = label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = spec.Title or spec.Name or "OK",
            TextSize = 13,
            TextColor3 = primary and Theme.AccentDark or Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTransparency = 1,
            ZIndex = 44,
            Parent = buttonFrame,
        })
        local restBg = primary and 0.12 or 0
        local restStroke = primary and 0.4 or 0
        table.insert(fading, { buttonFrame, "BackgroundTransparency", restBg })
        table.insert(fading, { buttonStroke, "Transparency", restStroke })
        table.insert(fading, { text, "TextTransparency", 0 })
        buttonFrame.MouseEnter:Connect(function()
            if closed then
                return
            end
            if primary then
                tween(buttonFrame, { BackgroundTransparency = 0 }, 0.12)
                tween(buttonStroke, { Transparency = 0 }, 0.12)
            else
                tween(buttonStroke, { Color = Theme.StrokeHover }, 0.12)
            end
        end)
        buttonFrame.MouseLeave:Connect(function()
            if closed then
                return
            end
            if primary then
                tween(buttonFrame, { BackgroundTransparency = restBg }, 0.2)
                tween(buttonStroke, { Transparency = restStroke }, 0.2)
            else
                tween(buttonStroke, { Color = Theme.Stroke }, 0.2)
            end
        end)
        buttonFrame.MouseButton1Click:Connect(function()
            dialog.Close()
            safeCall(spec.Callback)
        end)
    end

    if opts.CloseOnBackdrop ~= false then
        overlay.MouseButton1Click:Connect(function()
            dialog.Close()
            safeCall(opts.OnCancel)
        end)
    end

    self._dialog = dialog
    tween(overlay, { BackgroundTransparency = 0.45 }, 0.25)
    tween(card, { BackgroundTransparency = 0, Position = UDim2.fromScale(0.5, 0.5) }, 0.3, Enum.EasingStyle.Quint)
    tween(cardStroke, { Transparency = 0 }, 0.25)
    tween(cardScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
    for _, entry in ipairs(fading) do
        tween(entry[1], { [entry[2]] = entry[3] }, 0.25)
    end
    return dialog
end

function Window:Confirm(opts)
    opts = normalize(opts, { Text = "Content", Message = "Content" })
    return self:Dialog({
        Title = opts.Title or "Are you sure?",
        Content = opts.Content,
        Icon = opts.Icon,
        OnCancel = opts.OnCancel,
        Buttons = {
            { Title = opts.CancelText or "Cancel", Callback = opts.OnCancel },
            { Title = opts.ConfirmText or "Confirm", Variant = "Primary", Callback = opts.Callback },
        },
    })
end

function Window:_listen(kind, handler, owner)
    local list = self._inputListeners[kind]
    table.insert(list, handler)
    local function disconnect()
        for index, entry in ipairs(list) do
            if entry == handler then
                table.remove(list, index)
                break
            end
        end
    end
    if owner then
        owner._listeners = owner._listeners or {}
        table.insert(owner._listeners, disconnect)
    end
    return disconnect
end

function Window:_indicatorY(tab)
    local stack = self._tabStack
    return (tab._button.AbsolutePosition.Y - stack.AbsolutePosition.Y) / self.Scale.Scale + stack.Position.Y.Offset
end

function Window:_placeIndicator(tab)
    local indicator = self.Indicator
    local targetY = self:_indicatorY(tab)
    if not indicator.Visible then
        indicator.Visible = true
        indicator.Position = UDim2.fromOffset(8, targetY)
        indicator.BackgroundTransparency = 1
        tween(indicator, { BackgroundTransparency = 0.35 }, 0.3)
    end
    tween(indicator, { Position = UDim2.fromOffset(8, targetY) }, 0.45, Enum.EasingStyle.Quint)
end

-- While a tab list or sub tab strip runs past an end, that end gets a fade
-- and a small chip with a chevron and how many tabs are out of sight there.
-- Pressing the chip scrolls most of a view toward them.
function Window:_overflowHint(host, scroller, items, vertical, fadeColor)
    local overlay = create("Frame", {
        AnchorPoint = scroller.AnchorPoint,
        Position = scroller.Position,
        Size = scroller.Size,
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = host,
    })
    local function mirror()
        overlay.Position = scroller.Position
        overlay.Size = scroller.Size
        overlay.Visible = scroller.Visible
    end
    for _, property in ipairs({ "Position", "Size", "Visible" }) do
        scroller:GetPropertyChangedSignal(property):Connect(mirror)
    end

    local function axis(vector)
        return vertical and vector.Y or vector.X
    end
    local function scale()
        return self.Scale and self.Scale.Scale or 1
    end
    local function scrollBy(direction)
        local view = axis(scroller.AbsoluteWindowSize) / scale()
        local limit = math.max(axis(scroller.AbsoluteCanvasSize) / scale() - view, 0)
        local target = math.clamp(axis(scroller.CanvasPosition) + direction * view * 0.75, 0, limit)
        tween(scroller, { CanvasPosition = vertical and Vector2.new(0, target) or Vector2.new(target, 0) }, 0.35, Enum.EasingStyle.Quint)
    end

    local hints = {}
    for _, direction in ipairs({ -1, 1 }) do
        local far = direction > 0
        local fade = create("Frame", {
            AnchorPoint = vertical and Vector2.new(0, far and 1 or 0) or Vector2.new(far and 1 or 0, 0),
            Position = vertical and UDim2.fromScale(0, far and 1 or 0) or UDim2.fromScale(far and 1 or 0, 0),
            Size = vertical and UDim2.new(1, 0, 0, 34) or UDim2.new(0, 48, 1, 0),
            BackgroundColor3 = fadeColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            Parent = overlay,
        })
        create("UIGradient", {
            Rotation = vertical and (far and 270 or 90) or (far and 180 or 0),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.4, 0.2),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Parent = fade,
        })
        local home = vertical and UDim2.new(0.5, 0, far and 1 or 0, far and -5 or 5) or UDim2.new(far and 1 or 0, far and -2 or 2, 0.5, 0)
        local chip = create("TextButton", {
            AnchorPoint = vertical and Vector2.new(0.5, far and 1 or 0) or Vector2.new(far and 1 or 0, 0.5),
            Position = home,
            Size = UDim2.fromOffset(0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Surface3,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Visible = false,
            ZIndex = 2,
            Parent = overlay,
        })
        corner(chip, UDim.new(1, 0))
        local chipStroke = stroke(chip, Theme.Stroke, 1)
        padding(chip, 7, 7)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3),
            Parent = chip,
        })
        local arrow = create("ImageLabel", {
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            ImageColor3 = Theme.Accent,
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 1,
            ZIndex = 2,
            Parent = chip,
        })
        applyIcon(arrow, vertical and (far and "chevron-down" or "chevron-up") or (far and "chevron-right" or "chevron-left"))
        local arrowFade = "ImageTransparency"
        if arrow.Image == "" then
            arrow:Destroy()
            arrow = label({
                Size = UDim2.fromOffset(10, 20),
                Text = "›",
                TextSize = 16,
                TextColor3 = Theme.Accent,
                TextTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.None,
                Rotation = vertical and (far and 90 or -90) or (far and 0 or 180),
                LayoutOrder = 1,
                ZIndex = 2,
                Parent = chip,
            })
            arrowFade = "TextTransparency"
        end
        local count = label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            TextSize = 11,
            TextColor3 = Theme.Text,
            TextTransparency = 1,
            TextTruncate = Enum.TextTruncate.None,
            Visible = false,
            LayoutOrder = 2,
            ZIndex = 2,
            Parent = chip,
        })
        chip.MouseEnter:Connect(function()
            if not usingTouch() then
                tween(chipStroke, { Color = Theme.StrokeHover }, 0.12)
            end
        end)
        chip.MouseLeave:Connect(function()
            tween(chipStroke, { Color = Theme.Stroke }, 0.2)
        end)
        chip.MouseButton1Click:Connect(function()
            scrollBy(direction)
        end)
        hints[direction] = {
            Direction = direction,
            Fade = fade,
            Chip = chip,
            Stroke = chipStroke,
            Arrow = arrow,
            ArrowFade = arrowFade,
            Count = count,
            Home = home,
            Shown = false,
            Generation = 0,
        }
    end

    local function show(hint, on)
        if hint.Shown == on then
            return
        end
        hint.Shown = on
        hint.Generation += 1
        local away = hint.Home + (vertical and UDim2.fromOffset(0, hint.Direction * 6) or UDim2.fromOffset(hint.Direction * 6, 0))
        local value = on and 0 or 1
        if on then
            hint.Fade.Visible = true
            hint.Chip.Visible = true
            hint.Chip.Position = away
            tween(hint.Chip, { Position = hint.Home, BackgroundTransparency = 0.08 }, 0.3, Enum.EasingStyle.Quint)
        else
            tween(hint.Chip, { Position = away, BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quint)
            local generation = hint.Generation
            task.delay(0.21, function()
                if hint.Generation == generation then
                    hint.Fade.Visible = false
                    hint.Chip.Visible = false
                end
            end)
        end
        tween(hint.Fade, { BackgroundTransparency = value }, 0.2)
        tween(hint.Stroke, { Transparency = value }, 0.2)
        tween(hint.Arrow, { [hint.ArrowFade] = value }, 0.2)
        tween(hint.Count, { TextTransparency = value }, 0.2)
    end

    local function refresh()
        local view = axis(scroller.AbsoluteWindowSize)
        local overflow = (axis(scroller.AbsoluteCanvasSize) - view) / scale()
        local position = axis(scroller.CanvasPosition)
        local start = axis(scroller.AbsolutePosition)
        local before, after = 0, 0
        for _, item in ipairs(items:GetChildren()) do
            if item:IsA("GuiObject") and item.Visible and axis(item.AbsoluteSize) > 0 then
                local centre = axis(item.AbsolutePosition) + axis(item.AbsoluteSize) / 2 - start
                if centre < 0 then
                    before += 1
                elseif centre > view then
                    after += 1
                end
            end
        end
        for direction, hint in pairs(hints) do
            local hidden = direction < 0 and before or after
            hint.Count.Text = tostring(hidden)
            hint.Count.Visible = hidden > 0
            show(hint, overflow > 1 and (direction < 0 and position > 1 or direction > 0 and position < overflow - 1))
        end
    end
    for _, property in ipairs({ "CanvasPosition", "AbsoluteCanvasSize", "AbsoluteWindowSize" }) do
        scroller:GetPropertyChangedSignal(property):Connect(refresh)
    end
    task.defer(refresh)
end

function Window:_scrollTabIntoView(tab)
    local list = self.TabList
    local scale = self.Scale.Scale
    local top = (tab._button.AbsolutePosition.Y - list.AbsolutePosition.Y) / scale + list.CanvasPosition.Y
    local bottom = top + tab._button.AbsoluteSize.Y / scale
    local view = list.AbsoluteWindowSize.Y / scale
    local y = list.CanvasPosition.Y
    if top - 8 < y then
        y = top - 8
    elseif bottom + 8 > y + view then
        y = bottom + 8 - view
    else
        return
    end
    tween(list, { CanvasPosition = Vector2.new(0, math.max(0, y)) }, 0.35, Enum.EasingStyle.Quint)
end

function Window:_closePopups()
    if self._closePopup then
        self._closePopup()
    end
end

-- Popped-out groupboxes float on one screen-wide layer above the window. It
-- carries the window's scale, so a panel keeps the size it had in its column,
-- and it shows while the window is open (minimized included).
function Window:_popoutLayer()
    if self._popLayer then
        return self._popLayer
    end
    local layer = create("Frame", {
        Name = "PopOuts",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = self.Gui,
    })
    local layerScale = create("UIScale", { Parent = layer })
    self._popLayer = layer
    self._popPanels = {}
    self:_listen("Render", function()
        local scale = math.max(self.Scale.Scale, 0.05)
        if math.abs(layerScale.Scale - scale) > 1e-4 then
            layerScale.Scale = scale
            layer.Size = UDim2.fromScale(1 / scale, 1 / scale)
        end
        layer.Visible = self.Open == true and not self._destroyed
    end)
    return layer
end

-- Where a control's popup is drawn: the pop-out layer for one inside a
-- floating panel, otherwise the window body.
function Window:_popupHost(object)
    local layer = self._popLayer
    if layer and object and object:IsDescendantOf(layer) then
        return layer
    end
    return self.Body
end

-- A floating panel under the point counts as a control, so pressing it never
-- starts a window drag.
function Window:_overPopout(point)
    local layer = self._popLayer
    if not layer or not layer.Visible then
        return false
    end
    for _, panel in ipairs(self._popPanels) do
        if panel.Parent and panel.Visible and pointInside(point, panel) then
            return true
        end
    end
    return false
end

-- Fades the whole body by lending it to the fader CanvasGroup, then hands it
-- back to the root once fully shown so it renders directly again.
function Window:_fade(target, duration)
    local fader, body = self._fader, self.Body
    self._fadeGeneration = (self._fadeGeneration or 0) + 1
    local generation = self._fadeGeneration
    if body.Parent ~= fader then
        fader.GroupTransparency = self._bodyAlpha
        body.Parent = fader
    end
    fader.Visible = true
    self._bodyAlpha = target
    tween(fader, { GroupTransparency = target }, duration)
    task.delay(duration + 0.03, function()
        if self._fadeGeneration == generation and target <= 0 and not self._destroyed then
            body.Parent = self.Root
            fader.Visible = false
        end
    end)
end

function Window:SelectTab(tab)
    if self.CurrentTab == tab then
        return
    end
    local previous = self.CurrentTab
    self:_resetSearch()
    self:_closePopups()
    self.CurrentTab = tab

    self:_settleTransition()
    local generation = (self._transitionGeneration or 0) + 1
    self._transitionGeneration = generation

    if previous then
        tween(previous._label, { TextColor3 = Theme.Muted }, 0.3)
        if previous._icon then
            tintIcon(previous._icon, Theme.Muted, false, 0.3)
        end
        local outLayer = self._outLayer
        previous._page.Parent = outLayer
        self._outPage = previous._page
        outLayer.GroupTransparency = 0
        outLayer.Position = UDim2.fromOffset(0, 0)
        outLayer.Visible = true
        tween(outLayer, { GroupTransparency = 1, Position = UDim2.fromOffset(0, -6) }, 0.2, Enum.EasingStyle.Quint)
        task.delay(0.18, function()
            if self._transitionGeneration == generation then
                self:_settleOut()
            end
        end)
    end

    tween(tab._button, { BackgroundTransparency = 1 }, 0.2)
    tween(tab._stroke, { Transparency = 1 }, 0.2)
    tween(tab._label, { TextColor3 = Theme.Text }, 0.3)
    if tab._icon then
        tintIcon(tab._icon, Theme.Text, true, 0.3)
    end

    self:_placeIndicator(tab)
    self:_scrollTabIntoView(tab)

    local page = tab._page
    page.Position = UDim2.fromOffset(0, 0)
    page.Visible = true
    page.Parent = self._inLayer
    self._inPage = page
    fadeSlideIn(self._inLayer)
    task.delay(0.32, function()
        if self._transitionGeneration == generation then
            self:_settleIn()
        end
    end)
end

function Window:_settleOut()
    local page = self._outPage
    if page then
        page.Parent = self.Content
        page.Visible = false
        self._outPage = nil
    end
    self._outLayer.Visible = false
end

function Window:_settleIn()
    local page = self._inPage
    if page then
        page.Parent = self.Content
        page.Position = UDim2.fromOffset(0, 0)
        self._inPage = nil
    end
    self._inLayer.Visible = false
end

function Window:_settleTransition()
    self:_settleOut()
    self:_settleIn()
end

-- Backdrop: a black tint over the game while the window is up, with an
-- optional weather layer (rain, snow or hell fire embers) drifting through it.
-- It fades out when the window is minimized or hidden and sweeps back in with
-- a gust when it comes back.

local WEATHER = {
    -- The rain texture is a wide sheet with one faint streak down the middle
    -- (about 1/60 of its width, 57% of its height), so it is stretched much
    -- wider than the drop it draws. See RAIN_STREAK.
    Rain = { Image = "rbxassetid://241868005", Count = 90, Stretch = true },
    Snow = { Image = "rbxassetid://99851851", Count = 60 },
    Ember = { Image = "rbxassetid://242205518", Count = 55 },
    -- Drawn with plain frames and text, no images: petals are tinted pills
    -- that flip as they fall, matrix columns are text strips.
    Sakura = { Petal = true, Count = 46, Glow = Color3.fromRGB(255, 150, 190), GlowAmount = 0.1 },
    Fireflies = { Image = Assets.Glow, Count = 34, Glow = Color3.fromRGB(70, 150, 60), GlowAmount = 0.16 },
    Matrix = {
        Text = true,
        Count = 38,
        Glow = Color3.fromRGB(30, 200, 90),
        GlowAmount = 0.07,
        Glyphs = "01234567890123456789アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワン+-*=<>:",
    },
}
local WEATHER_NAMES = {
    rain = "Rain",
    snow = "Snow",
    ember = "Ember",
    embers = "Ember",
    fire = "Ember",
    hellfire = "Ember",
    sakura = "Sakura",
    petals = "Sakura",
    cherryblossom = "Sakura",
    firefly = "Fireflies",
    fireflies = "Fireflies",
    matrix = "Matrix",
    matrixrain = "Matrix",
    code = "Matrix",
}
local RAIN_STREAK = Vector2.new(7 / 420, 151 / 263)
local weatherRandom = Random.new()

-- "UI" keeps the weather inside the window, behind its content; anything
-- else drifts it across the whole screen.
local function weatherMode(mode)
    if type(mode) == "string" and ({ ui = true, window = true, inside = true })[mode:lower()] then
        return "UI"
    end
    return "Screen"
end

local function weatherName(name)
    if type(name) ~= "string" then
        return "None"
    end
    return WEATHER_NAMES[(name:lower():gsub("[%s_%-]", ""))] or "None"
end

local function roll(min, max)
    return weatherRandom:NextNumber(min, max)
end

-- Places a particle. `anywhere` scatters it over the whole screen (first
-- frame after the backdrop appears), otherwise it enters from its edge.
local function seedParticle(kind, particle, width, height, anywhere)
    particle.Time = roll(0, 10)
    particle.Phase = roll(0, math.pi * 2)
    if kind == "Rain" then
        local w = roll(2, 3.5)
        particle.Size = Vector2.new(w, roll(26, 52))
        particle.VY = roll(950, 1400)
        particle.VX = particle.VY * 0.12
        particle.Sway, particle.Spin = 0, 0
        particle.Rotation = -math.deg(math.atan2(particle.VX, particle.VY))
        particle.Alpha = roll(0, 0.35)
        particle.X = roll(-0.15 * width, width)
        particle.Y = anywhere and roll(-40, height) or roll(-120, -particle.Size.Y)
    elseif kind == "Snow" then
        local s = roll(6, 17)
        particle.Size = Vector2.new(s, s)
        particle.VY = roll(30, 55) * (0.6 + s / 17)
        particle.VX = roll(-8, 14)
        particle.Sway = roll(12, 38)
        particle.Frequency = roll(0.5, 1.3)
        particle.Spin = roll(-60, 60)
        particle.Rotation = roll(0, 360)
        particle.Alpha = roll(0.05, 0.45)
        particle.X = roll(0, width)
        particle.Y = anywhere and roll(-20, height) or roll(-60, -s)
    elseif kind == "Sakura" then
        local s = roll(7, 14)
        particle.Size = Vector2.new(s, s * roll(0.55, 0.75))
        particle.VY = roll(35, 70)
        particle.VX = roll(18, 45)
        particle.Sway = roll(14, 34)
        particle.Frequency = roll(0.6, 1.4)
        particle.Flutter = roll(1.2, 2.6)
        particle.Spin = roll(-90, 90)
        particle.Rotation = roll(0, 360)
        particle.Alpha = roll(0.05, 0.35)
        particle.Color = Color3.fromRGB(255, 205, 220):Lerp(Color3.fromRGB(255, 140, 180), roll(0, 1))
        particle.X = roll(-0.25 * width, width)
        particle.Y = anywhere and roll(-20, height) or roll(-60, -s)
    elseif kind == "Fireflies" then
        -- They wander instead of crossing the screen, and live a few seconds:
        -- fade in, pulse, fade out, then turn up somewhere else.
        local s = roll(14, 28)
        particle.Size = Vector2.new(s, s)
        particle.VY = roll(-14, 8)
        particle.VX = roll(-12, 12)
        particle.Sway = roll(10, 30)
        particle.SwayY = roll(8, 22)
        particle.Frequency = roll(0.3, 0.8)
        particle.Spin, particle.Rotation = 0, 0
        particle.Alpha = roll(0, 0.25)
        particle.Life = roll(5, 11)
        particle.Age = anywhere and roll(0, particle.Life) or 0
        particle.Pulse = roll(1.5, 3.5)
        particle.Color = Color3.fromRGB(200, 255, 120):Lerp(Color3.fromRGB(255, 230, 120), roll(0, 1))
        particle.X = roll(0, width)
        particle.Y = roll(height * 0.15, height)
    elseif kind == "Matrix" then
        local definition = WEATHER.Matrix
        if not definition.List then
            definition.List = {}
            for _, code in utf8.codes(definition.Glyphs) do
                table.insert(definition.List, utf8.char(code))
            end
        end
        local list = definition.List
        local s = math.floor(roll(12, 19))
        local length = math.floor(roll(8, 20))
        particle.TextSize = s
        particle.Size = Vector2.new(s + 6, s * length)
        particle.VY = roll(160, 360) * (s / 15)
        particle.VX, particle.Sway, particle.Spin, particle.Rotation = 0, 0, 0, 0
        -- Smaller columns read as further away: dimmer.
        particle.Alpha = roll(0, 0.25) + (19 - s) * 0.04
        particle.X = math.floor(roll(0, width) / 18) * 18 + 9
        particle.Y = anywhere and roll(-particle.Size.Y / 2, height) or -particle.Size.Y / 2 - roll(0, 240)
        particle.Chars = {}
        for index = 1, length do
            particle.Chars[index] = list[math.random(#list)]
        end
        particle.Shuffle = roll(0.05, 0.2)
    else
        local s = roll(4, 12)
        particle.Size = Vector2.new(s, s)
        particle.VY = -roll(60, 170)
        particle.VX = roll(-12, 12)
        particle.Sway = roll(8, 28)
        particle.Frequency = roll(1, 2.4)
        particle.Spin = roll(-140, 140)
        particle.Rotation = roll(0, 360)
        particle.Alpha = roll(0, 0.3)
        particle.Color = Color3.fromRGB(255, 70, 20):Lerp(Color3.fromRGB(255, 190, 70), roll(0, 1))
        particle.X = roll(0, width)
        particle.Y = anywhere and roll(height * 0.2, height + 10) or height + roll(10, 80)
    end
    local label = particle.Label
    if kind == "Rain" then
        label.Size = UDim2.fromOffset(particle.Size.X / RAIN_STREAK.X, particle.Size.Y / RAIN_STREAK.Y)
    else
        label.Size = UDim2.fromOffset(particle.Size.X, particle.Size.Y)
    end
    if kind == "Matrix" then
        label.TextSize = particle.TextSize
        label.Text = table.concat(particle.Chars, "\n")
    elseif kind == "Sakura" then
        label.BackgroundColor3 = particle.Color
    else
        label.ImageColor3 = particle.Color
            or (kind == "Rain" and Color3.fromRGB(190, 210, 245) or Color3.new(1, 1, 1))
    end
end

function Window:_buildBackdrop(opts)
    local layer = create("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 0,
        Parent = self.Gui,
    })
    local tint = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0,
        Parent = layer,
    })
    -- Darker towards the top and bottom edges.
    create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = tint,
    })
    -- Heat rising from the bottom of the screen, hell fire only.
    local heat = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 60, 15),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = layer,
    })
    create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new(1, 0),
        Parent = heat,
    })
    -- Holds the heat and the particles so both move together between the
    -- screen and the window.
    local field = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = layer,
    })
    heat.Parent = field
    self._backdrop = layer
    self._backdropTintFrame = tint
    self._backdropHeat = heat
    self._weatherField = field
    self._weatherParticles = {}
    self._backdropFade = 0
    self._weatherKick = 0
    self._backdropShown = false
    self._backdropEnabled = opts.Enabled ~= false
    self._backdropTint = math.clamp(tonumber(opts.Tint) or 0.45, 0, 1)
    self._backdropDim = opts.Dim ~= false
    self._dimLevel = self._backdropDim and 1 or 0
    self._weatherDensity = math.clamp(tonumber(opts.Density) or 1, 0, 3)
    self._weatherSpeed = math.clamp(tonumber(opts.Speed) or 1, 0.1, 3)
    self.Weather = weatherName(opts.Weather == nil and "Matrix" or opts.Weather)
    self.WeatherMode = "Screen"
    self:SetWeatherMode(opts.Mode)
    self:_rebuildWeather()
    table.insert(self._frameSteps, function(deltaTime)
        self:_stepBackdrop(deltaTime)
    end)
end

-- The area the particles cover, in the field's own (unscaled) units.
function Window:_weatherSize()
    if self.WeatherMode == "UI" then
        return Vector2.new(self.Root.Size.X.Offset, self.Root.Size.Y.Offset)
    end
    return self.Gui.AbsoluteSize
end

function Window:_rebuildWeather()
    for _, particle in ipairs(self._weatherParticles) do
        particle.Label:Destroy()
    end
    self._weatherParticles = {}
    local definition = WEATHER[self.Weather]
    if not definition then
        return
    end
    -- The glow along the bottom: red heat for hell fire, a soft tint for the
    -- others that ask for one.
    self._backdropHeat.BackgroundColor3 = definition.Glow or Color3.fromRGB(255, 60, 15)
    local size = self:_weatherSize()
    -- The window is a fraction of the screen, so it gets fewer particles.
    local count = definition.Count * self._weatherDensity * (self.WeatherMode == "UI" and 0.45 or 1)
    for _ = 1, math.floor(count + 0.5) do
        local instance, property
        if definition.Text then
            property = "TextTransparency"
            instance = create("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Text = "",
                TextColor3 = Color3.fromRGB(90, 255, 140),
                TextTransparency = 1,
                FontFace = Font.fromEnum(Enum.Font.Code),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Top,
                LineHeight = 1,
                ZIndex = 2,
                Parent = self._weatherField,
            })
            -- A fading tail and a pale leading glyph.
            create("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(0.88, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 255, 240)),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.6, 0.45),
                    NumberSequenceKeypoint.new(1, 0),
                }),
                Parent = instance,
            })
        elseif definition.Petal then
            property = "BackgroundTransparency"
            instance = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 190, 210),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 2,
                Parent = self._weatherField,
            })
            corner(instance, UDim.new(1, 0))
            create("UIGradient", {
                Rotation = 35,
                Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(235, 200, 215)),
                Parent = instance,
            })
        else
            property = "ImageTransparency"
            instance = create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Image = definition.Image,
                ImageTransparency = 1,
                ScaleType = definition.Stretch and Enum.ScaleType.Stretch or Enum.ScaleType.Fit,
                ZIndex = 2,
                Parent = self._weatherField,
            })
        end
        local particle = { Label = instance, Property = property }
        seedParticle(self.Weather, particle, size.X, size.Y, true)
        table.insert(self._weatherParticles, particle)
    end
end

function Window:_stepBackdrop(deltaTime)
    local target = self._backdropShown and 1 or 0
    local fade = self._backdropFade
    if fade == target and target == 0 then
        return
    end
    if fade < target then
        fade = math.min(fade + deltaTime / 0.45, target)
    elseif fade > target then
        fade = math.max(fade - deltaTime / 0.25, target)
    end
    self._backdropFade = fade
    if fade <= 0 then
        self._backdrop.Visible = false
        self._weatherField.Visible = false
        return
    end
    local eased = 1 - (1 - fade) ^ 3
    local kind = self.Weather
    -- The dim eases on its own so turning it off doesn't touch the weather.
    local dim = self._dimLevel
    if self._backdropDim then
        dim = math.min(dim + deltaTime / 0.3, 1)
    else
        dim = math.max(dim - deltaTime / 0.3, 0)
    end
    self._dimLevel = dim
    self._backdropTintFrame.BackgroundTransparency = 1 - self._backdropTint * eased * dim
    local definition = WEATHER[kind]
    self._backdropHeat.BackgroundTransparency = kind == "Ember"
        and 1 - (0.22 + math.sin(os.clock() * 2.1) * 0.05) * eased
        or definition and definition.GlowAmount and 1 - (definition.GlowAmount + math.sin(os.clock() * 0.8) * definition.GlowAmount * 0.25) * eased
        or 1

    -- The gust on restore: particles rush in fast and settle back.
    local kick = self._weatherKick
    self._weatherKick = math.max(kick - deltaTime * 1.3, 0)
    local speed = self._weatherSpeed * (1 + kick * kick * 2.5)
    local size = self:_weatherSize()
    local width, height = size.X, size.Y
    for _, particle in ipairs(self._weatherParticles) do
        particle.Time += deltaTime
        particle.X += particle.VX * deltaTime * speed
        particle.Y += particle.VY * deltaTime * speed
        particle.Rotation += particle.Spin * deltaTime * speed
        local margin = math.max(particle.Size.X, particle.Size.Y)
        if particle.Life then
            particle.Age += deltaTime
        end
        if (particle.Life and particle.Age > particle.Life)
            or (not particle.Life and ((particle.VY > 0 and particle.Y > height + margin) or (particle.VY < 0 and particle.Y < -margin))) then
            seedParticle(kind, particle, width, height, false)
        elseif particle.X > width + margin * 4 then
            particle.X -= width + margin * 6
        elseif particle.X < -margin * 4 then
            particle.X += width + margin * 6
        end
        local x = particle.X
        local alpha = 1 - particle.Alpha
        if particle.Sway ~= 0 then
            x += math.sin(particle.Time * particle.Frequency + particle.Phase) * particle.Sway
        end
        local y = particle.Y
        local label = particle.Label
        if kind == "Ember" then
            -- Flicker, and burn out on the way up.
            alpha *= math.clamp(particle.Y / (height * 0.85), 0, 1) ^ 0.6
            alpha *= 0.75 + math.sin(particle.Time * 9 + particle.Phase) * 0.25
        elseif kind == "Sakura" then
            -- Flip: the petal narrows and widens as it turns over.
            local turn = math.abs(math.cos(particle.Time * particle.Flutter + particle.Phase))
            label.Size = UDim2.fromOffset(particle.Size.X * (0.3 + turn * 0.7), particle.Size.Y)
        elseif kind == "Fireflies" then
            y += math.cos(particle.Time * particle.Frequency * 1.3 + particle.Phase) * particle.SwayY
            local age, life = particle.Age, particle.Life
            alpha *= math.clamp(math.min(age / 1.2, (life - age) / 1.2), 0, 1)
            alpha *= 0.5 + math.sin(particle.Time * particle.Pulse + particle.Phase) * 0.5
        elseif kind == "Matrix" then
            particle.Shuffle -= deltaTime * speed
            if particle.Shuffle <= 0 then
                particle.Shuffle = roll(0.05, 0.2)
                local list = WEATHER.Matrix.List
                local chars = particle.Chars
                chars[math.random(#chars)] = list[math.random(#list)]
                chars[#chars] = list[math.random(#list)]
                label.Text = table.concat(chars, "\n")
            end
        end
        label.Position = UDim2.fromOffset(x, y)
        label.Rotation = particle.Rotation
        label[particle.Property or "ImageTransparency"] = 1 - alpha * eased
    end
end

function Window:_refreshBackdrop(gust)
    if not self._backdrop then
        return
    end
    local shown = self._backdropEnabled and self._introDone and self.Open and not self.Minimized and not self._destroyed
    if shown and not self._backdropShown then
        self._backdrop.Visible = true
        self._weatherField.Visible = true
        if self._backdropFade <= 0 then
            local size = self:_weatherSize()
            for _, particle in ipairs(self._weatherParticles) do
                seedParticle(self.Weather, particle, size.X, size.Y, true)
            end
        end
        if gust then
            self._weatherKick = 1
        end
    end
    self._backdropShown = shown == true
end

function Window:SetBackdrop(enabled)
    if not self._backdrop then
        return
    end
    self._backdropEnabled = enabled ~= false
    self:_refreshBackdrop(true)
end

function Window:SetBackdropTint(amount)
    if not self._backdrop then
        return
    end
    self._backdropTint = math.clamp(tonumber(amount) or 0.45, 0, 1)
end

-- Turns the black tint on or off, leaving the weather running.
function Window:SetDim(enabled)
    if not self._backdrop then
        return
    end
    self._backdropDim = enabled ~= false
end

function Window:SetWeatherMode(mode)
    if not self._backdrop then
        return
    end
    mode = weatherMode(mode)
    local field = self._weatherField
    if mode == "UI" then
        -- Under everything else in the body: sidebar, content and glows.
        field.ZIndex = 0
        field.Parent = self.Body
    else
        field.ZIndex = 2
        field.Parent = self._backdrop
    end
    if mode == self.WeatherMode then
        return
    end
    self.WeatherMode = mode
    self:_rebuildWeather()
    if self._backdropShown then
        self._weatherKick = 1
    end
end

function Window:SetWeather(name)
    if not self._backdrop then
        return
    end
    local kind = weatherName(name)
    if kind == self.Weather then
        return
    end
    self.Weather = kind
    self:_rebuildWeather()
    if self._backdropShown then
        self._weatherKick = 1
    end
end

function Window:SetWeatherDensity(density)
    if not self._backdrop then
        return
    end
    self._weatherDensity = math.clamp(tonumber(density) or 1, 0, 3)
    self:_rebuildWeather()
end

function Window:SetWeatherSpeed(speed)
    if not self._backdrop then
        return
    end
    self._weatherSpeed = math.clamp(tonumber(speed) or 1, 0.1, 3)
end

-- Minimize: the window folds into a Dynamic Island style pill hanging from
-- the top of the screen. Compact, it shows the logo and a live meter of
-- running toggles. Hovering springs it open into a session card: the
-- player, the game and session time, frame rate and ping meters, the server
-- and running counts, and the key that reopens the window. A
-- notification while minimized opens it briefly to show it. Click or tap
-- restores.

-- One table, not separate locals: the main chunk is at Luau's 200 local limit.
local Mini = {
    -- Sized after the iPhone 18 island: a slimmer, shorter pill sitting close
    -- to the top edge, opening into a wide card with deep rounded corners.
    Top = 8, -- gap from the top of the screen
    Width = TOUCH and 176 or 168, -- compact
    Height = TOUCH and 36 or 32,
    Wide = 340, -- expanded and activity
    Radius = 34, -- corner of the expanded and activity cards
    Bars = 4,
    Pinned = 6,
}

-- The morph is carried by a plain "ghost" panel drawn over the window. The
-- window body itself never moves or fades, so nothing has to be laid out
-- again mid-animation: the ghost covers it, the window is hidden underneath,
-- and on the way back the window is shown under the ghost before it clears.
local function makeGhost(window, position, size, radius)
    if window._ghost then
        window._ghost:Destroy()
    end
    local ghost = create("Frame", {
        Position = UDim2.fromOffset(position.X, position.Y),
        Size = UDim2.fromOffset(size.X, size.Y),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 29,
        Parent = window.Gui,
    })
    local ghostCorner = Library._fixedCorner(ghost, UDim.new(0, radius))
    local ghostStroke = stroke(ghost, Theme.Stroke, 1)
    window._ghost = ghost
    return ghost, ghostStroke, ghostCorner
end

local function morphGhost(ghost, ghostCorner, position, size, radius, duration)
    tween(ghost, {
        Position = UDim2.fromOffset(position.X, position.Y),
        Size = UDim2.fromOffset(size.X, size.Y),
    }, duration, Enum.EasingStyle.Quint)
    tween(ghostCorner, { CornerRadius = UDim.new(0, radius) }, duration, Enum.EasingStyle.Quint)
end

local function dissolve(window, ghost, ghostStroke, duration)
    tween(ghost, { BackgroundTransparency = 1 }, duration, Enum.EasingStyle.Quad)
    tween(ghostStroke, { Transparency = 1 }, duration, Enum.EasingStyle.Quad)
    task.delay(duration + 0.02, function()
        if window._ghost == ghost then
            window._ghost = nil
        end
        ghost:Destroy()
    end)
end

function Window:_buildMiniBar()
    if self.MiniBar then
        return self.MiniBar
    end
    local gui = self.Gui

    -- The island itself: a black pill hanging from the top of the screen. It
    -- is a canvas so its rounded shape clips whatever layer is showing.
    local island = create("CanvasGroup", {
        Name = "Island",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, Mini.Top),
        Size = UDim2.fromOffset(Mini.Width, Mini.Height),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 30,
        Parent = gui,
    })
    local islandCorner = Library._fixedCorner(island, UDim.new(0, Mini.Height / 2))
    local islandScale = create("UIScale", { Parent = island })
    self._miniScale = islandScale
    -- How far the split bubble is out of the pill: drawn back in while the
    -- island is open, budded off again once it settles to the pill.
    local merge = create("NumberValue", { Value = 1 })
    local mergeTween
    self._miniOrb = island

    -- The wide layers keep a fixed width, so nothing reflows while the island
    -- grows around them.
    local function layer(name)
        return create("CanvasGroup", {
            Name = name,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, Mini.Wide, 0, 400),
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            Parent = island,
        })
    end

    -- Compact: the logo leading, a live meter of running toggles trailing.
    -- A graphite surface, lit from the top, so the pill isn't a flat black
    -- slab; it fades with the layer, leaving the open card black.
    local compact = create("CanvasGroup", {
        Name = "Compact",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(30, 30, 34),
        BorderSizePixel = 0,
        Parent = island,
    })
    create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(120, 120, 120)),
        Parent = compact,
    })
    -- The logo sits in a soft accent disc, like an app glyph.
    local logoDisc = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 5, 0.5, 0),
        Size = UDim2.fromOffset(Mini.Height - 10, Mini.Height - 10),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Parent = compact,
    })
    corner(logoDisc, UDim.new(1, 0))
    local logo = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        Parent = logoDisc,
    })
    applyIcon(logo, self._logoIcon, true)
    -- The script's name beside the logo, so the pill reads at a glance.
    local miniTitle = label({
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, Mini.Height + 2, 0.5, 0),
        Size = UDim2.new(1, -Mini.Height - 2 - 72, 0, 18),
        Text = self.Title,
        TextSize = 13,
        FontFace = Fonts.Bold,
        TextColor3 = Color3.fromRGB(244, 244, 246),
        Parent = compact,
    })
    local meter = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = compact,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 7),
        Parent = meter,
    })
    local barsHolder = create("Frame", {
        Size = UDim2.fromOffset(Mini.Bars * 3 + (Mini.Bars - 1) * 2, 16),
        BackgroundTransparency = 1,
        Visible = false,
        LayoutOrder = 1,
        Parent = meter,
    })
    local bars = {}
    for index = 1, Mini.Bars do
        local bar = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (index - 1) * 5, 0.5, 0),
            Size = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.Muted,
            BorderSizePixel = 0,
            Parent = barsHolder,
        })
        corner(bar, UDim.new(1, 0))
        bars[index] = bar
    end
    local countLabel = label({
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = "",
        TextSize = 13,
        FontFace = Fonts.Bold,
        TextTruncate = Enum.TextTruncate.None,
        Visible = false,
        LayoutOrder = 2,
        Parent = meter,
    })
    -- Idle (nothing running): a health dot tinted by frame rate and the
    -- session clock, so the pill never sits empty.
    local idleDot = create("Frame", {
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        LayoutOrder = -1,
        Parent = meter,
    })
    corner(idleDot, UDim.new(1, 0))
    local idleLabel = label({
        Size = UDim2.fromOffset(0, 18),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = "0s",
        TextSize = 12,
        FontFace = Fonts.Bold,
        TextColor3 = Color3.fromRGB(220, 220, 224),
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = 0,
        Parent = meter,
    })

    -- Expanded, on hover: the player's session.
    local expanded = layer("Expanded")
    local expandedList = create("Frame", {
        Position = UDim2.fromOffset(16, 14),
        Size = UDim2.new(1, -32, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = expanded,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = expandedList,
    })
    -- The open card is the player's session, like a now-playing card: who
    -- and where on top with the session clock, two wide meters for frame
    -- rate and ping, then chips for the server and what's running.
    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = expandedList,
    })
    local face = create("ImageLabel", {
        Size = UDim2.fromOffset(48, 48),
        BackgroundColor3 = Color3.fromRGB(38, 38, 41),
        BorderSizePixel = 0,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150",
        Parent = top,
    })
    corner(face, UDim.new(0, 12))
    local facePlaceholder = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Muted,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Parent = face,
    })
    applyIcon(facePlaceholder, "user")
    self:_trackAvatar(face, facePlaceholder)
    local nameLabel = label({
        Position = UDim2.fromOffset(60, 5),
        Size = UDim2.new(1, -150, 0, 20),
        TextSize = 15,
        FontFace = Fonts.Bold,
        TextColor3 = Color3.fromRGB(244, 244, 246),
        Parent = top,
    })
    self:_trackName(nameLabel, "Display")
    local tabLabel = label({
        Position = UDim2.fromOffset(60, 26),
        Size = UDim2.new(1, -150, 0, 15),
        Text = "",
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        Parent = top,
    })
    task.spawn(function()
        tabLabel.Text = detectGameName()
    end)
    local sessionLabel = label({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 3),
        Size = UDim2.fromOffset(90, 24),
        Text = "0s",
        TextSize = 20,
        FontFace = Fonts.Bold,
        TextColor3 = Color3.fromRGB(244, 244, 246),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = top,
    })
    label({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 27),
        Size = UDim2.fromOffset(90, 14),
        Text = "session",
        TextSize = 11,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = top,
    })

    -- Two readouts: a large number with its unit, a caption, and a thin
    -- line under them that fills and tints with how healthy it is.
    local meters = create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = expandedList,
    })
    local function meterPill(position, caption)
        local cell = create("Frame", {
            Position = position,
            Size = UDim2.new(0.5, -10, 1, 0),
            BackgroundTransparency = 1,
            Parent = meters,
        })
        local value = label({
            Size = UDim2.new(1, -70, 0, 24),
            Text = "",
            TextSize = 20,
            FontFace = Fonts.Bold,
            TextColor3 = Color3.fromRGB(244, 244, 246),
            RichText = true,
            Parent = cell,
        })
        label({
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, 0, 0, 6),
            Size = UDim2.fromOffset(70, 14),
            Text = caption,
            TextSize = 10,
            TextColor3 = Theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = cell,
        })
        local track = create("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -4),
            Size = UDim2.new(1, 0, 0, 3),
            BackgroundColor3 = Color3.fromRGB(38, 38, 42),
            BorderSizePixel = 0,
            Parent = cell,
        })
        corner(track, UDim.new(1, 0))
        local fill = create("Frame", {
            Size = UDim2.fromScale(0, 1),
            BackgroundColor3 = Theme.Success,
            BorderSizePixel = 0,
            Parent = track,
        })
        corner(fill, UDim.new(1, 0))
        return fill, value
    end
    local fpsFill, fpsValue = meterPill(UDim2.fromScale(0, 0), "FRAME RATE")
    local pingFill, pingValue = meterPill(UDim2.new(0.5, 10, 0, 0), "PING")

    -- Chips: a muted name and a bold value, the running count in accent.
    local chips = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        Parent = expandedList,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = chips,
    })
    local function chipOf(order, name, color)
        local chipFrame = create("Frame", {
            Size = UDim2.fromOffset(0, 30),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(32, 32, 35),
            BorderSizePixel = 0,
            LayoutOrder = order,
            Parent = chips,
        })
        corner(chipFrame, UDim.new(1, 0))
        padding(chipFrame, 14, 14)
        create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 7),
            Parent = chipFrame,
        })
        label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = name,
            TextSize = 12,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 1,
            Parent = chipFrame,
        })
        return label({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            TextSize = 12,
            FontFace = Fonts.Bold,
            TextColor3 = color or Color3.fromRGB(244, 244, 246),
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = 2,
            Parent = chipFrame,
        })
    end
    local playersValue = chipOf(1, "Players")
    local bigCount = chipOf(2, "Running", Theme.Accent)
    local tabValue = chipOf(3, "Tab")

    -- Pinned statuses are no longer shown here; the holder stays so the
    -- refresh below has somewhere to keep its rows.
    local rowsHolder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        LayoutOrder = 4,
        Parent = expandedList,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = rowsHolder,
    })
    -- What's running, by name, so the count above has something behind it.
    local runningNames = label({
        Size = UDim2.new(1, 0, 0, 15),
        Text = "",
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Color3.fromRGB(200, 200, 206),
        RichText = true,
        Visible = false,
        LayoutOrder = 4,
        Parent = expandedList,
    })
    local hint = label({
        Size = UDim2.new(1, 0, 0, 14),
        TextSize = 11,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        LayoutOrder = 5,
        Parent = expandedList,
    })

    -- Frame rate is counted every frame; the card's values refresh twice a
    -- second while it's open.
    local sessionStart = self._sessionStart or os.clock()
    local frames, frameClock, fps = 0, os.clock(), 60
    self:_listen("Render", function()
        frames += 1
        local now = os.clock()
        if now - frameClock >= 0.5 then
            fps = math.floor(frames / (now - frameClock) + 0.5)
            frames, frameClock = 0, now
        end
    end)
    local function refreshSession()
        sessionLabel.Text = formatDuration(os.clock() - sessionStart)
        idleLabel.Text = sessionLabel.Text
        tween(idleDot, { BackgroundColor3 = Library._healthColor(fps, 50, 30) }, 0.4)
        local unit = '<font size="12" color="#8A8A93"> %s</font>'
        fpsValue.Text = fps .. string.format(unit, "fps")
        tween(fpsFill, {
            Size = UDim2.fromScale(math.clamp(fps / 60, 0.05, 1), 1),
            BackgroundColor3 = Library._healthColor(fps, 50, 30),
        }, 0.4, Enum.EasingStyle.Quint)
        local okPing, ping = pcall(function()
            return math.floor(LocalPlayer:GetNetworkPing() * 1000)
        end)
        ping = okPing and ping or 0
        pingValue.Text = ping .. string.format(unit, "ms")
        -- Lower ping fills more: 40ms or less is full, 400ms and up is low.
        tween(pingFill, {
            Size = UDim2.fromScale(math.clamp(1 - (ping - 40) / 360, 0.05, 1), 1),
            BackgroundColor3 = Library._healthColor(ping, 90, 180, true),
        }, 0.4, Enum.EasingStyle.Quint)
        playersValue.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        local tab = self.CurrentTab
        tabValue.Text = tab and tab.Name or "-"
    end
    task.spawn(function()
        while island.Parent do
            if island.Visible and self.Minimized then
                refreshSession()
            end
            task.wait(0.5)
        end
    end)

    -- Activity: a notification that arrives while minimized drops in here.
    local activity = layer("Activity")
    local activityList = create("Frame", {
        Position = UDim2.fromOffset(16, 13),
        Size = UDim2.new(1, -32, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = activity,
    })
    local activityChip = create("Frame", {
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Parent = activityList,
    })
    corner(activityChip, UDim.new(1, 0))
    local activityIcon = create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(17, 17),
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        Parent = activityChip,
    })
    local activityText = create("Frame", {
        Position = UDim2.fromOffset(46, 0),
        Size = UDim2.new(1, -46, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = activityList,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
        Parent = activityText,
    })
    local activityTitle = label({
        Size = UDim2.new(1, 0, 0, 18),
        TextSize = 14,
        FontFace = Fonts.Bold,
        LayoutOrder = 1,
        Parent = activityText,
    })
    local activityBody = label({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextSize = 12,
        FontFace = Fonts.Regular,
        TextColor3 = Theme.Muted,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        TextYAlignment = Enum.TextYAlignment.Top,
        MaxVisibleGraphemes = 140,
        LayoutOrder = 2,
        Parent = activityText,
    })

    local hit = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 10,
        Parent = island,
    })

    -- Morphing between shapes: the island springs to its new size while the
    -- old layer fades out and the new one fades in just behind it.
    local layers = { Compact = compact, Expanded = expanded, Activity = activity }
    local mode = "Compact"
    local modeToken = 0
    local sizeTween, cornerTween
    local hovered, pressed = false, false
    local hoverToken = 0
    local dragFrom, dragAnchor, dragging, dragged = nil, nil, false, false
    local activityToken = 0
    local activityLive = false

    local function shapeFor(name)
        if name == "Expanded" then
            return Vector2.new(Mini.Wide, math.floor(expandedList.AbsoluteSize.Y + 28 + 0.5)), Mini.Radius
        elseif name == "Activity" then
            return Vector2.new(Mini.Wide, math.floor(math.max(activityList.AbsoluteSize.Y, 34) + 26 + 0.5)), Mini.Radius
        end
        return Vector2.new(Mini.Width, Mini.Height), Mini.Height / 2
    end

    -- Where the island hangs: the top centre of its shape, as fractions of
    -- the screen so it keeps its spot across resolutions. Dragging moves it;
    -- each shape is clamped on screen, so the wide card slides in from an edge
    -- and the pill goes back to its spot when it folds.
    local saved = self:_readConfigSettings().IslandPosition
    if type(saved) == "table" and tonumber(saved.X) and tonumber(saved.Y) then
        self._islandAnchor = Vector2.new(math.clamp(tonumber(saved.X), 0, 1), math.clamp(tonumber(saved.Y), 0, 1))
    end
    local positionTween
    local function anchorPixels()
        local view = gui.AbsoluteSize
        local anchor = self._islandAnchor
        if not anchor then
            return Vector2.new(view.X / 2, Mini.Top)
        end
        return Vector2.new(anchor.X * view.X, anchor.Y * view.Y)
    end
    local function islandSpot(size, from)
        local view = gui.AbsoluteSize
        local spot = from or anchorPixels()
        local margin = 6
        local x = math.clamp(spot.X, size.X / 2 + margin, math.max(view.X - size.X / 2 - margin, size.X / 2 + margin))
        local y = math.clamp(spot.Y, margin, math.max(view.Y - size.Y - margin, margin))
        return Vector2.new(x, y)
    end
    local function placeIsland(size, duration, style)
        local spot = islandSpot(size)
        if positionTween then
            positionTween:Cancel()
            positionTween = nil
        end
        if duration and duration > 0 then
            positionTween = tween(island, { Position = UDim2.fromOffset(spot.X, spot.Y) }, duration, style or Enum.EasingStyle.Quint)
        else
            island.Position = UDim2.fromOffset(spot.X, spot.Y)
        end
    end
    self._islandReset = function()
        self._islandAnchor = nil
        if island.Visible then
            placeIsland(Vector2.new(island.Size.X.Offset, island.Size.Y.Offset), 0.35)
        end
    end

    local function setMode(name, instant)
        local size, radius = shapeFor(name)
        local changed = name ~= mode
        mode = name
        modeToken += 1
        local token = modeToken
        local current = Vector2.new(island.Size.X.Offset, island.Size.Y.Offset)
        local growing = size.X > current.X + 1 or size.Y > current.Y + 1
        local duration = instant and 0 or (growing and 0.5 or 0.38)
        -- A snap must stop a morph still in flight, or it keeps writing the
        -- old shape over the new one.
        if sizeTween then
            sizeTween:Cancel()
        end
        if cornerTween then
            cornerTween:Cancel()
        end
        placeIsland(size, duration)
        sizeTween = tween(island, { Size = UDim2.fromOffset(size.X, size.Y) }, duration, growing and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
        cornerTween = tween(islandCorner, { CornerRadius = UDim.new(0, radius) }, duration, Enum.EasingStyle.Quint)
        -- The iOS island gives a soft squeeze as it swells open, then springs
        -- back, so the morph reads as one elastic body rather than a resize.
        if changed and not instant and not pressed and not dragging then
            islandScale.Scale = growing and 0.96 or 1.03
            tween(islandScale, { Scale = 1 }, growing and 0.55 or 0.4, Enum.EasingStyle.Back)
        end
        if changed or instant then
            if mergeTween then
                mergeTween:Cancel()
                mergeTween = nil
            end
            if instant then
                merge.Value = name == "Compact" and 1 or 0
            elseif name == "Compact" then
                -- Wait for the pill to shrink most of the way, then bud off.
                task.delay(duration * 0.55, function()
                    if modeToken == token then
                        mergeTween = tween(merge, { Value = 1 }, 0.6, Enum.EasingStyle.Back)
                    end
                end)
            else
                mergeTween = tween(merge, { Value = 0 }, 0.2, Enum.EasingStyle.Quint)
            end
        end
        if not changed and not instant then
            -- A refit (same shape, new height) bumps the token, which cancels
            -- a fade-in still waiting from the morph; finish it here or the
            -- card stays black until the next hover.
            local target = layers[name]
            if target.GroupTransparency > 0 then
                tween(target, { GroupTransparency = 0 }, 0.22, Enum.EasingStyle.Quad)
            end
            if target ~= compact and target.Position ~= UDim2.fromScale(0.5, 0) then
                tween(target, { Position = UDim2.fromScale(0.5, 0) }, 0.32, Enum.EasingStyle.Quint)
            end
            return
        end
        for key, group in pairs(layers) do
            if key ~= name then
                tween(group, { GroupTransparency = 1 }, instant and 0 or 0.14, Enum.EasingStyle.Quad)
            end
        end
        local target = layers[name]
        if instant then
            target.GroupTransparency = 0
            -- Compact fills the island from its corner; only the wide
            -- layers hang from the centre.
            if target ~= compact then
                target.Position = UDim2.fromScale(0.5, 0)
            end
        else
            -- The new layer rises a few pixels into place as it fades in, so
            -- the content reads as arriving with the shape, not popping in.
            if target ~= compact then
                target.Position = UDim2.new(0.5, 0, 0, 6)
            end
            task.delay(0.1, function()
                if modeToken == token then
                    tween(target, { GroupTransparency = 0 }, 0.22, Enum.EasingStyle.Quad)
                    if target ~= compact then
                        tween(target, { Position = UDim2.fromScale(0.5, 0) }, 0.32, Enum.EasingStyle.Quint)
                    end
                end
            end)
        end
    end

    local function settleMode()
        if hovered and not TOUCH and not dragging then
            setMode("Expanded")
        elseif activityLive then
            setMode("Activity")
        elseif self.IslandStyle == "Always Show" and not dragging then
            self:_refreshMini()
            refreshSession()
            setMode("Expanded")
        else
            setMode("Compact")
        end
    end

    self._islandSettle = function()
        if self.Minimized and island.Visible and not dragging then
            settleMode()
        end
    end

    -- Called by Minimize once the window is out of the way: the island is
    -- reset to its compact pill and its spot handed back for the ghost.
    function self:_miniLand()
        hovered, activityLive = false, false
        activityToken += 1
        islandScale.Scale = 1
        setMode("Compact", true)
        local size = Vector2.new(Mini.Width, Mini.Height)
        local spot = islandSpot(size)
        return Vector2.new(spot.X - size.X / 2, spot.Y), size
    end

    hit.MouseEnter:Connect(function()
        if usingTouch() or dragging then
            return
        end
        hovered = true
        hoverToken += 1
        local token = hoverToken
        -- Already open (the pointer left and came back within the grace):
        -- just stay. Otherwise lean in a touch, and only open once the
        -- pointer rests, so sweeping past the island doesn't burst it open.
        if mode == "Expanded" then
            return
        end
        if not pressed then
            tween(islandScale, { Scale = 1.04 }, 0.18, Enum.EasingStyle.Quint)
        end
        task.delay(0.12, function()
            if hoverToken == token and hovered and self.Minimized and not dragging then
                self:_refreshMini()
                refreshSession()
                setMode("Expanded")
            end
        end)
    end)
    hit.MouseLeave:Connect(function()
        hovered = false
        hoverToken += 1
        local token = hoverToken
        if not pressed then
            tween(islandScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Quint)
        end
        -- A grace period: the card shifts while it morphs and clamps on
        -- screen, so a pointer grazing its edge shouldn't snap it shut.
        task.delay(mode == "Expanded" and 0.28 or 0.1, function()
            if hoverToken == token and not hovered and self.Minimized then
                settleMode()
            end
        end)
    end)
    -- Press and pull to move the island anywhere on screen. It folds to the
    -- pill while carried, lifts a little, and a drop near its home at the top
    -- centre snaps back there. A drag never counts as the click that restores.
    hit.InputBegan:Connect(function(input)
        if not isPress(input) then
            return
        end
        pressed = true
        dragged = false
        tween(islandScale, { Scale = 0.95 }, 0.12, Enum.EasingStyle.Quad)
        if not self._islandLocked then
            dragFrom = Vector2.new(input.Position.X, input.Position.Y)
            dragAnchor = islandSpot(Vector2.new(Mini.Width, Mini.Height))
        end
    end)
    self:_listen("Changed", function(input)
        if not dragFrom or not isMove(input) or not self.Minimized then
            return
        end
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragFrom
        if not dragging then
            if delta.Magnitude < (TOUCH and 10 or 6) then
                return
            end
            dragging, dragged = true, true
            hovered = false
            setMode("Compact")
            tween(islandScale, { Scale = 1.06 }, 0.2, Enum.EasingStyle.Quint)
        end
        local spot = islandSpot(Vector2.new(Mini.Width, Mini.Height), dragAnchor + delta)
        local view = gui.AbsoluteSize
        self._islandAnchor = Vector2.new(spot.X / math.max(view.X, 1), spot.Y / math.max(view.Y, 1))
        if positionTween then
            positionTween:Cancel()
            positionTween = nil
        end
        island.Position = UDim2.fromOffset(spot.X, spot.Y)
    end)
    table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
        if not isPress(input) then
            return
        end
        dragFrom = nil
        if pressed then
            pressed = false
            tween(islandScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
        end
        if dragging then
            dragging = false
            local home = Vector2.new(gui.AbsoluteSize.X / 2, Mini.Top)
            local spot = islandSpot(Vector2.new(Mini.Width, Mini.Height))
            if (spot - home).Magnitude < 28 then
                self._islandAnchor = nil
                placeIsland(Vector2.new(Mini.Width, Mini.Height), 0.35, Enum.EasingStyle.Back)
            end
            local anchor = self._islandAnchor
            self:_writeConfigSettings({ IslandPosition = anchor and { X = anchor.X, Y = anchor.Y } or false })
            hovered = not usingTouch() and pointInside(pointerPosition(), island)
            task.delay(0.1, function()
                if self.Minimized and not dragging then
                    settleMode()
                end
            end)
        end
    end))
    -- Keeps the island on screen when the viewport changes size.
    table.insert(self._connections, gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if island.Visible and not dragging then
            placeIsland(Vector2.new(island.Size.X.Offset, island.Size.Y.Offset), 0)
        end
    end))
    hit.MouseButton1Click:Connect(function()
        if dragged then
            dragged = false
            return
        end
        if self.Minimized then
            self:Restore()
        end
    end)
    -- Restore hides the island under the pointer, so MouseLeave never fires.
    self._miniUnhover = function()
        hovered, pressed, activityLive = false, false, false
        dragFrom, dragging = nil, false
        activityToken += 1
        islandScale.Scale = 1
        -- Clicked open while expanded: once the island has faded out, fold it
        -- back to the pill so the next minimize starts from it.
        task.delay(0.15, function()
            if not self.Minimized then
                setMode("Compact", true)
            end
        end)
    end

    -- A notification while minimized: the island opens to show it for a few
    -- seconds, then folds back.
    self._islandActivity = function(opts)
        if not self.Minimized or not island.Visible then
            return
        end
        local color = NOTIFY_COLORS[opts.Type] or Theme.Accent
        activityTitle.Text = tostring(opts.Title or "Notification")
        activityTitle.TextColor3 = NOTIFY_COLORS[opts.Type] or Theme.Text
        activityBody.Text = tostring(opts.Content or "")
        activityBody.Visible = activityBody.Text ~= ""
        local icon = opts.Icon
        if icon == nil then
            icon = ({ Success = "circle-check", Warning = "triangle-alert", Error = "circle-x" })[opts.Type] or "bell"
        end
        applyIcon(activityIcon, icon)
        if not activityIcon:GetAttribute("CustomIcon") then
            activityIcon.ImageColor3 = color
        end
        activityChip.BackgroundColor3 = color
        activityLive = true
        activityToken += 1
        local token = activityToken
        task.defer(function()
            if activityToken == token and not hovered and not dragging then
                setMode("Activity")
                islandScale.Scale = 0.96
                tween(islandScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
            end
        end)
        task.delay(math.clamp(tonumber(opts.Duration) or 3, 1.5, 5), function()
            if activityToken == token then
                activityLive = false
                if self.Minimized and not hovered then
                    settleMode()
                end
            end
        end)
    end

    -- The meter dances while anything runs and lies flat when nothing does.
    local running = 0
    self:_listen("Render", function()
        if island.Visible and running > 0 and mode == "Compact" then
            local now = os.clock()
            for index, bar in ipairs(bars) do
                local wave = 0.5 + 0.5 * math.sin(now * (6 + index * 1.4) + index * 1.9)
                bar.Size = UDim2.fromOffset(3, math.floor(4 + wave * 11 + 0.5))
            end
        end
    end)

    -- Split, like iOS with two Live Activities: when toggles are running and
    -- a status is pinned, the pill keeps the status (logo leading, value
    -- trailing) and the running meter buds off into its own little circle
    -- beside it. One activity alone stays in the single pill.
    local pinValue = label({
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(1, -52, 0, 18),
        TextSize = 13,
        FontFace = Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Right,
        RichText = true,
        TextTransparency = 1,
        Parent = compact,
    })
    local bubble = create("TextButton", {
        Name = "IslandBubble",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Color3.fromRGB(26, 26, 30),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 30,
        Parent = gui,
    })
    corner(bubble, UDim.new(1, 0))
    local split = create("NumberValue", { Value = 0 })
    local splitOn = false
    local pinnedLead = nil
    local function setSplit(on)
        if on == splitOn then
            return
        end
        splitOn = on
        barsHolder.Parent = on and bubble or meter
        barsHolder.AnchorPoint = on and Vector2.new(0.5, 0.5) or Vector2.new(0, 0)
        barsHolder.Position = on and UDim2.fromScale(0.5, 0.5) or UDim2.new()
        meter.Visible = not on
        tween(pinValue, { TextTransparency = on and 0 or 1 }, 0.2, Enum.EasingStyle.Quad)
        -- Buds off with a spring, and is drawn back in quicker.
        tween(split, { Value = on and 1 or 0 }, on and 0.55 or 0.3, on and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
        if on then
            islandScale.Scale = 0.96
            tween(islandScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
        end
    end
    self:_listen("Render", function()
        local t = split.Value * merge.Value
        local shown = island.Visible and t > 0.02 and island.GroupTransparency < 0.5
        bubble.Visible = shown
        if not shown then
            return
        end
        local origin = gui.AbsolutePosition
        local pos, size = island.AbsolutePosition - origin, island.AbsoluteSize
        local d = math.min(size.Y, Mini.Height)
        local gap = 6
        -- Buds off the side with room to spare: the right, or the left near
        -- the right edge of the screen.
        local right = pos.X + size.X + gap + d <= gui.AbsoluteSize.X
        local edge = right and pos.X + size.X or pos.X
        local dir = right and 1 or -1
        local inner = edge - dir * d * 0.6
        local outer = edge + dir * (gap + d / 2)
        local x = inner + (outer - inner) * t
        local scale = math.clamp(0.35 + 0.65 * t, 0, 1.2)
        -- Liquid: mid-flight the drop stretches along its path and thins,
        -- then rounds back into a circle as it settles.
        local stretch = math.sin(math.clamp(t, 0, 1) * math.pi)
        bubble.Position = UDim2.fromOffset(x, pos.Y + d / 2)
        bubble.Size = UDim2.fromOffset(d * scale * (1 + 0.4 * stretch), d * scale * (1 - 0.18 * stretch))
        bubble.BackgroundTransparency = island.GroupTransparency
    end)
    bubble.MouseButton1Click:Connect(function()
        if self.Minimized then
            self:Restore()
        end
    end)

    local cardRows = {}
    function self:_refreshMini()
        local count = 0
        for _, element in pairs(Library.Flags) do
            if element._type == "Toggle" and element.Value == true then
                count += 1
            end
        end
        if count ~= running then
            local rising = count > running
            running = count
            countLabel.Text = tostring(count)
            for _, bar in ipairs(bars) do
                tween(bar, { BackgroundColor3 = count > 0 and Theme.Accent or Theme.Muted }, 0.25)
                if count == 0 then
                    tween(bar, { Size = UDim2.fromOffset(3, 3) }, 0.25)
                end
            end
            -- A small bump, like a live activity updating.
            if rising and mode == "Compact" and island.Visible then
                islandScale.Scale = 1.06
                tween(islandScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back)
            end
        end
        bigCount.Text = tostring(count)
        local names = {}
        for _, element in pairs(Library.Flags) do
            if element._type == "Toggle" and element.Value == true and element._searchName ~= "" then
                table.insert(names, element._searchName)
            end
        end
        table.sort(names)
        local shownNames = {}
        for index = 1, math.min(#names, 3) do
            shownNames[index] = Library._rich(names[index])
        end
        local extra = #names - #shownNames
        runningNames.Text = '<font color="#8A8A93">Running </font>' .. table.concat(shownNames, '<font color="#8A8A93"> · </font>')
            .. (extra > 0 and string.format('<font color="#8A8A93">  +%d</font>', extra) or "")
        runningNames.Visible = #names > 0
        pinnedLead = nil
        for _, handle in ipairs(self._pinned) do
            if not handle._isShown or handle:_isShown() then
                pinnedLead = handle
                break
            end
        end
        if pinnedLead then
            local text = tostring(pinnedLead:Text() or "")
            -- A status with nothing to show yet doesn't take the pill.
            if text:gsub("<[^>]*>", ""):match("%S") then
                pinValue.Text = text
                local color = pinnedLead._shownColor and pinnedLead._shownColor() or Theme.Text
                -- Too dark to read on the black pill: fall back to text colour.
                local _, _, value = color:ToHSV()
                pinValue.TextColor3 = value < 0.35 and Theme.Text or color
            else
                pinnedLead = nil
            end
        end
        setSplit(running > 0 and pinnedLead ~= nil)
        -- The pill's own meter: the clock when idle or when the bars budded
        -- off without a status to keep, the bars and count otherwise.
        local barsHere = running > 0 and not splitOn
        idleDot.Visible = not barsHere
        idleLabel.Visible = not barsHere
        countLabel.Visible = barsHere
        barsHolder.Visible = running > 0
        meter.Visible = not splitOn
        miniTitle.Visible = not splitOn
        local key = typeof(self.Keybind) == "EnumItem" and keyName(self.Keybind)
        hint.Text = TOUCH and "Tap to open" or (key and ("Click or press " .. key .. " to open") or "Click to open")

        local list = {}
        for _, handle in ipairs(self._pinned) do
            if (not handle._isShown or handle:_isShown()) and #list < Mini.Pinned then
                table.insert(list, handle)
            end
        end
        rowsHolder.Visible = false
        for index = 1, math.max(#list, #cardRows) do
            local handle = list[index]
            local row = cardRows[index]
            if handle then
                if not row then
                    local frame = create("Frame", {
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1,
                        LayoutOrder = index,
                        Parent = rowsHolder,
                    })
                    row = {
                        Frame = frame,
                        Key = label({
                            Size = UDim2.new(0.5, -4, 1, 0),
                            TextSize = 12,
                            FontFace = Fonts.Regular,
                            TextColor3 = Theme.Muted,
                            RichText = true,
                            Parent = frame,
                        }),
                        Value = label({
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.new(0.5, -4, 1, 0),
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Right,
                            RichText = true,
                            Parent = frame,
                        }),
                    }
                    cardRows[index] = row
                end
                row.Frame.Visible = true
                row.Key.Text = Library._rich(handle.Name)
                row.Value.Text = handle:Text()
                -- Carries the status's own colour: its Color, or its tone
                -- for the tinted styles (badge, dot, bar).
                local color = handle._shownColor and handle._shownColor() or Theme.Text
                if row.Value.TextColor3 ~= color then
                    tween(row.Value, { TextColor3 = color }, 0.2)
                end
            elseif row then
                row.Frame.Visible = false
            end
        end
        -- Rows coming and going change the expanded height.
        if mode == "Expanded" and (hovered or self.IslandStyle == "Always Show") then
            task.defer(function()
                if mode == "Expanded" and (hovered or self.IslandStyle == "Always Show") and self.Minimized then
                    local size = shapeFor("Expanded")
                    if math.abs(size.Y - island.Size.Y.Offset) > 1 then
                        setMode("Expanded")
                    end
                end
            end)
        end
    end

    self.MiniBar = island
    self.Island = island
    return island
end

function Window:Minimize()
    if self.Minimized or not self._introDone or not self.Open or self._destroyed then
        return
    end
    self.Minimized = true
    self._minimizeGeneration = (self._minimizeGeneration or 0) + 1
    local generation = self._minimizeGeneration
    self:_closePopups()
    self:_refreshToggleButton()
    self:_refreshBackdrop()
    local bar = self:_buildMiniBar()
    self:_refreshMini()
    local gui = self.Gui

    -- Starts from whatever is on screen: the window, or a ghost still
    -- mid-flight if a restore was interrupted.
    local fromPosition = self.Root.AbsolutePosition - gui.AbsolutePosition
    local fromSize = self.Root.AbsoluteSize
    local fromAlpha = 1
    if self._ghost then
        fromPosition = self._ghost.AbsolutePosition - gui.AbsolutePosition
        fromSize = self._ghost.AbsoluteSize
        fromAlpha = self._ghost.BackgroundTransparency
    end

    -- 1. The ghost fades in over the window while it eases back a touch.
    local ghost, ghostStroke, ghostCorner = makeGhost(self, fromPosition, fromSize, Library._radius(10))
    ghost.BackgroundTransparency = fromAlpha
    ghostStroke.Transparency = fromAlpha
    tween(ghost, { BackgroundTransparency = 0 }, 0.11, Enum.EasingStyle.Quad)
    tween(ghostStroke, { Transparency = 0 }, 0.11, Enum.EasingStyle.Quad)
    tween(self.Scale, { Scale = (self._fitScale or 1) * 0.985 }, 0.11, Enum.EasingStyle.Quad)
    tween(self.Shadow, { ImageTransparency = 1 }, 0.2)
    bar.Visible = true
    bar.GroupTransparency = 1

    task.delay(0.11, function()
        if self._minimizeGeneration ~= generation or self._destroyed then
            return
        end
        -- 2. Covered by the ghost, the window is hidden and the ghost folds
        -- down into the island.
        self.Root.Visible = false
        self.Scale.Scale = self._fitScale or 1
        local target, size = self:_miniLand(fromPosition + fromSize / 2)
        morphGhost(ghost, ghostCorner, target, size, math.floor(size.Y / 2), 0.36)
        task.delay(0.3, function()
            if self._minimizeGeneration ~= generation or self._destroyed then
                return
            end
            -- 3. The island fades in on top as the ghost lands.
            self._miniScale.Scale = 0.9
            tween(self._miniScale, { Scale = 1 }, 0.3, Enum.EasingStyle.Quint)
            tween(bar, { GroupTransparency = 0 }, 0.18, Enum.EasingStyle.Quad)
            dissolve(self, ghost, ghostStroke, 0.2)
            -- Always Show: once landed as the pill, swell open into the card.
            if self.IslandStyle == "Always Show" then
                task.delay(0.22, function()
                    if self._minimizeGeneration == generation and self._islandSettle then
                        self._islandSettle()
                    end
                end)
            end
        end)
    end)

    task.spawn(function()
        while self.Minimized and self._minimizeGeneration == generation and not self._destroyed do
            self:_refreshMini()
            task.wait(0.5)
        end
    end)
end

function Window:Restore()
    if not self.Minimized or self._destroyed then
        return
    end
    self.Minimized = false
    self._minimizeGeneration = (self._minimizeGeneration or 0) + 1
    local generation = self._minimizeGeneration
    self:_refreshToggleButton()
    self:_refreshBackdrop(true)
    local gui = self.Gui
    local bar = self.MiniBar
    local fit = self._fitScale or 1
    local size = Vector2.new(self.Root.Size.X.Offset, self.Root.Size.Y.Offset) * fit
    local centre = self.Root.AbsolutePosition + self.Root.AbsoluteSize / 2 - gui.AbsolutePosition
    local target = centre - size / 2

    -- Picks up from whatever is on screen: a ghost still mid-flight if
    -- minimize was interrupted, otherwise the island.
    local fromPosition, fromSize = target, size
    local fromAlpha = 1
    if self._ghost then
        fromPosition = self._ghost.AbsolutePosition - gui.AbsolutePosition
        fromSize = self._ghost.AbsoluteSize
        fromAlpha = self._ghost.BackgroundTransparency
    elseif bar and bar.Visible then
        fromPosition = self._miniOrb.AbsolutePosition - gui.AbsolutePosition
        fromSize = self._miniOrb.AbsoluteSize
    end
    if bar and bar.Visible then
        if self._miniUnhover then
            self._miniUnhover()
        end
        tween(bar, { GroupTransparency = 1 }, 0.12, Enum.EasingStyle.Quad)
        task.delay(0.12, function()
            if self._minimizeGeneration == generation then
                bar.Visible = false
            end
        end)
    end

    local ghost, ghostStroke, ghostCorner = makeGhost(self, fromPosition, fromSize, math.floor(math.min(fromSize.X, fromSize.Y) / 2))
    ghost.BackgroundTransparency = fromAlpha
    ghostStroke.Transparency = fromAlpha
    tween(ghost, { BackgroundTransparency = 0 }, 0.1, Enum.EasingStyle.Quad)
    tween(ghostStroke, { Transparency = 0 }, 0.1, Enum.EasingStyle.Quad)
    morphGhost(ghost, ghostCorner, target, size, Library._radius(10), 0.4)
    tween(self.Shadow, { ImageTransparency = self._shadowRest }, 0.45)

    -- Shown under the ghost a little early so its first frames are drawn
    -- while still covered, then the ghost clears to reveal it.
    task.delay(0.3, function()
        if self._minimizeGeneration ~= generation or self._destroyed then
            return
        end
        self.Scale.Scale = fit
        self.BodyStroke.Transparency = 0
        self.Root.Visible = true
    end)
    task.delay(0.4, function()
        if self._ghost == ghost and self._minimizeGeneration == generation then
            dissolve(self, ghost, ghostStroke, 0.22)
        end
    end)
end

-- The minimized island can be dragged anywhere; its spot is remembered in
-- the config folder. These lock it in place or send it back to the top.
function Window:SetIslandDraggable(enabled)
    self._islandLocked = enabled == false
end

function Window:ResetIslandPosition()
    self._islandAnchor = nil
    if self._islandReset then
        self._islandReset()
    end
    self:_writeConfigSettings({ IslandPosition = false })
end

function Window:SetMinimized(minimized)
    if minimized then
        self:Minimize()
    else
        self:Restore()
    end
end

function Window:Toggle(open)
    if not self._introDone then
        return
    end
    if self.Minimized then
        if open ~= false then
            self:Restore()
        end
        return
    end
    if open == nil then
        open = not self.Open
    end
    if open == self.Open then
        return
    end
    self.Open = open
    self:_refreshToggleButton()
    self:_refreshBackdrop(open)
    -- Like minimize, a plain ghost panel carries the scale and fade. The body
    -- is never reparented into the fader or rescaled, which relaid out the
    -- whole window and stuttered on the keypress frame.
    self._minimizeGeneration = (self._minimizeGeneration or 0) + 1
    local generation = self._minimizeGeneration
    local gui = self.Gui
    local fit = self._fitScale or 1
    local size = Vector2.new(self.Root.Size.X.Offset, self.Root.Size.Y.Offset) * fit
    local centre = self.Root.AbsolutePosition + self.Root.AbsoluteSize / 2 - gui.AbsolutePosition
    local shrunk = size * 0.94
    local fromPosition, fromSize, fromAlpha
    if self._ghost then
        fromPosition = self._ghost.AbsolutePosition - gui.AbsolutePosition
        fromSize = self._ghost.AbsoluteSize
        fromAlpha = self._ghost.BackgroundTransparency
    end
    if open then
        local ghost, ghostStroke, ghostCorner = makeGhost(self, fromPosition or centre - shrunk / 2, fromSize or shrunk, Library._radius(10))
        ghost.BackgroundTransparency = fromAlpha or 1
        ghostStroke.Transparency = fromAlpha or 1
        tween(ghost, { BackgroundTransparency = 0 }, 0.12, Enum.EasingStyle.Quad)
        tween(ghostStroke, { Transparency = 0 }, 0.12, Enum.EasingStyle.Quad)
        morphGhost(ghost, ghostCorner, centre - size / 2, size, Library._radius(10), 0.3)
        tween(self.Shadow, { ImageTransparency = self._shadowRest }, 0.3)
        -- Shown under the ghost once it covers the spot, then revealed.
        task.delay(0.2, function()
            if self._minimizeGeneration ~= generation or self._destroyed then
                return
            end
            self.Scale.Scale = fit
            self.BodyStroke.Transparency = 0
            self.Root.Visible = true
        end)
        task.delay(0.3, function()
            if self._ghost == ghost and self._minimizeGeneration == generation then
                dissolve(self, ghost, ghostStroke, 0.18)
            end
        end)
    else
        self:_closePopups()
        local position = fromPosition or self.Root.AbsolutePosition - gui.AbsolutePosition
        local current = fromSize or self.Root.AbsoluteSize
        local ghost, ghostStroke, ghostCorner = makeGhost(self, position, current, Library._radius(10))
        ghost.BackgroundTransparency = fromAlpha or 1
        ghostStroke.Transparency = fromAlpha or 1
        tween(ghost, { BackgroundTransparency = 0 }, 0.08, Enum.EasingStyle.Quad)
        tween(ghostStroke, { Transparency = 0 }, 0.08, Enum.EasingStyle.Quad)
        tween(self.Shadow, { ImageTransparency = 1 }, 0.16)
        task.delay(0.08, function()
            if self._minimizeGeneration ~= generation or self._destroyed then
                return
            end
            self.Root.Visible = false
            morphGhost(ghost, ghostCorner, centre - shrunk / 2, shrunk, Library._radius(10), 0.2)
            dissolve(self, ghost, ghostStroke, 0.16)
        end)
    end
end

function Window:SetKeepOnScreen(enabled)
    self.KeepOnScreen = enabled ~= false
    if self.KeepOnScreen then
        self:_clampToScreen()
    end
end

function Window:SetKeybind(keyCode)
    self.Keybind = keyCode
    if self._keyChipLabel then
        self._keyChipLabel.Text = keyName(keyCode)
    end
end

function Window:Notify(opts)
    opts = normalize(opts, { Text = "Content", Message = "Content", Image = "Icon" })
    if self.Minimized and self._islandActivity then
        self._islandActivity(opts)
    end
    local duration = opts.Duration or 4
    local titleColor = NOTIFY_COLORS[opts.Type] or Theme.Text

    self._notifyOrder = self._notifyOrder + 1
    local outer = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        LayoutOrder = self._notifyOrder,
        Parent = self.NotifyHolder,
    })
    local slide = create("Frame", {
        Position = UDim2.fromOffset(320, 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = outer,
    })
    local shadow = create("ImageLabel", {
        Position = UDim2.fromOffset(-20, -20),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = Assets.Shadow,
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = slide,
    })
    local toast = create("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Parent = slide,
    })
    corner(toast, UDim.new(0, 10))
    local toastStroke = stroke(toast, Theme.Stroke)
    edgeHighlight(toast)
    glow(toast, UDim2.fromOffset(260, 120), UDim2.new(1, -10, 0, -10), 0.86, 90)

    local inner = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = toast,
    })
    padding(inner, 16, 16, 14, 24)

    local titleOffset = 0
    if opts.Icon then
        glowIcon(inner, opts.Icon, titleColor == Theme.Text and Theme.Accent or titleColor, UDim2.new(0, 0, 0, 8))
        titleOffset = 24
    end
    label({
        Position = UDim2.fromOffset(titleOffset, 0),
        Size = UDim2.new(1, -28 - titleOffset, 0, 16),
        Text = opts.Title or "Notification",
        TextSize = 14,
        TextColor3 = titleColor,
        Parent = inner,
    })
    local closeButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 6, 0, -5),
        Size = UDim2.fromOffset(24, 24),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.Muted,
        TextSize = 22,
        FontFace = Fonts.Bold,
        AutoButtonColor = false,
        Parent = inner,
    })
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, { TextColor3 = Theme.Text }, 0.15)
    end)
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, { TextColor3 = Theme.Muted }, 0.2)
    end)
    if opts.Content then
        label({
            Position = UDim2.fromOffset(titleOffset, 21),
            Size = UDim2.new(1, -titleOffset, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = opts.Content,
            TextSize = 13,
            FontFace = Fonts.Regular,
            TextColor3 = Theme.Muted,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = inner,
        })
    end

    local track = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 16, 1, -8),
        Size = UDim2.new(1, -32, 0, 3),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Parent = toast,
    })
    corner(track, UDim.new(1, 0))
    local progress = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(progress, UDim.new(1, 0))

    task.defer(function()
        if outer.Parent then
            tween(outer, { Size = UDim2.new(1, 0, 0, toast.AbsoluteSize.Y) }, 0.3, Enum.EasingStyle.Quint)
        end
    end)
    tween(slide, { Position = UDim2.fromOffset(0, 0) }, 0.5, Enum.EasingStyle.Back)
    tween(toast, { GroupTransparency = 0 }, 0.3)
    tween(shadow, { ImageTransparency = 0.6 }, 0.4)
    tween(progress, { Size = UDim2.fromScale(0, 1) }, duration, Enum.EasingStyle.Linear)

    local dismissed = false
    local function dismiss()
        if dismissed then
            return
        end
        dismissed = true
        for index, entry in ipairs(self._toasts) do
            if entry == dismiss then
                table.remove(self._toasts, index)
                break
            end
        end
        tween(slide, { Position = UDim2.fromOffset(320, 0) }, 0.3, Enum.EasingStyle.Quint)
        tween(toast, { GroupTransparency = 1 }, 0.2)
        tween(toastStroke, { Transparency = 1 }, 0.15)
        tween(shadow, { ImageTransparency = 1 }, 0.2)
        task.delay(0.22, function()
            outer.ClipsDescendants = true
            tween(outer, { Size = UDim2.new(1, 0, 0, -4) }, 0.22, Enum.EasingStyle.Quint)
            task.delay(0.24, function()
                outer:Destroy()
            end)
        end)
    end

    task.delay(duration, dismiss)
    closeButton.MouseButton1Click:Connect(dismiss)

    table.insert(self._toasts, dismiss)
    while #self._toasts > self.MaxNotifications do
        local oldest = table.remove(self._toasts, 1)
        oldest()
    end

    return { Dismiss = dismiss }
end

function Window:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    for index, entry in ipairs(Library.Windows) do
        if entry == self then
            table.remove(Library.Windows, index)
            break
        end
    end
    for _, connection in ipairs(self._connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self._connections = {}
    self._inputListeners = { Began = {}, Changed = {}, Ended = {}, Render = {} }
    self._frameSteps = {}

    local gui = self.Gui
    local removed = false
    local function remove()
        if removed then
            return
        end
        removed = true
        if not pcall(gui.Destroy, gui) then
            pcall(function()
                gui.Enabled = false
            end)
        end
    end
    -- The fade out is decoration only. Input is already cut at this point, so
    -- if any of it fails the gui is removed straight away instead of being
    -- left frozen on screen.
    local ok, err = pcall(function()
        if self._dialog then
            self._dialog.Close()
        end
        self:_closePopups()
        local fit = self._fitScale or 1
        tween(self.Scale, { Scale = fit * 0.92 }, 0.22, Enum.EasingStyle.Quint)
        self:_fade(1, 0.2)
        tween(self.BodyStroke, { Transparency = 1 }, 0.12)
        tween(self.Shadow, { ImageTransparency = 1 }, 0.2)
        if self.MiniBar and self.MiniBar.Visible then
            tween(self.MiniBar, { GroupTransparency = 1 }, 0.18)
        end
        if self._backdrop then
            -- Frame steps are already cut, so the weather stops where it is.
            self._weatherField.Visible = false
            tween(self._backdropTintFrame, { BackgroundTransparency = 1 }, 0.2)
            tween(self._backdropHeat, { BackgroundTransparency = 1 }, 0.2)
        end
        for _, button in ipairs({ self.ToggleButton, self.OpenButton }) do
            if typeof(button) == "Instance" and button:IsA("GuiObject") then
                tween(button, { Size = UDim2.fromOffset(0, 0) }, 0.2, Enum.EasingStyle.Quint)
            end
        end
    end)
    if not ok then
        warn("[Noir] unload animation failed, removing the window directly: " .. tostring(err))
        remove()
        return
    end
    task.delay(0.24, remove)
end

Window.Unload = Window.Destroy

-- Unloads every window the library created.
function Library:Destroy()
    for index = #Library.Windows, 1, -1 do
        local window = Library.Windows[index]
        if window then
            window:Destroy()
        end
    end
end

Library.Unload = Library.Destroy

-- A script thread that yielded inside an engine call (InvokeServer and the
-- like) resumes at game identity and can no longer touch the GUI in CoreGui.
-- Every public call checks for that: it raises the thread back to the identity
-- the library loaded at, or, when the executor cannot, runs the call on a
-- trusted Heartbeat thread and waits for its result.
local getIdentity = getthreadidentity or getidentity or get_thread_identity or (syn and syn.get_thread_identity)
local setIdentity = setthreadidentity or setidentity or set_thread_identity or (syn and syn.set_thread_identity)
local loadIdentity = nil
if getIdentity then
    local ok, identity = pcall(getIdentity)
    if ok and type(identity) == "number" then
        loadIdentity = identity
    end
end

local function threadLowered()
    local window = Library.Windows[#Library.Windows]
    local probe = window and window.Gui
    if typeof(probe) ~= "Instance" then
        return false
    end
    return not pcall(function()
        return probe.Name
    end)
end

local trustedQueue = {}
RunService.Heartbeat:Connect(function()
    if #trustedQueue == 0 then
        return
    end
    local queue = trustedQueue
    trustedQueue = {}
    for _, job in ipairs(queue) do
        job()
    end
end)

local function runTrusted(fn, ...)
    local args = table.pack(...)
    local result = nil
    table.insert(trustedQueue, function()
        result = table.pack(pcall(fn, table.unpack(args, 1, args.n)))
    end)
    while result == nil do
        task.wait()
    end
    if not result[1] then
        error(result[2], 0)
    end
    return table.unpack(result, 2, result.n)
end

local guardedObjects = setmetatable({}, { __mode = "k" })
local guardObject

local function guarded(fn)
    return function(...)
        if threadLowered() then
            if setIdentity then
                pcall(setIdentity, loadIdentity or 8)
            end
            if threadLowered() then
                return guardObject(runTrusted(fn, ...))
            end
        end
        return guardObject(fn(...))
    end
end

-- Elements carry their methods as closures, so each returned object gets its
-- public functions wrapped too; windows and tabs share the guarded metatables.
function guardObject(...)
    for index = 1, select("#", ...) do
        local object = select(index, ...)
        if type(object) == "table" and not guardedObjects[object] then
            local meta = getmetatable(object)
            if meta ~= Window and meta ~= Tab then
                guardedObjects[object] = true
                for key, value in pairs(object) do
                    if type(key) == "string" and type(value) == "function" and key:sub(1, 1) ~= "_" then
                        object[key] = guarded(value)
                    elseif type(key) == "number" and type(value) == "table" then
                        guardObject(value)
                    end
                end
            end
        end
    end
    return ...
end

for _, class in ipairs({ Library, Window, Tab }) do
    for key, value in pairs(class) do
        if type(key) == "string" and type(value) == "function" and key:sub(1, 1) ~= "_" then
            class[key] = guarded(value)
        end
    end
end
-- ═══════════════════════════════════════════════════════════════════════════
--  БЛОК АВТОЗАПУСКА — открывает меню сразу при выполнении файла
-- ═══════════════════════════════════════════════════════════════════════════
--  Правь вкладки под себя или удали блок целиком (до "return Library") —
--  тогда файл станет чистой библиотекой: loadstring(...)() вернёт Noir.
-- ═══════════════════════════════════════════════════════════════════════════
local autoOk, autoErr = pcall(function()
    local genv = (typeof(getgenv) == "function" and getgenv()) or _G

    -- Повторный запуск: выгружаем прошлое меню, чтобы не плодить окна
    if genv.NoirAutoUnload then
        pcall(genv.NoirAutoUnload)
    end

    local window = Library:CreateWindow({
        Name            = "Noir",
        Title           = "Noir",
        LoadingTitle    = "Noir",
        LoadingSubtitle = "NOIR CREATOR",
        ToggleUIKeybind = "RightControl",      -- клавиша меню на ПК
        Theme           = "Noir",              -- брендовая тема (чёрный + багровый)
        DefaultTheme    = "Noir",
        Weather         = "Rain",              -- нуар-дождь: Snow/Rain/Hell Fire/Sakura/Fireflies/Matrix/None
        ConfigurationSaving = {
            Enabled    = true,
            FolderName = "Noir/Configs",
        },
        -- Плавающая кнопка открытия меню: нужна на телефоне (Delta)
        ToggleButton = { Platform = "Both", Icon = "layout-grid" },
    })

    -- Уведомления (Type: Success / Warning / Error / Info)
    local function Notify(title, text, typ)
        window:Notify({ Title = title, Content = text, Duration = 4, Type = typ })
    end

    -- ═════════════════════════════════════════════════════════════════════
    --  SILENT AIM CORE
    --  Ремуоты (по логам Remote Spy):
    --    GunFired:      FireServer(Handle, Origin, HitPos, HitPart)
    --    HandleTouched: FireServer(Part)            — удар/касание ножом
    --    KnifeThrown:   FireServer(CFrame, TargetCFrame) — бросок ножа
    --    KnifeStabbed:  FireServer()                — взмах ножом
    --  Лежат: ReplicatedStorage.ClientServices.WeaponService.GunFired
    --        и Players.<ты>.Backpack|Character.<Tool>.Events.*
    -- ═════════════════════════════════════════════════════════════════════
    local SA = {
        -- пистолет
        Enabled   = false,   -- вкл/выкл
        Part      = "Head",  -- куда стрелять
        FOV       = 250,     -- радиус захвата цели (px)
        IgnoreFOV = false,   -- цель = любой видимый на экране
        WallCheck = true,    -- не целиться сквозь стены
        TeamCheck = true,    -- пропускать свою команду
        ShowFOV   = false,   -- рисовать круг FOV
        -- нож
        Knife         = false, -- перенаправлять касания ножом в цель
        KnifeAuto     = false, -- каждый взмах сам бьёт ближайшего врага
        KnifeThrow    = false, -- брошенный нож летит в цель
        KnifeRange    = 18,    -- дистанция удара (studs)
        KnifeWallCheck = true, -- не бить сквозь стены
    }

    local SAPlayers = game:GetService("Players")
    local SARun = game:GetService("RunService")
    local SAInput = game:GetService("UserInputService")
    local SALocal = SAPlayers.LocalPlayer

    -- ── поиск ремуотов ─────────────────────────────────────────────────────
    local GunRemote = nil
    local function resyncGunRemote()
        local node = game:GetService("ReplicatedStorage"):FindFirstChild("ClientServices")
        node = node and node:FindFirstChild("WeaponService")
        local remote = node and node:FindFirstChild("GunFired")
        if typeof(remote) == "Instance" and remote:IsA("RemoteEvent") then
            GunRemote = remote
        end
        return GunRemote
    end
    resyncGunRemote()
    task.spawn(function() -- если сервис ещё не создан — дождаться
        for _ = 1, 60 do
            if resyncGunRemote() then break end
            task.wait(1)
        end
    end)

    -- Ножевые ремуоты лежат в Tool'е (Backpack или Character)
    local function getKnifeEvents()
        local containers = {}
        local bp = SALocal:FindFirstChildOfClass("Backpack")
        local char = SALocal.Character
        if bp then table.insert(containers, bp) end
        if char then table.insert(containers, char) end
        for _, container in ipairs(containers) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local events = tool:FindFirstChild("Events")
                    if typeof(events) == "Instance"
                    and (events:FindFirstChild("HandleTouched")
                        or events:FindFirstChild("KnifeThrown")
                        or events:FindFirstChild("KnifeStabbed")) then
                        return events
                    end
                end
            end
        end
        return nil
    end

    -- ── выбор цели ─────────────────────────────────────────────────────────
    local SA_PARTS = { "Head", "HumanoidRootPart", "Torso", "UpperTorso" }

    local function saAlive(plr)
        local char = plr.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        return char
    end

    local function saFriendly(plr)
        if not SA.TeamCheck then return false end
        local mine, theirs = SALocal.Team, plr.Team
        return mine ~= nil and theirs ~= nil and mine == theirs
    end

    -- Точка прицела: центр экрана на телефоне, курсор на ПК
    local function saScreenPoint()
        local camera = workspace.CurrentCamera
        if not camera then return nil end
        local v = camera.ViewportSize
        if SAInput.TouchEnabled and not SAInput.KeyboardEnabled then
            return Vector2.new(v.X * 0.5, v.Y * 0.5)
        end
        local ok, loc = pcall(function() return SAInput:GetMouseLocation() end)
        if ok and typeof(loc) == "Vector2" then return loc end
        return Vector2.new(v.X * 0.5, v.Y * 0.5)
    end

    -- Есть ли стена между камерой и целью (персонажи не считаются препятствием)
    local function saWallBlocked(targetPart)
        local camera = workspace.CurrentCamera
        if not camera then return false end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local exclude = {}
        for _, plr in ipairs(SAPlayers:GetPlayers()) do
            if plr.Character then table.insert(exclude, plr.Character) end
        end
        params.FilterDescendantsInstances = exclude
        local origin = camera.CFrame.Position
        local hit = workspace:Raycast(origin, targetPart.Position - origin, params)
        return hit ~= nil
    end

    local function saPickPart(char, want)
        if want == "Closest" then
            local camera = workspace.CurrentCamera
            local sp = camera and saScreenPoint()
            if not camera or not sp then return char:FindFirstChild("HumanoidRootPart") end
            local best, bestD = nil, math.huge
            for _, name in ipairs(SA_PARTS) do
                local p = char:FindFirstChild(name)
                if p then
                    local vp, onScreen = camera:WorldToViewportPoint(p.Position)
                    if onScreen then
                        local d = (Vector2.new(vp.X, vp.Y) - sp).Magnitude
                        if d < bestD then best, bestD = p, d end
                    end
                end
            end
            return best or char:FindFirstChild("HumanoidRootPart")
        end
        return char:FindFirstChild(want) or char:FindFirstChild("HumanoidRootPart")
    end

    -- Цель для пистолета/броска: ближайшая к точке прицела в пределах FOV
    local function saFindTarget()
        local camera = workspace.CurrentCamera
        if not camera then return nil, nil end
        local sp = saScreenPoint()
        if not sp then return nil, nil end
        local list = {}
        for _, plr in ipairs(SAPlayers:GetPlayers()) do
            if plr ~= SALocal and not saFriendly(plr) then
                local char = saAlive(plr)
                if char then
                    local part = saPickPart(char, SA.Part)
                    if part then
                        local vp, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            table.insert(list, {
                                part = part, plr = plr,
                                d = (Vector2.new(vp.X, vp.Y) - sp).Magnitude,
                                depth = (part.Position - camera.CFrame.Position).Magnitude,
                            })
                        end
                    end
                end
            end
        end
        table.sort(list, function(a, b) return a.d < b.d end)
        for _, cand in ipairs(list) do
            if SA.IgnoreFOV or cand.d <= SA.FOV then
                if not SA.WallCheck or not saWallBlocked(cand.part) then
                    return cand.part, cand
                end
            end
        end
        return nil, nil
    end

    -- Цель для ножа: ближайший враг в радиусе удара от персонажа
    local function saKnifeTarget()
        local char = SALocal.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local best, bestD = nil, math.huge
        for _, plr in ipairs(SAPlayers:GetPlayers()) do
            if plr ~= SALocal and not saFriendly(plr) then
                local pchar = saAlive(plr)
                if pchar then
                    local part = pchar:FindFirstChild("HumanoidRootPart")
                        or pchar:FindFirstChild("Torso")
                        or pchar:FindFirstChild("UpperTorso")
                        or pchar:FindFirstChild("Head")
                    if part then
                        local d = (part.Position - root.Position).Magnitude
                        if d <= SA.KnifeRange and d < bestD
                        and (not SA.KnifeWallCheck or not saWallBlocked(part)) then
                            best, bestD = part, d
                        end
                    end
                end
            end
        end
        return best
    end

    -- ── круг FOV ───────────────────────────────────────────────────────────
    local saCircle = nil
    local saNoDrawing = false
    local function saDrawFOV()
        if saNoDrawing then return end
        if not saCircle then
            local ok = pcall(function()
                saCircle = Drawing.new("Circle")
                saCircle.Thickness = 1
                saCircle.Filled = false
                saCircle.NumSides = 64
                saCircle.Color = Color3.fromRGB(228, 52, 66) -- акцент Noir
                saCircle.Transparency = 0.7
            end)
            if not ok then saNoDrawing = true saCircle = nil return end
        end
        local sp = saScreenPoint()
        if sp then
            saCircle.Visible = true
            saCircle.Position = sp
            saCircle.Radius = SA.FOV
        end
    end
    local function saHideFOV()
        if saCircle then pcall(function() saCircle.Visible = false end) end
    end

    -- ── хук __namecall ─────────────────────────────────────────────────────
    local saOldNamecall = nil
    local saHooked = false

    local function saOurCall()
        local f = checkcaller
        return typeof(f) == "function" and f() or false
    end

    local function saLocalKnife(self)
        local char = SALocal.Character
        if char and self:IsDescendantOf(char) then return true end
        local bp = SALocal:FindFirstChildOfClass("Backpack")
        if bp and self:IsDescendantOf(bp) then return true end
        return false
    end

    local function saInstallHook()
        if saHooked then return true end
        if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" then
            Notify("Silent Aim", "Исполнитель не поддерживает hookmetamethod", "Error")
            return false
        end
        local wrap = (typeof(newcclosure) == "function") and newcclosure or function(f) return f end
        local ok, err = pcall(function()
            saOldNamecall = hookmetamethod(game, "__namecall", wrap(function(self, ...)
                if getnamecallmethod() ~= "FireServer" then
                    return saOldNamecall(self, ...)
                end
                if typeof(self) ~= "Instance" or not self:IsA("RemoteEvent") then
                    return saOldNamecall(self, ...)
                end
                local name = self.Name
                -- ПИСТОЛЕТ: GunFired(Handle, Origin, HitPos, HitPart) ->
                -- подменяем HitPos и HitPart на цель
                if SA.Enabled and not saOurCall()
                and (GunRemote ~= nil and self == GunRemote
                    or (self.Parent ~= nil and self.Parent.Name == "WeaponService")) then
                    local args = { ... }
                    if #args >= 4
                    and typeof(args[3]) == "Vector3"
                    and typeof(args[4]) == "Instance" then
                        local target = saFindTarget()
                        if target then
                            args[3] = target.Position
                            args[4] = target
                        end
                        return saOldNamecall(self, table.unpack(args))
                    end
                end
                -- НОЖ: касание -> ближайший враг
                if name == "HandleTouched" and SA.Knife and saLocalKnife(self) then
                    local args = { ... }
                    if #args == 0 or typeof(args[1]) == "Instance" then
                        local target = saKnifeTarget()
                        if target then args[1] = target end
                        return saOldNamecall(self, table.unpack(args))
                    end
                end
                -- НОЖ: бросок -> цель (по FOV)
                if name == "KnifeThrown" and SA.KnifeThrow and saLocalKnife(self) then
                    local args = { ... }
                    if #args >= 2 and typeof(args[2]) == "CFrame" then
                        local target = saFindTarget()
                        if target then
                            args[2] = CFrame.new(target.Position)
                        end
                        return saOldNamecall(self, table.unpack(args))
                    end
                end
                -- НОЖ: авто-удар при взмахе (после KnifeStabbed шлём HandleTouched)
                if name == "KnifeStabbed" and SA.KnifeAuto
                and saLocalKnife(self) and not saOurCall() then
                    local result = saOldNamecall(self, ...)
                    local target = saKnifeTarget()
                    if target then
                        local events = getKnifeEvents()
                        local remote = events and events:FindFirstChild("HandleTouched")
                        if remote then
                            task.defer(function()
                                pcall(function() remote:FireServer(target) end)
                            end)
                        end
                    end
                    return result
                end
                return saOldNamecall(self, ...)
            end))
        end)
        if not ok then
            warn("[Noir] silent aim hook: " .. tostring(err))
            Notify("Silent Aim", "Не удалось поставить хук (см. консоль)", "Error")
            return false
        end
        saHooked = true
        return true
    end

    local function saEnsure()
        if SA.Enabled or SA.Knife or SA.KnifeAuto or SA.KnifeThrow then
            saInstallHook()
        end
    end

    local saRenderConn = SARun.RenderStepped:Connect(function()
        if SA.ShowFOV then saDrawFOV() else saHideFOV() end
    end)

    -- ── выгрузка ───────────────────────────────────────────────────────────
    genv.NoirAutoUnload = function()
        genv.NoirAutoUnload = nil
        pcall(function() if saRenderConn then saRenderConn:Disconnect() end end)
        pcall(function() if saCircle then saCircle:Remove() end end)
        pcall(function()
            if saHooked and saOldNamecall then
                hookmetamethod(game, "__namecall", saOldNamecall)
            end
        end)
        if window and not window._destroyed then
            pcall(window.Destroy, window)
        end
    end

    -- ═════════════════════════════════════════════════════════════════════
    --  ВКЛАДКА 1: MAIN — демо-элементы (замени на свои функции)
    -- ═════════════════════════════════════════════════════════════════════
    do
        local tab = window:CreateTab({ Name = "Main", Icon = "star", Desc = "Демо-элементы" })

        local left = tab:AddLeftGroupbox({ Name = "Настройки", Icon = "cog" })
        left:CreateToggle({
            Name     = "Включить функцию",
            Desc     = "Главный тумблер",
            Default  = false,
            Flag     = "DemoToggle",       -- Flag → значение сохраняется в конфиги
            Callback = function(v)
                Notify("Noir", "Функция: " .. (v and "ВКЛ" or "ВЫКЛ"), v and "Success" or nil)
            end,
        })
        left:CreateSlider({
            Name     = "Скорость",
            Min      = 0, Max = 100, Default = 50,
            Suffix   = "%",
            Flag     = "DemoSpeed",
            Callback = function(v) print("[Noir] Скорость:", v) end,
        })
        left:CreateDropdown({
            Name     = "Режим",
            Options  = { "Лёгкий", "Нормальный", "Хардкор" },
            Default  = "Нормальный",
            Flag     = "DemoMode",
            Callback = function(v) Notify("Noir", "Режим: " .. tostring(v)) end,
        })
        left:CreateButton({
            Name = "Проверить меню", Style = "Primary", Icon = "check",
            Callback = function()
                Notify("Noir", "Меню полностью работает!", "Success")
            end,
        })

        local right = tab:AddRightGroupbox({ Name = "Информация", Icon = "info" })
        right:CreateLabel("Это демо-вкладка автозапуска.")
        right:CreateParagraph({
            Title   = "Как пользоваться",
            Content = "Вкладка Combat — Silent Aim для пистолета и ножа. "
                    .. "Плавающая кнопка на экране открывает/закрывает меню. "
                    .. "На ПК — клавиша RightControl.",
        })
        right:CreateDivider("конец")
    end

    -- ═════════════════════════════════════════════════════════════════════
    --  ВКЛАДКА 2: COMBAT — Silent Aim (пистолет + нож)
    -- ═════════════════════════════════════════════════════════════════════
    local combatRows
    do
        local tab = window:CreateTab({ Name = "Combat", Icon = "crosshair", Desc = "Silent Aim" })

        local gun = tab:AddLeftGroupbox({ Name = "Пистолет", Icon = "crosshair" })
        gun:CreateToggle({
            Name    = "Silent Aim",
            Desc    = "Выстрелы летят в цель без наведения",
            Default = false,
            Flag    = "GunSilentAim",
            Callback = function(v)
                SA.Enabled = v
                saEnsure()
            end,
        })
        gun:CreateDropdown({
            Name    = "Часть тела",
            Options = { "Head", "HumanoidRootPart", "Torso", "UpperTorso", "Closest" },
            Default = "Head",
            Flag    = "GunPart",
            Callback = function(v) SA.Part = v end,
        })
        gun:CreateSlider({
            Name     = "FOV",
            Min      = 30, Max = 1000, Default = 250,
            Suffix   = "px",
            Flag     = "GunFOV",
            Callback = function(v) SA.FOV = v end,
        })
        gun:CreateToggle({
            Name    = "Без FOV (любая цель на экране)",
            Default = false,
            Flag    = "GunNoFOV",
            Callback = function(v) SA.IgnoreFOV = v end,
        })
        gun:CreateToggle({
            Name    = "Проверка стен",
            Desc    = "Не целиться сквозь препятствия",
            Default = true,
            Flag    = "GunWalls",
            Callback = function(v) SA.WallCheck = v end,
        })
        gun:CreateToggle({
            Name    = "Не бить свою команду",
            Default = true,
            Flag    = "GunTeam",
            Callback = function(v) SA.TeamCheck = v end,
        })
        gun:CreateToggle({
            Name    = "Круг FOV на экране",
            Default = false,
            Flag    = "GunCircle",
            Callback = function(v) SA.ShowFOV = v end,
        })

        local knife = tab:AddRightGroupbox({ Name = "Нож", Icon = "sword" })
        knife:CreateToggle({
            Name    = "Silent Aim (удары)",
            Desc    = "Касание ножом бьёт ближайшего врага",
            Default = false,
            Flag    = "KnifeSilent",
            Callback = function(v)
                SA.Knife = v
                saEnsure()
            end,
        })
        knife:CreateToggle({
            Name    = "Авто-удар при взмахе",
            Desc    = "Взмах сам попадает по врагу рядом",
            Default = false,
            Flag    = "KnifeAuto",
            Callback = function(v)
                SA.KnifeAuto = v
                saEnsure()
            end,
        })
        knife:CreateToggle({
            Name    = "Метание в цель",
            Desc    = "Брошенный нож летит в цель (по FOV)",
            Default = false,
            Flag    = "KnifeThrow",
            Callback = function(v)
                SA.KnifeThrow = v
                saEnsure()
            end,
        })
        knife:CreateSlider({
            Name     = "Дистанция удара",
            Min      = 5, Max = 40, Default = 18,
            Suffix   = " м",
            Flag     = "KnifeRange",
            Callback = function(v) SA.KnifeRange = v end,
        })
        knife:CreateToggle({
            Name    = "Проверка стен (удары)",
            Default = true,
            Flag    = "KnifeWalls",
            Callback = function(v) SA.KnifeWallCheck = v end,
        })

        local diag = tab:AddRightGroupbox({ Name = "Цель", Icon = "target" })
        combatRows = diag:CreateStatuses({
            { Name = "Цель",       Value = "-" },
            { Name = "Дистанция",  Value = "-" },
            { Name = "Часть",      Value = "-" },
            { Name = "Пистолет",   Value = "?" },
            { Name = "Нож",        Value = "?" },
        }, { Style = "Row" })
        diag:CreateButton({
            Name = "Перепроверить ремуоты", Icon = "radar",
            Callback = function()
                resyncGunRemote()
                local events = getKnifeEvents()
                local gunOk = GunRemote ~= nil
                local knifeOk = events ~= nil
                Notify("Диагностика",
                    "Пистолет: " .. (gunOk and "найден" or "НЕ найден")
                    .. " | Нож: " .. (knifeOk and "найден" or "возьми нож"),
                    gunOk and knifeOk and "Success" or "Warning")
            end,
        })
    end

    -- Живые статусы: какая сейчас цель
    task.spawn(function()
        while not window._destroyed do
            task.wait(0.25)
            pcall(function()
                if not combatRows then return end
                combatRows["Пистолет"]:Set(GunRemote ~= nil and "найден" or "нет")
                combatRows["Нож"]:Set(getKnifeEvents() ~= nil and "найден" or "нет")
                local anyOn = SA.Enabled or SA.Knife or SA.KnifeAuto or SA.KnifeThrow
                if anyOn then
                    local part, cand = saFindTarget()
                    if cand then
                        combatRows["Цель"]:Set(cand.plr.DisplayName)
                        combatRows["Дистанция"]:Set(string.format("%.0f м", cand.depth))
                        combatRows["Часть"]:Set(part.Name)
                    else
                        combatRows["Цель"]:Set("нет в FOV")
                        combatRows["Дистанция"]:Set("-")
                        combatRows["Часть"]:Set("-")
                    end
                else
                    combatRows["Цель"]:Set("выключено")
                    combatRows["Дистанция"]:Set("-")
                    combatRows["Часть"]:Set("-")
                end
            end)
        end
    end)

    -- ═════════════════════════════════════════════════════════════════════
    --  ВКЛАДКА 3: SETTINGS — темы, конфиги, погода, масштаб, выгрузка
    -- ═════════════════════════════════════════════════════════════════════
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
            Default = "Rain",
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
                    Title       = "Выгрузить Noir?",
                    Content     = "Меню закроется, Silent Aim выключится.",
                    ConfirmText = "Выгрузить",
                    Callback    = function() genv.NoirAutoUnload() end,
                })
            end,
        })

        -- Готовые менеджеры конфигов и тем (полноценный UI в один вызов)
        tab:CreateConfigManager({ Name = "Конфиги", Side = "Left" })
        tab:CreateThemeManager({ Name = "Темы", Side = "Right" })
    end

    print("[Noir] Меню загружено: Combat = Silent Aim (пистолет + нож). Кнопка на экране / RightControl")
end)

if not autoOk then
    warn("[Noir] Автозапуск не удался: " .. tostring(autoErr))
end

return Library
