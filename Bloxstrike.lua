-- Blox Strike v4: меню Silent Aim, Rapid Fire, Auto Shoot, Autowall и ESP.
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
gui.Name = "IndependentSilentAim"
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
menu.Size = UDim2.fromOffset(360, 280)
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.new(0.5, 0, 0.5, 0)
menu.BackgroundColor3 = Color3.fromRGB(12, 15, 25)
menu.BorderSizePixel = 0
menu.ZIndex = 10
menu.Parent = gui
round(menu, 14)
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(52, 66, 88)
border.Thickness = 1
border.Parent = menu
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, -28, 0, 1)
accent.Position = UDim2.fromOffset(14, 47)
accent.BorderSizePixel, accent.BackgroundColor3, accent.ZIndex = 0, Color3.fromRGB(72, 225, 202), 12
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
badge.Name, badge.BackgroundColor3, badge.BorderSizePixel = "BrandBadge", Color3.fromRGB(24, 65, 62), 0
badge.Size, badge.Position, badge.ZIndex, badge.Parent = UDim2.fromOffset(30,30), UDim2.fromOffset(14,9), 12, header
round(badge, 9)
local badgeText = label(badge, "BS", UDim2.fromScale(1,1), UDim2.fromOffset(0,0), 11)
badgeText.TextXAlignment, badgeText.TextColor3, badgeText.ZIndex = Enum.TextXAlignment.Center, Color3.fromRGB(157,255,232), 13
local title = label(header, "BLOXSTRIKE", UDim2.new(1, -60, 0, 22), UDim2.fromOffset(54, 6), 15)
title.ZIndex = 12
local subtitle = label(header, "CONTROL STUDIO  /  DRAG TO MOVE", UDim2.new(1, -60, 0, 17), UDim2.fromOffset(54, 26), 9)
subtitle.TextColor3 = Color3.fromRGB(139, 156, 190)
subtitle.ZIndex = 12
local close = smallButton(menu, "×", UDim2.fromOffset(32, 32), UDim2.new(1, -42, 0, 8))
close.TextSize = 21
close.ZIndex = 12

local reopen = smallButton(gui, "≡  MENU", UDim2.fromOffset(86, 36), UDim2.new(0, 12, 0.36, 0))
reopen.BackgroundColor3 = Color3.fromRGB(22, 49, 54)
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
        menuScale.Scale = math.clamp(math.min((size.X-16)/360, (size.Y-16)/280), 0.55, 1)
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

-- Компактная панель: четыре страницы, единые карточки и состояния.
local selectedTab = "COMBAT"
local tabs, entries, indicators = {}, {}, {}
local groups = {
    ["SILENT"]={"COMBAT",0}, ["AUTO SHOOT"]={"COMBAT",1},
    ["AUTOWALL"]={"COMBAT",2}, ["FORCE ORIGIN"]={"COMBAT",3}, ["TEAM CHECK"]={"COMBAT",4},
    ["RAPID"]={"WEAPON",0}, ["AUTO RELOAD"]={"WEAPON",1}, ["INSTA RELOAD"]={"WEAPON",2},
    ["ESP BOX"]={"VISUALS",0}, ["NAMES / HP"]={"VISUALS",1}, ["OUTLINE"]={"VISUALS",2}, ["CHAMS"]={"VISUALS",3},
    ["BOX STYLE"]={"VISUALS",4}, ["OUTLINE STYLE"]={"VISUALS",5}, ["CHAMS STYLE"]={"VISUALS",6}, ["ESP COLOR"]={"VISUALS",7},
    ["ANTI SMOKE"]={"EFFECTS",0}, ["ANTI FLASH"]={"EFFECTS",1},
}
local pageHint = label(menu, "TARGETING  /  360°", UDim2.fromOffset(240,15), UDim2.fromOffset(15,84), 9)
pageHint.TextColor3 = Color3.fromRGB(108, 128, 152)
pageHint.ZIndex = 12
local function setTab(name)
    selectedTab = name
    local hints = {COMBAT="TARGETING  /  360°", WEAPON="WEAPON CONTROL", VISUALS="ENEMY VISUALS", EFFECTS="LOCAL EFFECT FILTERS"}
    pageHint.Text = hints[name]
    for group, button in pairs(tabs) do
        local active = group == name
        button.BackgroundColor3 = active and Color3.fromRGB(31, 82, 78) or Color3.fromRGB(22, 27, 40)
        button.TextColor3 = active and Color3.fromRGB(175, 255, 238) or Color3.fromRGB(139, 156, 178)
    end
    for _, entry in ipairs(entries) do entry.button.Visible = entry.group == name end
