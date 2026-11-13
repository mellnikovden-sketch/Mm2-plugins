--[[
    MM2 — Тихий бросок ножа (silent aim) — стартовый скрипт с нуля, без зависимостей
    ================================================================================

    КАК ЭТО РАБОТАЕТ (коротко, по фактам игры):

    1) Бросок ножа в MM2 - клиентский. У ножа (Tool "Knife") есть папка
       Events -> RemoteEvent "KnifeThrown". Игра бросает нож так:
           remote:FireServer(handle.CFrame, CFrame.new(точка_куда_летит))
       То есть КЛИЕНТ сам говорит серверу, куда летит нож. Отсюда и silent aim:
       мы просто отправляем эту точку сами / подменяем её.

    2) Два режима работы:
       - ТИХИЙ ХУК: подменяем функции модуля
         ReplicatedStorage.ClientServices.WeaponService ->
         GetMouseTargetCFrame / GetTargetPosition. Игра вызывает их при твоём
         обычном клике, и бросок улетает в выбранную цель. Камера и мышь не
         двигаются вообще (в этом смысл "тихого" прицела).
       - КЛАВИША БРОСКА: сами шлём KnifeThrown:FireServer по нажатию клавиши.

    3) Определение маньяка:
       - главный источник: ReplicatedStorage.Remotes.Gameplay.PlayerDataChanged
         шлёт таблицу { [имя] = { Role = "Murderer"/"Sheriff"/"Hero"/"Innocent", ... } }
       - фолбэк: у маньяка в Backpack/Character лежит Tool "Knife",
         у шерифа - Tool "Gun".

    4) Прогноз движения: точка = позиция + MoveDirection*WalkSpeed *
       (пинг + дистанция/скорость_ножа), итеративно. Скорость ножа ~96
       studs/s; калибруется автоматически по частям "BladePosition"
       (игра создаёт их на летящем ноже).

    5) Кулдаун броска: атрибут ножа ThrowSpeed (обычно 0.7) ->
       cooldown = max(1.45, ThrowSpeed*2 + 0.08).

    УПРАВЛЕНИЕ:
       X  — вкл/выкл тихий прицел (клик мышью = бросок в цель)
       G  — мгновенный тихий бросок в цель (без клика, вообще без анимации прицела)

    API для своего меню:
       getgenv().KnifeSilentAim.Enable(bool)   -- вкл/выкл
       getgenv().KnifeSilentAim.Throw()        -- тихий бросок сейчас
       getgenv().KnifeSilentAim.CFG            -- таблица настроек
       getgenv().KnifeSilentAim.Unload()       -- выгрузить скрипт
]]

-- ═══════════════════════════════ НАСТРОЙКИ ═══════════════════════════════

local CFG = {
    -- основное
    Enabled      = true,              -- включить при загрузке
    Mode         = "Умный",           -- Умный | Прицел | Ближе | Шериф
    FOV          = 360,               -- угол захвата в градусах (360 = весь экран)
    MaxDistance  = 250,               -- макс. дистанция броска (studs)
    WallCheck    = true,              -- не целиться через стены
    Prediction   = true,              -- предугадывать движение цели
    Lead         = 100,               -- сила прогноза, % (100 = полная)
    Sticky       = true,              -- держать цель, пока она жива
    AimPart      = "HumanoidRootPart",-- куда целимся (можно "Head")

    -- визуал
    Marker       = true,              -- метка над выбранной целью
    FovCircle    = true,              -- круг FOV в центре экрана

    -- авто-бросок
    AutoThrow    = false,             -- бросать самому, когда цель в радиусе
    AutoRange    = 70,                -- радиус авто-броска (studs)

    -- физика ножа (не трогай, калибруется само)
    KnifeSpeed   = 96,

    -- клавиши
    ToggleKey    = Enum.KeyCode.X,    -- вкл/выкл тихого прицела
    ThrowKey     = Enum.KeyCode.G,    -- прямой тихий бросок
}

-- ═══════════════════════════════ СОСТОЯНИЕ ═══════════════════════════════

local State = {
    On      = CFG.Enabled == true,   -- silent aim активен
    Hooked  = false,                 -- WeaponService подменён
    Active  = true,                  -- скрипт жив (для остановки цикла)
}

