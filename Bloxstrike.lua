-- NOIR / Blox Strike: меню Silent Aim, Rapid Fire, Auto Shoot, Autowall и ESP.
-- Написан по принципу из приложенного stage_7; весь исходный скрипт не копируется.
-- Перед запуском перезайди в игру, чтобы убрать старые перехватчики.
-- Закрытие окна не отключает функции; открыть меню можно кнопкой MENU.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local environment = getgenv()

if environment.BloxCombinedSilentRapid and environment.BloxCombinedSilentRapid.gui and environment.BloxCombinedSilentRapid.gui.Parent then
    environment.BloxCombinedSilentRapid.gui.Enabled = true
    return
end

local config = {
    enabled = false,
    fullCircle = true,     -- 360 градусов: включая цели за камерой
    maxDistance = 2000,    -- максимальное расстояние до цели
    visibilityCheck = true,
    teamCheck = true,
    originRadius = 6, -- плавная настройка от 0 до 9 studs
}

local state = {
    gui = nil,
    target = nil,
    camera = nil,
    savedView = nil,
    redirected = false,
    ready = false,
    message = "Поиск функций...",
    wallReady = false,
    wallMessage = "Поиск модулей...",
    extras = { autoShoot = false, autoWall = false, box = false, names = false, outline = false, forceOrigin = false, autoReload = false, instaReload = false, chams = false, antiSmoke = false, antiFlash = false },
}

local gui = Instance.new("ScreenGui")
gui.Name = "NoirControl"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100

local mounted = false
if type(gethui) == "function" then
    local ok, hidden = pcall(gethui)
    if ok and hidden then mounted = pcall(function() gui.Parent = hidden end) end
end
if not mounted then
    mounted = pcall(function() gui.Parent = game:GetService("CoreGui") end)
end
if not mounted then
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
end
state.gui = gui
environment.BloxCombinedSilentRapid = state

-- Интерфейс: одно окно, а не отдельные кнопки.
local function round(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
end
local function label(parent, text, size, position, fontSize)
    local item = Instance.new("TextLabel")
    item.BackgroundTransparency = 1
    item.Size, item.Position = size, position
    item.Text = text
    item.TextColor3 = Color3.fromRGB(238, 242, 255)
    item.TextSize = fontSize
    item.Font = Enum.Font.GothamBold
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.Parent = parent
    return item
end
local function smallButton(parent, text, size, position)
    local item = Instance.new("TextButton")
    item.Size, item.Position = size, position
    item.BackgroundColor3 = Color3.fromRGB(38, 45, 67)
    item.BorderSizePixel = 0
    item.Text, item.TextSize = text, 13
    item.TextColor3 = Color3.fromRGB(235, 240, 255)
    item.Font = Enum.Font.GothamBold
    item.AutoButtonColor = false
    item.Parent = parent
    round(item, 8)
    return item
end

gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local overlay = Instance.new("Frame")
overlay.Name = "EspOverlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = gui

local menu = Instance.new("Frame")
menu.Name = "BloxMenu"
menu.Size = UDim2.fromOffset(430, 300)
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.new(0.5, 0, 0.5, 0)
menu.BackgroundColor3 = Color3.fromRGB(13, 12, 20)
menu.BorderSizePixel = 0
menu.ZIndex = 10
menu.Parent = gui
menu.Visible = false -- до завершения заставки
round(menu, 14)
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(76, 65, 99)
border.Thickness = 1
border.Parent = menu
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, -28, 0, 1)
accent.Position = UDim2.fromOffset(14, 47)
accent.BorderSizePixel, accent.BackgroundColor3, accent.ZIndex = 0, Color3.fromRGB(144, 112, 209), 12
accent.Parent = menu
round(accent, 2)

local header = Instance.new("Frame")
header.Name = "DragBar"
header.Size = UDim2.new(1, -50, 0, 48)
header.BackgroundTransparency = 1
header.Active = true
header.ZIndex = 11
header.Parent = menu
local badge = Instance.new("Frame")
badge.Name, badge.BackgroundColor3, badge.BorderSizePixel = "BrandBadge", Color3.fromRGB(54, 39, 76), 0
badge.Size, badge.Position, badge.ZIndex, badge.Parent = UDim2.fromOffset(30,30), UDim2.fromOffset(14,9), 12, header
round(badge, 9)
local badgeText = label(badge, "N", UDim2.fromScale(1,1), UDim2.fromOffset(0,0), 11)
badgeText.TextXAlignment, badgeText.TextColor3, badgeText.ZIndex = Enum.TextXAlignment.Center, Color3.fromRGB(232,214,255), 13
local title = label(header, "N O I R", UDim2.new(1, -60, 0, 22), UDim2.fromOffset(54, 6), 15)
title.ZIndex = 12
local subtitle = label(header, "CREATOR  /  BLOX STRIKE", UDim2.new(1, -60, 0, 17), UDim2.fromOffset(54, 26), 9)
subtitle.TextColor3 = Color3.fromRGB(139, 156, 190)
subtitle.ZIndex = 12
local close = smallButton(menu, "×", UDim2.fromOffset(32, 32), UDim2.new(1, -42, 0, 8))
close.TextSize = 21
close.ZIndex = 12

local reopen = smallButton(gui, "N  /  NOIR", UDim2.fromOffset(86, 36), UDim2.new(0, 12, 0.36, 0))
reopen.BackgroundColor3 = Color3.fromRGB(49, 37, 68)
reopen.Visible = false
reopen.ZIndex = 10
close.MouseButton1Click:Connect(function() menu.Visible = false; reopen.Visible = true end)
reopen.MouseButton1Click:Connect(function() menu.Visible = true; reopen.Visible = false end)
state.menu = menu
-- Подгоняем панель под маленький экран; изменения устройства не растягивают её.
local menuScale = Instance.new("UIScale")
menuScale.Parent = menu
local function updateMenuScale()
    local camera = Workspace.CurrentCamera
    if camera then
        local size = camera.ViewportSize
        menuScale.Scale = math.clamp(math.min((size.X-16)/430, (size.Y-16)/300), 0.3, 1)
    end
end
local viewportConnection
local function watchCamera()
    if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
    if Workspace.CurrentCamera then
        viewportConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMenuScale)
    end
    updateMenuScale()
end
watchCamera()
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)