end
for index, name in ipairs({"COMBAT", "WEAPON", "VISUALS", "EFFECTS"}) do
    local tab = smallButton(menu, name, UDim2.fromOffset(79, 26), UDim2.fromOffset(14+(index-1)*84, 53))
    tab.Name, tab.TextSize, tab.ZIndex = name.."Tab", 9, 12
    tabs[name] = tab
    tab.MouseButton1Click:Connect(function() setTab(name) end)
end
setTab(selectedTab)
local function makeToggle(name, index)
    local layout = assert(groups[name], "unknown toggle: " .. name)
    local col, row = layout[2] % 2, math.floor(layout[2] / 2)
    local item = smallButton(menu, "   "..name, UDim2.fromOffset(162, 32), UDim2.fromOffset(14+col*170, 103+row*37))
    item.Name, item.ZIndex, item.TextSize = name.."Toggle", 12, 10
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    item.Visible = layout[1] == selectedTab
    local edge = Instance.new("UIStroke")
    edge.Color, edge.Thickness, edge.Transparency, edge.Parent = Color3.fromRGB(55, 68, 88), 1, 0.35, item
    local status = label(item, "", UDim2.fromOffset(35,18), UDim2.new(1,-40,0.5,-9), 9)
    status.TextXAlignment, status.ZIndex = Enum.TextXAlignment.Right, 14
    indicators[item] = {status=status, edge=edge}
    table.insert(entries, {group=layout[1], button=item})
    return item
end
local function showToggle(item, name, enabled, waiting)
    item.Text = "   " .. name
    item.BackgroundColor3 = enabled and Color3.fromRGB(22, 49, 49) or Color3.fromRGB(24, 30, 44)
    local data = indicators[item]
    data.status.Text = waiting and "WAIT" or (enabled and "ON" or "OFF")
    data.status.TextColor3 = waiting and Color3.fromRGB(247, 192, 103) or (enabled and Color3.fromRGB(109, 246, 210) or Color3.fromRGB(112, 129, 151))
    data.edge.Color = enabled and Color3.fromRGB(65, 164, 143) or Color3.fromRGB(55, 68, 88)
end
local footer = label(menu, "CLIENT CONTROL     •     TAP TO CONFIGURE", UDim2.new(1, -28, 0, 16), UDim2.fromOffset(14, 258), 9)
footer.TextColor3 = Color3.fromRGB(95, 112, 135)
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
    status.Text, status.TextColor3 = value, Color3.fromRGB(131, 220, 209)
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
slider.Name, slider.BackgroundColor3, slider.BorderSizePixel = "OriginSlider", Color3.fromRGB(24,30,44), 0
slider.Size, slider.Position, slider.ZIndex = UDim2.fromOffset(332, 42), UDim2.fromOffset(14, 211), 12
slider.Parent = menu
round(slider, 8)
local sliderEdge = Instance.new("UIStroke")
sliderEdge.Color, sliderEdge.Transparency, sliderEdge.Parent = Color3.fromRGB(55,68,88), 0.35, slider
local sliderTitle = label(slider, "ORIGIN RADIUS", UDim2.fromOffset(170,14), UDim2.fromOffset(10,5), 9)
sliderTitle.TextColor3, sliderTitle.ZIndex = Color3.fromRGB(172,190,205), 13
local sliderValue = label(slider, "", UDim2.fromOffset(65,14), UDim2.new(1,-75,0,5), 9)
sliderValue.TextXAlignment, sliderValue.TextColor3, sliderValue.ZIndex = Enum.TextXAlignment.Right, Color3.fromRGB(120,246,221), 13
local track = Instance.new("Frame")
track.Name, track.BorderSizePixel, track.BackgroundColor3 = "Track", 0, Color3.fromRGB(45,58,73)
track.Position, track.Size, track.ZIndex, track.Parent = UDim2.fromOffset(12,28), UDim2.new(1,-24,0,4), 13, slider
round(track, 3)
local fill = Instance.new("Frame")
fill.BorderSizePixel, fill.BackgroundColor3, fill.ZIndex, fill.Parent = 0, Color3.fromRGB(95,230,200), 14, track
round(fill, 3)
local knob = Instance.new("Frame")
knob.AnchorPoint, knob.Size = Vector2.new(0.5,0.5), UDim2.fromOffset(13,13)
knob.BackgroundColor3, knob.BorderSizePixel, knob.ZIndex, knob.Parent = Color3.fromRGB(211,255,244), 0, 15, track
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
