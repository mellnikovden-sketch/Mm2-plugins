-- RageHop / monochrome reference layout: black, grey and white.
-- Interface-only copy: tabs, controls, images, animations, search and UI settings.
-- No gameplay engines, remote calls, movement, inventory modifications or weapon effects.
-- Run as a client LocalScript; gameplay controls are visual placeholders.
-- Menu: RightShift.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local player = Players.LocalPlayer
assert(player, "Run this script in a LocalScript on the client.")
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("RageHopMenuOnly")
if old then old:Destroy() end

local TITLE, W, H = "RageHop", 986, 550
local menuKey = Enum.KeyCode.RightShift
local BODY_FONT = Enum.Font.Gotham
local C = {
    bg = Color3.fromRGB(10, 10, 10), header = Color3.fromRGB(16, 16, 16),
    panel = Color3.fromRGB(12, 12, 12), raised = Color3.fromRGB(28, 28, 28),
    line = Color3.fromRGB(36, 36, 36), text = Color3.fromRGB(210, 210, 210),
    dim = Color3.fromRGB(120, 120, 120), white = Color3.fromRGB(242, 242, 242),
    accent = Color3.fromRGB(235, 235, 235), soft = Color3.fromRGB(66, 66, 66),
    slider = Color3.fromRGB(106, 106, 106),
}
local preferences = {scale = 100, opacity = 0, border = true, motion = true, pattern = true}
local alive, opened, waitingKey = true, true, false
local connections, animations, values, setters = {}, {}, {}, {}
local activeSlider, dragging, cameraConnection, snapshot
local transition = 0
local currentTab, currentSection = "Main", "Combat"
local pages, navigation, sections, rows = {}, {}, {}, {}
local settingsSetters = {}
local refreshKey, applySearch, selectPage, setOpen
local avatarPreview
local previewExtra, layoutExtra = 0, 0
local refreshHud, refreshHudLayout

local function make(kind, props, parent)
    local o = Instance.new(kind)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function on(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end
local function animate(o, props, duration)
    if not alive then return end
    if animations[o] then animations[o]:Cancel(); animations[o] = nil end
    if not preferences.motion then for k, v in pairs(props) do o[k] = v end; return end
    local a = TweenService:Create(o, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    animations[o] = a
    a.Completed:Once(function() if animations[o] == a then animations[o] = nil end end)
    a:Play()
end
local function box(parent, x, y, w, h, color, transparency)
    return make("Frame", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
        BackgroundColor3 = color or C.panel, BackgroundTransparency = transparency or 0, BorderSizePixel = 0}, parent)
end
local function label(parent, value, x, y, w, h, size, color, font)
    return make("TextLabel", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
        BackgroundTransparency = 1, Text = value, Font = font or BODY_FONT,
        TextSize = size or 13, TextColor3 = color or C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        BorderSizePixel = 0}, parent)
end
local function border(o, color, transparency)
    return make("UIStroke", {Color = color or C.line, Transparency = transparency or 0,
        Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end
local function corner(o, radius) make("UICorner", {CornerRadius = UDim.new(0, radius)}, o) end
local function button(parent, value, x, y, w, h)
    return make("TextButton", {Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h),
        BackgroundTransparency = 1, Text = value, Font = BODY_FONT,
        TextSize = 13, TextColor3 = C.text, AutoButtonColor = false, BorderSizePixel = 0}, parent)
end

-- Native UI line icons, no image assets needed.
local function icon(parent, name, x, y, color)
    local host = box(parent, x, y, 20, 20, C.bg, 1)
    local parts = {}
    local function rect(rx, ry, rw, rh, filled, rot, round)
        local r = box(host, rx, ry, rw, rh, color or C.dim)
        r.Rotation = rot or 0
        if round then corner(r, round) end
        if filled then table.insert(parts, r) else r.BackgroundTransparency = 1; table.insert(parts, border(r, color or C.dim)) end
        return r
    end
    if name == "Main" then
        rect(8, 1, 2, 18, true, 43); rect(9, 1, 2, 18, true, -43)
        rect(0, 12, 8, 2, true, 43); rect(12, 12, 8, 2, true, -43)
    elseif name == "Visuals" then
        rect(1, 5, 18, 10, false, 0, 8); rect(7, 7, 6, 6, false, 0, 8)
    elseif name == "Player" then
        rect(7, 1, 7, 7, false, 0, 8); rect(3, 11, 14, 8, false, 0, 6)
    elseif name == "search" then
        rect(1, 1, 12, 12, false, 0, 10); rect(13, 11, 2, 9, true, -42)
    elseif name == "folder" then
        rect(1, 5, 18, 13, false, 0, 1); rect(2, 2, 7, 3, false)
    elseif name == "save" then
        rect(2, 1, 16, 18, false, 0, 1); rect(6, 1, 8, 6, false); rect(6, 12, 8, 7, false)
    else
        rect(3, 1, 1, 18, true); rect(10, 1, 1, 18, true); rect(17, 1, 1, 18, true)
        rect(1, 4, 5, 3, true); rect(8, 12, 5, 3, true); rect(15, 7, 5, 3, true)
    end
    local function tint(c)
        for _, part in ipairs(parts) do
            if part:IsA("UIStroke") then animate(part, {Color = c}) else animate(part, {BackgroundColor3 = c}) end
        end
    end
    return tint
end

local gui = make("ScreenGui", {Name = "RageHopMenuOnly", IgnoreGuiInset = true, ResetOnSpawn = false,
    DisplayOrder = 30, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, playerGui)
local holder = make("Frame", {Name = "WindowPosition", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(W, H), BackgroundTransparency = 1}, gui)
local uiScale = make("UIScale", {Scale = 1}, holder)
local root = make("CanvasGroup", {Name = "Window", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, GroupTransparency = 1}, holder)
corner(root, 6)
local outline = border(root, C.accent, 0.18)
local wallpaper = box(root, 0, 0, W, H, C.bg, 1)
wallpaper.ClipsDescendants = true

-- Subtle falling stars and fading meteor trails behind the menu controls.
do
    wallpaper.Name = "FallingStarsBackground"
    local random = Random.new()
    local points, meteors = {}, {}
    local function between(low, high) return random:NextNumber(low, high) end
    for i = 1, 28 do
        local size = i % 5 == 0 and 2 or 1
        local star = box(wallpaper, 0, 0, size, size, C.white, 0.65)
        star.Name, star.Rotation = "FallingStar", 45
        star.AnchorPoint = Vector2.new(0.5, 0.5)
        local point = {frame = star, x = between(0, W), y = between(0, H),
            speed = between(17, 43), drift = between(4, 13), phase = between(0, math.pi * 2)}
        star.Position = UDim2.fromOffset(point.x, point.y)
        table.insert(points, point)
    end
    local function spawn(meteor, initial)
        meteor.x = between(-130, W - 15)
        meteor.y = initial and between(-100, H - 20) or -70
        meteor.speed = between(145, 225)
        meteor.drift = meteor.speed * between(0.38, 0.55)
        meteor.frame.Rotation = math.deg(math.atan2(meteor.speed, meteor.drift))
        meteor.frame.Position = UDim2.fromOffset(meteor.x, meteor.y)
    end
    for i = 1, 7 do
        local length = between(36, 76)
        local host = box(wallpaper, 0, 0, length, 8, C.white, 1)
        host.Name, host.AnchorPoint = "ShootingStar", Vector2.new(1, 0.5)
        local trail = box(host, 0, 3.5, length, 1, C.white, between(0.35, 0.6))
        make("UIGradient", {Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.55, 0.85),
            NumberSequenceKeypoint.new(1, 0.1)})}, trail)
        local glow = box(host, length - 3, 1, 6, 6, C.white, 0.9)
        corner(glow, 3)
        local head = box(host, length - 1, 3, 2, 2, C.white, 0.15)
        head.Rotation = 45
        local meteor = {frame = host}
        spawn(meteor, true)
        table.insert(meteors, meteor)
    end
    local time = 0
    on(RunService.RenderStepped, function(dt)
        if not alive or not opened or not preferences.pattern or not preferences.motion then return end
        dt = math.min(dt, 0.05)
        time = time + dt
        for _, point in ipairs(points) do
            point.x, point.y = point.x + point.drift * dt, point.y + point.speed * dt
            if point.y > H + 3 then point.y, point.x = -3, between(0, W) end
            if point.x > W + 3 then point.x = -3 end
            point.frame.Position = UDim2.fromOffset(point.x, point.y)
            point.frame.BackgroundTransparency = 0.65 + math.sin(time * 1.6 + point.phase) * 0.18
        end
        for _, meteor in ipairs(meteors) do
            meteor.x, meteor.y = meteor.x + meteor.drift * dt, meteor.y + meteor.speed * dt
            if meteor.y > H + 100 or meteor.x > W + 110 then spawn(meteor, false) end
            meteor.frame.Position = UDim2.fromOffset(meteor.x, meteor.y)
        end
    end)
end