local stickyChar   = nil   -- текущая "прилипшая" цель (Model)
local lastTarget   = nil   -- последняя выбранная цель (Model)
local lastDist     = 0
local lastThrow    = 0     -- os.clock() последнего броска
local aimCache     = nil   -- кэш точки прицела
local aimCacheT    = 0

local Connections  = {}    -- все соединения для Unload()
local marker       = nil   -- BillboardGui
local circle       = nil   -- Drawing круг

-- ═══════════════════════════════ СЕРВИСЫ ═════════════════════════════════

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui    = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════ УТИЛИТЫ ═════════════════════════════════

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 2,
        })
    end)
end

local function track(conn)
    if conn then table.insert(Connections, conn) end
    return conn
end

-- ══════════════════════════ НОЖ (поиск / готовность) ═════════════════════

local function findKnifeIn(container)
    if not container then return nil end
    local tool = container:FindFirstChild("Knife")
    if tool and tool:IsA("Tool") then return tool end
    return nil
end

-- нож в руках
local function equippedKnife()
    return findKnifeIn(LocalPlayer.Character)
end

-- нож где угодно (руки или рюкзак); из рюкзака - экипируем
local function readyKnife()
    local char = LocalPlayer.Character
    local knife = findKnifeIn(char)
    if knife then return knife end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    knife = findKnifeIn(backpack)
    if knife and char then
        pcall(function() knife.Parent = char end)  -- экипировка = parent в Character
        return findKnifeIn(char)
    end
    return nil
end