-- Сохраняем UDim2 как есть: вместо пересчёта AbsolutePosition не появляется скачок.
local drag, origin, original
header.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    drag, origin, original = input, input.Position, menu.Position
end)
UserInputService.InputChanged:Connect(function(input)
    if not drag then return end
    local touch = drag.UserInputType == Enum.UserInputType.Touch and input == drag
    local mouse = drag.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
    if touch or mouse then
        local offset = input.Position - origin
        menu.Position = UDim2.new(original.X.Scale, original.X.Offset + offset.X, original.Y.Scale, original.Y.Offset + offset.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if drag and (input == drag or (drag.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then
        drag = nil
    end
end)

-- NOIR: боковая навигация, рабочая область и карточки вместо старой сетки вкладок.
local selectedTab = "COMBAT"
local tabs, entries, indicators = {}, {}, {}
local groups = {
    ["SILENT"]={"COMBAT",0}, ["AUTO SHOOT"]={"COMBAT",1},
    ["AUTOWALL"]={"COMBAT",2}, ["FORCE ORIGIN"]={"COMBAT",3}, ["TEAM CHECK"]={"COMBAT",4},
    ["RAPID"]={"WEAPON",0}, ["AUTO RELOAD"]={"WEAPON",1}, ["INSTA RELOAD"]={"WEAPON",2},
    ["ESP BOX"]={"VISUALS",0}, ["NAMES / HP"]={"VISUALS",1}, ["OUTLINE"]={"VISUALS",2}, ["CHAMS"]={"VISUALS",3},
    ["BOX STYLE"]={"VISUALS",4}, ["OUTLINE STYLE"]={"VISUALS",5}, ["CHAMS STYLE"]={"VISUALS",6}, ["ESP COLOR"]={"VISUALS",7},
    ["ANTI SMOKE"]={"EFFECTS",0}, ["ANTI FLASH"]={"EFFECTS",1},
    ["BOMB ESP"]={"OBJECTIVE",0}, ["BOMB TIMER"]={"OBJECTIVE",1},
    ["AUTO DEFUSE"]={"OBJECTIVE",2}, ["AUTO PLANT"]={"OBJECTIVE",3},
}
do
    local rail = Instance.new("Frame")
    rail.Name, rail.BackgroundColor3, rail.BorderSizePixel = "NavigationRail", Color3.fromRGB(19,18,29), 0
    rail.Size, rail.Position, rail.ZIndex, rail.Parent = UDim2.fromOffset(101,226), UDim2.fromOffset(11,61), 11, menu
    round(rail, 10)
    local line = Instance.new("Frame")
    line.BackgroundColor3, line.BorderSizePixel = Color3.fromRGB(46,39,58), 0
    line.Size, line.Position, line.ZIndex, line.Parent = UDim2.fromOffset(1,205), UDim2.fromOffset(116,68), 11, menu
    local tag = label(rail, "NAVIGATION", UDim2.fromOffset(86,16), UDim2.fromOffset(10,8), 8)
    tag.TextColor3, tag.ZIndex = Color3.fromRGB(110,103,127), 12
    local edition = label(rail, "NOIR  /  V", UDim2.fromOffset(90,15), UDim2.fromOffset(10,207), 8)
    edition.TextColor3, edition.ZIndex = Color3.fromRGB(105,95,122), 12
end
local pageHint = label(menu, "", UDim2.fromOffset(260,19), UDim2.fromOffset(129,63), 11)
pageHint.TextColor3 = Color3.fromRGB(231,224,245)
pageHint.ZIndex = 12
local pageSub = label(menu, "", UDim2.fromOffset(260,13), UDim2.fromOffset(129,81), 8)
pageSub.TextColor3, pageSub.ZIndex = Color3.fromRGB(127,118,145), 12
local function setTab(name)
    selectedTab = name
    local headings = {COMBAT="COMBAT", WEAPON="WEAPON", VISUALS="VISUALS", OBJECTIVE="OBJECTIVE", EFFECTS="EFFECTS"}
    local hints = {COMBAT="TARGETING & PRECISION", WEAPON="FIRE & RELOAD", VISUALS="ENEMY OVERLAYS", OBJECTIVE="BOMB / CONTROL", EFFECTS="LOCAL EFFECT FILTERS"}
    pageHint.Text, pageSub.Text = headings[name], hints[name]
    for group, button in pairs(tabs) do
        local active = group == name
        button.BackgroundColor3 = active and Color3.fromRGB(65,49,91) or Color3.fromRGB(19,18,29)
        button.TextColor3 = active and Color3.fromRGB(241,229,255) or Color3.fromRGB(154,144,169)
    end
    for _, entry in ipairs(entries) do entry.button.Visible = entry.group == name end
end
for index, name in ipairs({"COMBAT", "WEAPON", "VISUALS", "OBJECTIVE", "EFFECTS"}) do
    local tab = smallButton(menu, "  "..name, UDim2.fromOffset(91, 30), UDim2.fromOffset(16, 86+(index-1)*34))
    tab.Name, tab.TextSize, tab.ZIndex = name.."Tab", 9, 12
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tabs[name] = tab
    tab.MouseButton1Click:Connect(function() setTab(name) end)
end
setTab(selectedTab)
local function makeToggle(name, index)
    local layout = assert(groups[name], "unknown toggle: " .. name)
    local col, row = layout[2] % 2, math.floor(layout[2] / 2)
    local item = smallButton(menu, "   "..name, UDim2.fromOffset(136, 34), UDim2.fromOffset(129+col*143, 101+row*39))
    item.Name, item.ZIndex, item.TextSize = name.."Toggle", 12, 9
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.BackgroundColor3 = Color3.fromRGB(26,24,37)
    item.Visible = layout[1] == selectedTab
    local edge = Instance.new("UIStroke")
    edge.Color, edge.Thickness, edge.Transparency, edge.Parent = Color3.fromRGB(69,61,82), 1, 0.35, item
    local status = label(item, "", UDim2.fromOffset(33,18), UDim2.new(1,-38,0.5,-9), 8)
    status.TextXAlignment, status.ZIndex = Enum.TextXAlignment.Right, 14
    indicators[item] = {status=status, edge=edge}
    table.insert(entries, {group=layout[1], button=item})
    return item
end
local function showToggle(item, name, enabled, waiting)
    item.Text = "   " .. name
    item.BackgroundColor3 = enabled and Color3.fromRGB(48,36,64) or Color3.fromRGB(26,24,37)
    local data = indicators[item]
    data.status.Text = waiting and "WAIT" or (enabled and "ON" or "OFF")
    data.status.TextColor3 = waiting and Color3.fromRGB(247,192,103) or (enabled and Color3.fromRGB(218,183,255) or Color3.fromRGB(119,111,132))
    data.edge.Color = enabled and Color3.fromRGB(147,112,196) or Color3.fromRGB(69,61,82)
end
local footer = label(menu, "NOIR CREATOR   /   LOCAL CONTROL", UDim2.fromOffset(272,16), UDim2.fromOffset(129,280), 8)
footer.TextColor3 = Color3.fromRGB(103,93,117)
footer.ZIndex = 12
local button = makeToggle("SILENT", 0)

local function refreshButton()
    showToggle(button, "SILENT", config.enabled, not state.ready)
end

local function restoreCamera()
    local camera, previous = state.camera, state.savedView
    state.camera, state.savedView, state.redirected = nil, nil, false
    if camera and previous then
        pcall(function() camera.CFrame = previous end)
    end
end

button.MouseButton1Click:Connect(function()
    if not state.ready then
        warn("[Silent Aim] " .. state.message)
        return
    end
    config.enabled = not config.enabled
    if not config.enabled then
        state.target = nil
        restoreCamera()
    end
    refreshButton()
end)
refreshButton()


-- Rapid Fire: независимая кнопка и собственное состояние, без дополнительных GUI.
do
    local rapid = {
        enabled = false,
        ready = false,
        shotsPerSecond = 12, -- желаемая частота; сервер может её ограничить
        message = "Поиск оружия...",
        controller = nil,
        currentWeapon = nil,
        lastSequence = nil,
        lastShotAt = nil,
        previousShooting = false,
    }
    state.rapid = rapid

    local rapidButton = makeToggle("RAPID", 1)

    local function refreshRapid()
        showToggle(rapidButton, "RAPID", rapid.enabled, not rapid.ready)
    end

    rapidButton.MouseButton1Click:Connect(function()
        if not rapid.ready then
            warn("[Rapid Fire] " .. rapid.message)
            return
        end
        rapid.enabled = not rapid.enabled
        rapid.currentWeapon = nil
        rapid.lastSequence = nil
        rapid.lastShotAt = nil
        rapid.previousShooting = false
        refreshRapid()
    end)
    refreshRapid()

    local function validController(value)
        return type(value) == "table" and type(rawget(value, "peekCurrentEquippedForMovement")) == "function"
    end

    local function findController()
        local controllers = ReplicatedStorage:FindFirstChild("Controllers")
        local module = controllers and controllers:FindFirstChild("InventoryController")
        if module and module:IsA("ModuleScript") then
            local ok, value = pcall(require, module)
            if ok and validController(value) then return value end
        end
        if type(getgc) == "function" then
            local ok, objects = pcall(getgc, true)
            if ok and type(objects) == "table" then
                for _, value in ipairs(objects) do
                    if validController(value) then return value end
                end
            end
        end
        return nil
    end

    local function resetTracking()
        rapid.currentWeapon = nil
        rapid.lastSequence = nil
        rapid.lastShotAt = nil
        rapid.previousShooting = false
    end

    local function processWeapon()
        if not rapid.enabled or not rapid.ready then return end
        local getter = rapid.controller and rapid.controller.peekCurrentEquippedForMovement
        if type(getter) ~= "function" then return end
        local ok, weapon = pcall(getter)
        if not ok or type(weapon) ~= "table" or weapon.Player ~= localPlayer or weapon.IsDestroyed then
            resetTracking()
            return
        end
        if weapon ~= rapid.currentWeapon then
            rapid.currentWeapon = weapon
            rapid.lastSequence = weapon.ShotSeq
            rapid.lastShotAt = nil
            rapid.previousShooting = false
        end
        if weapon.IsReloading then
            -- Перезарядку не прерываем и таймер повторного выстрела не сбрасываем.
            rapid.lastSequence = weapon.ShotSeq
            rapid.lastShotAt = nil
            rapid.previousShooting = false
            return
        end

        local now = os.clock()
        local sequence = weapon.ShotSeq
        local firing = weapon.IsShooting == true
        if sequence ~= nil and rapid.lastSequence ~= nil and sequence ~= rapid.lastSequence then
            rapid.lastShotAt = now
        elseif firing and not rapid.previousShooting then
            rapid.lastShotAt = now
        end
        rapid.lastSequence = sequence
        rapid.previousShooting = firing

        if not rapid.lastShotAt or now - rapid.lastShotAt < 1 / rapid.shotsPerSecond then return end
        if firing or (type(weapon.NextShotDue) == "number" and weapon.NextShotDue > 0) then
            if weapon.ShootDelayThread then
                pcall(task.cancel, weapon.ShootDelayThread)
                weapon.ShootDelayThread = nil
            end
            weapon.IsShooting = false
            weapon.NextShotDue = 0
            rapid.previousShooting = false
            rapid.lastShotAt = nil
        end
    end

    local lastWarning = 0
    RunService.Heartbeat:Connect(function()
        local ok, err = pcall(processWeapon)
        if not ok and os.clock() - lastWarning > 5 then
            lastWarning = os.clock()
            rapid.enabled = false
            refreshRapid()
            warn("[Rapid Fire] Отключено из-за ошибки: " .. tostring(err))
        end
    end)

    task.spawn(function()
        while gui.Parent do
            local ok, controller = pcall(findController)
            if ok and controller then
                rapid.controller = controller
                rapid.ready = true
                rapid.message = "Готово"
                refreshRapid()
                return
            end
            task.wait(0.5)
        end
        rapid.message = "Контроллер не найден"
        refreshRapid()
        warn("[Rapid Fire] InventoryController не найден или недоступен в этом executor")
    end)
end

local function teamOf(character)
    if not character then return nil end
    local owner = Players:FindFirstChild(character.Name)
    local team = owner and owner:GetAttribute("Team")
    if team ~= nil then return team end
    local appearance = character:GetAttribute("CharacterName")
    if appearance ~= nil and appearance == Workspace:GetAttribute("CTCharacter") then
        return "Counter-Terrorists"
    elseif appearance ~= nil and appearance == Workspace:GetAttribute("TCharacter") then
        return "Terrorists"
    end
    return nil
end

local function isEnemy(character, ownCharacter, freeForAll, myTeam)
    if character == ownCharacter or character.Name == localPlayer.Name then return false end
    if not character:IsA("Model") or tostring(character:GetAttribute("Dead")) == "true" then return false end
    local owner = Players:FindFirstChild(character.Name)
    if not owner and character:GetAttribute("Health") == nil then return false end
    if config.teamCheck and not freeForAll then
        local otherTeam = teamOf(character)
        -- Не стреляем по неизвестной команде: лучше пропустить цель, чем выбрать союзника.
        if myTeam == nil or otherTeam == nil or myTeam == otherTeam then return false end
    end
    return true
end

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude

-- Автопробитие учитывает реальные расчёты игры и значение Penetration оружия.
-- Это выбор пробиваемой цели, а не обещание пробить любую поверхность.
local function tracePenetration(origin, target)
    local raylib, ignoreFn = state.wallRay, state.wallIgnore
    local controller = state.rapid and state.rapid.controller
    if not (raylib and ignoreFn and controller and target.Parent) then return false end
    local okWeapon, weapon = pcall(controller.peekCurrentEquippedForMovement)
    if not okWeapon or type(weapon) ~= "table" or type(weapon.Properties) ~= "table" then return false end
    local pen = tonumber(weapon.Properties.Penetration) or 0
    local delta = target.Position - origin
    local length = delta.Magnitude
    local range = tonumber(weapon.Properties.Range) or 500
    if pen <= 0 or length <= 0.01 or length > range then return false end
    local okIgnore, ignore = pcall(ignoreFn)
    if not okIgnore or type(ignore) ~= "table" then return false end
    local okHit, hit = pcall(raylib.cast, origin, delta, nil, ignore)
    if not okHit or type(hit) ~= "table" or not hit.instance or not hit.position then return false end
    if hit.instance:IsDescendantOf(target.Parent) then return true end
    local direction = delta.Unit
    local okThrough, hits = pcall(raylib.castThrough, hit.position - direction * 0.001, direction * (pen + 0.001), pen, ignore, target.Parent)
    if not okThrough or type(hits) ~= "table" then return false end
    for _, entry in ipairs(hits) do
        if entry.instance and entry.instance:IsDescendantOf(target.Parent) then return true end
    end
    return false
end

-- FOV 360°: враги сзади и вне экрана тоже рассматриваются; приоритет ближе к прицелу.
local history = setmetatable({}, {__mode = "k"})
local function updateMotion(part, now)
    local previous = history[part]
    local position = part.Position
    if previous then
        local dt = now - previous.time
        if dt > 0.005 and dt < 0.3 then
            local velocity = (position - previous.position) / dt
            if velocity.Magnitude <= 90 then
                previous.velocity = previous.velocity and (previous.velocity * 0.6 + velocity * 0.4) or velocity
            else
                previous.velocity = nil -- телепорт/резкое перемещение не предсказываем
            end
        else
            previous.velocity = nil
        end
        previous.position, previous.time = position, now
    else
        history[part] = {position = position, time = now}
    end
end
local function predictedPoint(part)
    local position = part.Position
    local sample = history[part]
    if not sample or not sample.velocity or os.clock() - sample.time > 0.3 then return position end
    local ok, ping = pcall(localPlayer.GetNetworkPing, localPlayer)
    local delay = math.clamp((ok and tonumber(ping) or 0.04) + 0.015, 0, 0.15)
    return position + sample.velocity * delay
end
-- Сканируем точки вокруг камеры, не проходя через препятствия от исходной точки.
-- Исключения те же, что у проверки видимости; это приближение, не копия Shitaro.
local function findShiftedOrigin(origin, target, camera)
    if config.originRadius <= 0 then return nil end
    local direction = target.Position - origin
    if direction.Magnitude < 0.01 then return nil end
    local right = direction.Unit:Cross(Vector3.new(0, 1, 0))
    if right.Magnitude < 0.01 then right = camera.CFrame.RightVector else right = right.Unit end
    local up = right:Cross(direction.Unit).Unit
    local offsets = {right, -right, up, -up, (right+up).Unit, (-right+up).Unit,
        (right-up).Unit, (-right-up).Unit, direction.Unit, -direction.Unit}
    for _, radius in ipairs({config.originRadius * 0.5, config.originRadius}) do
        for _, axis in ipairs(offsets) do
            local offset = axis * radius
            if not Workspace:Raycast(origin, offset, losParams) then
                local candidate = origin + offset
                if not Workspace:Raycast(candidate, target.Position-candidate, losParams) then return candidate end
            end
        end
    end
    return nil
end
local function selectTarget()
    local camera = Workspace.CurrentCamera
    local characters = Workspace:FindFirstChild("Characters")
    if not camera or not characters or tostring(localPlayer:GetAttribute("Dead")) == "true" then return nil end
    local ownCharacter = characters:FindFirstChild(localPlayer.Name) or localPlayer.Character
    if not ownCharacter or not ownCharacter.Parent then return nil end
    local origin, look = camera.CFrame.Position, camera.CFrame.LookVector
    local myTeam = localPlayer:GetAttribute("Team") or teamOf(ownCharacter)
    local freeForAll = string.find(tostring(Workspace:GetAttribute("Gamemode")), "Deathmatch", 1, true) ~= nil
    local best, bestDot = nil, -math.huge
    local now = os.clock()
    if config.visibilityCheck then
        local exclusions = {camera, characters}
        local debris = Workspace:FindFirstChild("Debris")
        local stash = Workspace:FindFirstChild("ThirdPersonWeaponStash")
        if debris then table.insert(exclusions, debris) end
        if stash then table.insert(exclusions, stash) end
        losParams.FilterDescendantsInstances = exclusions
    end
    for _, character in ipairs(characters:GetChildren()) do
        if isEnemy(character, ownCharacter, freeForAll, myTeam) then
            local part = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            local hp = tonumber(character:GetAttribute("Health"))
            if part and part:IsA("BasePart") and (not hp or hp > 0) then
                updateMotion(part, now)
                local delta = part.Position - origin
                local distance = delta.Magnitude
                if distance > 0.01 and distance <= config.maxDistance then
                    local score = look:Dot(delta.Unit)
                    if score > bestDot then
                        local blocked = config.visibilityCheck and Workspace:Raycast(origin, delta, losParams)
                        local reachable = not blocked
                        if blocked and state.extras.autoWall and state.wallReady then reachable = tracePenetration(origin, part) end
                        if blocked and not reachable and state.extras.forceOrigin and state.forceReady then
                            reachable = findShiftedOrigin(origin, part, camera) ~= nil
                        end
                        if reachable then best, bestDot = part, score end
                    end
                end
            end
        end
    end
    return best
end

RunService.Heartbeat:Connect(function()
    if not config.enabled or not state.ready then
        state.target = nil
        return
    end
    local ok, result = pcall(selectTarget)
    state.target = ok and result or nil
end)

-- Дополнительные переключатели меню.
local autoButton = makeToggle("AUTO SHOOT", 2)
local wallButton = makeToggle("AUTOWALL", 3)
local boxButton = makeToggle("ESP BOX", 4)
local namesButton = makeToggle("NAMES / HP", 5)
local outlineButton = makeToggle("OUTLINE", 6)
local teamButton = makeToggle("TEAM CHECK", 7)
local extras = state.extras
local originButton = makeToggle("FORCE ORIGIN", 8)
local autoReloadButton = makeToggle("AUTO RELOAD", 9)
local instaReloadButton = makeToggle("INSTA RELOAD", 10)
local boxStyleButton = makeToggle("BOX STYLE", 12)
local outlineStyleButton = makeToggle("OUTLINE STYLE", 13)
local chamsButton = makeToggle("CHAMS", 14)
local chamsStyleButton = makeToggle("CHAMS STYLE", 15)
local colorButton = makeToggle("ESP COLOR", 16)
local smokeButton = makeToggle("ANTI SMOKE", 17)
local flashButton = makeToggle("ANTI FLASH", 18)
local boxStyle, outlineStyle, chamsStyle, colorStyle = 2, 1, 1, 1
local boxNames = {"FULL", "CORNERS", "SOFT"}
local outlineNames = {"GLOW", "EDGE", "SOFT"}
local chamsNames = {"GLASS", "SOLID", "PULSE"}
local colorNames = {"MINT", "ROSE", "ICE"}
local colors = {
    {bright=Color3.fromRGB(113,255,222), fill=Color3.fromRGB(36,207,177)},
    {bright=Color3.fromRGB(255,138,175), fill=Color3.fromRGB(229,67,121)},
    {bright=Color3.fromRGB(138,201,255), fill=Color3.fromRGB(69,138,236)},
}
local function styleCard(item, title, value)
    item.Text = "   "..title
    local status = indicators[item].status
    status.Text, status.TextColor3 = value, Color3.fromRGB(209, 175, 244)
    status.Size = UDim2.fromOffset(62,18)
    status.Position = UDim2.new(1,-67,0.5,-9)
end
local function refreshStyles()
    styleCard(boxStyleButton, "BOX", boxNames[boxStyle])
    styleCard(outlineStyleButton, "OUTLINE", outlineNames[outlineStyle])
    styleCard(chamsStyleButton, "CHAMS", chamsNames[chamsStyle])
    styleCard(colorButton, "COLOR", colorNames[colorStyle])
end
boxStyleButton.MouseButton1Click:Connect(function() boxStyle = boxStyle % #boxNames + 1; refreshStyles() end)
outlineStyleButton.MouseButton1Click:Connect(function() outlineStyle = outlineStyle % #outlineNames + 1; refreshStyles() end)
chamsStyleButton.MouseButton1Click:Connect(function() chamsStyle = chamsStyle % #chamsNames + 1; refreshStyles() end)
colorButton.MouseButton1Click:Connect(function() colorStyle = colorStyle % #colorNames + 1; refreshStyles() end)
refreshStyles()

-- Ползунок Force Origin. AbsolutePosition/AbsoluteSize учитывают UIScale телефона.
local slider = Instance.new("Frame")
slider.Name, slider.BackgroundColor3, slider.BorderSizePixel = "OriginSlider", Color3.fromRGB(26,24,37), 0
slider.Size, slider.Position, slider.ZIndex = UDim2.fromOffset(279, 42), UDim2.fromOffset(129, 220), 12
slider.Parent = menu
round(slider, 8)
local sliderEdge = Instance.new("UIStroke")
sliderEdge.Color, sliderEdge.Transparency, sliderEdge.Parent = Color3.fromRGB(55,68,88), 0.35, slider
local sliderTitle = label(slider, "ORIGIN RADIUS", UDim2.fromOffset(170,14), UDim2.fromOffset(10,5), 9)
sliderTitle.TextColor3, sliderTitle.ZIndex = Color3.fromRGB(172,190,205), 13
local sliderValue = label(slider, "", UDim2.fromOffset(65,14), UDim2.new(1,-75,0,5), 9)
sliderValue.TextXAlignment, sliderValue.TextColor3, sliderValue.ZIndex = Enum.TextXAlignment.Right, Color3.fromRGB(221,189,255), 13
local track = Instance.new("Frame")
track.Name, track.BorderSizePixel, track.BackgroundColor3 = "Track", 0, Color3.fromRGB(45,58,73)
track.Position, track.Size, track.ZIndex, track.Parent = UDim2.fromOffset(12,28), UDim2.new(1,-24,0,4), 13, slider
round(track, 3)
local fill = Instance.new("Frame")
fill.BorderSizePixel, fill.BackgroundColor3, fill.ZIndex, fill.Parent = 0, Color3.fromRGB(174,131,231), 14, track
round(fill, 3)
local knob = Instance.new("Frame")
knob.AnchorPoint, knob.Size = Vector2.new(0.5,0.5), UDim2.fromOffset(13,13)
knob.BackgroundColor3, knob.BorderSizePixel, knob.ZIndex, knob.Parent = Color3.fromRGB(245,225,255), 0, 15, track
round(knob, 8)
local function redrawSlider()
    local ratio = config.originRadius/9
    fill.Size, knob.Position = UDim2.fromScale(ratio,1), UDim2.fromScale(ratio,0.5)
    sliderValue.Text = string.format("%.1f st", config.originRadius)
end
redrawSlider()
table.insert(entries, {group="COMBAT", button=slider})
slider.Visible = selectedTab == "COMBAT"
local sliderInput
local function sliderMove(input)
    local width = track.AbsoluteSize.X
    if width <= 0 then return end
    local ratio = math.clamp((input.Position.X-track.AbsolutePosition.X)/width, 0, 1)
    config.originRadius = math.floor(ratio*90+0.5)/10
    redrawSlider()
end
slider.Active = true
slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderInput = input
        sliderMove(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not sliderInput then return end
    if input == sliderInput or (sliderInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then sliderMove(input) end
end)
UserInputService.InputEnded:Connect(function(input)
    if sliderInput and (input == sliderInput or (sliderInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then sliderInput=nil end
end)


local function refreshExtras()
    showToggle(autoButton, "AUTO SHOOT", extras.autoShoot, false)
    showToggle(wallButton, "AUTOWALL", extras.autoWall, not state.wallReady)

    showToggle(boxButton, "ESP BOX", extras.box, false)
    showToggle(namesButton, "NAMES / HP", extras.names, false)
    showToggle(outlineButton, "OUTLINE", extras.outline, false)
    showToggle(teamButton, "TEAM CHECK", config.teamCheck, false)
    showToggle(originButton, "FORCE ORIGIN", extras.forceOrigin, not state.forceReady)
    showToggle(autoReloadButton, "AUTO RELOAD", extras.autoReload, false)
    showToggle(instaReloadButton, "INSTA RELOAD", extras.instaReload, extras.instaReload and not state.reloadReady)
    showToggle(chamsButton, "CHAMS", extras.chams, false)
    showToggle(smokeButton, "ANTI SMOKE", extras.antiSmoke, extras.antiSmoke and not state.smokeReady)
    showToggle(flashButton, "ANTI FLASH", extras.antiFlash, extras.antiFlash and not state.flashReady)
end

originButton.MouseButton1Click:Connect(function()
    if not state.forceReady then warn("[Force Origin] Внутренний метод пули недоступен") return end
    extras.forceOrigin = not extras.forceOrigin
    refreshExtras()
end)
autoReloadButton.MouseButton1Click:Connect(function()
    extras.autoReload = not extras.autoReload
    refreshExtras()
end)
instaReloadButton.MouseButton1Click:Connect(function()
    extras.instaReload = not extras.instaReload
    refreshExtras()
end)

autoButton.MouseButton1Click:Connect(function()
    extras.autoShoot = not extras.autoShoot
    if extras.autoShoot and not config.enabled then
        warn("[Auto Shoot] Включи SILENT: без него стрельба приостановлена")
    end
    refreshExtras()
end)
wallButton.MouseButton1Click:Connect(function()
    if not state.wallReady then
        warn("[Autowall] " .. (state.wallMessage or "Модули ещё не готовы"))
        return
    end
    extras.autoWall = not extras.autoWall
    refreshExtras()
end)
boxButton.MouseButton1Click:Connect(function() extras.box = not extras.box; refreshExtras() end)
namesButton.MouseButton1Click:Connect(function() extras.names = not extras.names; refreshExtras() end)
outlineButton.MouseButton1Click:Connect(function() extras.outline = not extras.outline; refreshExtras() end)
chamsButton.MouseButton1Click:Connect(function() extras.chams = not extras.chams; refreshExtras() end)
teamButton.MouseButton1Click:Connect(function() config.teamCheck = not config.teamCheck; refreshExtras() end)
refreshExtras()

task.spawn(function()
    while gui.Parent do
        local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
        local rayModule = sharedFolder and sharedFolder:FindFirstChild("Raycast")
        local components = ReplicatedStorage:FindFirstChild("Components")
        local common = components and components:FindFirstChild("Common")
        local ignoreModule = common and common:FindFirstChild("GetRayIgnore")
        if rayModule and ignoreModule then
            local ok1, ray = pcall(require, rayModule)
            local ok2, ignore = pcall(require, ignoreModule)
            if ok1 and type(ray) == "table" and type(ray.cast) == "function"
                and type(ray.castThrough) == "function" and ok2 and type(ignore) == "function" then
                state.wallRay, state.wallIgnore = ray, ignore
                state.wallReady = true
                state.wallMessage = "Готово"
                refreshExtras()
                return
            end
        end
        task.wait(0.5)
    end
    state.wallMessage = "Модули пробития недоступны"
    state.wallFailed = true
    warn("[Autowall] " .. state.wallMessage)
    refreshExtras()
end)

-- Auto Shoot вызывает обычную функцию оружия; без цели или Silent Aim не стреляет.
local nextAutoAttempt = 0
local lastAutoWarning = 0
RunService.Heartbeat:Connect(function()
    if not extras.autoShoot or not config.enabled or not state.ready or not state.target or not state.target.Parent then return end
    local controller = state.rapid and state.rapid.controller
    if not controller then return end
    local now = os.clock()
    if now < nextAutoAttempt then return end
    local ok, weapon = pcall(controller.peekCurrentEquippedForMovement)
    if not ok or type(weapon) ~= "table" or weapon.Player ~= localPlayer or weapon.IsDestroyed
        or weapon.IsReloading or weapon.IsShooting or type(weapon.shoot) ~= "function"
        or (tonumber(weapon.Rounds) or 1) <= 0 then return end
    local properties = weapon.Properties
    local modes = type(properties) == "table" and properties.FireModes
    local primary = type(modes) == "table" and modes.Primary
    local delay = tonumber(type(primary) == "table" and primary.FireRate)
        or tonumber(type(properties) == "table" and properties.FireRate) or 0.12
    if state.rapid.enabled then delay = 1 / state.rapid.shotsPerSecond end
    nextAutoAttempt = now + math.clamp(delay, 1 / 19, 2)
    local fired, err = pcall(weapon.shoot, weapon, "Primary")
    if not fired and now - lastAutoWarning > 3 then
        lastAutoWarning = now
        warn("[Auto Shoot] Ошибка выстрела: " .. tostring(err))
    end
end)

-- Auto Reload: обычная перезарядка при пустом магазине, не чаще раза в секунду.
local nextReload = 0
RunService.Heartbeat:Connect(function()
    if not extras.autoReload or os.clock() < nextReload then return end
    local controller = state.rapid and state.rapid.controller
    if not controller or type(controller.peekCurrentEquippedForMovement) ~= "function" then return end
    local ok, weapon = pcall(controller.peekCurrentEquippedForMovement)
    if not ok or type(weapon) ~= "table" or weapon.Player ~= localPlayer or weapon.IsDestroyed
        or weapon.IsReloading or tonumber(weapon.Rounds) ~= 0 or type(weapon.reload) ~= "function" then return end
    if (tonumber(weapon.Capacity) or 0) <= 0 and Workspace:GetAttribute("Gamemode") ~= "Deathmatch" then return end
    nextReload = os.clock() + 1
    local worked, err = pcall(weapon.reload, weapon)
    if not worked then warn("[Auto Reload] " .. tostring(err)) end
end)

-- Insta Reload: находим класс независимо от наличия оружия при запуске.
-- Пока класс или сеть недоступны, обычный reload не блокируется.
local function getModule(...)
    local node = ReplicatedStorage
    for _, name in ipairs({...}) do
        node = node and node:FindFirstChild(name)
        if not node then return nil end
    end
    if not node:IsA("ModuleScript") then return nil end
    local ok, result = pcall(require, node)
    if ok and type(result) == "table" then return result end
end
-- Objective: локальный ESP и автоматизация штатных взаимодействий C4.
-- Нет телепорта и мгновенного разминирования: время и проверка остаются у сервера.
do
    local collection = game:GetService("CollectionService")
    local http = game:GetService("HttpService")
    local controls = {esp=false, timer=false, plant=false, defuse=false}
    local ui = {
        esp=makeToggle("BOMB ESP", 20), timer=makeToggle("BOMB TIMER", 21),
        defuse=makeToggle("AUTO DEFUSE", 22), plant=makeToggle("AUTO PLANT", 23),
    }
    state.objective = controls
    local function packets()
        local net = state.net
        if not net then net=getModule("Database","Security","Remotes"); if net then state.net=net end end
        return net and net.C4
    end
    local function refreshObjective()
        showToggle(ui.esp, "BOMB ESP", controls.esp, false)
        showToggle(ui.timer, "BOMB TIMER", controls.timer, false)
        local p = packets()
        local available = p and p.StartDefuse and type(p.StartDefuse.Send)=="function" and p.Defused and type(p.Defused.Send)=="function"
        showToggle(ui.defuse, "AUTO DEFUSE", controls.defuse, controls.defuse and not available)
        showToggle(ui.plant, "AUTO PLANT", controls.plant, controls.plant and not (state.rapid and state.rapid.ready))
    end
    for key, item in pairs(ui) do
        item.MouseButton1Click:Connect(function()
            controls[key] = not controls[key]
            refreshObjective()
        end)
    end
    refreshObjective()

    -- Отдельный мировой маркер и HUD-таймер не зависят от включённого ESP игроков.
    local marker = Instance.new("TextLabel")
    marker.Name, marker.AnchorPoint = "NoirBombMarker", Vector2.new(0.5,1)
    marker.Size, marker.BackgroundTransparency, marker.BorderSizePixel = UDim2.fromOffset(180,32), 0.18, 0
    marker.BackgroundColor3, marker.TextColor3 = Color3.fromRGB(24,18,33), Color3.fromRGB(244,214,255)
    marker.Font, marker.TextSize, marker.ZIndex = Enum.Font.GothamBold, 11, 4
    marker.TextStrokeTransparency, marker.Visible, marker.Parent = 0.25, false, overlay
    round(marker,6)
    local markerEdge = Instance.new("UIStroke")
    markerEdge.Color, markerEdge.Transparency, markerEdge.Parent = Color3.fromRGB(167,113,213), 0.18, marker
    local hud = Instance.new("Frame")
    hud.Name, hud.AnchorPoint = "NoirBombTimer", Vector2.new(0.5,0)
    hud.Position, hud.Size = UDim2.new(0.5,0,0,64), UDim2.fromOffset(190,35)
    hud.BackgroundColor3, hud.BackgroundTransparency, hud.BorderSizePixel, hud.ZIndex = Color3.fromRGB(21,17,28), 0.08, 0, 4
    hud.Visible, hud.Parent = false, gui
    round(hud,8)
    local hudText = label(hud, "", UDim2.new(1,-18,1,-5), UDim2.fromOffset(9,1), 11)
    hudText.TextXAlignment, hudText.ZIndex = Enum.TextXAlignment.Center, 5
    local hudTrack = Instance.new("Frame")
    hudTrack.Size, hudTrack.Position = UDim2.new(1,-16,0,3), UDim2.new(0,8,1,-7)
    hudTrack.BackgroundColor3, hudTrack.BorderSizePixel, hudTrack.ZIndex, hudTrack.Parent = Color3.fromRGB(58,43,66), 0, 5, hud
    round(hudTrack,3)
    local hudFill = Instance.new("Frame")
    hudFill.BackgroundColor3, hudFill.BorderSizePixel, hudFill.ZIndex, hudFill.Parent = Color3.fromRGB(194,145,240), 0, 6, hudTrack
    round(hudFill,3)
    local cachedBomb, cachedDropped, nextScan = nil, nil, 0
    local function livePlanted(obj)
        return obj and obj:IsDescendantOf(Workspace) and obj:GetAttribute("BombPlanted") ~= nil
            and obj:GetAttribute("Defused") ~= true and obj:GetAttribute("Exploded") ~= true and obj:GetAttribute("Exploding") ~= true
    end
    local function scanBombs(now)
        if now < nextScan then return end
        nextScan = now + 0.35
        cachedBomb, cachedDropped = nil, nil
        for _, obj in ipairs(collection:GetTagged("Bomb")) do
            if livePlanted(obj) then cachedBomb=obj; break end
        end
        if not cachedBomb then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then for _, obj in ipairs(debris:GetChildren()) do
                if livePlanted(obj) then cachedBomb=obj; break end
            end end
        end
        if not cachedBomb and controls.esp then
            for _, obj in ipairs(collection:GetTagged("WeaponDropped")) do
                if obj:IsDescendantOf(Workspace) and obj:GetAttribute("Weapon") == "C4" then cachedDropped=obj; break end
            end
        end
    end
    local function positionOf(obj)
        if not obj then return nil end
        if obj:IsA("BasePart") then return obj.Position end
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then return part.Position end
            local ok, pivot = pcall(obj.GetPivot, obj)
            if ok and pivot then return pivot.Position end
        end
    end
    local rawSaved, timeData, rawOwner
    local function timerFor(bomb)
        local raw = bomb and bomb:GetAttribute("BombPlanted")
        if bomb ~= rawOwner or raw ~= rawSaved then
            rawOwner, rawSaved, timeData = bomb, raw, nil
            if type(raw)=="string" then
                local ok, decoded = pcall(http.JSONDecode, http, raw)
                if ok and type(decoded)=="table" then timeData=decoded end
            elseif type(raw)=="table" then timeData=raw end
        end
        local start = timeData and tonumber(timeData.Time)
        local duration = timeData and tonumber(timeData.TimeUntilExplode)
        if not start or not duration or start ~= start or duration ~= duration or math.abs(start)==math.huge or duration<=0 or duration==math.huge then return nil,nil end
        local ok, now = pcall(Workspace.GetServerTimeNow, Workspace)
        if not ok or type(now)~="number" then return nil,nil end
        return math.max(0,start+duration-now), duration
    end
    local function renderObjective()
        local camera, bomb = Workspace.CurrentCamera, cachedBomb
        if bomb and not livePlanted(bomb) then bomb=nil end
        local remaining, duration = timerFor(bomb)
        hud.Visible = controls.timer and bomb ~= nil
        if hud.Visible then
            hudText.Text = remaining and string.format("BOMB  /  %.1f s",remaining) or "BOMB  /  TIME UNKNOWN"
            hudFill.Size = UDim2.fromScale(remaining and math.clamp(remaining/duration,0,1) or 0,1)
            hudFill.BackgroundColor3 = remaining and remaining < 10 and Color3.fromRGB(255,105,131) or Color3.fromRGB(194,145,240)
        end
        local obj = bomb or cachedDropped
        local pos = positionOf(obj)
        marker.Visible = false
        if controls.esp and camera and pos then
            local screen, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen and screen.Z > 0 then
                local dist = math.floor((pos-camera.CFrame.Position).Magnitude)
                marker.Text = bomb and (remaining and controls.timer and string.format("C4  /  %.1fs  ·  %d st",remaining,dist) or "C4  /  PLANTED  ·  "..dist.." st") or "C4  /  DROPPED  ·  "..dist.." st"
                marker.Position = UDim2.fromOffset(screen.X,screen.Y-8)
                marker.Visible = true
            end
        end
    end
    local ray = RaycastParams.new()
    ray.FilterType, ray.IgnoreWater = Enum.RaycastFilterType.Exclude, true
    local plantNext = 0
    local function aliveCharacter()
        local chars = Workspace:FindFirstChild("Characters")
        local character = (chars and chars:FindFirstChild(localPlayer.Name)) or localPlayer.Character
        if not character or not character.Parent or character:GetAttribute("Dead")==true then return nil end
        local health = tonumber(character:GetAttribute("Health"))
        if health and health<=0 then return nil end
        return character
    end
    local function doPlant(now)
        if not controls.plant or now < plantNext or livePlanted(cachedBomb) or localPlayer:GetAttribute("Team") ~= "Terrorists" then return end
        local character = aliveCharacter()
        local root = character and (character.PrimaryPart or character:FindFirstChild("HumanoidRootPart"))
        local controller = state.rapid and state.rapid.controller
        local getter = controller and controller.peekCurrentEquippedForMovement
        if not root or type(getter)~="function" then return end
        local ok, weapon = pcall(getter)
        if not ok or type(weapon)~="table" or not weapon.Properties or weapon.Properties.Class~="C4"
            or weapon.IsDestroyed or weapon.IsPlanting or type(weapon.shoot)~="function" then return end
        if tick()-(tonumber(weapon.PlantStartedTick) or 0)<0.55 then return end
        local ignored = {character}
        if Workspace.CurrentCamera then table.insert(ignored,Workspace.CurrentCamera) end
        local debris = Workspace:FindFirstChild("Debris")
        if debris then table.insert(ignored,debris) end
        ray.FilterDescendantsInstances = ignored
        local hit = Workspace:Raycast(root.Position,Vector3.new(0,-5,0),ray)
        local part = hit and hit.Instance
        if not part or not collection:HasTag(part,"PlantArea") or part:GetAttribute("Site")==nil then return end
        plantNext=now+0.7
        pcall(weapon.shoot,weapon)
    end
    local defuse = {phase="idle", session=0, lastStart=0, lastFinish=0}
    local function stopDefuse(send)
        if defuse.phase=="idle" then return end
        if send then
            local p = packets()
            if p and p.CancelDefuse and type(p.CancelDefuse.Send)=="function" then pcall(p.CancelDefuse.Send,{SessionId=defuse.session}) end
        end
        pcall(localPlayer.SetAttribute,localPlayer,"IsLocallyDefusingBomb",nil)
        defuse.phase, defuse.bomb = "idle", nil
    end
    local function nextSession()
        -- Синхронизируем счётчик штатного DefuseBomb.StartDefuse, если executor даёт доступ.
        local module = getModule("Interface","Screens","Gameplay","Middle","DefuseBomb")
        local fn = module and module.StartDefuse
        local getter = getupvalues or (debug and debug.getupvalues)
        local setter = setupvalue or (debug and debug.setupvalue)
        if type(fn)=="function" and type(getter)=="function" and type(setter)=="function" then
            local ok, values = pcall(getter,fn)
            if ok and type(values)=="table" then
                local index, value, count = nil, 0, 0
                for k,v in pairs(values) do if type(v)=="number" then index,value,count=k,v,count+1 end end
                if count==1 then
                    defuse.session=(math.floor(math.max(value,defuse.session)) % 4294967295)+1
                    pcall(setter,fn,index,defuse.session)
                    return defuse.session
                end
            end
        end
        defuse.session=(defuse.session % 4294967295)+1
        return defuse.session
    end
    local function doDefuse(now)
        if not controls.defuse then stopDefuse(true); return end
        local character = aliveCharacter()
        local root = character and (character.PrimaryPart or character:FindFirstChild("HumanoidRootPart"))
        local bomb = cachedBomb
        local position = livePlanted(bomb) and positionOf(bomb) or nil
        local p = packets()
        local canSend = p and p.StartDefuse and type(p.StartDefuse.Send)=="function" and p.Defused and type(p.Defused.Send)=="function"
        if not controls.defuse or localPlayer:GetAttribute("Team")~="Counter-Terrorists" or not root or not position or not canSend
            or (root.Position-position).Magnitude>5.2 or (defuse.bomb and defuse.bomb~=bomb) then
            stopDefuse(true); return
        end
        local ack = localPlayer:GetAttribute("IsDefusingBomb")==true
        if defuse.phase=="idle" then
            if ack or localPlayer:GetAttribute("IsLocallyDefusingBomb")==true or bomb:GetAttribute("IsGettingDefused")==true or now-defuse.lastStart<1.5 then return end
            for _, player in ipairs(Players:GetPlayers()) do
                if player~=localPlayer and player:GetAttribute("IsDefusingBomb")==true then return end
            end
            defuse.session=nextSession()
            defuse.phase, defuse.bomb, defuse.lastStart = "starting", bomb, now
            pcall(localPlayer.SetAttribute,localPlayer,"IsLocallyDefusingBomb",true)
            local sent, response = pcall(p.StartDefuse.Send,{SessionId=defuse.session})
            if not sent or response==false then stopDefuse(false) end
            return
        end
        if defuse.phase=="starting" then
            if ack then defuse.phase="active"; defuse.acked=now
            elseif now-defuse.lastStart>1.5 then stopDefuse(true) end
            return
        end
        if not ack then stopDefuse(false); return end
        local total = localPlayer:GetAttribute("HasDefuseKit")==true and 5 or 10
        local started = tonumber(localPlayer:GetAttribute("DefuseStartTime"))
        local ok, serverNow = pcall(Workspace.GetServerTimeNow,Workspace)
        local elapsed = now-(defuse.acked or now)
        if ok and started and started<=serverNow and serverNow-started<=total+5 then elapsed=serverNow-started end
        if elapsed>=total+0.05 and now-defuse.lastFinish>=0.5 then
            defuse.lastFinish=now
            pcall(p.Defused.Send)
        end
    end
    local last, lastWarning, nextUiRefresh = 0, 0, 0
    RunService.Heartbeat:Connect(function()
        local now=os.clock()
        if now-last<0.1 then return end
        last=now
        local ok, err=pcall(function()
            if controls.esp or controls.timer or controls.defuse or controls.plant then scanBombs(now) end
            renderObjective(); doPlant(now); doDefuse(now)
            if now >= nextUiRefresh then nextUiRefresh=now+1; refreshObjective() end
        end)
        if not ok and now-lastWarning>5 then lastWarning=now; warn("[NOIR / Objective] "..tostring(err)) end
    end)
end


-- Удаляем только локальные визуальные эффекты; на серверное состояние гранат не влияет.
local effectModules = {}
local function cancelExisting(kind)
    local module = effectModules[kind]
    if not module then return end
    if kind == "flash" and type(module.CancelFlash) == "function" then pcall(module.CancelFlash) end
    if kind == "smoke" and type(module.DestroyAll) == "function" then pcall(module.DestroyAll) end
end
smokeButton.MouseButton1Click:Connect(function()
    extras.antiSmoke = not extras.antiSmoke
    if extras.antiSmoke then cancelExisting("smoke") end
    refreshExtras()
end)
flashButton.MouseButton1Click:Connect(function()
    extras.antiFlash = not extras.antiFlash
    if extras.antiFlash then cancelExisting("flash") end
    refreshExtras()
end)
local function installEffect(module, method, flag, blockedReturn)
    local fn = module and module[method]
    if type(fn) ~= "function" then return false end
    -- hookfunction перехватывает и сохранённые ссылки; если недоступен, меняем поле модуля.
    local hookFn = hookfunction or replaceclosure
    if type(hookFn) == "function" then
        local previous
        local ok, result = pcall(function()
            return hookFn(fn, function(...)
                if extras[flag] then return blockedReturn end
                return previous(...)
            end)
        end)
        if ok and type(result) == "function" then previous = result; return true end
    end
    local wrapped = function(...)
        if extras[flag] then return blockedReturn end
        return fn(...)
    end
    local ok = pcall(function() module[method] = wrapped end)
    return ok and module[method] == wrapped
end
task.spawn(function()
    while gui.Parent and not (state.smokeReady and state.flashReady) do
        if not state.smokeReady then
            local module = getModule("Components", "Common", "VFXLibary", "CreateVoxelSmoke")
            if module and installEffect(module, "Create", "antiSmoke", nil) then
                state.smokeReady, effectModules.smoke = true, module
                if extras.antiSmoke then cancelExisting("smoke") end
            end
        end
        if not state.flashReady then
            local module = getModule("Components", "Common", "VFXLibary", "FlashEffect")
            if module and installEffect(module, "Flash", "antiFlash", false) then
                state.flashReady, effectModules.flash = true, module
                if extras.antiFlash then cancelExisting("flash") end
            end
        end
        refreshExtras()
        task.wait(2)
    end
end)

local function tryInstantReload(w)
    local inventory = state.net and state.net.Inventory
    local packet = inventory and inventory.ReloadWeapon
    local props = type(w) == "table" and w.Properties
    if not packet or type(packet.Send) ~= "function" or type(props) ~= "table"
        or w.IsDestroyed or w.IsEquipped ~= true or w.IsReloading or w.IsAdjustingSuppressor
        or props.Class ~= "Weapon" or props.RechargeTime or type(w.Identifier) ~= "string" then return false end
    if w.Player and w.Player ~= localPlayer then return false end
    if not w.Player then
        local ctrl = state.rapid and state.rapid.controller
        local getter = ctrl and ctrl.peekCurrentEquippedForMovement
        if type(getter) ~= "function" then return false end
        local ok, equipped = pcall(getter)
        if not ok or equipped ~= w then return false end
    end
    local maxRounds, rounds, reserve = tonumber(props.Rounds), tonumber(w.Rounds), tonumber(w.Capacity)
    local dm = Workspace:GetAttribute("Gamemode") == "Deathmatch"
    if not maxRounds or not rounds or not reserve or rounds >= maxRounds or (reserve <= 0 and not dm) then return false end
    if w.IsChargeFiring and type(w.cancelRevolverCharge) == "function" then pcall(w.cancelRevolverCharge, w, false, false) end
    local create = inventory.CreateMagazine
    if create and type(create.Send) == "function" then pcall(create.Send, w.Identifier) end
    local sent, response = pcall(packet.Send, {Identifier = w.Identifier, Rounds = rounds, Capacity = reserve})
    if not sent or response == false then return false end
    if dm and tonumber(props.ReloadAnimationCount) == 1 then
        w.Rounds, w.Capacity = maxRounds, tonumber(props.Capacity) or reserve
    else
        local loaded = math.min(maxRounds - rounds, reserve)
        w.Rounds, w.Capacity = rounds + loaded, math.max(0, reserve - loaded)
    end
    w.CurrentReloadIdentity, w.IsReloading, w.IsShooting, w.CurrentWalkSpeedOverride = nil, false, false, nil
    local connection = rawget(w, "ReloadTrackFinishedConnection")
    if connection then pcall(connection.Disconnect, connection); w.ReloadTrackFinishedConnection = nil end
    if type(w.stopAllAnimations) == "function" then pcall(w.stopAllAnimations, w) end
    return true
end
local function installReload(class)
    local original = class and class.reload
    if type(original) ~= "function" then return false end
    local wrapped = function(w, ...)
        if extras.instaReload then
            local ok, done = pcall(tryInstantReload, w)
            if ok and done then return end
        end
        return original(w, ...)
    end
    -- Замена метода класса охватывает ручную кнопку и Auto Reload.
    local changed = pcall(function() class.reload = wrapped end)
    if changed and class.reload == wrapped then return true end
    local hookReload = hookfunction or replaceclosure
    if type(hookReload) ~= "function" then return false end
    local old
    local ok, result = pcall(function()
        return hookReload(original, function(w, ...)
            if extras.instaReload then
                local success, done = pcall(tryInstantReload, w)
                if success and done then return end
            end
            return old(w, ...)
        end)
    end)
    if ok and type(result) == "function" then old = result; return true end
    return false
end
task.spawn(function()
    local installed = false
    while gui.Parent do
        if not state.net then state.net = getModule("Database", "Security", "Remotes") end
        if not installed then
            local class = getModule("Components", "Weapon")
            if class then installed = installReload(class) end
        end
        local inventory = state.net and state.net.Inventory
        state.reloadReady = installed and inventory and inventory.ReloadWeapon and type(inventory.ReloadWeapon.Send) == "function" or false
        state.reloadFailed = not state.reloadReady
        refreshExtras()
        task.wait(2)
    end
end)

-- ESP по отдельным частям тела, без оружия и аксессуаров в размер рамки.
local esp = {}
local bodyNames = {"Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
local function removeEntry(model)
    local entry = esp[model]
    if not entry then return end
    entry.box:Destroy(); entry.shadow:Destroy(); entry.caption:Destroy(); entry.distance:Destroy(); entry.hpText:Destroy(); entry.healthBack:Destroy()
    if entry.highlight then entry.highlight:Destroy() end
    esp[model] = nil
end
local function entryFor(model)
    if esp[model] then return esp[model] end
    local box = Instance.new("Frame")
    box.Name, box.BackgroundTransparency, box.BorderSizePixel, box.Visible, box.ZIndex = "EnemyBox", 1, 0, false, 2
    box.Parent = overlay
    local shadow = Instance.new("Frame")
    shadow.Name, shadow.BackgroundTransparency, shadow.BorderSizePixel, shadow.ZIndex = "BoxShadow", 1, 0, 1
    shadow.Parent = overlay
    local shadowStroke = Instance.new("UIStroke")
    shadowStroke.Color, shadowStroke.Thickness, shadowStroke.Transparency, shadowStroke.Parent = Color3.fromRGB(2,7,12), 3, 0.18, shadow
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness, stroke.Parent = Color3.fromRGB(106, 233, 208), 1.3, box
    local corners = {}
    for i = 1, 8 do
        local bar = Instance.new("Frame")
        bar.Name, bar.BackgroundColor3, bar.BorderSizePixel, bar.ZIndex = "Corner"..i, Color3.fromRGB(106,233,208), 0, 3
        bar.Parent = box
        local blackEdge = Instance.new("UIStroke")
        blackEdge.Color, blackEdge.Thickness, blackEdge.Transparency, blackEdge.Parent = Color3.fromRGB(1,8,12), 1, 0.2, bar
        corners[i] = bar
    end
    local caption = Instance.new("TextLabel")
    caption.Name = "EnemyInfo"
    caption.AnchorPoint = Vector2.new(0.5, 1)
    caption.Size = UDim2.fromOffset(220, 18)
    caption.BackgroundTransparency = 1
    caption.TextColor3 = Color3.fromRGB(239, 255, 252)
    caption.TextStrokeTransparency = 0.12
    caption.Font, caption.TextSize, caption.Visible, caption.ZIndex = Enum.Font.GothamBold, 11, false, 3
    caption.Parent = overlay
    local distance = Instance.new("TextLabel")
    distance.Name, distance.AnchorPoint = "EnemyDistance", Vector2.new(0.5, 0)
    distance.Size, distance.BackgroundTransparency = UDim2.fromOffset(110, 15), 1
    distance.TextColor3, distance.TextStrokeTransparency = Color3.fromRGB(211, 228, 235), 0.15
    distance.Font, distance.TextSize, distance.Visible, distance.ZIndex = Enum.Font.GothamBold, 10, false, 3
    distance.Parent = overlay
    local hpText = Instance.new("TextLabel")
    hpText.Name, hpText.AnchorPoint = "EnemyHealth", Vector2.new(1, 0.5)
    hpText.Size, hpText.BackgroundTransparency = UDim2.fromOffset(35, 14), 1
    hpText.TextColor3, hpText.TextStrokeTransparency = Color3.fromRGB(225,255,235), 0.1
    hpText.TextXAlignment, hpText.Font, hpText.TextSize, hpText.ZIndex = Enum.TextXAlignment.Right, Enum.Font.GothamBold, 9, 3
    hpText.Visible, hpText.Parent = false, overlay
    local healthBack = Instance.new("Frame")
    healthBack.Name = "HealthBack"
    healthBack.BackgroundColor3 = Color3.fromRGB(12, 18, 24)
    healthBack.BorderSizePixel, healthBack.Visible, healthBack.ZIndex = 0, false, 2
    healthBack.Parent = overlay
    local healthFill = Instance.new("Frame")
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.Position = UDim2.fromScale(0, 1)
    healthFill.BorderSizePixel, healthFill.ZIndex = 0, 3
    healthFill.Parent = healthBack
    local entry = {box = box, shadow = shadow, stroke = stroke, corners = corners, caption = caption, distance = distance, hpText = hpText, healthBack = healthBack, healthFill = healthFill}
    esp[model] = entry
    return entry
end
local function boundsOnScreen(camera, model)
    local anchor = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    if not anchor or not anchor:IsA("BasePart") then return nil end
    local anchorPos = anchor.Position
    local minX, minY, maxX, maxY
    local headMin, headMax
    for _, name in ipairs(bodyNames) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") and (part.Position - anchorPos).Magnitude < 12 and part.Size.Magnitude < 20 then
            for _, x in ipairs({-1, 1}) do
                for _, y in ipairs({-1, 1}) do
                    for _, z in ipairs({-1, 1}) do
                        local position = part.CFrame * Vector3.new(part.Size.X*x/2, part.Size.Y*y/2, part.Size.Z*z/2)
                        local screen = camera:WorldToViewportPoint(position)
                        if screen.Z > 0.1 then
                            minX=math.min(minX or screen.X,screen.X); maxX=math.max(maxX or screen.X,screen.X)
                            minY=math.min(minY or screen.Y,screen.Y); maxY=math.max(maxY or screen.Y,screen.Y)
                            if part == anchor then
                                headMin=math.min(headMin or screen.Y,screen.Y)
                                headMax=math.max(headMax or screen.Y,screen.Y)
                            end
                        end
                    end
                end
            end
        end
    end
    if not minX or not headMin then return nil end
    -- Отсекаем аномально далёкие части даже при повреждённой модели.
    local anchorScreen = camera:WorldToViewportPoint(anchorPos)
    local headHeight = math.max(2, headMax - headMin)
    local maxWidth, maxHeight = math.max(12,headHeight*5), math.max(20,headHeight*8)
    minX, maxX = math.max(minX,anchorScreen.X-maxWidth/2), math.min(maxX,anchorScreen.X+maxWidth/2)
    minY, maxY = math.max(minY,headMin-headHeight), math.min(maxY,headMin+maxHeight)
    local viewport = camera.ViewportSize
    if maxX < 0 or maxY < 0 or minX > viewport.X or minY > viewport.Y then return nil end
    minX, maxX = math.clamp(minX,0,viewport.X), math.clamp(maxX,0,viewport.X)
    minY, maxY = math.clamp(minY,0,viewport.Y), math.clamp(maxY,0,viewport.Y)
    if maxX-minX < 2 or maxY-minY < 2 then return nil end
    return minX, minY, maxX-minX, maxY-minY
end
local function updateEsp()
    local camera, characters = Workspace.CurrentCamera, Workspace:FindFirstChild("Characters")
    if not (extras.box or extras.names or extras.outline or extras.chams) or not camera or not characters then
        for model in pairs(esp) do removeEntry(model) end
        return
    end
    local own = characters:FindFirstChild(localPlayer.Name) or localPlayer.Character
    local myTeam = localPlayer:GetAttribute("Team") or teamOf(own)
    local ffa = string.find(tostring(Workspace:GetAttribute("Gamemode")), "Deathmatch", 1, true) ~= nil
    local seen = {}
    for _, model in ipairs(characters:GetChildren()) do
        if isEnemy(model, own, ffa, myTeam) then
            local hp = tonumber(model:GetAttribute("Health"))
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if not hp and humanoid then hp = humanoid.Health end
            local maxHp = tonumber(model:GetAttribute("MaxHealth")) or (humanoid and humanoid.MaxHealth) or 100
            if not hp or hp > 0 then
                seen[model] = true
                local entry = entryFor(model)
                if extras.outline or extras.chams then
                    if not entry.highlight then
                        local h = Instance.new("Highlight")
                        h.Name, h.DepthMode = "EnemyOutline", Enum.HighlightDepthMode.AlwaysOnTop
                        h.FillColor, h.OutlineColor = Color3.fromRGB(58,170,158), Color3.fromRGB(120,245,223)
                        h.FillTransparency, h.OutlineTransparency = 0.88, 0
                        h.Adornee, h.Parent = model, gui
                        entry.highlight = h
                    end
                    local color = colors[colorStyle]
                    entry.highlight.Enabled = true
                    entry.highlight.FillColor, entry.highlight.OutlineColor = color.fill, color.bright
                    if extras.chams then
                        entry.highlight.FillTransparency = chamsStyle == 1 and 0.65 or (chamsStyle == 2 and 0.28 or 0.48 + math.sin(os.clock()*2.5)*0.12)
                    else
                        entry.highlight.FillTransparency = 1
                    end
                    entry.highlight.OutlineTransparency = not extras.outline and 1 or (outlineStyle == 1 and 0 or (outlineStyle == 2 and 0.18 or 0.48))
                elseif entry.highlight then entry.highlight.Enabled = false end
                local x,y,w,h = boundsOnScreen(camera,model)
                entry.box.Visible = extras.box and x ~= nil
                entry.shadow.Visible = extras.box and boxStyle ~= 2 and x ~= nil
                entry.caption.Visible = extras.names and x ~= nil
                entry.distance.Visible = extras.names and x ~= nil
                entry.hpText.Visible = extras.names and x ~= nil and hp ~= nil
                entry.healthBack.Visible = extras.names and x ~= nil and hp ~= nil
                if x then
                    entry.box.Position,entry.box.Size = UDim2.fromOffset(x,y),UDim2.fromOffset(w,h)
                    entry.shadow.Position,entry.shadow.Size = entry.box.Position,entry.box.Size
                    local color = colors[colorStyle]
                    entry.stroke.Color = color.bright
                    entry.stroke.Enabled = boxStyle ~= 2
                    entry.stroke.Transparency = boxStyle == 3 and 0.42 or 0
                    entry.box.BackgroundColor3 = color.fill
                    entry.box.BackgroundTransparency = boxStyle == 3 and 0.91 or 1
                    local cw, ch = math.max(4, math.floor(w*0.25)), math.max(4, math.floor(h*0.20))
                    local positions = {{0,0,cw,2},{0,0,2,ch},{w-cw,0,cw,2},{w-2,0,2,ch},
                        {0,h-2,cw,2},{0,h-ch,2,ch},{w-cw,h-2,cw,2},{w-2,h-ch,2,ch}}
                    for i, bar in ipairs(entry.corners) do
                        local q = positions[i]
                        bar.Visible = boxStyle == 2
                        bar.BackgroundColor3 = color.bright
                        bar.Position, bar.Size = UDim2.fromOffset(q[1],q[2]), UDim2.fromOffset(q[3],q[4])
                    end
                    entry.caption.Position = UDim2.fromOffset(x+w/2,y-3)
                    entry.caption.TextColor3 = color.bright
                    entry.healthBack.Position,entry.healthBack.Size = UDim2.fromOffset(x-7,y-1),UDim2.fromOffset(4,h+2)
                    if hp then
                        local ratio = math.clamp(hp / math.max(1, maxHp),0,1)
                        entry.healthFill.Size = UDim2.fromScale(1,ratio)
                        entry.healthFill.BackgroundColor3 = Color3.fromRGB(math.floor(230*(1-ratio)),math.floor(185*ratio+50),70)
                    end
                    local head = model:FindFirstChild("Head")
                    local distance = head and math.floor((head.Position-camera.CFrame.Position).Magnitude) or 0
                    entry.caption.Text = model.Name
                    entry.distance.Position = UDim2.fromOffset(x+w/2,y+h+3)
                    entry.distance.Text = tostring(distance).." st"
                    if hp then
                        entry.hpText.Text = tostring(math.floor(hp))
                        entry.hpText.Position = UDim2.fromOffset(x-9, y+h*(1-math.clamp(hp/math.max(1,maxHp),0,1)))
                    end
                end
            end
        end
    end
    for model in pairs(esp) do if not seen[model] then removeEntry(model) end end
end
local lastEsp, espWarnAt = 0, 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now-lastEsp < 0.05 then return end
    lastEsp = now
    local ok, err = pcall(updateEsp)
    if not ok and now-espWarnAt > 5 then espWarnAt=now; warn("[ESP] "..tostring(err)) end
end)

-- Последняя страховка, если отправка пакета не состоялась.
RunService:BindToRenderStep("IndependentSilentRestore", Enum.RenderPriority.First.Value, restoreCamera)

-- Заставка — локальная анимация интерфейса, а не индикатор готовности сетевых функций.
do
    local tweenService = game:GetService("TweenService")
    local splash = Instance.new("Frame")
    splash.Name, splash.AnchorPoint = "NoirIntro", Vector2.new(0.5,0.5)
    splash.Position, splash.Size = UDim2.fromScale(0.5,0.5), UDim2.fromOffset(300,180)
    splash.BackgroundColor3, splash.BorderSizePixel, splash.ZIndex = Color3.fromRGB(12,10,19), 0, 30
    splash.Parent = gui
    round(splash,14)
    local stroke = Instance.new("UIStroke")
    stroke.Color, stroke.Thickness, stroke.Transparency, stroke.Parent = Color3.fromRGB(131,99,171), 1, 0.2, splash
    local introScale = Instance.new("UIScale")
    introScale.Scale, introScale.Parent = menuScale.Scale, splash
    local line = Instance.new("Frame")
    line.Size, line.Position = UDim2.fromOffset(48,2), UDim2.new(0.5,-24,0,25)
    line.BackgroundColor3, line.BorderSizePixel, line.ZIndex, line.Parent = Color3.fromRGB(191,145,242), 0, 31, splash
    round(line,2)
    local word = label(splash, "N O I R", UDim2.new(1,0,0,41), UDim2.fromOffset(0,38), 28)
    word.TextXAlignment, word.TextColor3, word.ZIndex = Enum.TextXAlignment.Center, Color3.fromRGB(244,237,255), 31
    local creator = label(splash, "C R E A T O R", UDim2.new(1,0,0,18), UDim2.fromOffset(0,79), 9)
    creator.TextXAlignment, creator.TextColor3, creator.ZIndex = Enum.TextXAlignment.Center, Color3.fromRGB(177,148,207), 31
    local loading = label(splash, "INITIALISING INTERFACE", UDim2.new(1,-48,0,16), UDim2.fromOffset(24,119), 8)
    loading.TextColor3, loading.ZIndex = Color3.fromRGB(154,142,170), 31
    local percent = label(splash, "0%", UDim2.fromOffset(42,16), UDim2.new(1,-66,0,119), 8)
    percent.TextXAlignment, percent.TextColor3, percent.ZIndex = Enum.TextXAlignment.Right, Color3.fromRGB(205,171,240), 31
    local track = Instance.new("Frame")
    track.Position, track.Size = UDim2.fromOffset(24,144), UDim2.new(1,-48,0,4)
    track.BackgroundColor3, track.BorderSizePixel, track.ZIndex, track.Parent = Color3.fromRGB(54,43,68), 0, 31, splash
    round(track,3)
    local fill = Instance.new("Frame")
    fill.Size, fill.BackgroundColor3, fill.BorderSizePixel, fill.ZIndex, fill.Parent = UDim2.fromScale(0,1), Color3.fromRGB(190,140,242), 0, 32, track
    round(fill,3)
    task.spawn(function()
        local function animate(obj, seconds, props)
            local ok, tween = pcall(tweenService.Create,tweenService,obj,TweenInfo.new(seconds,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
            if ok and tween then tween:Play() else for k,v in pairs(props) do obj[k]=v end end
        end
        local introFull = introScale.Scale
        introScale.Scale = introFull * 0.94
        animate(introScale,0.3,{Scale=introFull})
        for _, stage in ipairs({{0.28,"PREPARING INTERFACE"},{0.64,"CONNECTING CONTROLS"},{1,"INTERFACE READY"}}) do
            loading.Text, percent.Text = stage[2], tostring(math.floor(stage[1]*100)).."%"
            animate(fill,0.38,{Size=UDim2.fromScale(stage[1],1)})
            task.wait(0.45)
        end
        task.wait(0.2)
        animate(splash,0.23,{BackgroundTransparency=1})
        animate(stroke,0.23,{Transparency=1})
        animate(introScale,0.23,{Scale=introFull*0.96})
        for _, text in ipairs({word,creator,loading,percent}) do animate(text,0.23,{TextTransparency=1}) end
        for _, part in ipairs({line,track,fill}) do animate(part,0.23,{BackgroundTransparency=1}) end
        task.wait(0.25)
        splash.Visible = false
        menu.Visible = true
        local full = menuScale.Scale
        menuScale.Scale = full*0.93
        animate(menuScale,0.3,{Scale=full})
        splash:Destroy()
    end)
end


local hook = hookfunction or replaceclosure
if type(hook) ~= "function" or type(getgc) ~= "function" then
    state.message = "Нет hookfunction/getgc"
    refreshButton()
    warn("[Silent Aim] Executor не поддерживает hookfunction или getgc")
    return
end

local function lookupNetworkSend()
    local database = ReplicatedStorage:FindFirstChild("Database")
    local security = database and database:FindFirstChild("Security")
    local module = security and security:FindFirstChild("Remotes")
    if not module or not module:IsA("ModuleScript") then return nil end
    local ok, net = pcall(require, module)
    if not ok or type(net) ~= "table" then return nil end
    state.net = net
    local packet = net.Inventory and net.Inventory.ShootWeapon
    return packet and type(packet.Send) == "function" and packet.Send or nil
end

local function findBulletClass()
    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then return nil end
    for _, item in ipairs(objects) do
        if type(item) == "table"
            and type(rawget(item, "create")) == "function"
            and type(rawget(item, "getTrueSpread")) == "function"
            and type(rawget(item, "getSpreadForConfig")) == "function"
        then
            return item
        end
    end
    return nil
end

local function redirectCamera()
    local target, camera = state.target, Workspace.CurrentCamera
    if not config.enabled or not target or not target.Parent or not camera then return end
    local ok, position = pcall(predictedPoint, target)
    if not ok then return end
    local origin = camera.CFrame.Position
    if (position - origin).Magnitude < 0.001 then return end
    if not state.savedView then
        state.camera = camera
        state.savedView = camera.CFrame
    end
    camera.CFrame = CFrame.lookAt(origin, position)
    state.redirected = true
end

local function install(bullet, sendFunction)
    -- Сначала ставим возврат вида; до полного завершения установки enabled=false.
    local previousSend
    local ok, result = pcall(function()
        return hook(sendFunction, function(...)
            restoreCamera()
            return previousSend(...)
        end)
    end)
    if not ok or type(result) ~= "function" then return false, "Не удалось перехватить Send" end
    previousSend = result

    local previousCreate
    ok, result = pcall(function()
        return hook(bullet.create, function(...)
            if config.enabled then pcall(redirectCamera) end
            local resultPack = table.pack(pcall(previousCreate, ...))
            if not resultPack[1] then
                restoreCamera()
                error(resultPack[2], 0)
            end
            return table.unpack(resultPack, 2, resultPack.n)
        end)
    end)
    if not ok or type(result) ~= "function" then return false, "Не удалось перехватить create" end
    previousCreate = result

    -- Force Origin: проверяем локальную точку и траекторию заново непосредственно при выстреле.
    if type(bullet._performRaycast) == "function" then
        local previousRay
        local good, old = pcall(function()
            return hook(bullet._performRaycast, function(...)
                local camera, target = Workspace.CurrentCamera, state.target
                if not (extras.forceOrigin and config.enabled and state.redirected and camera and target and target.Parent) then
                    return previousRay(...)
                end
                local oldView = camera.CFrame
                local okPoint, aim = pcall(predictedPoint, target)
                if not okPoint then return previousRay(...) end
                local origin = oldView.Position
                local blocked = Workspace:Raycast(origin, target.Position-origin, losParams)
                if not blocked then return previousRay(...) end
                local shifted = findShiftedOrigin(origin, target, camera)
                if not shifted or (aim-shifted).Magnitude < 0.01 then return previousRay(...) end
                if Workspace:Raycast(shifted, aim-shifted, losParams) then return previousRay(...) end
                local moved = pcall(function() camera.CFrame = CFrame.lookAt(shifted, aim) end)
                if not moved then return previousRay(...) end
                local resultPack = table.pack(pcall(previousRay, ...))
                pcall(function() camera.CFrame = oldView end)
                if not resultPack[1] then error(resultPack[2], 0) end
                return table.unpack(resultPack, 2, resultPack.n)
            end)
        end)
        if good and type(old) == "function" then previousRay = old; state.forceReady = true end
    end
    state.forceFailed = not state.forceReady
    refreshExtras()

    -- Убираем разброс только во время перенаправленного выстрела.
    local seen = {}
    for _, name in ipairs({ "getTrueSpread", "getSpreadForConfig", "getMovementSpreadForConfig", "getBaseSpreadForConfig", "getBaseSpread" }) do
        local fn = rawget(bullet, name)
        if type(fn) == "function" and not seen[fn] then
            seen[fn] = true
            local previous
            local hooked, original = pcall(function()
                return hook(fn, function(...)
                    local values = table.pack(previous(...))
                    if state.redirected and type(values[1]) == "number" then values[1] = 0 end
                    return table.unpack(values, 1, values.n)
                end)
            end)
            if hooked and type(original) == "function" then previous = original end
        end
    end
    return true
end

task.spawn(function()
    -- Классы могут появиться только после загрузки матча/оружия.
    while gui.Parent do
        local okBullet, bullet = pcall(findBulletClass)
        local okSend, send = pcall(lookupNetworkSend)
        if okBullet and bullet and okSend and send then
            local installed, why = install(bullet, send)
            state.ready = installed
            state.message = installed and "Готово" or why
            refreshButton()
            if not installed then warn("[Silent Aim] " .. tostring(why)) end
            return
        end
        task.wait(0.5)
    end
    state.message = "Функции не найдены"
    refreshButton()
    warn("[Silent Aim] Не найдены bullet.create или Remotes.Inventory.ShootWeapon.Send; версия игры либо возможности executor могут отличаться")
end)