local top = box(root, 1, 1, W - 2, 73, C.header, 0.12)
make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), C.header), Rotation = 90}, top)
local dragZone = box(top, 0, 0, W - 2, 18, C.bg, 1)
dragZone.Active = true
local logoDrag = box(top, 8, 17, 120, 52, C.bg, 1)
logoDrag.Active = true
-- New transparent RageHop wordmark, embedded as compact shaded UI geometry.
-- Grayscale bevels and transparent surroundings; no image asset or external download.
local logo = box(logoDrag, 8, 0, 116, 46, C.bg, 1)
make("UIScale", {Scale = 0.9}, logo)
logo.Name = TITLE .. "Wordmark"
local logoGeometry = {
    {29,0,1,1,192,75}, {30,0,1,1,160,75}, {89,0,1,1,224,75}, {90,0,1,1,192,50}, {27,1,1,1,224,75},
    {28,1,1,1,248,25}, {29,1,1,1,224,0}, {30,1,1,1,128,75}, {87,1,1,1,224,75}, {88,1,1,1,224,25},
    {89,1,1,1,224,0}, {90,1,1,1,128,75}, {18,2,1,1,192,75}, {19,2,5,1,224,75}, {24,2,1,1,224,50},
    {25,2,1,1,248,25}, {26,2,1,1,248,0}, {27,2,1,1,255,0}, {28,2,1,1,248,0}, {29,2,1,1,160,25},
    {85,2,1,1,224,75}, {86,2,1,1,248,25}, {87,2,2,1,248,0}, {89,2,1,1,160,25}, {13,3,1,1,224,75},
    {14,3,1,1,248,50}, {15,3,1,1,248,25}, {16,3,2,1,248,0}, {18,3,8,1,255,0}, {26,3,2,1,248,0},
    {28,3,1,1,192,0}, {29,3,1,1,160,75}, {75,3,1,1,224,75}, {76,3,1,1,224,25}, {77,3,1,1,192,25},
    {84,3,1,1,248,25}, {85,3,1,1,248,0}, {86,3,1,1,255,0}, {87,3,1,1,248,0}, {88,3,1,1,192,0},
    {89,3,1,1,128,75}, {10,4,1,1,224,75}, {11,4,1,1,248,25}, {12,4,1,1,248,0}, {13,4,11,1,255,0},
    {24,4,3,1,248,0}, {27,4,1,3,192,0}, {28,4,1,1,160,0}, {73,4,1,1,224,75}, {74,4,1,1,248,25},
    {75,4,1,1,255,0}, {76,4,1,1,192,0}, {77,4,1,1,128,75}, {83,4,1,1,248,25}, {84,4,3,1,255,0},
    {87,4,1,1,192,0}, {88,4,1,1,160,25}, {9,5,1,1,224,25}, {10,5,11,1,255,0}, {21,5,5,1,248,0},
    {26,5,1,2,224,0}, {28,5,1,1,160,50}, {71,5,1,1,224,75}, {72,5,1,1,248,25}, {73,5,2,1,255,0},
    {75,5,1,1,224,0}, {76,5,1,1,160,25}, {82,5,1,1,224,50}, {83,5,3,2,255,0}, {86,5,1,1,224,0},
    {87,5,1,2,160,0}, {88,5,1,1,128,50}, {7,6,1,1,192,75}, {8,6,1,1,248,25}, {9,6,11,1,255,0},
    {20,6,6,1,248,0}, {28,6,1,1,128,75}, {70,6,1,1,224,50}, {71,6,1,1,248,0}, {72,6,2,1,255,0},
    {74,6,1,1,248,0}, {75,6,1,1,192,0}, {76,6,1,1,128,75}, {82,6,1,1,248,25}, {86,6,1,4,192,0},
    {7,7,1,1,248,25}, {8,7,10,1,255,0}, {18,7,7,1,248,0}, {25,7,1,1,224,0}, {26,7,1,1,192,0},
    {27,7,1,1,160,25}, {69,7,1,1,192,75}, {70,7,1,1,248,0}, {71,7,3,1,255,0}, {74,7,1,4,192,0},
    {75,7,1,1,160,0}, {82,7,1,1,248,0}, {83,7,2,1,255,0}, {85,7,1,1,248,0}, {87,7,1,1,160,25},
    {6,8,1,1,224,50}, {7,8,6,1,255,0}, {13,8,1,1,248,0}, {14,8,8,1,224,0}, {22,8,3,1,248,0},
    {25,8,1,1,192,0}, {26,8,1,1,160,0}, {27,8,1,1,128,75}, {69,8,1,1,224,50}, {70,8,3,3,255,0},
    {73,8,1,1,248,0}, {75,8,1,1,160,25}, {81,8,1,1,224,75}, {82,8,3,2,255,0}, {85,8,1,2,224,0},
    {87,8,1,1,160,50}, {5,9,1,1,192,75}, {6,9,1,1,248,0}, {7,9,3,1,255,0}, {10,9,1,1,248,0},
    {11,9,1,1,192,0}, {12,9,6,1,160,0}, {18,9,3,1,192,0}, {21,9,3,1,224,0}, {24,9,1,1,192,0},
    {25,9,1,1,160,0}, {26,9,1,1,160,50}, {69,9,1,2,248,25}, {73,9,1,4,224,0}, {75,9,1,1,160,75},
    {81,9,1,1,224,50}, {87,9,1,1,128,75}, {5,10,1,1,224,50}, {6,10,3,2,255,0}, {9,10,1,1,224,0},
    {10,10,2,1,160,0}, {12,10,1,1,128,0}, {13,10,1,1,128,25}, {14,10,1,1,128,50}, {15,10,5,1,160,50},
    {20,10,1,1,224,0}, {21,10,1,1,248,0}, {22,10,1,1,224,0}, {23,10,1,1,192,0}, {24,10,1,1,160,0},
    {25,10,1,1,160,25}, {81,10,1,1,248,25}, {82,10,2,2,255,0}, {84,10,1,2,248,0}, {85,10,1,5,192,0},
    {86,10,1,1,160,0}, {5,11,1,2,224,25}, {9,11,1,1,192,0}, {10,11,1,1,160,0}, {11,11,1,1,128,50},
    {17,11,1,1,192,75}, {18,11,1,1,224,50}, {19,11,2,1,248,0}, {21,11,1,1,224,0}, {22,11,2,1,160,0},
    {24,11,1,1,128,25}, {34,11,2,1,192,75}, {36,11,4,1,224,75}, {40,11,1,1,192,75}, {48,11,2,1,192,75},
    {50,11,3,1,224,75}, {53,11,1,1,224,50}, {54,11,1,1,192,75}, {61,11,4,1,224,75}, {69,11,1,1,248,0},
    {70,11,2,1,255,0}, {72,11,1,2,248,0}, {74,11,1,1,192,25}, {81,11,1,1,248,0}, {86,11,1,1,160,50},
    {93,11,1,1,192,75}, {94,11,3,1,224,75}, {106,11,1,1,192,75}, {110,11,1,1,192,75}, {111,11,2,1,224,75},
    {113,11,1,1,160,75}, {6,12,2,1,248,0}, {8,12,1,2,255,0}, {9,12,1,1,224,0}, {10,12,1,1,192,0},
    {11,12,1,1,192,50}, {12,12,3,1,224,50}, {15,12,1,1,192,50}, {16,12,1,1,192,25}, {17,12,1,1,224,25},
    {18,12,2,1,224,0}, {20,12,1,1,192,0}, {21,12,1,1,160,0}, {22,12,1,1,128,25}, {23,12,1,1,128,75},
    {30,12,1,1,224,75}, {31,12,1,1,248,50}, {32,12,1,1,248,25}, {33,12,1,1,248,0}, {34,12,5,1,255,0},
    {39,12,1,1,224,0}, {40,12,1,1,160,75}, {45,12,1,1,224,50}, {46,12,1,1,248,25}, {47,12,1,1,248,0},
    {48,12,5,1,255,0}, {53,12,1,1,224,0}, {54,12,1,1,160,50}, {58,12,1,1,224,75}, {59,12,1,1,248,25},
    {60,12,1,1,248,0}, {61,12,4,1,255,0}, {65,12,1,3,248,0}, {66,12,1,1,192,75}, {68,12,1,1,224,75},
    {69,12,3,3,255,0}, {74,12,1,1,192,50}, {75,12,1,1,160,75}, {76,12,1,1,224,75}, {77,12,2,1,224,50},
    {79,12,1,1,248,50}, {80,12,1,1,224,25}, {81,12,3,1,255,0}, {84,12,1,5,224,0}, {86,12,1,1,160,75},
    {90,12,1,1,192,75}, {91,12,1,1,224,50}, {92,12,1,1,248,0}, {93,12,4,1,255,0}, {97,12,1,1,248,0},
    {98,12,1,1,224,50}, {102,12,1,1,224,75}, {103,12,1,1,248,25}, {104,12,2,1,248,0}, {106,12,1,1,224,0},
    {108,12,1,1,224,75}, {109,12,1,1,248,25}, {110,12,1,1,248,0}, {111,12,2,1,255,0}, {113,12,1,1,248,0},
    {114,12,1,1,224,50}, {5,13,1,1,224,50}, {6,13,1,1,224,0}, {7,13,1,1,248,0}, {9,13,2,1,224,0},
    {11,13,1,1,160,75}, {12,13,1,1,192,25}, {13,13,1,1,248,0}, {14,13,2,1,255,0}, {16,13,1,1,248,0},
    {17,13,1,1,224,0}, {18,13,1,1,224,50}, {19,13,1,1,160,75}, {20,13,1,1,128,75}, {29,13,1,1,224,50},
    {30,13,1,1,248,0}, {31,13,7,1,255,0}, {38,13,1,1,224,0}, {39,13,1,1,160,0}, {43,13,1,1,224,50},
    {44,13,1,1,248,0}, {45,13,7,1,255,0}, {52,13,1,1,224,0}, {53,13,1,1,192,0}, {54,13,1,1,128,75},
    {56,13,1,1,192,75}, {57,13,1,1,224,25}, {58,13,7,1,255,0}, {66,13,1,1,224,25}, {68,13,1,1,224,50},
    {72,13,3,1,248,0}, {75,13,8,1,255,0}, {83,13,1,1,248,0}, {86,13,1,1,128,75}, {89,13,1,1,224,50},
    {90,13,1,1,248,0}, {91,13,7,1,255,0}, {98,13,1,2,248,0}, {99,13,1,1,192,50}, {101,13,1,1,224,75},
    {102,13,1,1,248,0}, {103,13,2,1,255,0}, {105,13,1,1,248,0}, {106,13,1,1,224,25}, {107,13,1,1,224,50},
    {108,13,1,1,248,0}, {109,13,3,1,255,0}, {112,13,2,1,248,0}, {114,13,1,4,224,0}, {115,13,1,1,192,75},
    {5,14,1,1,160,75}, {6,14,2,1,192,0}, {8,14,3,1,248,0}, {11,14,1,1,224,25}, {12,14,1,1,160,75},
    {13,14,2,1,224,0}, {15,14,1,1,248,0}, {16,14,3,1,255,0}, {19,14,1,1,248,0}, {20,14,1,1,192,50},
    {28,14,1,1,248,25}, {29,14,4,1,255,0}, {33,14,3,1,248,0}, {36,14,1,1,255,0}, {37,14,1,1,248,0},
    {38,14,1,4,192,0}, {39,14,1,1,160,25}, {42,14,1,1,248,25}, {43,14,4,1,255,0}, {47,14,3,1,248,0},
    {50,14,2,1,255,0}, {52,14,1,2,192,0}, {53,14,1,1,160,0}, {55,14,1,1,224,75}, {56,14,1,1,248,0},
    {57,14,2,1,255,0}, {59,14,1,1,248,0}, {60,14,1,1,224,0}, {61,14,1,1,192,0}, {62,14,1,2,224,0},
    {63,14,2,1,255,0}, {66,14,1,1,192,0}, {68,14,1,1,224,25}, {72,14,1,1,248,0}, {73,14,4,1,255,0},
    {77,14,7,1,248,0}, {88,14,1,1,224,25}, {89,14,3,1,255,0}, {92,14,4,1,248,0}, {96,14,2,1,255,0},
    {99,14,1,3,224,0}, {100,14,1,1,160,75}, {101,14,1,1,224,50}, {102,14,5,1,248,0}, {107,14,1,1,255,0},
    {108,14,6,1,248,0}, {115,14,1,1,192,25}, {6,15,1,1,160,50}, {7,15,2,1,192,0}, {9,15,1,1,224,0},
    {10,15,2,1,248,0}, {12,15,1,1,192,50}, {13,15,1,1,160,75}, {14,15,1,1,224,0}, {15,15,1,1,192,0},
    {16,15,1,1,224,0}, {17,15,4,1,248,0}, {21,15,1,1,192,50}, {27,15,1,1,248,25}, {28,15,3,1,255,0},
    {31,15,1,1,224,0}, {32,15,1,1,192,0}, {33,15,2,1,160,0}, {35,15,1,1,192,0}, {36,15,2,1,248,0},
    {39,15,1,1,160,50}, {41,15,1,1,224,25}, {42,15,3,1,255,0}, {45,15,1,1,224,0}, {46,15,2,1,160,0},
    {48,15,1,1,160,25}, {49,15,1,1,192,0}, {50,15,2,2,248,0}, {53,15,1,2,160,50}, {54,15,1,1,192,75},
    {55,15,1,1,248,0}, {56,15,2,1,255,0}, {58,15,1,1,248,0}, {59,15,1,1,160,0}, {60,15,1,1,128,25},
    {61,15,1,1,128,75}, {63,15,1,2,255,0}, {64,15,1,1,248,0}, {65,15,1,1,192,0}, {66,15,1,1,160,25},
    {68,15,16,1,248,0}, {85,15,1,1,192,25}, {87,15,1,1,224,25}, {88,15,3,1,255,0}, {91,15,1,1,224,0},
    {92,15,3,1,160,0}, {95,15,1,1,192,0}, {96,15,3,1,248,0}, {100,15,1,1,192,75}, {101,15,1,1,224,25},
    {102,15,3,1,248,0}, {105,15,1,1,255,0}, {106,15,1,1,248,0}, {107,15,1,1,224,0}, {108,15,2,1,160,0},
    {110,15,1,1,192,0}, {111,15,1,3,224,0}, {112,15,2,3,248,0}, {115,15,1,1,192,0}, {7,16,1,1,160,50},
    {8,16,2,1,160,0}, {10,16,1,1,192,0}, {11,16,1,1,224,0}, {12,16,1,1,248,0}, {13,16,1,1,192,50},
    {14,16,1,1,160,50}, {15,16,2,1,192,0}, {17,16,3,1,248,0}, {20,16,2,1,224,0}, {22,16,1,1,160,75},
    {26,16,1,1,224,50}, {27,16,2,2,255,0}, {29,16,1,1,248,0}, {30,16,1,1,192,0}, {31,16,1,1,128,0},
    {32,16,1,1,128,75}, {34,16,1,1,160,75}, {35,16,1,1,224,0}, {36,16,1,1,248,0}, {37,16,1,5,224,0},
    {39,16,1,1,128,75}, {40,16,1,1,224,50}, {41,16,3,1,255,0}, {44,16,1,1,192,0}, {45,16,1,1,160,0},
    {46,16,1,1,128,75}, {48,16,1,1,160,75}, {49,16,1,1,224,0}, {52,16,1,3,224,0}, {54,16,1,1,224,25},
    {55,16,2,1,255,0}, {57,16,1,1,248,0}, {58,16,1,1,192,0}, {59,16,1,1,128,50}, {61,16,1,1,224,50},
    {62,16,1,2,248,0}, {64,16,1,1,224,0}, {65,16,1,1,160,0}, {66,16,1,1,128,50}, {67,16,1,1,192,75},
    {68,16,4,1,248,0}, {72,16,5,1,224,0}, {77,16,3,1,192,0}, {80,16,1,2,224,0}, {81,16,3,1,248,0},
    {85,16,1,1,192,50}, {86,16,1,1,224,50}, {87,16,3,1,255,0}, {90,16,1,1,192,0}, {91,16,1,1,160,0},
    {92,16,1,1,128,75}, {95,16,1,1,160,25}, {96,16,1,2,224,0}, {97,16,2,1,248,0}, {100,16,1,1,192,50},
    {101,16,4,1,248,0}, {105,16,1,1,192,0}, {106,16,2,1,160,0}, {108,16,1,1,128,50}, {109,16,1,1,96,75},
    {110,16,1,1,160,50}, {115,16,1,1,160,0}, {8,17,1,1,128,75}, {9,17,1,1,160,25}, {10,17,2,1,160,0},
    {12,17,2,1,192,0}, {14,17,1,1,160,75}, {15,17,1,1,160,50}, {16,17,1,1,160,0}, {17,17,1,3,192,0},
    {18,17,3,1,248,0}, {21,17,1,4,224,0}, {22,17,1,1,192,25}, {25,17,1,1,192,75}, {26,17,1,1,248,0},
    {29,17,1,1,192,0}, {30,17,1,1,128,25}, {34,17,1,1,224,50}, {35,17,2,1,248,0}, {40,17,1,4,248,0},
    {41,17,2,1,255,0}, {43,17,1,1,224,0}, {44,17,1,1,160,0}, {45,17,1,1,128,75}, {48,17,1,1,224,50},
    {49,17,3,2,248,0}, {53,17,1,1,192,50}, {54,17,3,2,255,0}, {57,17,1,1,224,0}, {58,17,1,1,192,25},
    {59,17,1,1,224,50}, {60,17,1,1,224,25}, {61,17,1,1,255,0}, {63,17,1,1,192,0}, {64,17,1,1,160,0},
    {65,17,1,1,128,25}, {67,17,1,1,224,50}, {68,17,3,2,248,0}, {71,17,1,1,224,0}, {72,17,1,2,160,0},
    {73,17,1,1,128,0}, {74,17,6,1,160,0}, {81,17,4,1,248,0}, {85,17,1,1,160,75}, {86,17,1,1,248,0},
    {87,17,2,1,255,0}, {89,17,1,1,224,0}, {90,17,1,1,160,0}, {91,17,1,1,128,75}, {95,17,1,1,192,50},
    {97,17,1,1,248,0}, {98,17,2,1,224,0}, {100,17,1,1,160,50}, {101,17,3,2,248,0}, {104,17,1,3,192,0},
    {105,17,1,1,160,0}, {106,17,1,1,128,25}, {110,17,1,1,128,75}, {114,17,1,2,192,0}, {115,17,1,1,160,25},
    {10,18,2,1,128,75}, {12,18,3,1,128,50}, {16,18,1,1,160,25}, {18,18,1,2,224,0}, {19,18,2,2,248,0},
    {22,18,1,3,192,0}, {23,18,1,1,128,75}, {25,18,1,1,224,50}, {26,18,2,2,255,0}, {28,18,1,1,248,0},
    {29,18,1,1,160,0}, {30,18,1,1,128,75}, {34,18,1,1,224,25}, {35,18,1,1,255,0}, {36,18,1,2,248,0},
    {38,18,1,1,192,25}, {39,18,1,1,192,75}, {41,18,1,3,255,0}, {42,18,1,3,248,0}, {43,18,1,1,192,0},
    {44,18,1,1,128,75}, {48,18,1,1,224,0}, {53,18,1,1,224,25}, {57,18,1,1,248,0}, {58,18,1,1,255,0},
    {59,18,1,1,248,0}, {60,18,1,1,224,0}, {61,18,1,1,192,0}, {62,18,1,1,160,0}, {63,18,1,1,128,0},
    {64,18,1,1,128,50}, {67,18,1,1,224,25}, {71,18,1,3,192,0}, {73,18,4,1,128,50}, {77,18,2,1,128,75},
    {79,18,1,1,192,0}, {80,18,4,2,248,0}, {84,18,1,1,224,0}, {85,18,1,1,192,50}, {86,18,2,1,255,0},
    {88,18,1,4,248,0}, {89,18,1,1,192,0}, {90,18,1,1,128,50}, {95,18,1,1,224,25}, {96,18,2,1,248,0},
    {98,18,1,1,224,0}, {99,18,1,1,192,0}, {100,18,1,1,192,50}, {105,18,1,1,128,25}, {110,18,1,1,192,50},
    {111,18,2,2,248,0}, {113,18,1,1,224,0}, {115,18,1,1,160,50}, {9,19,7,1,128,75}, {16,19,1,1,160,50},
    {23,19,1,1,160,50}, {25,19,1,1,224,0}, {28,19,1,2,224,0}, {29,19,1,2,160,25}, {33,19,1,1,224,25},
    {34,19,2,1,255,0}, {38,19,1,1,160,50}, {39,19,1,1,224,50}, {43,19,1,1,160,0}, {47,19,1,1,224,25},
    {48,19,3,1,248,0}, {51,19,1,2,224,0}, {52,19,1,1,192,25}, {53,19,1,2,224,0}, {54,19,1,2,248,0},
    {55,19,1,3,255,0}, {56,19,1,2,224,0}, {57,19,3,1,160,0}, {60,19,1,1,128,0}, {61,19,1,1,128,25},
    {62,19,1,1,128,50}, {67,19,3,3,248,0}, {70,19,1,2,224,0}, {72,19,1,1,160,25}, {78,19,1,1,128,75},
    {79,19,1,1,224,0}, {84,19,2,1,224,25}, {86,19,1,2,248,0}, {87,19,1,3,255,0}, {89,19,1,1,160,0},
    {90,19,1,1,96,75}, {94,19,1,1,192,75}, {95,19,2,2,248,0}, {97,19,1,1,224,0}, {98,19,1,1,192,0},
    {99,19,1,1,160,25}, {100,19,1,1,224,25}, {101,19,2,2,248,0}, {103,19,1,1,224,0}, {105,19,1,1,160,50},
    {110,19,1,1,224,0}, {113,19,1,1,192,0}, {114,19,1,1,160,0}, {115,19,1,1,128,75}, {6,20,1,1,224,75},
    {7,20,2,1,248,0}, {9,20,6,1,255,0}, {15,20,1,1,248,0}, {16,20,2,1,192,25}, {18,20,1,1,192,0},
    {19,20,1,1,224,0}, {20,20,1,1,248,0}, {23,20,1,1,160,25}, {24,20,1,2,160,75}, {25,20,2,1,248,0},
    {27,20,1,2,255,0}, {31,20,1,1,192,75}, {32,20,1,1,224,25}, {33,20,1,1,255,0}, {34,20,3,1,248,0},
    {38,20,1,1,160,75}, {39,20,1,1,224,25}, {43,20,1,1,192,0}, {44,20,1,1,192,50}, {45,20,1,1,224,50},
    {46,20,2,1,248,0}, {48,20,1,3,224,0}, {49,20,2,1,248,0}, {52,20,1,1,160,50}, {57,20,1,1,192,0},
    {58,20,1,1,128,75}, {63,20,1,1,160,75}, {64,20,1,1,192,50}, {66,20,1,1,192,75}, {72,20,1,1,128,50},
    {78,20,1,1,192,75}, {79,20,3,1,248,0}, {82,20,2,1,224,0}, {84,20,1,1,192,50}, {85,20,1,1,224,25},
    {89,20,1,1,192,0}, {90,20,1,1,128,75}, {93,20,1,1,192,75}, {94,20,1,1,248,25}, {97,20,1,1,192,0},
    {98,20,1,1,160,0}, {99,20,1,1,128,75}, {100,20,1,1,224,0}, {103,20,2,1,224,0}, {105,20,1,1,160,75},
    {108,20,1,1,192,75}, {109,20,1,1,224,25}, {110,20,2,1,248,0}, {112,20,1,1,192,0}, {113,20,1,1,160,0},
    {114,20,1,1,128,50}, {5,21,1,1,224,50}, {6,21,1,1,248,0}, {7,21,7,1,255,0}, {14,21,1,1,224,0},
    {15,21,1,1,160,0}, {16,21,1,1,128,75}, {17,21,1,1,160,75}, {18,21,2,1,192,0}, {20,21,2,1,248,0},
    {22,21,2,1,192,0}, {25,21,1,1,224,0}, {26,21,1,1,248,0}, {28,21,1,1,248,0}, {29,21,2,1,224,0},
    {31,21,2,1,248,0}, {33,21,2,1,224,0}, {35,21,2,1,248,0}, {37,21,1,2,192,0}, {38,21,1,1,96,75},
    {39,21,1,1,192,25}, {40,21,1,1,224,0}, {41,21,4,1,248,0}, {45,21,1,1,255,0}, {46,21,1,1,248,0},
    {47,21,1,2,192,0}, {49,21,1,2,248,0}, {50,21,1,1,224,0}, {51,21,1,1,192,0}, {52,21,1,1,128,75},
    {53,21,1,1,192,0}, {54,21,1,1,224,0}, {56,21,1,1,248,0}, {57,21,2,1,224,0}, {59,21,3,1,224,50},
    {62,21,1,1,224,25}, {63,21,1,1,224,0}, {64,21,1,1,160,25}, {66,21,1,1,224,25}, {70,21,1,2,192,0},
    {71,21,1,1,160,0}, {72,21,1,1,96,75}, {78,21,1,1,224,50}, {79,21,2,1,248,0}, {81,21,2,1,224,0},
    {83,21,1,1,192,0}, {84,21,1,1,160,75}, {85,21,1,1,192,25}, {86,21,1,1,224,0}, {89,21,1,1,224,0},
    {90,21,1,1,192,25}, {91,21,1,1,192,75}, {92,21,1,1,224,50}, {93,21,1,1,248,0}, {94,21,1,1,255,0},
    {95,21,1,1,248,0}, {96,21,1,1,192,0}, {97,21,1,1,160,0}, {98,21,1,1,128,50}, {99,21,1,1,160,75},
    {100,21,3,2,248,0}, {103,21,1,2,224,0}, {104,21,1,2,192,0}, {105,21,2,1,192,50}, {107,21,1,1,224,50},
    {108,21,1,1,248,0}, {109,21,1,1,255,0}, {110,21,1,1,248,0}, {111,21,1,1,192,0}, {112,21,1,1,160,0},
    {113,21,1,1,128,25}, {4,22,1,1,224,50}, {5,22,1,1,248,0}, {6,22,7,1,255,0}, {13,22,1,1,224,0},
    {14,22,1,1,192,0}, {15,22,1,1,128,50}, {18,22,1,1,160,25}, {19,22,1,1,160,0}, {20,22,1,1,192,0},
    {21,22,1,1,248,0}, {22,22,1,1,224,0}, {23,22,1,1,192,0}, {24,22,1,1,128,75}, {25,22,2,1,224,0},
    {27,22,4,1,255,0}, {31,22,1,1,224,0}, {32,22,1,1,192,0}, {33,22,1,1,160,0}, {34,22,1,1,224,0},
    {35,22,1,1,255,0}, {36,22,1,1,248,0}, {39,22,1,1,192,50}, {40,22,1,1,192,0}, {41,22,1,1,224,0},
    {42,22,2,1,255,0}, {44,22,1,1,224,0}, {45,22,1,1,192,0}, {46,22,1,1,160,0}, {50,22,1,1,192,0},
    {51,22,1,1,160,25}, {53,22,1,1,192,25}, {54,22,1,1,192,0}, {55,22,1,1,224,0}, {56,22,6,1,255,0},
    {62,22,1,1,248,0}, {63,22,1,1,192,0}, {64,22,1,1,128,75}, {66,22,1,1,224,0}, {67,22,2,1,248,0},
    {69,22,1,1,224,0}, {71,22,1,1,160,25}, {78,22,1,1,224,25}, {79,22,1,1,248,0}, {80,22,2,1,224,0},
    {82,22,1,1,192,0}, {83,22,1,1,160,0}, {85,22,1,1,192,50}, {86,22,1,1,192,0}, {87,22,1,1,224,0},
    {88,22,1,1,255,0}, {89,22,2,1,248,0}, {91,22,3,1,255,0}, {94,22,1,1,224,0}, {95,22,2,1,160,0},
    {97,22,1,1,128,25}, {99,22,1,1,192,50}, {105,22,1,1,248,0}, {106,22,2,1,255,0}, {108,22,2,1,248,0},
    {110,22,1,1,192,0}, {111,22,1,1,160,0}, {112,22,1,1,128,0}, {113,22,1,1,96,75}, {3,23,1,1,192,75},
    {4,23,1,1,248,0}, {5,23,6,1,255,0}, {11,23,1,1,248,0}, {12,23,1,1,192,0}, {13,23,1,1,160,0},
    {14,23,1,1,128,25}, {19,23,2,1,160,0}, {21,23,1,1,192,0}, {22,23,2,1,224,0}, {24,23,1,1,192,50},
    {25,23,1,1,160,25}, {26,23,2,1,192,0}, {28,23,2,1,224,0}, {30,23,1,1,192,0}, {31,23,1,1,128,0},
    {32,23,1,1,128,25}, {33,23,1,1,192,25}, {34,23,3,1,224,0}, {37,23,1,1,160,25}, {40,23,5,1,160,0},
    {45,23,1,1,128,0}, {46,23,1,1,128,50}, {47,23,1,1,224,0}, {48,23,1,1,248,0}, {49,23,1,1,224,0},
    {50,23,1,2,160,0}, {51,23,1,1,128,50}, {53,23,1,1,128,75}, {54,23,2,1,160,0}, {56,23,1,1,192,0},
    {57,23,1,1,224,0}, {58,23,2,1,248,0}, {60,23,1,1,224,0}, {61,23,1,1,192,0}, {62,23,1,1,160,0},
    {63,23,1,1,128,50}, {65,23,1,1,192,50}, {66,23,2,1,248,0}, {68,23,1,1,224,0}, {69,23,1,1,192,0},
    {70,23,1,1,160,0}, {71,23,1,1,128,50}, {77,23,1,1,160,75}, {78,23,2,1,224,0}, {80,23,1,1,192,0},
    {81,23,1,1,160,0}, {82,23,1,1,128,0}, {83,23,1,1,128,75}, {85,23,1,1,128,75}, {86,23,1,1,160,0},
    {87,23,1,1,192,0}, {88,23,1,1,224,0}, {89,23,1,1,248,0}, {90,23,2,1,255,0}, {92,23,1,1,248,0},
    {93,23,1,1,192,0}, {94,23,1,1,160,0}, {95,23,1,1,128,0}, {96,23,1,1,128,25}, {99,23,1,1,224,25},
    {100,23,2,1,248,0}, {102,23,1,1,224,0}, {103,23,2,1,192,0}, {105,23,2,1,248,0}, {107,23,1,1,224,0},
    {108,23,1,1,192,0}, {109,23,1,1,160,0}, {110,23,1,1,128,0}, {111,23,1,1,128,25}, {112,23,1,1,96,75},
    {2,24,1,1,192,75}, {3,24,1,1,248,0}, {4,24,1,1,255,0}, {5,24,1,1,248,0}, {6,24,2,1,224,0},
    {8,24,2,1,192,0}, {10,24,2,1,160,0}, {12,24,1,1,128,0}, {13,24,1,1,128,50}, {19,24,1,1,128,75},
    {20,24,1,1,128,25}, {21,24,2,1,160,0}, {23,24,1,1,224,0}, {24,24,1,2,192,0}, {25,24,1,1,128,75},
    {26,24,1,1,160,25}, {27,24,4,1,128,0}, {31,24,1,1,128,50}, {33,24,1,1,192,0}, {34,24,2,1,160,0},
    {36,24,1,1,128,0}, {37,24,1,1,128,25}, {40,24,1,1,128,75}, {41,24,1,1,128,50}, {42,24,2,1,128,25},
    {44,24,1,1,128,50}, {46,24,1,1,224,25}, {47,24,1,1,248,0}, {48,24,1,2,224,0}, {49,24,1,1,192,0},
    {51,24,1,1,96,75}, {54,24,1,1,128,75}, {55,24,1,1,128,25}, {56,24,1,1,160,0}, {57,24,5,1,128,0},
    {62,24,1,1,128,50}, {65,24,1,1,224,25}, {66,24,1,1,248,0}, {67,24,1,1,192,0}, {68,24,1,1,160,0},
    {69,24,1,1,128,0}, {70,24,1,1,128,25}, {77,24,1,1,192,50}, {78,24,1,1,192,0}, {79,24,2,1,160,0},
    {81,24,1,1,128,25}, {82,24,1,1,96,75}, {86,24,1,1,128,75}, {87,24,5,1,160,0}, {92,24,2,1,128,0},
    {94,24,1,1,128,25}, {95,24,1,1,128,75}, {99,24,1,2,224,0}, {100,24,1,2,248,0}, {101,24,2,1,224,0},
    {103,24,2,1,160,0}, {105,24,1,1,192,0}, {106,24,4,1,128,0}, {110,24,1,1,128,50}, {2,25,1,1,248,0},
    {3,25,1,1,224,0}, {4,25,1,1,192,0}, {5,25,1,1,160,0}, {6,25,4,1,128,0}, {10,25,1,1,128,25},
    {11,25,1,1,128,50}, {12,25,1,1,96,75}, {21,25,1,1,128,25}, {22,25,2,1,160,0}, {25,25,1,1,160,50},
    {27,25,1,1,128,75}, {28,25,1,1,128,50}, {29,25,1,1,96,75}, {33,25,1,1,128,50}, {34,25,2,1,128,75},
    {45,25,1,1,192,50}, {46,25,2,1,248,0}, {49,25,1,1,160,0}, {50,25,1,1,128,50}, {56,25,1,1,128,75},
    {57,25,2,1,128,50}, {59,25,1,1,128,75}, {60,25,1,1,96,75}, {64,25,1,1,192,75}, {65,25,1,1,224,0},
    {66,25,2,1,160,0}, {68,25,1,1,128,0}, {69,25,1,1,96,50}, {77,25,1,1,160,25}, {78,25,1,1,128,0},
    {79,25,1,1,128,25}, {80,25,1,1,96,75}, {88,25,1,1,128,50}, {89,25,3,1,128,25}, {92,25,1,1,128,50},
    {93,25,1,1,96,75}, {98,25,1,1,160,75}, {101,25,1,1,224,0}, {102,25,1,3,192,0}, {103,25,1,1,160,0},
    {104,25,1,1,128,75}, {105,25,2,1,128,25}, {107,25,1,1,128,50}, {108,25,1,1,96,75}, {1,26,1,1,224,25},
    {2,26,1,1,192,0}, {3,26,1,1,128,0}, {4,26,1,1,128,25}, {5,26,2,1,128,50}, {7,26,1,1,96,75},
    {22,26,1,1,128,50}, {23,26,1,1,128,0}, {24,26,1,1,160,0}, {25,26,1,1,192,0}, {39,26,1,1,160,75},
    {40,26,1,1,128,75}, {42,26,1,1,128,75}, {43,26,1,1,192,75}, {44,26,1,1,224,25}, {45,26,2,1,248,0},
    {47,26,1,1,224,0}, {48,26,1,2,160,0}, {49,26,1,1,128,0}, {50,26,1,1,96,75}, {64,26,1,1,192,25},
    {65,26,1,1,160,0}, {66,26,1,1,128,0}, {67,26,1,1,128,50}, {77,26,1,1,128,75}, {98,26,1,1,192,50},
    {99,26,1,3,248,0}, {100,26,2,2,224,0}, {103,26,1,1,160,25}, {0,27,1,1,160,50}, {1,27,1,1,128,25},
    {2,27,1,1,128,50}, {3,27,1,1,96,75}, {24,27,1,1,128,50}, {25,27,1,1,128,0}, {26,27,1,1,128,50},
    {37,27,1,1,224,50}, {38,27,1,1,248,0}, {39,27,1,1,255,0}, {40,27,3,1,248,0}, {43,27,2,1,255,0},
    {45,27,1,1,248,0}, {46,27,1,1,224,0}, {47,27,1,1,192,0}, {49,27,1,1,128,50}, {63,27,1,1,160,50},
    {64,27,1,1,160,0}, {65,27,1,1,128,50}, {98,27,1,1,224,25}, {103,27,1,1,128,50}, {26,28,1,1,128,75},
    {36,28,1,1,224,50}, {37,28,7,1,248,0}, {44,28,2,1,224,0}, {46,28,1,1,160,0}, {47,28,1,1,128,0},
    {48,28,1,1,128,25}, {63,28,1,1,128,75}, {97,28,1,1,160,75}, {98,28,1,1,224,0}, {100,28,1,1,224,0},
    {101,28,1,1,192,0}, {102,28,1,1,160,0}, {103,28,1,1,128,75}, {35,29,1,1,192,75}, {36,29,3,1,248,0},
    {39,29,5,1,224,0}, {44,29,1,1,192,0}, {45,29,1,1,160,0}, {46,29,1,1,128,0}, {47,29,1,1,128,25},
    {97,29,1,1,192,50}, {98,29,1,1,248,0}, {99,29,1,1,224,0}, {100,29,1,1,192,0}, {101,29,1,1,128,0},
    {102,29,1,1,128,25}, {34,30,1,1,160,75}, {35,30,1,1,224,0}, {36,30,1,1,248,0}, {37,30,1,1,224,0},
    {38,30,3,1,192,0}, {41,30,2,1,160,0}, {43,30,2,1,128,0}, {45,30,1,1,128,25}, {46,30,1,1,128,75},
    {97,30,1,1,224,25}, {98,30,1,1,224,0}, {99,30,1,1,160,0}, {100,30,1,1,128,0}, {101,30,1,1,128,25},
    {34,31,1,1,192,25}, {35,31,1,1,192,0}, {36,31,1,1,160,0}, {37,31,5,1,128,0}, {42,31,1,1,128,25},
    {43,31,1,1,128,50}, {44,31,1,1,96,75}, {96,31,1,1,160,75}, {97,31,1,1,192,0}, {98,31,1,1,128,0},
    {99,31,1,1,128,25}, {100,31,1,1,96,75}, {33,32,1,1,160,75}, {34,32,1,1,160,0}, {35,32,1,1,128,25},
    {36,32,1,1,128,50}, {37,32,2,1,96,75}, {96,32,1,1,160,25}, {97,32,1,1,128,0}, {98,32,1,1,96,50},
    {33,33,1,1,128,75}, {95,33,1,1,128,75}, {96,33,1,1,128,50},
}
for _, r in ipairs(logoGeometry) do
    box(logo, r[1], r[2] + 6, r[3], r[4], Color3.fromRGB(r[5], r[5], r[5]), r[6] / 100)