-- точка, откуда летит нож (для расчётов)
local function knifeOrigin()
    local knife = equippedKnife()
    local handle = knife and (knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart"))
    if handle then return handle.Position end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    return root and root.Position or nil
end

-- кулдаун броска из атрибута ножа
local function throwCooldown()
    local knife = equippedKnife() or findKnifeIn(LocalPlayer:FindFirstChildOfClass("Backpack"))
    local throwSpeed = knife and tonumber(knife:GetAttribute("ThrowSpeed")) or 0.7
    return math.max(1.45, throwSpeed * 2 + 0.08)
end

-- ══════════════════════════ РОЛИ (маньяк / шериф) ════════════════════════

local Roles = {}  -- [имя_игрока] = { Role = "...", Dead = bool, Killed = bool }

do
    task.spawn(function()
        local replicated = game:GetService("ReplicatedStorage")
        local remotes  = replicated:WaitForChild("Remotes", 15)
        local gameplay = remotes and remotes:WaitForChild("Gameplay", 15)
        local event    = gameplay and gameplay:WaitForChild("PlayerDataChanged", 15)
        if not event then return end
        track(event.OnClientEvent:Connect(function(data)
            if typeof(data) ~= "table" then return end
            for name, info in pairs(data) do
                if typeof(info) == "table" and info.Role then
                    Roles[name] = {
                        Role   = tostring(info.Role),
                        Dead   = info.Dead == true,
                        Killed = info.Killed == true,
                    }
                end
            end
        end))
    end)
end

-- я маньяк?
local function isMurderer()
    local myRole = Roles[LocalPlayer.Name]
    if myRole and myRole.Role ~= nil then
        return myRole.Role:lower():find("murder") ~= nil
    end
    -- фолбэк: если у нас в руках/рюкзаке нож - мы маньяк
    return equippedKnife() ~= nil
        or findKnifeIn(LocalPlayer:FindFirstChildOfClass("Backpack")) ~= nil
end

-- у игрока есть пистолет (шериф/герой)?
local function isArmed(player)
    local role = Roles[player.Name]
    if role and role.Role then
        local n = role.Role:lower()
        if n:find("sheriff") or n:find("hero") then return true end
    end
    local char, backpack = player.Character, player:FindFirstChildOfClass("Backpack")
    return (char and char:FindFirstChild("Gun") ~= nil)
        or (backpack and backpack:FindFirstChild("Gun") ~= nil) or false
end

-- живая ли цель (по ролям и по humanoid)
local function isValidTarget(player)
    if player == LocalPlayer then return false end
    local role = Roles[player.Name]
    if role and (role.Dead or role.Killed) then return false end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

-- ════════════════════ ПРИЦЕЛИВАНИЕ (выбор цели) ══════════════════════════

local function pingSeconds()
    local ok, value = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok and type(value) == "number" and value == value then
        return math.clamp(value / 1000, 0, 1)
    end
    return 0.08
end

-- простая стена-проверка: луч от ножа до точки, игроки не мешают
local function blocked(origin, target)
    if not CFG.WallCheck then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.RespectCanCollide = true
    params.IgnoreWater = true

    local ignore = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then table.insert(ignore, player.Character) end
    end
    params.FilterDescendantsInstances = ignore

    local result = workspace:Raycast(origin, target - origin, params)
    return result ~= nil
end

-- предсказанная точка, где цель будет в момент прилёта ножа
local function predictPoint(origin, character)
    local root = character:FindFirstChild(CFG.AimPart) or character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local position = root.Position

    if not CFG.Prediction then return position end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local move = Vector3.new(0, 0, 0)
    if humanoid then
        local dir = humanoid.MoveDirection
        move = Vector3.new(dir.X, 0, dir.Z) * humanoid.WalkSpeed
    end

    local latency = pingSeconds() + 0.1
    local point = position
    for _ = 1, 5 do  -- итеративно: чем дальше, тем дольше летит нож
        point = position + move * (latency + (point - origin).Magnitude / CFG.KnifeSpeed)
    end
    return point
end

-- список кандидатов с оценкой (чем больше score, тем лучше)
local function candidates(origin)
    local camera = workspace.CurrentCamera
    local direction = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
    local list = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local delta = root.Position - origin
                local distance = delta.Magnitude
                if distance <= CFG.MaxDistance and distance > 0.5 then
                    local angle = math.deg(math.acos(math.clamp(direction:Dot(delta.Unit), -1, 1)))
                    if CFG.FOV >= 360 or angle <= CFG.FOV * 0.5 then
                        local armed = isArmed(player)
                        local score
                        if CFG.Mode == "Прицел" then
                            score = -angle
                        elseif CFG.Mode == "Ближе" then
                            score = -distance
                        elseif CFG.Mode == "Шериф" then
                            score = (armed and 1000 or 0) - angle - distance * 0.05
                        else -- Умный
                            score = -angle - distance * 0.12 + (armed and 14 or 0)
                        end
                        if CFG.Sticky and stickyChar == character then
                            if CFG.Mode == "Ближе" then score = score + 12 else score = score + 8 end
                        end
                        table.insert(list, { player = player, char = character, dist = distance, score = score })
                    end
                end
            end
        end
    end

    table.sort(list, function(a, b) return a.score > b.score end)
    return list
end

-- главная функция: вернуть точку для броска (или nil)
local function aim()
    if not (State.On or CFG.AutoThrow) then return nil end
    if not isMurderer() then return nil end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    -- кэш 35 мс, чтобы не считать 100 раз за кадр (hook дергает часто)
    local now = os.clock()
    if aimCache and now - aimCacheT < 0.035 then return aimCache end

    local origin = knifeOrigin()
    if not origin then return nil end

    local list = candidates(origin)
    for i = 1, math.min(#list, 4) do
        local cand = list[i]
        local raw = predictPoint(origin, cand.char)
        if raw then
            local root = cand.char:FindFirstChild("HumanoidRootPart")
            local base = root and root.Position or raw
            local lead = math.clamp(CFG.Lead / 100, 0, 3)
            local point = (lead ~= 1) and (base + (raw - base) * lead) or raw

            if point and not blocked(origin, point) then
                stickyChar = cand.char
                lastTarget = cand.char
                lastDist   = cand.dist
                aimCache, aimCacheT = point, now
                return point
            end
        end
    end

    lastTarget = nil
    return nil
end

-- ══════════════════════════ БРОСОК (remote) ══════════════════════════════

-- тихий бросок: KnifeThrown:FireServer(handle.CFrame, CFrame.new(точка))
local function throwTo(point)
    local knife = readyKnife()
    if not knife then return false end

    local events = knife:FindFirstChild("Events")
    local remote = events and events:FindFirstChild("KnifeThrown")
    local handle = knife:FindFirstChild("Handle") or knife:FindFirstChildWhichIsA("BasePart")
    if not remote or not handle then
        notify("Тихий нож", "KnifeThrown не найден", 2)
        return false
    end

    local ok = pcall(function()
        remote:FireServer(handle.CFrame, CFrame.new(point))
    end)
    lastThrow = os.clock()
    return ok
end

-- ════════════════ SILENT HOOK (подмена WeaponService) ════════════════════

local HookRefs = nil

local function installHook()
    if HookRefs then return true end

    local ok = pcall(function()
        local services = game:GetService("ReplicatedStorage"):WaitForChild("ClientServices", 10)
        local module   = services and services:WaitForChild("WeaponService", 10)
        if not module then error("ClientServices.WeaponService не найден") end

        local weapons = require(module)  -- тот же объект, что использует игра
        if type(weapons) ~= "table" then error("WeaponService не таблица") end

        local oldMouse  = weapons.GetMouseTargetCFrame
        local oldTarget = weapons.GetTargetPosition
        if type(oldMouse) ~= "function" or type(oldTarget) ~= "function" then
            error("функции WeaponService не найдены")
        end

        local function mouse(self, ...)
            local okAim, point = pcall(aim)
            if okAim and point then return CFrame.new(point) end
            return oldMouse(self, ...)
        end
        local function target(self, ...)
            local okAim, point = pcall(aim)
            if okAim and point then return CFrame.new(point) end
            return oldTarget(self, ...)
        end

        weapons.GetMouseTargetCFrame, weapons.GetTargetPosition = mouse, target
        if weapons.GetMouseTargetCFrame == mouse and weapons.GetTargetPosition == target then
            HookRefs = {
                weapons = weapons,
                mouse = mouse, target = target,
                oldMouse = oldMouse, oldTarget = oldTarget,
            }
            State.Hooked = true
            return
        end
        error("подмена не применилась")
    end)

    if not ok then
        notify("Тихий нож", "Хук не встал, работает только клавиша G", 3)
    end
    return ok and HookRefs ~= nil
end

local function uninstallHook()
    local refs = HookRefs
    if not refs then return end
    HookRefs = nil
    State.Hooked = false
    pcall(function()
        refs.weapons.GetMouseTargetCFrame = refs.oldMouse
        refs.weapons.GetTargetPosition   = refs.oldTarget
    end)
end

-- ══════════════════════════ ВИЗУАЛ (метка / FOV) ═════════════════════════

local function ensureMarker()
    if marker and marker.Parent then return marker end

    local gui = Instance.new("BillboardGui")
    gui.Name = "KnifeSilentTarget"
    gui.Size = UDim2.fromOffset(110, 26)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
    gui.AlwaysOnTop = true
    gui.ResetOnSpawn = false

    local label = Instance.new("TextLabel")
    label.Name = "L"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextColor3 = Color3.fromRGB(255, 120, 70)
    label.TextStrokeTransparency = 0.35
    label.Parent = gui

    local placed = pcall(function() gui.Parent = CoreGui end)
    if not placed or not gui.Parent then
        gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end

    marker = gui
    return gui
end

local function setMarker(character, distance)
    if not CFG.Marker then
        if marker then marker.Enabled = false end
        return
    end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        if marker then marker.Enabled = false end
        return
    end

    local gui = ensureMarker()
    gui.Adornee = root
    gui.Enabled = true
    local label = gui:FindFirstChild("L")
    if label then
        label.Text = string.format("НОЖ %dм", math.floor(distance + 0.5))
    end
end

-- круг FOV (Drawing API)
local function ensureCircle()
    if circle or not Drawing then return nil end
    local ok, obj = pcall(function() return Drawing.new("Circle") end)
    if not ok or not obj then return nil end
    obj.Thickness = 1.5
    obj.NumSides = 64
    obj.Filled = false
    obj.Color = Color3.fromRGB(255, 120, 70)
    obj.Transparency = 0.55
    obj.Visible = false
    circle = obj
    return circle
end

local function destroyCircle()
    if circle then
        pcall(function() circle:Remove() end)
        circle = nil
    end
end

-- ════════════════════ ГЛАВНЫЙ ЦИКЛ (шаг каждые 0.12с) ════════════════════

local function step()
    if not (State.On or CFG.AutoThrow) then setMarker(nil) return end
    if not isMurderer() then setMarker(nil) return end

    local point = aim()
    if point and lastTarget and lastTarget.Parent then
        local origin = knifeOrigin()
        local distance = lastDist
        if origin and lastTarget:FindFirstChild("HumanoidRootPart") then
            distance = (lastTarget.HumanoidRootPart.Position - origin).Magnitude
        end
        setMarker(lastTarget, distance)

        -- авто-бросок
        if CFG.AutoThrow and origin and distance <= CFG.AutoRange then
            if os.clock() - lastThrow >= throwCooldown() then
                throwTo(point)
            end
        end
    else
        setMarker(nil)
    end
end

-- ═══════════ КАЛИБРОВКА СКОРОСТИ НОЖА (по частям BladePosition) ══════════

track(workspace.DescendantAdded:Connect(function(part)
    if part.Name ~= "BladePosition" or not part:IsA("BasePart") then return end
    task.spawn(function()
        local samples = {}
        for _ = 1, 30 do
            RunService.Heartbeat:Wait()
            if not part.Parent then return end
            table.insert(samples, { os.clock(), part.Position })
        end
        if #samples < 12 then return end

        local moving = {}
        for i = 2, #samples do
            if (samples[i][2] - samples[i - 1][2]).Magnitude > 0.02 then
                table.insert(moving, i)
            end
        end
        if #moving < 5 then return end

        local first, last = samples[moving[2]], samples[moving[#moving]]
        local elapsed = last[1] - first[1]
        if elapsed < 0.15 then return end

        local speed = (last[2] - first[2]).Magnitude / elapsed
        if speed <= 85 or speed >= 108 then return end

        CFG.KnifeSpeed = CFG.KnifeSpeed * 0.9 + speed * 0.1  -- сглаживание
    end)
end))

-- ══════════════════════════ КЛАВИШИ ══════════════════════════════════════

track(UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == CFG.ToggleKey then
        State.On = not State.On
        if State.On then
            task.spawn(installHook)
            notify("Тихий нож", "ВКЛ — клик = бросок в цель", 2)
        else
            notify("Тихий нож", "ВЫКЛ", 2)
        end

    elseif input.KeyCode == CFG.ThrowKey then
        task.spawn(function()
            if not isMurderer() then
                notify("Тихий нож", "Ты не маньяк", 2)
                return
            end
            if os.clock() - lastThrow < 0.35 then return end

            -- временно включаем прицел, чтобы aim() отработал
            local saved = State.On
            State.On = true
            local point = aim()
            State.On = saved

            if point then
                throwTo(point)
            else
                notify("Тихий нож", "Нет цели в зоне", 2)
            end
        end)
    end
end))

-- ══════════════════════════ ЗАПУСК ═══════════════════════════════════════

-- повторный запуск: сначала выгружаем прошлую копию, чтобы циклы не дублировались
pcall(function()
    local prev = getgenv().KnifeSilentAim
    if prev and type(prev.Unload) == "function" then prev.Unload() end
end)

-- цикл прицела/маркера/авто-броска
task.spawn(function()
    while State.Active do
        task.wait(0.12)
        pcall(step)
    end
end)

-- обновление круга FOV
track(RunService.RenderStepped:Connect(function()
    if not CFG.FovCircle or CFG.FOV >= 360 then
        if circle then circle.Visible = false end
        return
    end
    local c = ensureCircle()
    if not c then return end

    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    -- перевод угла FOV в пиксели (вертикальный FOV камеры Roblox ~70 град)
    local radius = math.tan(math.rad(CFG.FOV) / 2) / math.tan(math.rad(35)) * (vp.Y / 2)
    c.Radius = math.clamp(radius, 8, math.max(vp.X, vp.Y))
    c.Position = vp / 2
    c.Visible = true
end))

-- ══════════════════════════ API + ВЫГРУЗКА ═══════════════════════════════

local function unload()
    State.Active = false
    State.On = false
    uninstallHook()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)
    destroyCircle()
    if marker then pcall(function() marker:Destroy() end) marker = nil end
    if getgenv().KnifeSilentAim then getgenv().KnifeSilentAim = nil end
    notify("Тихий нож", "Выгружен", 2)
end

getgenv().KnifeSilentAim = {
    CFG   = CFG,
    State = State,

    Enable = function(value)
        State.On = value and true or false
        if State.On then task.spawn(installHook) end
        return State.On
    end,

    -- тихий бросок прямо сейчас (для кнопки в меню / бинда)
    Throw = function()
        local saved = State.On
        State.On = true
        local point = aim()
        State.On = saved
        if point then return throwTo(point) end
        return false
    end,

    Unload = unload,
}

-- старт
if State.On then
    task.spawn(installHook)
end
notify("Тихий нож", string.format("Загружен | X — вкл/выкл, G — бросок | режим: %s", CFG.Mode), 3)
print("[НожТихийПрицел] загружен. API: getgenv().KnifeSilentAim")