end
local headerLine = box(root, 1, 74, W - 2, 1, C.accent, 0.25)
make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(0.5, 0.4), NumberSequenceKeypoint.new(1, 0.1)})}, headerLine)

local username = label(top, player.Name, W - 209, 17, 143, 20, 12, C.white)
username.TextXAlignment = Enum.TextXAlignment.Right
local buildLabel = label(top, "RageHop / beta", W - 206, 39, 140, 17, 10, C.dim)
buildLabel.TextXAlignment = Enum.TextXAlignment.Right
local avatar = box(top, W - 53, 19, 33, 35, Color3.fromRGB(31, 31, 31), 0.2)
corner(avatar, 10)
border(avatar, C.soft)
local avatarText = label(avatar, string.upper(string.sub(player.Name, 1, 2)), 0, 0, 33, 35, 11, C.accent)
avatarText.TextXAlignment = Enum.TextXAlignment.Center

local side = box(root, 17, 95, 127, H - 149, C.bg, 1)
local vertical = box(root, 148, 92, 1, H - 145, C.line, 0.55)
local content = box(root, 160, 95, W - 178, H - 148, C.bg, 1)
local navWidths = {60, 62, 56, 58, 52, 52, 58, 46}
local tabNames = {"Main", "Visuals", "Player", "Model", "Fling", "Troll", "Drone", "HUD"}
local tabX = 140
for index, name in ipairs(tabNames) do
    local x, width = tabX, navWidths[index]
    local hit = button(top, "", x, 23, width, 32)
    hit.Name = name .. "Tab"
    hit.BackgroundColor3, hit.BackgroundTransparency = C.white, 0
    corner(hit, 16)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(22, 22, 22),
        Color3.fromRGB(7, 7, 7)), Rotation = 90}, hit)
    local rim = border(hit, Color3.fromRGB(130, 130, 130), 0.3)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(180, 180, 180),
        Color3.fromRGB(48, 48, 48)), Rotation = 65}, rim)
    local title = label(hit, name, 0, 0, width, 32, 11, C.text, Enum.Font.GothamMedium)
    title.TextXAlignment = Enum.TextXAlignment.Center
    local function paint(active, hovered)
        animate(hit, {BackgroundColor3 = (active or hovered) and C.white or Color3.fromRGB(190, 190, 190)})
        animate(rim, {Transparency = active and 0.08 or (hovered and 0.18 or 0.48)})
        animate(title, {TextColor3 = (active or hovered) and C.white or C.dim})
    end
    navigation[name] = {hit = hit, title = title, paint = paint, x = x}
    on(hit.MouseEnter, function() paint(currentTab == name, true) end)
    on(hit.MouseLeave, function() paint(currentTab == name, false) end)
    on(hit.Activated, function() selectPage(name) end)
    tabX = tabX + width + 4
end

local footer = box(root, 1, H - 38, W - 2, 37, C.bg)
box(footer, 0, 0, W - 2, 1, C.line)
local message = label(footer, "RAGEHOP / BETA", 115, 0, W - 322, 37, 9, C.dim)
local footerKey = label(footer, "RSHIFT", W - 197, 0, 117, 37, 9, C.dim)
footerKey.TextXAlignment = Enum.TextXAlignment.Right
local function toast(value)
    message.Text = value
    local ticket = value
    task.delay(3, function() if alive and message.Text == ticket then message.Text = "RAGEHOP / BETA" end end)
end
local function footerButton(name, x, tooltip)
    local b = button(footer, "", x, 8, 23, 23)
    local tint = icon(b, name, 1, 1, C.dim)
    on(b.MouseEnter, function() tint(C.accent); message.Text = tooltip end)
    on(b.MouseLeave, function() tint(C.dim); if message.Text == tooltip then message.Text = "RAGEHOP / BETA" end end)
    return b
end
local searchButton = footerButton("search", 17, "Найти настройку")
local loadButton = footerButton("folder", 51, "Загрузить снимок текущего сеанса")
local saveButton = footerButton("save", 85, "Сохранить снимок до перезапуска скрипта")
local settingsButton = footerButton("settings", W - 54, "Настройки интерфейса")

local function viewport()
    return Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
end
local function resize(center)
    local view = viewport()
    local oldScale = uiScale.Scale
    center = center or Vector2.new(holder.Position.X.Scale * view.X + holder.Position.X.Offset + layoutExtra * oldScale / 2,
        holder.Position.Y.Scale * view.Y + holder.Position.Y.Offset)
    local totalWidth = W + previewExtra
    uiScale.Scale = math.max(0.05, math.min(preferences.scale / 100, (view.X - 28) / totalWidth, (view.Y - 28) / H))
    local scale = uiScale.Scale
    local halfWidth, halfHeight = totalWidth * scale / 2, H * scale / 2
    local x = math.clamp(center.X, halfWidth + 8, math.max(halfWidth + 8, view.X - halfWidth - 8))
    local y = math.clamp(center.Y, halfHeight + 8, math.max(halfHeight + 8, view.Y - halfHeight - 8))
    holder.Position = UDim2.fromOffset(x - previewExtra * scale / 2, y)
    layoutExtra = previewExtra
    if refreshHudLayout then refreshHudLayout() end
end

-- HUD tracks UI toggle states, independently of the main menu visibility.
local hudConfig = {enabled = false, empty = true, scale = 100, opacity = 10, category = true}
local hudDrag, hudVersion = nil, 0
local hud = make("CanvasGroup", {Name = "ActiveTogglesHUD", Position = UDim2.new(1, -232, 0, 100),
    Size = UDim2.fromOffset(220, 69), BackgroundColor3 = C.panel,
    BackgroundTransparency = 0.1, BorderSizePixel = 0, Visible = false, GroupTransparency = 1}, gui)
corner(hud, 8)
border(hud, C.soft, 0.25)
local hudScale = make("UIScale", {Scale = 1}, hud)
local hudHeader = box(hud, 0, 0, 220, 34, C.bg, 1)
hudHeader.Active = true
label(hudHeader, "Active toggles", 12, 0, 158, 34, 12, C.white, Enum.Font.GothamMedium)
local hudCount = label(hudHeader, "0", 178, 0, 29, 34, 10, C.dim)
hudCount.TextXAlignment = Enum.TextXAlignment.Right
box(hud, 12, 34, 196, 1, C.line)
local hudList = make("ScrollingFrame", {Position = UDim2.fromOffset(12, 40), Size = UDim2.fromOffset(196, 23),
    BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
    ScrollBarThickness = 2, ScrollBarImageColor3 = C.soft, ScrollingDirection = Enum.ScrollingDirection.Y}, hud)
local function clampHud()
    local view = viewport()
    hudScale.Scale = math.max(0.1, math.min(hudConfig.scale / 100, (view.X - 16) / 220, (view.Y - 16) / 245))
    local x = hud.Position.X.Scale * view.X + hud.Position.X.Offset
    local y = hud.Position.Y.Scale * view.Y + hud.Position.Y.Offset
    local width, height = 220 * hudScale.Scale, hud.Size.Y.Offset * hudScale.Scale
    hud.Position = UDim2.fromOffset(math.clamp(x, 8, math.max(8, view.X - width - 8)),
        math.clamp(y, 8, math.max(8, view.Y - height - 8)))
end
refreshHudLayout = clampHud
refreshHud = function()
    local entries = {}
    for id, value in pairs(values) do
        if value == true and string.sub(id, 1, 10) ~= "interface/" and string.sub(id, 1, 4) ~= "HUD/" then
            local category = string.match(id, "^([^/]+)/") or ""
            local title = string.match(id, "([^/]+)$") or id
            table.insert(entries, {id = id, title = title, category = category})
        end
    end
    table.sort(entries, function(a, b) return a.id < b.id end)
    hudVersion = hudVersion + 1
    local ticket = hudVersion
    local show = hudConfig.enabled and (hudConfig.empty or #entries > 0)
    if show then
        for _, child in ipairs(hudList:GetChildren()) do child:Destroy() end
        if #entries == 0 then
            label(hudList, "Нет включённых переключателей", 0, 0, 194, 23, 10, C.dim)
        else
            for i, entry in ipairs(entries) do
                local y = (i - 1) * 24
                local dot = box(hudList, 0, y + 10, 3, 3, C.white)
                corner(dot, 2)
                label(hudList, entry.title, 10, y, hudConfig.category and 120 or 181, 23, 11, C.text)
                if hudConfig.category then
                    local category = label(hudList, entry.category, 131, y, 61, 23, 9, C.dim)
                    category.TextXAlignment = Enum.TextXAlignment.Right
                end
            end
        end
        local listHeight = math.min(math.max(1, #entries), 8) * 24
        hudCount.Text = tostring(#entries)
        hudList.Size = UDim2.fromOffset(196, listHeight)
        hudList.CanvasSize = UDim2.fromOffset(0, math.max(1, #entries) * 24)
        hud.Size = UDim2.fromOffset(220, 48 + listHeight)
        hud.BackgroundTransparency = hudConfig.opacity / 100
        clampHud()
        hud.Visible = true
        animate(hud, {GroupTransparency = 0}, 0.18)
    elseif hud.Visible then
        animate(hud, {GroupTransparency = 1}, 0.18)
        local function finish()
            if alive and hudVersion == ticket then hud.Visible = false end
        end
        if preferences.motion then task.delay(0.19, finish) else finish() end
    end
end
on(hudHeader.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hudDrag = {input = input, start = input.Position, position = hud.Position}
    end
end)
on(UIS.InputChanged, function(input)
    if hudDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input == hudDrag.input) then
        local delta = input.Position - hudDrag.start
        hud.Position = UDim2.new(hudDrag.position.X.Scale, hudDrag.position.X.Offset + delta.X,
            hudDrag.position.Y.Scale, hudDrag.position.Y.Offset + delta.Y)
        clampHud()
    end
end)
on(UIS.InputEnded, function(input)
    if hudDrag and (input == hudDrag.input or input.UserInputType == Enum.UserInputType.MouseButton1) then hudDrag = nil end
end)
on(UIS.WindowFocusReleased, function() hudDrag = nil end)

-- Fixed watermark at the marked upper-center position. No drag handlers.
local wmConfig = {enabled = true, fps = true, ping = true, clock = true, scale = 100, opacity = 10}
local wmVersion = 0
local watermark = make("CanvasGroup", {Name = "WatermarkHUD", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.15),
    Size = UDim2.fromOffset(448, 30), BackgroundTransparency = 1,
    GroupTransparency = 1, Visible = false, BorderSizePixel = 0}, gui)
local wmScale = make("UIScale", {Scale = 1}, watermark)
local function watermarkSegment(x, width)
    local segment = box(watermark, x, 0, width, 30, Color3.fromRGB(18, 18, 18), 0.1)
    corner(segment, 9)
    local rim = border(segment, Color3.fromRGB(75, 75, 75), 0.28)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(190, 190, 190),
        Color3.fromRGB(62, 62, 62)), Rotation = 90}, rim)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(230, 230, 230),
        Color3.fromRGB(140, 140, 140)), Rotation = 90}, segment)
    segment.Active = false
    return segment
end
local wmBrand = watermarkSegment(0, 82)
local wmInfo = watermarkSegment(88, 360)
local wmLogo = logo:Clone()
wmLogo.Name, wmLogo.Position = "WatermarkLogo", UDim2.fromOffset(11, 3)
wmLogo:FindFirstChildOfClass("UIScale").Scale = 0.52
wmLogo.Parent = wmBrand
local wmAvatar = make("ImageLabel", {Position = UDim2.fromOffset(10, 6), Size = UDim2.fromOffset(18, 18),
    BackgroundColor3 = C.raised, BorderSizePixel = 0,
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=48&h=48"}, wmInfo)
corner(wmAvatar, 9)
label(wmInfo, player.DisplayName, 36, 0, 85, 30, 10, C.text, Enum.Font.GothamMedium)
local wmFields = {}
local function wmField(name, width)
    local field = box(wmInfo, 0, 0, width, 30, C.bg, 1)
    box(field, 0, 9, 1, 12, C.soft, 0.25)
    local ink = Color3.fromRGB(135, 135, 135)
    if name == "fps" then
        for i = 0, 2 do
            local layer = box(field, 13, 10 + i * 3, 9, 5, ink, 1)
            corner(layer, 2)
            border(layer, ink, 0.15)
        end
    elseif name == "ping" then
        for i = 0, 2 do
            local height = 3 + i * 3
            local bar = box(field, 12 + i * 4, 20 - height, 2, height, ink)
            corner(bar, 1)
        end
    else
        local clockFace = box(field, 12, 9, 12, 12, ink, 1)
        corner(clockFace, 6)
        border(clockFace, ink, 0.1)
        box(clockFace, 5, 2, 1, 5, ink)
        box(clockFace, 5, 6, 4, 1, ink)
    end
    local value = label(field, "—", 30, 0, width - 36, 30, 10, C.text)
    wmFields[name] = {frame = field, value = value, width = width}
end
wmField("fps", 71)
wmField("ping", 83)
wmField("clock", 68)
local wmWidth = 448
local function clampWatermark()
    local view = viewport()
    wmScale.Scale = math.max(0.05, math.min(wmConfig.scale / 100, (view.X - 16) / wmWidth, (view.Y - 16) / 30))
    local halfWidth = wmWidth * wmScale.Scale / 2
    local halfHeight = 30 * wmScale.Scale / 2
    -- Fixed center: 50% across and 15% down the screen.
    watermark.Position = UDim2.fromOffset(
        math.clamp(view.X * 0.5, halfWidth + 8, math.max(halfWidth + 8, view.X - halfWidth - 8)),
        math.clamp(view.Y * 0.15, halfHeight + 8, math.max(halfHeight + 8, view.Y - halfHeight - 8)))
end
local function refreshWatermark()
    local cursor = 130
    for _, name in ipairs({"fps", "ping", "clock"}) do
        local field = wmFields[name]
        field.frame.Visible = wmConfig[name]
        if wmConfig[name] then
            field.frame.Position = UDim2.fromOffset(cursor, 0)
            cursor = cursor + field.width
        end
    end
    local infoWidth = cursor + 8
    wmInfo.Size = UDim2.fromOffset(infoWidth, 30)
    wmWidth = 88 + infoWidth
    watermark.Size = UDim2.fromOffset(wmWidth, 30)
    wmBrand.BackgroundTransparency, wmInfo.BackgroundTransparency = wmConfig.opacity / 100, wmConfig.opacity / 100
    clampWatermark()
    wmVersion = wmVersion + 1
    local ticket = wmVersion
    if wmConfig.enabled then
        watermark.Visible = true
        animate(watermark, {GroupTransparency = 0}, 0.2)
    elseif watermark.Visible then
        animate(watermark, {GroupTransparency = 1}, 0.18)
        local function finish()
            if alive and wmVersion == ticket then watermark.Visible = false end
        end
        if preferences.motion then task.delay(0.19, finish) else finish() end
    end
end
refreshHudLayout = function() clampHud(); clampWatermark() end
local fpsFrames, fpsElapsed = 0, 0
wmFields.clock.value.Text = os.date("%H:%M")
wmFields.ping.value.Text = "— ms"
on(RunService.RenderStepped, function(dt)
    if not wmConfig.enabled then fpsFrames, fpsElapsed = 0, 0; return end
    fpsFrames, fpsElapsed = fpsFrames + 1, fpsElapsed + dt
    if fpsElapsed < 0.75 then return end
    wmFields.fps.value.Text = tostring(math.floor(fpsFrames / fpsElapsed + 0.5))
    fpsFrames, fpsElapsed = 0, 0
    if wmConfig.ping then
        local ok, ping = pcall(function()
            local item = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            return item and item:GetValue()
        end)
        wmFields.ping.value.Text = ok and type(ping) == "number" and tostring(math.floor(math.max(0, ping) + 0.5)) .. "ms" or "— ms"
    end
    if wmConfig.clock then wmFields.clock.value.Text = os.date("%H:%M") end
end)


-- Interface definitions. Gameplay callbacks are intentionally absent.
local function check(title, initial, callback) return {kind = "check", title = title, initial = initial or false, callback = callback} end
local function range(title, low, high, initial, suffix, callback) return {kind = "range", title = title, low = low, high = high, initial = initial, suffix = suffix or "", callback = callback} end
local function action(title, callback, caption) return {kind = "action", title = title, callback = callback or function() toast("Только интерфейс меню") end, caption = caption} end
local function choice(title, options, initial, callback) return {kind = "choice", title = title, options = options, initial = initial, callback = callback} end
local definitions = {
    Main = {
        {name = "Combat", variants = {
        {name = "Sheriff", groups = {
            {title = "SHERIFF", controls = {
                check("Silent Aim", false, nil),
                check("Force Shot", false, nil),
                check("Auto Shot", false, nil),
                check("Только с ножом", false, nil),
                range("fov", 20, 400, 160, " px", nil),
                check("Круг FOV", true, nil),
                range("Дистанция стрельбы", 10, 2000, 1000, " studs", nil),
            }},
            {title = "REVOLVER", controls = {
                check("Prediction", true, nil),
                range("lead", 0, 200, 100, "%", nil),
                range("extra lead", 0, 200, 0, " ms", nil),
                range("shot delay", 2600, 5500, 3200, " ms", nil),
            }},
        }},
        {name = "Murderer", groups = {
            {title = "MURDERER", controls = {
                check("kill aura", false, nil),
                range("aura radius", 5, 200, 20, " studs", nil),
                check("kill all", false, nil),
                check("kill gun players", false, nil),
                action("Бросить нож в цель", nil, "БРОСОК"),
            }},
            {title = "KNIFE", controls = {
                check("throw silent", false, nil),
                check("auto throw", false, nil),
                check("prediction", true, nil),
                range("lead", 0, 150, 100, "%", nil),
                range("knife speed", 85, 108, 96, " studs/s", nil),
                range("max distance", 30, 400, 250, " studs", nil),
            }},
            {title = "TARGETING", settingsKey = "KNIFE", controls = {
                range("aim fov", 10, 360, 360, "°", nil),
                range("auto range", 20, 200, 70, " studs", nil),
                range("throw delay", 1450, 5000, 1500, " ms", nil),
                check("wall check", true, nil),
                check("sticky target", true, nil),
                check("sheriff first", false, nil),
            }},
        }},
        {name = "Survivors", groups = {
            {title = "GUN PICKUP", controls = {
                check("Взять пистолет", false, nil),
            }},
            {title = "SURVIVORS", controls = {check("auto collect"), range("distance", 1, 100, 25, " studs")}},
        }},
        }},
        {name = "Auto Farm", groups = {
            {title = "FARM", controls = {
                choice("Что собирать", {"Конфеты", "Монеты"}, "Конфеты", nil),
                check("Auto Farm", false, nil),
                range("Скорость фарма", 8, 22, 21, " studs/s", nil),
                check("Подбирать Gun", true, nil),
                check("Избегать убийцы", false, nil),
            }},
            {title = "FULL BAG / ROUND", controls = {
                check("Стрелять при полном", true, nil),
                check("Респавн при полном", false, nil),
                check("Убить всех с Knife", false, nil),
                check("Fling после респавна", false, nil),
            }},
        }},
    },
    Visuals = {
        {name = "Auras", groups = {
            {title = "AURA", controls = {
                check("Аура", false, nil),
                choice("Стиль ауры", {"Кольцо", "Орбита", "Пульс"}, "Кольцо", nil),
                range("Размер ауры", 60, 180, 100, "%", nil),
                range("Скорость ауры", 0, 200, 100, "%", nil),
                range("Прозрачность ауры", 0, 85, 20, "%", nil),
            }},
            {title = "PREVIEW", note = "Справа показан твой персонаж.\nЗажми мышь и поверни модель.\nАуры видны только тебе."},
        }},
        {name = "Players", groups = {
            {title = "PLAYER ESP", controls = {
                check("enabled", false, nil),
                check("boxes", true, nil),
                check("names", true, nil),
                check("health bar", true, nil),
                check("distance", true, nil),
                check("chams", false, nil),
            }},
            {title = "STYLE", controls = {
                range("max distance", 0, 1000, 500, " studs", nil),
                range("text size", 8, 24, 12, "", nil),
                check("team colors", false, nil),
                check("Угловые рамки", true, nil),
                check("Лёгкая заливка", false, nil),
                check("Роли игроков", true, nil),
                check("Число HP", true, nil),
                check("Линии к игрокам", false, nil),
                range("Прозрачность chams", 10, 100, 75, "%", nil),
            }},
        }},
        {name = "Aim", groups = {
            {title = "FOV / TARGET", controls = {
                range("Толщина круга", 1, 3, 1, " px", nil),
                range("Прозрачность FOV", 0, 85, 22, "%", nil),
                check("Метка цели", true, nil),
                check("Точка prediction", true, nil),
            }},
            {title = "CROSSHAIR", controls = {
                check("Прицел", false, nil),
                range("Размер прицела", 3, 14, 6, " px", nil),
            }},
        }},
        {name = "World", groups = {
            {title = "LIGHTING", controls = {
                check("fullbright", false, nil),
                range("Яркость", 0, 500, 200, "%", nil),
                check("no fog", false, nil),
                check("Своё время суток", false, nil),
                range("Время суток", 0, 24, 18, " h", nil),
            }},
            {title = "COLOR / GLOW", controls = {
                check("Мягкая цветокоррекция", false, nil),
                range("Контраст", 0, 40, 8, "%", nil),
                range("Насыщенность", -100, 100, -12, "%", nil),
                check("Мягкое свечение", false, nil),
                range("Сила свечения", 0, 60, 18, "%", nil),
            }},
        }},
    },
    Player = {
        {name = "Movement", groups = {
            {title = "MOVEMENT", controls = {check("speed override"), range("walk speed", 16, 100, 16), check("jump override"), range("jump power", 0, 150, 50)}},
            {title = "EXTRA", controls = {
                check("fly", false, nil),
                range("fly speed", 1, 150, 50, "", nil),
                check("cframe fly", false, nil),
                check("anti ragdoll"),
            }},
        }},
        {name = "Camera", groups = {{title = "CAMERA", controls = {range("field of view", 30, 120, 70, "°"), check("third person")}}}},
    },
    Model = {
        {name = "Guns", groups = {{title = "GUN MODEL", controls = {
            check("Своя модель", false, nil),
            choice("Оружие", {"AWP", "USP-S"}, "AWP", nil),
        }}}},
        {name = "Skin", groups = {}},
    },
    Fling = {{name = "Players", groups = {}}},
    Troll = {
        {name = "Fun", groups = {
            {title = "FUN", controls = {
                check("Спин",false,nil),
                range("Скорость спина",2,200,20," rad/s",nil),
                check("Roblox Egor",false,nil),
                action("Фейковая смерть 1",nil,"АНИМ."),
                action("Фейковая смерть 2",nil,"АНИМ."),
                action("Сбросить анимации",nil,"СБРОС"),
            }},
            {title = "ANIMATIONS",note = "Roblox Egor: медленная ходьба с быстрой анимацией.\nФейковая смерть сбрасывается при движении.\nДоступность анимаций зависит от игры."},
        }},
        {name = "Fake Lag", groups = {
            {title = "FAKE LAG", controls = {
                check("Fake Lag",false,nil),
                range("Интервал",10,1000,70," ms",nil),
                range("Замирание",300,2000,400," ms",nil),
                check("Рывки при движении",false,nil),
                range("Дистанция рывка",5,50,5," studs",nil),
            }},
            {title = "INFO",note = "Fake Lag чередует замирание и движение персонажа.\nFly, Drone, Fling и Auto Farm ставят эффекты Troll на паузу."},
        }},
    },
    Drone = {{name = "Control", groups = {{title = "DRONE", controls = {
        action("Запустить дрон", nil, "ПОЛЁТ"),
        action("Вернуться", nil, "СТОП"),
        range("Скорость", 20, 150, 65, " studs/s", nil),
        range("Радиус попадания", 0, 2, 0, " studs", nil),
        range("Дистанция камеры", 7, 22, 12, " studs", nil),
    }}}}},
    HUD = {
        {name = "Watermark", groups = {
            {title = "WATERMARK", controls = {
                check("показывать ватермарк", true, function(v) wmConfig.enabled = v; refreshWatermark() end),
                range("масштаб", 70, 150, 100, "%", function(v) wmConfig.scale = v; refreshWatermark() end),
                range("прозрачность", 0, 50, 10, "%", function(v) wmConfig.opacity = v; refreshWatermark() end),
            }},
            {title = "ELEMENTS", controls = {
                check("показывать FPS", true, function(v) wmConfig.fps = v; refreshWatermark() end),
                check("показывать пинг", true, function(v) wmConfig.ping = v; refreshWatermark() end),
                check("показывать время", true, function(v) wmConfig.clock = v; refreshWatermark() end),
            }},
        }},
        {name = "Display", groups = {
            {title = "ACTIVE TOGGLES", controls = {
                check("показывать панель", false, function(v) hudConfig.enabled = v; refreshHud() end),
                check("показывать пустую", true, function(v) hudConfig.empty = v; refreshHud() end),
                range("масштаб HUD", 70, 130, 100, "%", function(v) hudConfig.scale = v; refreshHud() end),
            }},
            {title = "APPEARANCE", controls = {
                check("названия вкладок", true, function(v) hudConfig.category = v; refreshHud() end),
                range("прозрачность", 0, 50, 10, "%", function(v) hudConfig.opacity = v; refreshHud() end),
            }},
        }},
        {name = "About", groups = {{title = "HUD", note = "Панель можно перетаскивать за заголовок. Она показывает состояния переключателей меню."}}},
    },
}

local skinGallery = {catalog = game:GetService("HttpService"):JSONDecode([=[[{"id":"UFOKnife","name":"Alienbeam","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=77607127867154&w=420&h=420"},{"id":"Amerilaser","name":"Amerilaser","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=446050753&w=420&h=420"},{"id":"AuroraKnife","name":"Australis","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=101343256002049&w=420&h=420"},{"id":"ZombieBat","name":"Bat","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11229814357&w=420&h=420"},{"id":"BattleAxe","name":"BattleAxe","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1133237368&w=420&h=420"},{"id":"BattleAxe2","name":"BattleAxe II","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=2513535503&w=420&h=420"},{"id":"Scythe","name":"Batwing","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=375690925&w=420&h=420"},{"id":"Bauble","name":"Bauble","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=84481559639371&w=420&h=420"},{"id":"Beachy","name":"Beachy","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=120888453565511&w=420&h=420"},{"id":"Bioblade","name":"Bioblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4751540097&w=420&h=420"},{"id":"Blaster","name":"Blaster","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=386277381&w=420&h=420"},{"id":"Blizzard","name":"Blizzard","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=88928894807422&w=420&h=420"},{"id":"Bloom","name":"Bloom","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=132419834610569&w=420&h=420"},{"id":"Blossom_G","name":"Blossom","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=12339377105&w=420&h=420"},{"id":"BlueSeer","name":"Blue Seer","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3184139996&w=420&h=420"},{"id":"Boneblade","name":"Boneblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=2513505477&w=420&h=420"},{"id":"AuroraGun","name":"Borealis","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=108635848059846&w=420&h=420"},{"id":"Candleflame","name":"Candleflame","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=7805833970&w=420&h=420"},{"id":"Candy","name":"Candy","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=332021011&w=420&h=420"},{"id":"Celestial","name":"Celestial","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=136673966529736&w=420&h=420"},{"id":"Chill","name":"Chill","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=332022166&w=420&h=420"},{"id":"UFOKnifeChroma","name":"Chroma Alienbeam","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=104256106059730&w=420&h=420"},{"id":"BaubleChroma","name":"Chroma Bauble","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=137938731902685&w=420&h=420"},{"id":"BeachyChroma","name":"Chroma Beachy","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=140314060642852&w=420&h=420"},{"id":"BlizzardChroma","name":"Chroma Blizzard","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=128221996859844&w=420&h=420"},{"id":"BonebladeChroma","name":"Chroma Boneblade","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=2513597845&w=420&h=420"},{"id":"CandleflameChroma","name":"Chroma Candleflame","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=7806149582&w=420&h=420"},{"id":"ConstellationChroma","name":"Chroma Constellation","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=98517109155878&w=420&h=420"},{"id":"Gingermint_KChroma","name":"Chroma Cookiecane","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=11979596437&w=420&h=420"},{"id":"ChromaDarkbringer","name":"Chroma Darkbringer","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=4751507011&w=420&h=420"},{"id":"DeathshardChroma","name":"Chroma Deathshard","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187397317&w=420&h=420"},{"id":"ElderwoodKnifeChroma","name":"Chroma Elderwood Blade","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=11255021976&w=420&h=420"},{"id":"TreeKnife2023Chroma","name":"Chroma Evergreen","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=15694192241&w=420&h=420"},{"id":"TreeGun2023Chroma","name":"Chroma Evergun","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=15694208971&w=420&h=420"},{"id":"FangChroma","name":"Chroma Fang","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187397850&w=420&h=420"},{"id":"GemstoneChroma","name":"Chroma Gemstone","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3183657875&w=420&h=420"},{"id":"GingerbladeChroma","name":"Chroma Gingerblade","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=2672351679&w=420&h=420"},{"id":"HeartWandChroma","name":"Chroma Heart Wand","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=112139581726305&w=420&h=420"},{"id":"HeatChroma","name":"Chroma Heat","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187444849&w=420&h=420"},{"id":"IcecreamChroma","name":"Chroma Icecream","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=96898758158389&w=420&h=420"},{"id":"LaserChroma","name":"Chroma Laser","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187422628&w=420&h=420"},{"id":"ChromaLightbringer","name":"Chroma Lightbringer","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=4751507078&w=420&h=420"},{"id":"LugerChroma","name":"Chroma Luger","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187399258&w=420&h=420"},{"id":"BaubleKnifeChroma","name":"Chroma Ornament","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=109529888742973&w=420&h=420"},{"id":"RaygunChroma","name":"Chroma Raygun","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=83259634072260&w=420&h=420"},{"id":"SandsChroma","name":"Chroma Sands","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=86168413958858&w=420&h=420"},{"id":"SawChroma","name":"Chroma Saw","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187398132&w=420&h=420"},{"id":"SeerChroma","name":"Chroma Seer","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3184140321&w=420&h=420"},{"id":"SharkChroma","name":"Chroma Shark","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187421856&w=420&h=420"},{"id":"SlasherChroma","name":"Chroma Slasher","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187398385&w=420&h=420"},{"id":"SnowDaggerChroma","name":"Chroma Snow Dagger","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=88800167694751&w=420&h=420"},{"id":"SnowcannonChroma","name":"Chroma Snowcannon","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=85283931666319&w=420&h=420"},{"id":"SnowstormChroma","name":"Chroma Snowstorm","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=138236810069600&w=420&h=420"},{"id":"SunsetGunChroma","name":"Chroma Sunrise","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=124766755976937&w=420&h=420"},{"id":"SunsetKnifeChroma","name":"Chroma Sunset","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=118232478609755&w=420&h=420"},{"id":"SweetChroma","name":"Chroma Sweet","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=104484904779308&w=420&h=420"},{"id":"SwirlyGunChroma","name":"Chroma Swirly Gun","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=8311453396&w=420&h=420"},{"id":"TidesChroma","name":"Chroma Tides","kind":"Knife","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=3187398906&w=420&h=420"},{"id":"TravelerGunChroma","name":"Chroma Traveler's Gun","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=15097920149&w=420&h=420"},{"id":"TreatChroma","name":"Chroma Treat","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=114308643779951&w=420&h=420"},{"id":"VampireGunChroma","name":"Chroma Vampire's Gun","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=85107391551890&w=420&h=420"},{"id":"WatergunChroma","name":"Chroma Watergun","kind":"Gun","rarity":"Godly","chroma":true,"image":"rbxthumb://type=Asset&id=18351465514&w=420&h=420"},{"id":"Clockwork","name":"Clockwork","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=360609441&w=420&h=420"},{"id":"Constellation","name":"Constellation","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=114197436469014&w=420&h=420"},{"id":"Cookieblade","name":"Cookieblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6121574620&w=420&h=420"},{"id":"Gingermint_K","name":"Cookiecane","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11855306927&w=420&h=420"},{"id":"Sorry","name":"Corrupt","kind":"Knife","rarity":"Unique","chroma":false,"image":"rbxthumb://type=Asset&id=197879343&w=420&h=420"},{"id":"Darkbringer","name":"Darkbringer","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4751387674&w=420&h=420"},{"id":"Darkshot","name":"Darkshot","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=15080280688&w=420&h=420"},{"id":"Darksword","name":"Darksword","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=15080267070&w=420&h=420"},{"id":"Dartbringer","name":"Dartbringer","kind":"Gun","rarity":"Unique","chroma":false,"image":"rbxthumb://type=Asset&id=8626617523&w=420&h=420"},{"id":"Deathshard","name":"Deathshard","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3175017717&w=420&h=420"},{"id":"Eggblade","name":"Eggblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6607512359&w=420&h=420"},{"id":"ElderwoodKnife","name":"Elderwood Blade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11254879631&w=420&h=420"},{"id":"ElderwoodGun","name":"Elderwood Revolver","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4468571736&w=420&h=420"},{"id":"ElderwoodScythe","name":"Elderwood Scythe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=4468593654&w=420&h=420"},{"id":"Eternal","name":"Eternal","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=538706317&w=420&h=420"},{"id":"Eternal2","name":"Eternal II","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=2545253030&w=420&h=420"},{"id":"Eternal3","name":"Eternal III","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3281170430&w=420&h=420"},{"id":"Eternal4","name":"Eternal IV","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4999958740&w=420&h=420"},{"id":"EternalCane","name":"Eternalcane","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4488391411&w=420&h=420"},{"id":"TreeKnife2023","name":"Evergreen","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=15694357137&w=420&h=420"},{"id":"TreeGun2023","name":"Evergun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=15694357721&w=420&h=420"},{"id":"Fang","name":"Fang","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187397768&w=420&h=420"},{"id":"Flames","name":"Flames","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=585873746&w=420&h=420"},{"id":"Flora","name":"Flora","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=139276091458016&w=420&h=420"},{"id":"FlowerwoodKnife","name":"Flowerwood","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=16963860501&w=420&h=420"},{"id":"FlowerwoodGun","name":"Flowerwood Gun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=16963894455&w=420&h=420"},{"id":"Frostbite","name":"Frostbite","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4528373246&w=420&h=420"},{"id":"Frostsaber","name":"Frostsaber","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1268934541&w=420&h=420"},{"id":"Gemstone","name":"Gemstone","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3183657748&w=420&h=420"},{"id":"Ghostblade","name":"Ghostblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4217586790&w=420&h=420"},{"id":"GingerLuger","name":"Ginger Luger","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=2674983099&w=420&h=420"},{"id":"Gingerblade","name":"Gingerblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=2669336659&w=420&h=420"},{"id":"Gingermint_G","name":"Gingermint","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11872179646&w=420&h=420"},{"id":"Gingerscope","name":"Gingerscope","kind":"Gun","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=15666596216&w=420&h=420"},{"id":"Gingerscythe_Ancient","name":"Gingerscythe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=15683188776&w=420&h=420"},{"id":"GreenLuger","name":"Green Luger","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=332044679&w=420&h=420"},{"id":"HallowsBlade","name":"Hallow's Blade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1132775323&w=420&h=420"},{"id":"Hallow","name":"Hallow's Edge","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=531878205&w=420&h=420"},{"id":"Hallowgun","name":"Hallowgun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=5877089721&w=420&h=420"},{"id":"Hallowscythe","name":"Hallowscythe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=5877016863&w=420&h=420"},{"id":"Handsaw","name":"Handsaw","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=332042435&w=420&h=420"},{"id":"Harvester","name":"Harvester","kind":"Gun","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=7800847534&w=420&h=420"},{"id":"HeartWand","name":"Heart Wand","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=118334707962654&w=420&h=420"},{"id":"Heartblade","name":"Heartblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6413214382&w=420&h=420"},{"id":"Heat","name":"Heat","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187444758&w=420&h=420"},{"id":"IceDragon","name":"Ice Dragon","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=585846454&w=420&h=420"},{"id":"IceShard","name":"Ice Shard","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1268710824&w=420&h=420"},{"id":"Icebeam","name":"Icebeam","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=8305000161&w=420&h=420"},{"id":"Iceblaster","name":"Iceblaster","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6121579464&w=420&h=420"},{"id":"Icebreaker","name":"Icebreaker","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=6121572723&w=420&h=420"},{"id":"Icecream","name":"Icecream","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=87189663191639&w=420&h=420"},{"id":"IceHammer_Ancient","name":"Icecrusher","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=11855274019&w=420&h=420"},{"id":"Iceflake","name":"Iceflake","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=8304818186&w=420&h=420"},{"id":"Icepiercer","name":"Icepiercer","kind":"Gun","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=11874071041&w=420&h=420"},{"id":"Icewing","name":"Icewing","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=2669997196&w=420&h=420"},{"id":"Jinglegun","name":"Jinglegun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6121678262&w=420&h=420"},{"id":"Laser","name":"Laser","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187422496&w=420&h=420"},{"id":"Lightbringer","name":"Lightbringer","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4751387063&w=420&h=420"},{"id":"Logchopper","name":"Logchopper","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=4528268775&w=420&h=420"},{"id":"Luger","name":"Luger","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187399148&w=420&h=420"},{"id":"Lugercane","name":"Lugercane","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4535482609&w=420&h=420"},{"id":"Makeshift","name":"Makeshift","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11229837140&w=420&h=420"},{"id":"Minty","name":"Minty","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=4528291487&w=420&h=420"},{"id":"Nebula","name":"Nebula","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6598123521&w=420&h=420"},{"id":"Nightblade","name":"Nightblade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=475478854&w=420&h=420"},{"id":"NikKnife","name":"Nik's Scythe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=2533350813&w=420&h=420"},{"id":"Ocean_G","name":"Ocean","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=13933165014&w=420&h=420"},{"id":"AmericaSword","name":"Old Glory","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=446047742&w=420&h=420"},{"id":"OrangeSeer","name":"Orange Seer","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3184139504&w=420&h=420"},{"id":"BaubleKnife","name":"Ornament","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=111092946728824&w=420&h=420"},{"id":"Pearl_K","name":"Pearl","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=18322621319&w=420&h=420"},{"id":"Pearl_G","name":"Pearlshine","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=18322646152&w=420&h=420"},{"id":"Peppermint","name":"Peppermint","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=6076067750&w=420&h=420"},{"id":"Phantom2022","name":"Phantom","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11229732037&w=420&h=420"},{"id":"Pixel","name":"Pixel","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=365347166&w=420&h=420"},{"id":"Plasmabeam","name":"Plasmabeam","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=10014717343&w=420&h=420"},{"id":"Plasmablade","name":"Plasmablade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=10014680882&w=420&h=420"},{"id":"Prismatic","name":"Prismatic","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=5360359935&w=420&h=420"},{"id":"Pumpking","name":"Pumpking","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1133082421&w=420&h=420"},{"id":"PurpleSeer","name":"Purple Seer","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3184140119&w=420&h=420"},{"id":"Rainbow_K","name":"Rainbow","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=12966184630&w=420&h=420"},{"id":"Rainbow_G","name":"Rainbow Gun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=12966354606&w=420&h=420"},{"id":"Raygun","name":"Raygun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=139431943195380&w=420&h=420"},{"id":"Reaver_Ancient","name":"Reaver","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=7791640819&w=420&h=420"},{"id":"RedLuger","name":"Red Luger","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=332044583&w=420&h=420"},{"id":"RedSeer","name":"Red Seer","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3184139367&w=420&h=420"},{"id":"Sakura_K","name":"Sakura","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=12339366064&w=420&h=420"},{"id":"Sands","name":"Sands","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=119213058412452&w=420&h=420"},{"id":"Saw","name":"Saw","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187397991&w=420&h=420"},{"id":"TheSeer","name":"Seer","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3184139765&w=420&h=420"},{"id":"Shark","name":"Shark","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187421705&w=420&h=420"},{"id":"SharkSeeker","name":"SharkSeeker","kind":"Gun","rarity":"Unique","chroma":false,"image":"rbxthumb://type=Asset&id=6967771328&w=420&h=420"},{"id":"Slasher","name":"Slasher","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187398274&w=420&h=420"},{"id":"SnowDagger","name":"Snow Dagger","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=95328449981238&w=420&h=420"},{"id":"Snowcannon","name":"Snowcannon","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=129186939023729&w=420&h=420"},{"id":"Snowflake","name":"Snowflake","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1268932977&w=420&h=420"},{"id":"Snowstorm","name":"Snowstorm","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=70973050894155&w=420&h=420"},{"id":"WraithGun","name":"Soul","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=75233248021696&w=420&h=420"},{"id":"Spectre2022","name":"Spectre","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=11229779932&w=420&h=420"},{"id":"Spider","name":"Spider","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=315120760&w=420&h=420"},{"id":"WraithKnife","name":"Spirit","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=107190526940939&w=420&h=420"},{"id":"Sugar","name":"Sugar","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3215356000&w=420&h=420"},{"id":"SunsetGun","name":"Sunrise","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=129480661108374&w=420&h=420"},{"id":"SunsetKnife","name":"Sunset","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=103526268515240&w=420&h=420"},{"id":"Sweet","name":"Sweet","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=126937716954396&w=420&h=420"},{"id":"SwirlyAxe","name":"Swirly Axe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=8304801000&w=420&h=420"},{"id":"SwirlyBlade","name":"Swirly Blade","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=8304805693&w=420&h=420"},{"id":"SwirlyGun","name":"Swirly Gun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=8305002569&w=420&h=420"},{"id":"Synthwave_Ancient","name":"Synthwave","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=133828016595037&w=420&h=420"},{"id":"Tides","name":"Tides","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3187398809&w=420&h=420"},{"id":"TravelerAxe","name":"Traveler's Axe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=15070870271&w=420&h=420"},{"id":"TravelerGun","name":"Traveler's Gun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=15091442039&w=420&h=420"},{"id":"Treat","name":"Treat","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=131626924640663&w=420&h=420"},{"id":"Turkey2023","name":"Turkey","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=15413162319&w=420&h=420"},{"id":"VampireAxe","name":"Vampire's Axe","kind":"Knife","rarity":"Ancient","chroma":false,"image":"rbxthumb://type=Asset&id=130837676383567&w=420&h=420"},{"id":"VampiresEdge","name":"Vampire's Edge","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=5873256998&w=420&h=420"},{"id":"VampireGun","name":"Vampire's Gun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=90274872705656&w=420&h=420"},{"id":"Virtual","name":"Virtual","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=386276987&w=420&h=420"},{"id":"Watergun","name":"Watergun","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=18351388416&w=420&h=420"},{"id":"Waves_K","name":"Waves","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=13933066522&w=420&h=420"},{"id":"WintersEdge","name":"Winter's Edge","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=1268708987&w=420&h=420"},{"id":"XenoKnife","name":"Xenoknife","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=115021756767182&w=420&h=420"},{"id":"XenoGun","name":"Xenoshot","kind":"Gun","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=96859273002742&w=420&h=420"},{"id":"Xmas","name":"Xmas","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=332077449&w=420&h=420"},{"id":"YellowSeer","name":"Yellow Seer","kind":"Knife","rarity":"Godly","chroma":false,"image":"rbxthumb://type=Asset&id=3184139648&w=420&h=420"}]]=]), running=true, granted={}, status="Только интерфейс меню"}
local weaponGallery={selected="AWP",status="Только интерфейс меню",catalog={{name="AWP",id="4531395275"},{name="USP-S",id="12899296613"}}}
function weaponGallery:Thumbnail(name)
    for _,entry in ipairs(self.catalog)do
        if entry.name==(name or self.selected)then return "rbxthumb://type=Asset&id="..entry.id.."&w=420&h=420"end
    end
    return ""
end
local playerPickerState={busy=false,lastStatus="Только интерфейс меню",durationMs=800,followCamera=false}

local function controlHeight(definition)
    return definition.kind == "range" and 54 or 40
end

local function buildControl(parent, definition, id, index, width, callback, rowY)
    local height = controlHeight(definition)
    local rw = width - 16
    local row = box(parent, 8, rowY or (36 + (index - 1) * height), rw, height - 6,
        Color3.fromRGB(19, 19, 19), 0.32)
    corner(row, 6)
    local rim = border(row, Color3.fromRGB(60, 60, 60), 0.82)
    local hovered = false
    local title = label(row, definition.title, 10, 0, rw - 67, height - 6, 12, C.text, Enum.Font.GothamMedium)
    local set
    if definition.kind == "action" then
        title.Size = UDim2.fromOffset(rw - 72, height - 6)
        title.TextColor3 = C.white
        local hit = button(row, "", 0, 0, rw, height - 6)
        corner(hit, 6)
        local chip = box(hit, rw - 58, 7, 48, 20, C.raised)
        corner(chip, 5)
        local caption = label(chip, definition.caption or "FIRE", 0, 0, 48, 20, 9, C.white, Enum.Font.GothamMedium)
        caption.TextXAlignment = Enum.TextXAlignment.Center
        on(hit.MouseEnter, function()
            animate(rim, {Transparency = 0.2})
            animate(chip, {BackgroundColor3 = C.soft})
        end)
        on(hit.MouseLeave, function()
            animate(rim, {Transparency = 0.82})
            animate(chip, {BackgroundColor3 = C.raised})
        end)
        on(hit.Activated, function() if callback then callback() end end)
        return row, nil, height
    elseif definition.kind == "choice" then
        title.Size = UDim2.fromOffset(rw - 108, height - 6)
        local hit = button(row, "", 0, 0, rw, height - 6)
        local chip = label(hit, "", rw - 100, 7, 91, 20, 10, C.white, Enum.Font.GothamMedium)
        chip.BackgroundColor3, chip.BackgroundTransparency = C.raised, 0
        chip.TextXAlignment = Enum.TextXAlignment.Center
        corner(chip, 5)
        set = function(value)
            if not table.find(definition.options, value) then value = definition.options[1] end
            values[id], chip.Text = value, value .. " ›"
            if callback then callback(value) end
        end
        on(hit.Activated, function()
            local index = table.find(definition.options, values[id]) or 1
            set(definition.options[index % #definition.options + 1])
        end)
        on(hit.MouseEnter, function() animate(rim, {Transparency = 0.2}) end)
        on(hit.MouseLeave, function() animate(rim, {Transparency = 0.82}) end)
    elseif definition.kind == "check" then
        local hit = button(row, "", 0, 0, rw, height - 6)
        corner(hit, 6)
        local track = box(hit, rw - 46, 8, 36, 18, C.raised)
        corner(track, 9)
        local trackRim = border(track, Color3.fromRGB(64, 64, 64), 0.25)
        local knob = box(track, 3, 3, 12, 12, C.dim)
        corner(knob, 6)
        local function paint()
            local enabled = values[id]
            animate(row, {BackgroundColor3 = Color3.fromRGB(enabled and 26 or 19, enabled and 26 or 19, enabled and 26 or 19),
                BackgroundTransparency = hovered and 0 or 0.32})
            animate(rim, {Transparency = hovered and 0.28 or (enabled and 0.48 or 0.82)})
            animate(title, {TextColor3 = (hovered or enabled) and C.white or C.text})
        end
        set = function(value)
            value = not not value
            values[id] = value
            animate(track, {BackgroundColor3 = value and C.white or C.raised})
            animate(trackRim, {Transparency = value and 0.8 or 0.25})
            animate(knob, {Position = UDim2.fromOffset(value and 21 or 3, 3),
                BackgroundColor3 = value and C.bg or C.dim}, 0.19)
            paint()
            if callback then callback(value) end
            if refreshHud and string.sub(id, 1, 10) ~= "interface/" and string.sub(id, 1, 4) ~= "HUD/" then refreshHud() end
        end
        on(hit.Activated, function() set(not values[id]) end)
        on(hit.MouseEnter, function() hovered = true; paint() end)
        on(hit.MouseLeave, function() hovered = false; paint() end)
    else
        title.Position, title.Size = UDim2.fromOffset(10, 6), UDim2.fromOffset(rw - 95, 18)
        local valueChip = box(row, rw - 82, 6, 72, 18, C.raised)
        corner(valueChip, 4)
        border(valueChip, C.line, 0.35)
        local val = label(valueChip, "", 0, 0, 72, 18, 10, C.white, Enum.Font.GothamMedium)
        val.TextXAlignment = Enum.TextXAlignment.Center
        local hit = button(row, "", 11, 26, rw - 22, 20)
        local track = box(hit, 0, 9, rw - 22, 3, Color3.fromRGB(43, 43, 43))
        corner(track, 2)
        local fill = box(track, 0, 0, 0, 3, C.white)
        corner(fill, 2)
        make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(130, 130, 130), C.white)}, fill)
        local knob = box(track, 0, 0, 7, 7, C.white)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.fromScale(0, 0.5)
        corner(knob, 4)
        border(knob, Color3.fromRGB(165, 165, 165), 0.45)
        set = function(value)
            value = math.clamp(math.floor(value + 0.5), definition.low, definition.high)
            local changed = values[id] ~= value
            values[id] = value
            local ratio = (value - definition.low) / (definition.high - definition.low)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            val.Text = tostring(value) .. definition.suffix
            if callback and changed then callback(value) end
        end
        local function update(x)
            local ratio = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
            set(definition.low + ratio * (definition.high - definition.low))
        end
        on(hit.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                activeSlider = {input = input, update = update}
                update(input.Position.X)
            end
        end)
        on(hit.MouseEnter, function()
            animate(rim, {Transparency = 0.28})
            animate(row, {BackgroundTransparency = 0})
            animate(knob, {Size = UDim2.fromOffset(9, 9)})
        end)
        on(hit.MouseLeave, function()
            animate(rim, {Transparency = 0.82})
            animate(row, {BackgroundTransparency = 0.32})
            animate(knob, {Size = UDim2.fromOffset(7, 7)})
        end)
    end
    setters[id] = set
    set(definition.initial)
    return row, set, height
end

local function buildGroup(parent, definition, x, width, prefix)
    local height = 42
    for _, control in ipairs(definition.controls or {}) do height = height + controlHeight(control) end
    if definition.note then height = 115 end
    local group = box(parent, x, 0, width, height, C.panel, 0.18)
    corner(group, 8)
    border(group, Color3.fromRGB(51, 51, 51), 0.25)
    label(group, definition.title, 13, 0, width - 57, 30, 10, C.text, Enum.Font.GothamMedium)
    if definition.controls then
        local count = label(group, string.format("%02d", #definition.controls), width - 42, 0, 28, 30, 9, C.dim)
        count.TextXAlignment = Enum.TextXAlignment.Right
    end
    box(group, 12, 30, width - 24, 1, C.line, 0.3)
    if definition.note then
        local note = label(group, definition.note, 13, 43, width - 26, 61, 11, C.dim)
        note.TextWrapped, note.TextTruncate, note.TextYAlignment = true, Enum.TextTruncate.None, Enum.TextYAlignment.Top
    else
        local cursor = 38
        for i, control in ipairs(definition.controls) do
            local row, _, consumed = buildControl(group, control, prefix .. "/" .. control.title, i, width, control.callback, cursor)
            cursor = cursor + consumed
            table.insert(rows, {row = row, query = string.lower(control.title .. " " .. definition.title), group = group, position = row.Position})
        end
    end
    return group
end

local combatPages = {}
local mainSectionBar = box(side, 0, 0, 127, H - 149, C.bg, 1)
mainSectionBar.Name, mainSectionBar.Visible = "MainSections", false
local mainRoleBar = box(mainSectionBar, 8, 88, 116, 128, C.bg, 1)
mainRoleBar.Name = "CombatRoles"
box(mainRoleBar, 0, 0, 108, 1, C.line, .4)
local function sectionPill(parent, text, x, width)
    local hit = button(parent, "", x, 0, width, 32)
    hit.Name = text .. "Pill"
    hit.BackgroundColor3, hit.BackgroundTransparency = C.white, 0
    corner(hit, 16)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(22,22,22),
        Color3.fromRGB(7,7,7)), Rotation = 90}, hit)
    local rim = border(hit, Color3.fromRGB(130,130,130), .3)
    make("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(180,180,180),
        Color3.fromRGB(48,48,48)), Rotation = 65}, rim)
    local title = label(hit, text, 0, 0, width, 32, 11, C.text, Enum.Font.GothamMedium)
    title.TextXAlignment = Enum.TextXAlignment.Center
    local active = false
    local function paint(selected, hovered)
        active = selected
        animate(hit, {BackgroundColor3 = (selected or hovered) and C.white or Color3.fromRGB(190,190,190)})
        animate(rim, {Transparency = selected and .08 or (hovered and .18 or .48)})
        animate(title, {TextColor3 = (selected or hovered) and C.white or C.dim})
    end
    on(hit.MouseEnter, function() paint(active,true) end)
    on(hit.MouseLeave, function() paint(active,false) end)
    return {hit = hit, title = title, paint = paint}
end
local function buildSectionScroll(page, groups, prefix)
    local scroll = make("ScrollingFrame", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.soft, ScrollingDirection = Enum.ScrollingDirection.Y}, page)
    make("UIPadding", {PaddingTop = UDim.new(0,1), PaddingLeft = UDim.new(0,1), PaddingBottom = UDim.new(0,5)}, scroll)
    for j, group in ipairs(groups) do
        buildGroup(scroll, group, (j-1)*266, 252, prefix .. "/" .. (group.settingsKey or group.title))
    end
    return scroll
end

for tabName, tabSections in pairs(definitions) do
    pages[tabName], sections[tabName] = {}, {}
    for i, section in ipairs(tabSections) do
        local sectionOffset = 0
        local page = make("CanvasGroup", {Name = tabName .. "_" .. section.name,
            Position = UDim2.fromOffset(0,sectionOffset), Size = UDim2.new(1,0,1,-sectionOffset),
            BackgroundTransparency = 1, Visible = false, BorderSizePixel = 0}, content)
        pages[tabName][section.name] = page
        if section.variants then
            local variants, buttons = {}, {}
            local function showVariant(name)
                activeSlider = nil
                for key, host in pairs(variants) do
                    local selected = key == name
                    host.Visible = selected
                    buttons[key].paint(selected,false)
                end
                if applySearch then applySearch() end
            end
            for j, variant in ipairs(section.variants) do
                local entry = sectionPill(mainRoleBar, variant.name, 0, 116)
                entry.hit.Position = UDim2.fromOffset(0,12+(j-1)*40)
                buttons[variant.name] = entry
                local host = make("CanvasGroup", {Name = variant.name, Position = UDim2.fromOffset(0,0),
                    Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Visible = false}, page)
                variants[variant.name] = host
                combatPages[variant.name] = buildSectionScroll(host, variant.groups,
                    tabName .. "/" .. section.name .. "/" .. variant.name)
                on(entry.hit.Activated, function() showVariant(variant.name) end)
            end
            showVariant("Murderer")
        else
            buildSectionScroll(page, section.groups, tabName .. "/" .. section.name)
        end
        if tabName == "Main" then
            local entry = sectionPill(mainSectionBar, section.name, 0, 124)
            entry.hit.Position = UDim2.fromOffset(0,(i-1)*40)
            sections[tabName][section.name] = entry
            on(entry.hit.Activated, function() selectPage(tabName,section.name) end)
        else
        local hit = button(side, "", 0, (i - 1) * 28, 124, 27)
        hit.Visible = false
        local highlight = box(hit, 0, 0, 124, 27, C.soft, 0.9)
        local stripe = box(hit, 2, 4, 3, 20, C.accent)
        local title = label(hit, section.name, 14, 0, 107, 27, 13)
        sections[tabName][section.name] = {hit = hit, highlight = highlight, stripe = stripe, title = title}
        on(hit.Activated, function() selectPage(tabName, section.name) end)
        on(hit.MouseEnter, function() animate(title, {TextColor3 = C.white}) end)
        on(hit.MouseLeave, function() animate(title, {TextColor3 = currentTab == tabName and currentSection == section.name and C.white or C.dim}) end)
        end
    end
end

do
    local scroll = combatPages.Sheriff
    local panel = box(scroll, 0, 400, 518, 100, C.panel, 0.15)
    corner(panel, 7)
    border(panel, C.line, 0.3)
    label(panel, "СТРЕЛЬБА", 13, 5, 490, 22, 10, C.white, Enum.Font.GothamMedium)
    local hint = label(panel, "Force Shot — по нажатию с Gun в руках. Auto Shot — автоматически. FOV относится к Silent Aim.",
        13, 30, 490, 33, 11, C.dim)
    hint.TextWrapped, hint.TextTruncate, hint.TextYAlignment = true, Enum.TextTruncate.None, Enum.TextYAlignment.Top
    local current = label(panel, "Только интерфейс меню", 13, 70, 490, 22, 11, C.text)
end

do
    local scroll = pages.Main["Auto Farm"]:FindFirstChildOfClass("ScrollingFrame")
    local card = box(scroll, 0, 272, 252, 145, C.panel, .18)
    corner(card, 8); border(card, C.line, .3)
    label(card, "SESSION", 13, 0, 226, 30, 10, C.white, Enum.Font.GothamMedium)
    box(card, 12, 30, 228, 1, C.line, .3)
    local status = label(card, "Выключен", 13, 40, 226, 25, 11, C.text)
    local collected = label(card, "Собрано: 0", 13, 72, 226, 22, 11, C.dim)
    local bag = label(card, "Мешок: 0", 13, 101, 226, 22, 11, C.dim)
    local note = buildGroup(scroll, {title = "INFO", note = "Выбери монеты или конфеты.\nСтатистика и заполнение мешка учитываются отдельно для каждого ресурса."}, 266, 252, "Main/Auto Farm/INFO")
    note.Position = UDim2.fromOffset(266,218)
end

-- Image catalog for the local SNPWare-style weapon skin spawner.
do
    local scroll=pages.Model.Skin:FindFirstChildOfClass("ScrollingFrame")
    local selected,focus,page,kind,rarity={},skinGallery.catalog[1]and skinGallery.catalog[1].id,1,"Все","Все"
    local pageSize,rowConnections=8,{}
    local browser=box(scroll,0,0,508,380,C.panel,.15);browser.Name="SkinCatalog";corner(browser,8);border(browser,C.line,.25)
    label(browser,"SKIN SPAWNER",12,2,236,27,11,C.white,Enum.Font.GothamMedium)
    local clearSelection=button(browser,"Сбросить выбор",350,4,146,22);clearSelection.TextSize=10;clearSelection.TextColor3=C.dim
    box(browser,12,31,484,1,C.line,.35)
    local search=make("TextBox",{Name="SkinSearch",Position=UDim2.fromOffset(12,40),Size=UDim2.fromOffset(218,27),
        BackgroundColor3=C.raised,BackgroundTransparency=.2,BorderSizePixel=0,Text="",PlaceholderText="Поиск скина…",
        ClearTextOnFocus=false,Font=BODY_FONT,TextSize=11,TextColor3=C.white,PlaceholderColor3=C.dim},browser);corner(search,5)
    local typeButtons,rarityButtons={},{}
    for i,text in ipairs({"Все","Ножи","Пистолеты"})do
        local hit=button(browser,text,238+(i-1)*87,40,82,27);hit.TextSize=10;corner(hit,5)
        typeButtons[text]=hit
    end
    for i,text in ipairs({"Все","Ancient","Godly","Unique","Chroma"})do
        local hit=button(browser,text,12+(i-1)*98,76,92,24);hit.TextSize=10;corner(hit,5)
        rarityButtons[text]=hit
    end
    local grid=box(browser,12,110,484,216,C.bg,1);grid.Name="SkinCards"
    local previous=button(browser,"‹",12,341,32,27)
    local nextPage=button(browser,"›",50,341,32,27)
    local pageLabel=label(browser,"",91,341,190,27,10,C.dim)
    local clearInventory=button(browser,"Очистить инвентарь",300,341,196,27)
    for _,hit in ipairs({previous,nextPage,clearInventory})do
        hit.BackgroundColor3=C.raised;hit.BackgroundTransparency=.1;hit.TextSize=11;corner(hit,5);border(hit,C.line,.3)
    end
    local preview=box(scroll,522,0,262,380,C.panel,.15);preview.Name="SkinPreview";corner(preview,8);border(preview,C.line,.25)
    label(preview,"ПРЕДПРОСМОТР",12,2,238,27,10,C.white,Enum.Font.GothamMedium)
    box(preview,12,31,238,1,C.line,.35)
    local hero=make("ImageLabel",{Name="SkinImage",Position=UDim2.fromOffset(18,40),Size=UDim2.fromOffset(226,140),
        BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Fit},preview)
    local title=label(preview,"",12,185,238,23,13,C.white,Enum.Font.GothamMedium)
    title.TextXAlignment=Enum.TextXAlignment.Center
    local meta=label(preview,"",12,211,238,20,10,C.dim);meta.TextXAlignment=Enum.TextXAlignment.Center
    local grant=button(preview,"Выдать в инвентарь",12,241,238,30);grant.TextSize=11
    for _,hit in ipairs({grant})do
        hit.BackgroundColor3=C.raised;hit.BackgroundTransparency=0;corner(hit,5);border(hit,C.soft,.2)
        on(hit.MouseEnter,function()animate(hit,{BackgroundColor3=C.soft})end)
        on(hit.MouseLeave,function()animate(hit,{BackgroundColor3=C.raised})end)
    end
    label(preview,"Количество",12,280,146,28,11,C.dim)
    local amount=make("TextBox",{Name="SkinAmount",Position=UDim2.fromOffset(175,279),Size=UDim2.fromOffset(75,30),
        BackgroundColor3=C.raised,BorderSizePixel=0,Text="1",PlaceholderText="1–999",ClearTextOnFocus=false,
        Font=BODY_FONT,TextSize=11,TextColor3=C.white},preview);corner(amount,5);border(amount,C.line,.3)
    local selection=label(preview,"Выбрано: 0",12,315,238,21,10,C.text);selection.TextXAlignment=Enum.TextXAlignment.Center
    local hint=label(preview,"Предпросмотр интерфейса.\nВыдача скинов отключена.",12,340,238,29,10,C.dim)
    hint.TextWrapped=true;hint.TextXAlignment=Enum.TextXAlignment.Center
    local state=label(scroll,skinGallery.status,0,384,784,20,10,C.dim);state.Name="SkinSpawnerStatus"
    local lookup={};for _,entry in ipairs(skinGallery.catalog)do lookup[entry.id]=entry end
    local filtered={}
    local render
    local function paintFilters()
        for text,hit in pairs(typeButtons)do local active=text==kind;hit.BackgroundColor3=active and C.white or C.raised;hit.TextColor3=active and C.bg or C.text end
        for text,hit in pairs(rarityButtons)do local active=text==rarity;hit.BackgroundColor3=active and C.white or C.raised;hit.TextColor3=active and C.bg or C.text end
    end
    local function previewSelected()
        local entry=lookup[focus]
        if entry then
            hero.Image=entry.image;title.Text=entry.name
            meta.Text=(entry.kind=="Knife"and"Нож"or"Пистолет").." · "..entry.rarity..(entry.chroma and" · Chroma"or"")
        else hero.Image="";title.Text="Выбери скин";meta.Text=""end
        local count=0;for _,value in pairs(selected)do if value then count=count+1 end end
        selection.Text="Выбрано: "..count.." · количество: "..tostring(math.clamp(math.floor(tonumber(amount.Text)or 1),1,999))
    end
    local function rebuild(reset)
        if not alive or not skinGallery.running then return end
        if reset then page=1 end
        filtered={}
        local query=search.Text:lower()
        for _,entry in ipairs(skinGallery.catalog)do
            local matchesKind=kind=="Все"or(kind=="Ножи"and entry.kind=="Knife")or(kind=="Пистолеты"and entry.kind=="Gun")
            local matchesRarity=rarity=="Все"or(rarity=="Chroma"and entry.chroma)or(rarity~="Chroma"and entry.rarity==rarity)
            if matchesKind and matchesRarity and (query==""or(entry.name.." "..entry.id):lower():find(query,1,true))then filtered[#filtered+1]=entry end
        end
        page=math.clamp(page,1,math.max(1,math.ceil(#filtered/pageSize)))
        render();paintFilters()
    end
    render=function()
        for _,connection in ipairs(rowConnections)do connection:Disconnect()end
        rowConnections={}
        for _,child in ipairs(grid:GetChildren())do child:Destroy()end
        for index=(page-1)*pageSize+1,math.min(page*pageSize,#filtered)do
            local entry=filtered[index];local slot=index-(page-1)*pageSize-1
            local card=button(grid,"",(slot%4)*122,math.floor(slot/4)*108,116,100)
            card.Name="SkinCard_"..entry.id;card.BackgroundColor3=selected[entry.id]and C.raised or C.header;card.BackgroundTransparency=0;corner(card,6)
            border(card,selected[entry.id]and C.white or C.line,selected[entry.id]and .25 or .45)
            make("ImageLabel",{Position=UDim2.fromOffset(7,3),Size=UDim2.fromOffset(102,65),BackgroundTransparency=1,
                Image=entry.image,ScaleType=Enum.ScaleType.Fit},card)
            local name=label(card,entry.name,5,69,106,17,10,C.text);name.TextXAlignment=Enum.TextXAlignment.Center
            local badge=label(card,selected[entry.id]and"✓"or"+",91,7,17,17,13,C.white);badge.TextXAlignment=Enum.TextXAlignment.Center
            local owned=label(card,skinGallery.granted[entry.id]and("x"..skinGallery.granted[entry.id])or entry.rarity,6,86,104,12,8,C.dim)
            owned.TextXAlignment=Enum.TextXAlignment.Center
            rowConnections[#rowConnections+1]=card.Activated:Connect(function()
                focus=entry.id;selected[entry.id]=not selected[entry.id]or nil;render();previewSelected()
            end)
            rowConnections[#rowConnections+1]=card.MouseEnter:Connect(function()animate(card,{BackgroundColor3=C.raised})end)
            rowConnections[#rowConnections+1]=card.MouseLeave:Connect(function()animate(card,{BackgroundColor3=selected[entry.id]and C.raised or C.header})end)
        end
        if #filtered==0 then label(grid,"Скины не найдены",0,70,484,28,12,C.dim).TextXAlignment=Enum.TextXAlignment.Center end
        pageLabel.Text=string.format("%d / %d  ·  %d скинов",page,math.max(1,math.ceil(#filtered/pageSize)),#filtered)
        previous.TextColor3=page>1 and C.white or C.dim
        nextPage.TextColor3=page*pageSize<#filtered and C.white or C.dim
        previewSelected()
    end
    on(search:GetPropertyChangedSignal("Text"),function()rebuild(true)end)
    for text,hit in pairs(typeButtons)do on(hit.Activated,function()kind=text;rebuild(true)end)end
    for text,hit in pairs(rarityButtons)do on(hit.Activated,function()rarity=text;rebuild(true)end)end
    on(previous.Activated,function()page=math.max(1,page-1);rebuild(false)end)
    on(nextPage.Activated,function()page=page+1;rebuild(false)end)
    on(clearSelection.Activated,function()selected={};render()end)
    on(clearInventory.Activated,function()selected={};render();toast("Только интерфейс меню")end)
    on(grant.Activated,function()toast("Только интерфейс меню")end)
    on(amount.FocusLost,function()amount.Text=tostring(math.clamp(math.floor(tonumber(amount.Text)or 1),1,999));previewSelected()end)
    skinGallery.onStatus=function(message)if state.Parent then state.Text=message end end
    skinGallery.onChange=function()if alive and skinGallery.running then render()end end
    gui.Destroying:Connect(function()for _,connection in ipairs(rowConnections)do connection:Disconnect()end end)
    rebuild(true)
end


do
    local scroll = pages.Model.Guns:FindFirstChildOfClass("ScrollingFrame")
    local preview = box(scroll,266,0,252,122,C.panel,.18)
    corner(preview,8); border(preview,C.line,.3)
    label(preview,"SELECTED MODEL",13,0,226,27,10,C.text,Enum.Font.GothamMedium)
    local hero = make("ImageLabel",{Position=UDim2.fromOffset(10,29),Size=UDim2.fromOffset(104,83),
        BackgroundTransparency=1,Image=weaponGallery:Thumbnail(),ScaleType=Enum.ScaleType.Fit},preview)
    local selectedName = label(preview,weaponGallery.selected,124,35,116,22,12,C.white,Enum.Font.GothamMedium)
    local selectedStatus = label(preview,"Выключено",124,62,116,43,10,C.dim)
    selectedStatus.TextWrapped,selectedStatus.TextTruncate = true,Enum.TextTruncate.None
    local cards = {}
    for i, entry in ipairs(weaponGallery.catalog) do
        local x,y = ((i-1)%2)*266,144+math.floor((i-1)/2)*160
        local card = button(scroll,"",x,y,252,146)
        card.Name="GunCard_"..entry.name
        card.BackgroundColor3,card.BackgroundTransparency = C.panel,.1
        corner(card,8)
        local rim=border(card,C.line,.3)
        make("ImageLabel",{Name="WeaponImage",Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(232,99),
            BackgroundTransparency=1,Image=weaponGallery:Thumbnail(entry.name),ScaleType=Enum.ScaleType.Fit,Active=false},card)
        label(card,entry.name,13,112,143,24,12,C.white,Enum.Font.GothamMedium)
        local state=label(card,"ВЫБРАТЬ",158,112,80,24,9,C.dim,Enum.Font.GothamMedium)
        state.TextXAlignment=Enum.TextXAlignment.Right
        cards[entry.name]={card=card,rim=rim,state=state}
        on(card.Activated,function()
            weaponGallery.selected=entry.name
            setters["Model/Guns/GUN MODEL/Оружие"](entry.name)
            setters["Model/Guns/GUN MODEL/Своя модель"](true)
        end)
        on(card.MouseEnter,function() animate(rim,{Transparency=.08,Color=C.white}) end)
        on(card.MouseLeave,function()
            local selected=weaponGallery.selected==entry.name
            animate(rim,{Transparency=selected and .15 or .45,Color=selected and C.white or C.line})
        end)
    end
    local function refresh()
        selectedName.Text,selectedStatus.Text = weaponGallery.selected,weaponGallery.status
        hero.Image=weaponGallery:Thumbnail()
        for name,entry in pairs(cards) do
            local selected=weaponGallery.selected==name
            entry.rim.Color,entry.rim.Transparency=selected and C.white or C.line,selected and .15 or .45
            entry.state.Text,entry.state.TextColor3=selected and "ВЫБРАНО" or "ВЫБРАТЬ",selected and C.white or C.dim
            entry.card.BackgroundColor3=selected and C.raised or C.panel
        end
    end
    local elapsed=0
    on(RunService.Heartbeat,function(dt)
        elapsed=elapsed+dt
        if elapsed<.2 or not pages.Model.Guns.Visible then return end
        elapsed=0;refresh()
    end)
    refresh()
end


do
    local scroll=pages.Drone.Control:FindFirstChildOfClass("ScrollingFrame")
    local preview=box(scroll,266,0,252,292,C.panel,.15)
    preview.Name="DroneModelCard";corner(preview,8);border(preview,C.line,.25)
    label(preview,"REMOTE DRONE",13,2,226,28,10,C.white,Enum.Font.GothamMedium)
    box(preview,12,31,228,1,C.line,.3)
    make("ImageLabel",{Name="DroneImage",Position=UDim2.fromOffset(10,40),Size=UDim2.fromOffset(232,188),
        BackgroundTransparency=1,Image="rbxthumb://type=Asset&id=124994246147928&w=420&h=420",ScaleType=Enum.ScaleType.Fit},preview)
    label(preview,"DRONE / 124994246147928",13,234,226,20,11,C.text,Enum.Font.GothamMedium)
    label(preview,"Камера от третьего лица",13,256,226,20,10,C.dim)
    local info=box(scroll,532,0,252,292,C.panel,.15);corner(info,8);border(info,C.line,.25)
    label(info,"УПРАВЛЕНИЕ",13,2,226,28,10,C.white,Enum.Font.GothamMedium)
    box(info,12,31,228,1,C.line,.3)
    for i,text in ipairs({"WASD — направление","Мышь — поворот камеры","Space / Ctrl — выше / ниже","Shift — ускорение","X — выход из дрона"})do
        label(info,text,13,40+(i-1)*25,226,22,11,C.text)
    end
    local hint=label(info,"Радиус 0 — срабатывание при касании корпуса игрока. Увеличь радиус до 2, если нужно попадание рядом.",13,177,226,92,11,C.dim)
    hint.TextWrapped,hint.TextTruncate,hint.TextYAlignment=true,Enum.TextTruncate.None,Enum.TextYAlignment.Top
    local state=box(scroll,0,302,784,78,C.panel,.15);corner(state,8);border(state,C.line,.25)
    label(state,"DRONE STATUS",13,4,758,22,10,C.dim,Enum.Font.GothamMedium)
    local status=label(state,"Только интерфейс меню",13,30,758,32,12,C.white)
    status.TextWrapped,status.TextTruncate=true,Enum.TextTruncate.None
end


-- Live target picker, separate from saved menu settings: user IDs are session-specific.
do
    local scroll = pages.Fling.Players:FindFirstChildOfClass("ScrollingFrame")
    local actionCard = box(scroll, 0, 0, 252, 250, C.panel, 0.1)
    corner(actionCard, 9)
    border(actionCard, C.soft, 0.35)
    label(actionCard, "ВЫКИНУТЬ ЗА КАРТУ", 14, 8, 224, 24, 12, C.white, Enum.Font.GothamBold)
    local help = label(actionCard, "Выбери игрока в списке справа", 14, 33, 224, 20, 11, C.dim)
    local selectedBox = box(actionCard, 12, 64, 228, 43, C.raised, 0.2)
    corner(selectedBox, 6)
    label(selectedBox, "ЦЕЛЬ", 10, 4, 208, 13, 9, C.dim, Enum.Font.GothamMedium)
    local selectedLabel = label(selectedBox, "Игрок не выбран", 10, 19, 208, 19, 12, C.white, Enum.Font.GothamMedium)
    local startButton = button(actionCard, "Выкинуть игрока", 12, 119, 228, 42)
    startButton.BackgroundTransparency = 0
    startButton.Font, startButton.TextSize = Enum.Font.GothamBold, 13
    corner(startButton, 7)
    local stopButton = button(actionCard, "Остановить и вернуться", 12, 171, 228, 32)
    stopButton.BackgroundTransparency, stopButton.BackgroundColor3 = 0.2, C.raised
    stopButton.TextSize = 11
    corner(stopButton, 6)
    border(stopButton, C.soft, 0.5)
    local statusLabel = label(actionCard, playerPickerState.lastStatus, 14, 214, 224, 28, 10, C.dim)
    statusLabel.TextWrapped, statusLabel.TextTruncate = true, Enum.TextTruncate.None
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    local function syncActions()
        local target = playerPickerState.selectedUserId and Players:GetPlayerByUserId(playerPickerState.selectedUserId)
        local canStart = target ~= nil and not playerPickerState.busy
        startButton.Active = canStart
        startButton.Text = playerPickerState.busy and "Выполняется…" or "Выкинуть игрока"
        startButton.BackgroundColor3 = canStart and C.white or C.raised
        startButton.TextColor3 = canStart and C.bg or C.dim
        stopButton.Active, stopButton.TextColor3 = playerPickerState.busy, playerPickerState.busy and C.white or C.dim
        help.Text = playerPickerState.busy and "Остановка вернёт персонажа на место" or "Выбери цель и нажми кнопку ниже"
    end
    playerPickerState.onStatus = function(message) statusLabel.Text = message; syncActions() end
    on(startButton.Activated, function()
        if startButton.Active then toast("Только интерфейс меню"); syncActions() end
    end)
    on(stopButton.Activated, function() if playerPickerState.busy then toast("Только интерфейс меню"); syncActions() end end)
    on(startButton.MouseEnter, function()
        if startButton.Active then animate(startButton, {BackgroundColor3 = Color3.fromRGB(210, 210, 210)}) end
    end)
    on(startButton.MouseLeave, syncActions)
    local settingsHost = box(scroll, 0, 262, 252, 136, C.bg, 1)
    buildGroup(settingsHost, {title = "НАСТРОЙКИ ПОПЫТКИ", controls = {
        range("Длительность", 400, 2000, 800, " мс", function(v) playerPickerState.durationMs = v end),
        check("Следить камерой", false, function(v) playerPickerState.followCamera = v end),
    }}, 0, 252, "Fling/Players/SETTINGS")

    local pickerWidth, innerWidth = W - 468, W - 492
    local picker = box(scroll, 266, 0, pickerWidth, 398, C.panel, 0.18)
    corner(picker, 8)
    border(picker, C.line, 0.25)
    label(picker, "ВЫБЕРИ ИГРОКА", 13, 0, pickerWidth - 100, 30, 10, C.text, Enum.Font.GothamMedium)
    local countLabel = label(picker, "0", pickerWidth - 66, 0, 52, 30, 10, C.dim)
    countLabel.TextXAlignment = Enum.TextXAlignment.Right
    box(picker, 12, 30, innerWidth, 1, C.line, 0.3)
    local searchField = make("TextBox", {Position = UDim2.fromOffset(12, 42), Size = UDim2.fromOffset(innerWidth, 32),
        BackgroundColor3 = C.raised, BorderSizePixel = 0, Text = "", PlaceholderText = "Ник или имя игрока…",
        PlaceholderColor3 = C.dim, TextColor3 = C.text, Font = BODY_FONT, TextSize = 12,
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left}, picker)
    corner(searchField, 6)
    make("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, searchField)
    local list = make("ScrollingFrame", {Position = UDim2.fromOffset(12, 84), Size = UDim2.fromOffset(innerWidth, 302),
        BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.new(),
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.soft, ScrollingDirection = Enum.ScrollingDirection.Y}, picker)
    local empty = label(list, "Других игроков нет", 0, 10, innerWidth - 8, 25, 12, C.dim)
    empty.TextXAlignment = Enum.TextXAlignment.Center
    local entries = {}
    local function paintSelection()
        for id, entry in pairs(entries) do
            local selected = id == playerPickerState.selectedUserId
            entry.rim.Transparency = selected and 0.15 or 0.85
            entry.row.BackgroundColor3 = selected and C.soft or C.raised
            entry.marker.Text = selected and "●" or "○"
            entry.marker.TextColor3 = selected and C.white or C.dim
        end
        local target = playerPickerState.selectedUserId and Players:GetPlayerByUserId(playerPickerState.selectedUserId)
        selectedLabel.Text = target and ("@" .. target.Name) or "Игрок не выбран"
        syncActions()
    end
    local function rebuild(excluded)
        for _, entry in pairs(entries) do entry.connection:Disconnect(); entry.row:Destroy() end
        entries = {}
        local candidates = {}
        local query = string.lower(searchField.Text)
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and other ~= excluded and (query == ""
                or string.find(string.lower(other.Name .. " " .. other.DisplayName), query, 1, true)) then
                table.insert(candidates, other)
            end
        end
        table.sort(candidates, function(a, b) return string.lower(a.Name) < string.lower(b.Name) end)
        for i, other in ipairs(candidates) do
            local row = button(list, "", 0, (i - 1) * 52, innerWidth - 8, 46)
            row.BackgroundTransparency, row.BackgroundColor3 = 0.15, C.raised
            corner(row, 6)
            local rim = border(row, C.white, 0.85)
            label(row, other.DisplayName, 12, 4, innerWidth - 72, 20, 12, C.white, Enum.Font.GothamMedium)
            label(row, "@" .. other.Name, 12, 24, innerWidth - 72, 16, 10, C.dim)
            local marker = label(row, "○", innerWidth - 46, 0, 26, 46, 16, C.dim)
            marker.TextXAlignment = Enum.TextXAlignment.Center
            local connection = row.Activated:Connect(function()
                playerPickerState.selectedUserId = other.UserId
                paintSelection()
                if not playerPickerState.busy then statusLabel.Text = "Только интерфейс меню." end
            end)
            entries[other.UserId] = {row = row, rim = rim, marker = marker, connection = connection}
        end
        empty.Visible = #candidates == 0
        empty.Text = query == "" and "Других игроков нет" or "Ничего не найдено"
        countLabel.Text = tostring(#candidates)
        list.CanvasSize = UDim2.fromOffset(0, #candidates * 52)
        paintSelection()
    end
    on(searchField:GetPropertyChangedSignal("Text"), function() rebuild() end)
    on(Players.PlayerAdded, function() rebuild() end)
    on(Players.PlayerRemoving, function(other)
        if playerPickerState.selectedUserId == other.UserId then
            playerPickerState.selectedUserId = nil
            if not playerPickerState.busy then statusLabel.Text = "Игрок вышел. Выбери новую цель." end
        end
        rebuild(other)
    end)
    on(gui.Destroying, function()
        for _, entry in pairs(entries) do entry.connection:Disconnect() end
    end)
    rebuild()
end

-- Avatar image preview belongs only to the menu.
avatarPreview=(function()
    local api={requested=false}
    local panel=make("CanvasGroup",{Name="AvatarPreviewPanel",Position=UDim2.fromOffset(W+12,0),Size=UDim2.fromOffset(246,H),
        BackgroundColor3=C.bg,BackgroundTransparency=.03,BorderSizePixel=0,Visible=false},holder)
    corner(panel,7);border(panel,C.soft,.2)
    label(panel,player.DisplayName,13,7,220,23,12,C.white,Enum.Font.GothamMedium)
    label(panel,"AVATAR / UI PREVIEW",13,29,220,15,9,C.dim)
    box(panel,10,50,226,1,C.line,.3)
    make("ImageLabel",{Name="AvatarImage",Position=UDim2.fromOffset(9,66),Size=UDim2.fromOffset(228,H-112),
        BackgroundTransparency=1,Image="rbxthumb://type=Avatar&id="..player.UserId.."&w=420&h=420",ScaleType=Enum.ScaleType.Fit},panel)
    label(panel,"Только интерфейс",12,H-35,222,20,10,C.dim).TextXAlignment=Enum.TextXAlignment.Center
    function api:SyncVisibility()panel.Visible=self.requested and opened end
    function api:SetVisible(value)self.requested=value;self:SyncVisibility()end
    return api
end)()

selectPage = function(tabName, sectionName)
    sectionName = sectionName or definitions[tabName][1].name
    currentTab, currentSection = tabName, sectionName
    mainSectionBar.Visible = tabName == "Main"
    mainRoleBar.Visible = tabName == "Main" and sectionName == "Combat"
    if avatarPreview then avatarPreview:SetVisible(tabName == "Visuals") end
    previewExtra = tabName == "Visuals" and 258 or 0
    resize()
    activeSlider = nil
    for name, entry in pairs(navigation) do
        entry.paint(name == tabName, false)
    end
    for name, tabPages in pairs(pages) do
        for section, page in pairs(tabPages) do
            local selected = name == tabName and section == sectionName
            page.Visible = selected
            local entry = sections[name][section]
            entry.hit.Visible = name == tabName
            if entry.paint then entry.paint(selected,false)
            else
                entry.highlight.Visible, entry.stripe.Visible = selected, selected
                animate(entry.title, {TextColor3 = selected and C.white or C.dim})
            end
        end
    end
    local page = pages[tabName][sectionName]
    local sectionOffset = 0
    if preferences.motion then page.GroupTransparency = 1; page.Position = UDim2.fromOffset(-5, sectionOffset) end
    animate(page, {GroupTransparency = 0, Position = UDim2.fromOffset(0, sectionOffset)}, 0.18)
    if applySearch then applySearch() end
end

-- Search filters labels on the selected page. Empty rows retain their geometry.
local searchPanel = box(root, 17, H - 78, 288, 30, C.panel)
border(searchPanel, C.soft)
searchPanel.Visible = false
local search = make("TextBox", {Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(268, 30),
    BackgroundTransparency = 1, Text = "", PlaceholderText = "Поиск на текущей вкладке…",
    PlaceholderColor3 = C.dim, TextColor3 = C.text, Font = BODY_FONT, TextSize = 11,
    ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left}, searchPanel)
applySearch = function()
    local query = searchPanel.Visible and string.lower(search.Text) or ""
    for _, entry in ipairs(rows) do entry.row.Visible = query == "" or string.find(entry.query, query, 1, true) ~= nil end
end
on(search:GetPropertyChangedSignal("Text"), applySearch)
on(searchButton.Activated, function()
    searchPanel.Visible = not searchPanel.Visible
    if searchPanel.Visible then search:CaptureFocus() else search:ReleaseFocus() end
    applySearch()
end)

-- Interface settings open from the lower right icon.
local overlay = button(root, "", 0, 75, W, H - 113)
overlay.BackgroundColor3, overlay.BackgroundTransparency, overlay.Visible = Color3.new(0, 0, 0), 0.25, false
local settingsPanel = box(overlay, W - 329, 13, 306, 370, C.panel)
settingsPanel.Active = true
corner(settingsPanel, 8)
border(settingsPanel, C.soft)
label(settingsPanel, "INTERFACE", 13, 0, 220, 30, 11, C.accent, Enum.Font.GothamMedium)
local dismiss = button(settingsPanel, "×", 272, 2, 25, 25)
box(settingsPanel, 0, 30, 306, 1, C.soft, 0.4)
local settingsBody = box(settingsPanel, 0, 10, 306, 264, C.bg, 1)
local settingsDefinitions = {
    {range("масштаб", 70, 120, 100, "%"), "scale", function(v) preferences.scale = v; resize() end},
    {range("прозрачность", 0, 30, 0, "%"), "opacity", function(v) preferences.opacity = v; root.BackgroundTransparency = v / 100 end},
    {check("рамка", true), "border", function(v) preferences.border = v; outline.Enabled = v end},
    {check("анимации", true), "motion", function(v) preferences.motion = v end},
    {check("падающие звёзды", true), "pattern", function(v) preferences.pattern = v; wallpaper.Visible = v end},
}
local settingsCursor = 28
for i, item in ipairs(settingsDefinitions) do
    local _, setter, consumed = buildControl(settingsBody, item[1], "interface/" .. item[2], i, 306, item[3], settingsCursor)
    settingsCursor = settingsCursor + consumed
    settingsSetters[item[2]] = setter
end
label(settingsPanel, "menu key", 13, 281, 130, 28, 11)
local keyButton = button(settingsPanel, menuKey.Name, 170, 281, 120, 28)
keyButton.BackgroundColor3, keyButton.BackgroundTransparency = C.raised, 0
corner(keyButton, 6)
border(keyButton, C.line)
refreshKey = function()
    keyButton.Text = waitingKey and "press a key…" or menuKey.Name
    footerKey.Text = menuKey == Enum.KeyCode.RightShift and "RSHIFT" or string.upper(menuKey.Name)
end
on(keyButton.Activated, function() waitingKey = not waitingKey; refreshKey() end)
local reset = button(settingsPanel, "reset interface", 13, 326, 279, 30)
reset.BackgroundColor3, reset.BackgroundTransparency = C.raised, 0
corner(reset, 6)
border(reset, C.line)
local function closeSettings() overlay.Visible = false; waitingKey = false; refreshKey() end
on(dismiss.Activated, closeSettings)
on(overlay.Activated, closeSettings)
on(settingsButton.Activated, function()
    overlay.Visible = not overlay.Visible
    waitingKey = false
    refreshKey()
end)
on(reset.Activated, function()
    settingsSetters.motion(true); settingsSetters.scale(100); settingsSetters.opacity(0)
    settingsSetters.border(true); settingsSetters.pattern(true)
    menuKey, waitingKey = Enum.KeyCode.RightShift, false
    refreshKey()
    holder.Position = UDim2.fromScale(0.5, 0.5); resize()
    toast("Оформление сброшено")
end)
on(saveButton.Activated, function()
    snapshot = {key = menuKey, values = {}}
    for id, value in pairs(values) do snapshot.values[id] = value end
    toast("Снимок сохранён до перезапуска скрипта")
end)
on(loadButton.Activated, function()
    if not snapshot then toast("Сначала сохрани снимок кнопкой справа от папки"); return end
    for id, value in pairs(snapshot.values) do if setters[id] then setters[id](value) end end
    menuKey, waitingKey = snapshot.key, false
    refreshKey()
    toast("Снимок сеанса загружен")
end)

setOpen = function(value)
    if opened == value then return end
    transition = transition + 1
    local token = transition
    opened = value
    if avatarPreview then avatarPreview:SyncVisibility() end
    activeSlider, dragging = nil, nil
    closeSettings()
    search:ReleaseFocus()
    if value then holder.Visible = true; resize() end
    animate(root, {GroupTransparency = value and 0 or 1, Position = UDim2.fromOffset(value and 0 or -10, 0)}, 0.19)
    local function finish()
        if alive and token == transition then holder.Visible = opened end
    end
    if preferences.motion then task.delay(0.2, finish) else finish() end
end
local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local view = viewport()
        dragging = {input = input, start = input.Position,
            center = Vector2.new(holder.Position.X.Scale * view.X + holder.Position.X.Offset + previewExtra * uiScale.Scale / 2,
                holder.Position.Y.Scale * view.Y + holder.Position.Y.Offset)}
    end
end
on(dragZone.InputBegan, startDrag); on(logoDrag.InputBegan, startDrag)
on(UIS.InputChanged, function(input)
    local mouse = input.UserInputType == Enum.UserInputType.MouseMovement
    if activeSlider and (mouse or input == activeSlider.input) then activeSlider.update(input.Position.X) end
    if dragging and (mouse or input == dragging.input) then
        local delta = input.Position - dragging.start
        resize(dragging.center + Vector2.new(delta.X, delta.Y))
    end
end)
on(UIS.InputEnded, function(input)
    if activeSlider and (input == activeSlider.input or input.UserInputType == Enum.UserInputType.MouseButton1) then activeSlider = nil end
    if dragging and (input == dragging.input or input.UserInputType == Enum.UserInputType.MouseButton1) then dragging = nil end
end)
on(UIS.WindowFocusReleased, function() activeSlider, dragging = nil, nil end)
on(UIS.InputBegan, function(input, processed)
    if UIS:GetFocusedTextBox() then return end
    if waitingKey and input.UserInputType == Enum.UserInputType.Keyboard then
        waitingKey = false
        if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then menuKey = input.KeyCode end
        refreshKey(); return
    end
    if not processed and input.KeyCode == menuKey then setOpen(not opened) end
end)
local function bindCamera()
    if cameraConnection then cameraConnection:Disconnect(); cameraConnection = nil end
    if Workspace.CurrentCamera then cameraConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function() resize() end) end
    resize()
end
on(Workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera)
gui.Destroying:Connect(function()
    alive = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    if cameraConnection then cameraConnection:Disconnect() end
    for _, animation in pairs(animations) do animation:Cancel() end
    activeSlider, dragging = nil, nil
end)
selectPage("Main", "Combat")
refreshKey(); bindCamera(); refreshHud(); refreshWatermark()
animate(root, {GroupTransparency = 0}, 0.23)

