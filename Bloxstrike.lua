-- NOIR / Blox Strike — Motion Edition: меню Silent Aim, Rapid Fire, Auto Shoot, Autowall и ESP.
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
    extras = { autoShoot = false, autoWall = false, box = false, names = false, outline = false, forceOrigin = false, autoReload = false, instaReload = false, chams = false, antiSmoke = false, antiFlash = false, autoScope = false },
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
menu.Size = UDim2.fromOffset(640, 440)
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.new(0.5, 0, 0.5, 0)
menu.BackgroundColor3 = Color3.fromRGB(9,15,11)
menu.BorderSizePixel = 0
menu.ZIndex = 10
menu.Parent = gui
menu.Visible = false -- до завершения заставки
round(menu, 14)
do
    local grad=Instance.new("UIGradient")
    grad.Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(176,198,181))
    grad.Rotation,grad.Parent=90,menu
end
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255,255,255)
border.Thickness, border.Transparency = 1.6, 0.1
border.Parent = menu
local borderGrad=Instance.new("UIGradient")
borderGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(106,210,145)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(174,226,191)),ColorSequenceKeypoint.new(1,Color3.fromRGB(106,210,145))})
borderGrad.Parent=border
RunService.Heartbeat:Connect(function()
    if menu.Visible then borderGrad.Rotation=(os.clock()*35)%360 end
end)
local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, -28, 0, 2)
accent.Position = UDim2.fromOffset(14, 46)
accent.BorderSizePixel, accent.BackgroundColor3, accent.ZIndex = 0, Color3.fromRGB(255,255,255), 12
accent.Parent = menu
round(accent, 2)
do
    local ag=Instance.new("UIGradient")
    ag.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(106,210,145)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(174,226,191)),ColorSequenceKeypoint.new(1,Color3.fromRGB(24,28,48))})
    ag.Parent=accent
end

local header = Instance.new("Frame")
header.Name = "DragBar"
header.Size = UDim2.new(1, -50, 0, 48)
header.BackgroundTransparency = 1
header.Active = true
header.ZIndex = 11
header.Parent = menu
local badge = Instance.new("Frame")
badge.Name, badge.BackgroundColor3, badge.BorderSizePixel = "BrandBadge", Color3.fromRGB(26,60,38), 0
badge.Size, badge.Position, badge.ZIndex, badge.Parent = UDim2.fromOffset(30,30), UDim2.fromOffset(14,9), 12, header
round(badge, 9)
local badgeText = label(badge, "N", UDim2.fromScale(1,1), UDim2.fromOffset(0,0), 11)
badgeText.TextXAlignment, badgeText.TextColor3, badgeText.ZIndex = Enum.TextXAlignment.Center, Color3.fromRGB(201,241,211), 13
local title = label(header, "N O I R", UDim2.new(1, -60, 0, 22), UDim2.fromOffset(54, 6), 15)
title.ZIndex = 12
local subtitle = label(header, "CREATOR  /  BLOX STRIKE", UDim2.new(1, -60, 0, 17), UDim2.fromOffset(54, 26), 9)
subtitle.TextColor3 = Color3.fromRGB(156,159,182)
subtitle.ZIndex = 12
do
    local version=label(header,"CONTROL  /  01",UDim2.fromOffset(130,16),UDim2.new(1,-153,0.5,-8),9)
    version.TextXAlignment,version.TextColor3,version.ZIndex=Enum.TextXAlignment.Right,Color3.fromRGB(133,159,140),12
end
do
    local chip=Instance.new("Frame")
    chip.Name,chip.Size,chip.Position,chip.BackgroundColor3,chip.BorderSizePixel,chip.ZIndex,chip.Parent="StatusDot",UDim2.fromOffset(6,6),UDim2.new(1,-168,0.5,-3),Color3.fromRGB(239,187,101),0,12,header
    round(chip,3)
    local last=0
    RunService.Heartbeat:Connect(function()
        local now=os.clock()
        if now-last<0.4 or not menu.Visible then return end
        last=now
        local ready=state.ready
        chip.BackgroundColor3=ready and Color3.fromRGB(151,235,175) or Color3.fromRGB(239,187,101)
    end)
end
local close = smallButton(menu, "×", UDim2.fromOffset(32, 32), UDim2.new(1, -42, 0, 8))
close.Name = "NoirClose"
close.BackgroundColor3 = Color3.fromRGB(27,39,30)
close.TextColor3 = Color3.fromRGB(209,212,232)
close.TextSize = 21
close.ZIndex = 12

local reopen = smallButton(gui, "", UDim2.fromOffset(110, 40), UDim2.new(0, 12, 0.36, 0))
reopen.Name, reopen.BackgroundColor3, reopen.Visible, reopen.ZIndex = "NoirReopen", Color3.fromRGB(12,20,14), false, 10
local reopenEdge=Instance.new("UIStroke")
reopenEdge.Color,reopenEdge.Thickness,reopenEdge.Transparency,reopenEdge.Parent=Color3.fromRGB(180,184,208),1.4,0.1,reopen
reopenEdge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local reopenIcon=Instance.new("Frame")
reopenIcon.Size,reopenIcon.Position=UDim2.fromOffset(29,29),UDim2.fromOffset(5,5)
reopenIcon.BackgroundColor3,reopenIcon.BorderSizePixel,reopenIcon.ZIndex,reopenIcon.Parent=Color3.fromRGB(28,76,43),0,11,reopen
round(reopenIcon,9)
local reopenN=label(reopenIcon,"N",UDim2.fromScale(1,1),UDim2.fromOffset(0,0),14)
reopenN.TextXAlignment,reopenN.TextColor3,reopenN.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(208,213,245),12
local reopenText=label(reopen,"NOIR",UDim2.fromOffset(65,16),UDim2.fromOffset(40,5),11)
reopenText.TextColor3,reopenText.ZIndex=Color3.fromRGB(226,235,228),12
local reopenSub=label(reopen,"CONTROL",UDim2.fromOffset(62,12),UDim2.fromOffset(40,21),8)
reopenSub.TextColor3,reopenSub.ZIndex=Color3.fromRGB(117,124,174),12
local reopenScale=Instance.new("UIScale")
reopenScale.Scale,reopenScale.Parent=1,reopen
local function introReopen()
    reopenScale.Scale=0.88
    pcall(function() game:GetService("TweenService"):Create(reopenScale,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1}):Play() end)
end
RunService.Heartbeat:Connect(function()
    if reopen.Visible then reopenEdge.Transparency=0.18+0.12*(0.5+0.5*math.sin(os.clock()*2.2)) end
end)
local reopenDrag, reopenStart, reopenOriginal, reopenMoved
reopen.InputBegan:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    reopenDrag,reopenStart,reopenOriginal,reopenMoved=input,input.Position,reopen.Position,false
end)
UserInputService.InputChanged:Connect(function(input)
    if not reopenDrag then return end
    local matching=(input==reopenDrag) or (reopenDrag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)
    if matching then
        local delta=input.Position-reopenStart
        if delta.Magnitude>5 then reopenMoved=true end
        if reopenMoved then reopen.Position=UDim2.new(reopenOriginal.X.Scale,reopenOriginal.X.Offset+delta.X,reopenOriginal.Y.Scale,reopenOriginal.Y.Offset+delta.Y) end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if reopenDrag and (input==reopenDrag or (reopenDrag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then
        reopenDrag=nil
        task.delay(0.15,function() if not reopenDrag then reopenMoved=false end end)
    end
end)
close.MouseButton1Click:Connect(function() menu.Visible=false; reopen.Visible=true; introReopen() end)
reopen.MouseButton1Click:Connect(function()
    if reopenMoved then return end
    menu.Visible=true; reopen.Visible=false
    if state.menuScale then
        local target=state.menuScale.Scale
        state.menuScale.Scale=target*0.96
        local ok=pcall(function() game:GetService("TweenService"):Create(state.menuScale,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=target}):Play() end)
        if not ok then state.menuScale.Scale=target end
    end
end)
state.menu = menu
-- Подгоняем панель под маленький экран; изменения устройства не растягивают её.
local menuScale = Instance.new("UIScale")
menuScale.Parent = menu
state.menuScale=menuScale
local function updateMenuScale()
    local camera = Workspace.CurrentCamera
    if camera then
        local size = camera.ViewportSize
        menuScale.Scale = math.clamp(math.min((size.X-16)/640, (size.Y-16)/440), 0.3, 1)
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

-- Основные разделы сверху, под ними вложенные страницы.
local selectedTab = "COMBAT"
local tabs, entries, indicators = {}, {}, {}
local groups = {
    ["SILENT"]={"COMBAT",0}, ["AUTO SHOOT"]={"COMBAT",1},
    ["AUTOWALL"]={"COMBAT",2}, ["FORCE ORIGIN"]={"COMBAT",3}, ["TEAM CHECK"]={"COMBAT",4}, ["AUTO SCOPE"]={"COMBAT",5},
    ["RAPID"]={"WEAPON",0}, ["AUTO RELOAD"]={"WEAPON",1}, ["INSTA RELOAD"]={"WEAPON",2},
    ["ESP BOX"]={"VISUALS",0}, ["NAMES / HP"]={"VISUALS",1}, ["OUTLINE"]={"VISUALS",2}, ["CHAMS"]={"VISUALS",3}, ["RADAR"]={"VISUALS",4}, ["HIT LOG"]={"VISUALS",5},
    ["BOX STYLE"]={"SETTINGS",0}, ["OUTLINE STYLE"]={"SETTINGS",1}, ["CHAMS STYLE"]={"SETTINGS",2}, ["ESP COLOR"]={"SETTINGS",3},
    ["ANTI SMOKE"]={"EFFECTS",0}, ["ANTI FLASH"]={"EFFECTS",1},
    ["BOMB ESP"]={"OBJECTIVE",0}, ["BOMB TIMER"]={"OBJECTIVE",1}, ["AUTO DEFUSE"]={"OBJECTIVE",2}, ["AUTO PLANT"]={"OBJECTIVE",3},
    ["BHOP"]={"MOVEMENT",0}, ["THIRD PERSON"]={"MOVEMENT",1},
}
local mainFor = {COMBAT="COMBAT", WEAPON="COMBAT", VISUALS="VISUALS", OBJECTIVE="TOOLS", EFFECTS="TOOLS", MOVEMENT="TOOLS"}
local subNames = {COMBAT="AIM", WEAPON="WEAPON", VISUALS="PLAYER", OBJECTIVE="BOMB", EFFECTS="EFFECTS", MOVEMENT="MOVEMENT"}
local subTabs, mainTabs = {}, {}
do
    local panel=Instance.new("Frame")
    panel.Name,panel.Position,panel.Size="ContentPanel",UDim2.fromOffset(10,118),UDim2.new(1,-20,0,280)
    panel.BackgroundColor3,panel.BorderSizePixel,panel.ZIndex,panel.Parent=Color3.fromRGB(12,20,14),0,11,menu
    round(panel,11)
    local edge=Instance.new("UIStroke")
    edge.Color,edge.Transparency,edge.Thickness,edge.Parent=Color3.fromRGB(82,112,89),0.72,1,panel
end
local pageHint = label(menu, "", UDim2.fromOffset(290,20), UDim2.fromOffset(16,123), 12)
pageHint.TextColor3, pageHint.ZIndex = Color3.fromRGB(226,237,229), 12
local pageSub = label(menu, "", UDim2.fromOffset(180,16), UDim2.new(1,-195,0,125), 9)
pageSub.TextXAlignment, pageSub.TextColor3, pageSub.ZIndex = Enum.TextXAlignment.Right, Color3.fromRGB(133,157,138), 12
local hideSettings = function() end
local function setTab(name)
    hideSettings()
    selectedTab = name
    local main = mainFor[name]
    local headings = {COMBAT="PRECISION  /  AIM", WEAPON="COMBAT  /  WEAPON", VISUALS="VISUALS  /  PLAYER", STYLE="VISUALS  /  STYLE", OBJECTIVE="TOOLS  /  OBJECTIVE", EFFECTS="TOOLS  /  EFFECTS", MOVEMENT="TOOLS  /  MOVEMENT"}
    local hints = {COMBAT="360° TARGETING", WEAPON="FIRE & RELOAD", VISUALS="PLAYER OVERLAY", STYLE="VISUAL PRESETS", OBJECTIVE="BOMB CONTROL", EFFECTS="LOCAL FILTERS", MOVEMENT="CAMERA & MOBILITY"}
    pageHint.Text, pageSub.Text = headings[name], hints[name]
    for group, button in pairs(mainTabs) do
        local active = group == main
        button.BackgroundColor3 = active and Color3.fromRGB(28,67,42) or Color3.fromRGB(18,28,21)
        button.TextColor3 = active and Color3.fromRGB(214,222,255) or Color3.fromRGB(143,169,149)
        local st=button:FindFirstChildOfClass("UIStroke")
        if st then st.Color=active and Color3.fromRGB(106,210,145) or Color3.fromRGB(104,132,111); st.Transparency=active and 0.1 or 0.55 end
    end
    local slot=0
    for _, sub in ipairs({"COMBAT","WEAPON","VISUALS","OBJECTIVE","EFFECTS","MOVEMENT"}) do
        local item = subTabs[sub]
        item.Visible = mainFor[sub] == main
        if item.Visible then
            item.Position = UDim2.fromOffset(15+slot*100, 91); slot+=1
            item.BackgroundColor3 = sub == name and Color3.fromRGB(32,50,37) or Color3.fromRGB(12,13,20)
            item.TextColor3 = sub == name and Color3.fromRGB(222,239,225) or Color3.fromRGB(125,128,154)
        end
    end
    for _, entry in ipairs(entries) do entry.button.Visible = entry.group == name end
end
for index, name in ipairs({"COMBAT", "VISUALS", "TOOLS"}) do
    local tab = smallButton(menu, name, UDim2.fromOffset(198, 30), UDim2.fromOffset(15+(index-1)*206, 54))
    tab.Name, tab.TextSize, tab.ZIndex = name.."MainTab", 10, 12
    local edge = Instance.new("UIStroke")
    edge.Color, edge.Transparency, edge.Thickness, edge.Parent = Color3.fromRGB(93,126,101), 0.52, 1, tab
    edge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    mainTabs[name] = tab
    local target = name == "TOOLS" and "OBJECTIVE" or name
    tab.MouseButton1Click:Connect(function() setTab(target) end)
end
for _, name in ipairs({"COMBAT","WEAPON","VISUALS","OBJECTIVE","EFFECTS","MOVEMENT"}) do
    local tab = smallButton(menu, subNames[name], UDim2.fromOffset(93, 24), UDim2.fromOffset(15,91))
    tab.Name, tab.TextSize, tab.ZIndex = name.."Tab", 9, 12
    subTabs[name], tabs[name] = tab, tab
    tab.MouseButton1Click:Connect(function() setTab(name) end)
end
setTab(selectedTab)
local descriptions={
    SILENT="Target redirection", ["AUTO SHOOT"]="Fire on target", AUTOWALL="Penetration check", ["FORCE ORIGIN"]="Local origin scan", ["TEAM CHECK"]="Exclude teammates",
    RAPID="Fire rate control", ["AUTO RELOAD"]="Reload when empty", ["INSTA RELOAD"]="Fast magazine reload",
    ["ESP BOX"]="Enemy frame", ["NAMES / HP"]="Name, distance & health", OUTLINE="Silhouette edge", CHAMS="Silhouette fill",
    ["BOMB ESP"]="Planted or dropped C4", ["BOMB TIMER"]="Explosion countdown", ["AUTO DEFUSE"]="Defuse in range", ["AUTO PLANT"]="Plant on site",
    ["AUTO SCOPE"]="Scope on a target", RADAR="Nearby enemies", ["HIT LOG"]="Observed hit & HP",
    ["ANTI SMOKE"]="Hide local smoke", ["ANTI FLASH"]="Block flash effect", BHOP="Hold jump to repeat", ["THIRD PERSON"]="Offset camera",
}
local function makeToggle(name, index)
    local layout = assert(groups[name], "unknown toggle: " .. name)
    local col,row=layout[2]%2,math.floor(layout[2]/2)
    local item=smallButton(menu,"",UDim2.fromOffset(295,58),UDim2.fromOffset(15+col*315,151+row*74))
    item.Name,item.ZIndex,item.Visible=name.."Toggle",12,layout[1]==selectedTab
    item.BackgroundColor3=Color3.fromRGB(17,27,20)
    local edge=Instance.new("UIStroke")
    edge.Color,edge.Thickness,edge.Transparency,edge.Parent=Color3.fromRGB(100,128,106),1,0.7,item
    edge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local nameText=label(item,name,UDim2.fromOffset(142,16),UDim2.fromOffset(12,6),10)
    nameText.TextColor3,nameText.ZIndex=Color3.fromRGB(222,235,225),14
    local detail=label(item,descriptions[name] or "",UDim2.fromOffset(144,15),UDim2.fromOffset(12,24),8)
    detail.TextColor3,detail.ZIndex=Color3.fromRGB(122,127,158),14
    local status=label(item,"",UDim2.fromOffset(40,11),UDim2.new(1,-47,0,0),8)
    status.TextXAlignment,status.ZIndex=Enum.TextXAlignment.Center,14
    local switch=Instance.new("Frame")
    switch.Name,switch.Size,switch.Position="Switch",UDim2.fromOffset(30,16),UDim2.new(1,-41,0.5,-8)
    switch.BackgroundColor3,switch.BorderSizePixel,switch.ZIndex,switch.Parent=Color3.fromRGB(53,73,58),0,14,item
    round(switch,8)
    local knob=Instance.new("Frame")
    knob.Size,knob.Position=UDim2.fromOffset(12,12),UDim2.fromOffset(2,2)
    knob.BackgroundColor3,knob.BorderSizePixel,knob.ZIndex,knob.Parent=Color3.fromRGB(182,185,204),0,15,switch
    round(knob,7)
    local accent=Instance.new("Frame")
    accent.Name,accent.Size,accent.Position="StateDot",UDim2.fromOffset(2,22),UDim2.new(0,3,0.5,-11)
    accent.BackgroundColor3,accent.BorderSizePixel,accent.ZIndex,accent.Parent=Color3.fromRGB(61,87,67),0,13,item
    round(accent,2)
    indicators[item]={status=status,edge=edge,dot=accent,switch=switch,knob=knob,name=nameText,detail=detail}
    table.insert(entries,{group=layout[1],button=item})
    item.MouseEnter:Connect(function()
        local data=indicators[item]
        if data and not data.lastEnabled then pcall(function() game:GetService("TweenService"):Create(item,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,44,32)}):Play() end) end
    end)
    item.MouseLeave:Connect(function()
        pcall(function() game:GetService("TweenService"):Create(item,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(18,28,21)}):Play() end)
    end)
    return item
end
local function showToggle(item,name,enabled,waiting)
    local data=indicators[item]
    data.name.Text=name
    data.status.Text=waiting and "WAIT" or ""
    data.status.TextColor3=Color3.fromRGB(235,185,100)
    local trackColor=enabled and Color3.fromRGB(53,158,92) or Color3.fromRGB(53,73,58)
    local knobPosition=UDim2.fromOffset(enabled and 16 or 2,2)
    local knobColor=enabled and Color3.fromRGB(224,228,255) or Color3.fromRGB(182,185,204)
    if data.lastEnabled~=nil and data.lastEnabled~=enabled then
        local ok=pcall(function()
            local tweenService=game:GetService("TweenService")
            local info=TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
            tweenService:Create(data.switch,info,{BackgroundColor3=trackColor}):Play()
            tweenService:Create(data.knob,info,{Position=knobPosition,BackgroundColor3=knobColor}):Play()
        end)
        if not ok then data.switch.BackgroundColor3=trackColor;data.knob.Position=knobPosition;data.knob.BackgroundColor3=knobColor end
    elseif data.lastEnabled==nil then
        data.switch.BackgroundColor3=trackColor;data.knob.Position=knobPosition;data.knob.BackgroundColor3=knobColor
    end
    data.lastEnabled=enabled
    data.edge.Color=enabled and Color3.fromRGB(111,173,125) or Color3.fromRGB(100,128,106)
    data.edge.Transparency=enabled and 0.42 or 0.7
    data.dot.BackgroundColor3=waiting and Color3.fromRGB(239,187,101) or (enabled and Color3.fromRGB(116,223,151) or Color3.fromRGB(61,87,67))
end
local footer = label(menu, "NOIR CREATOR   /   PRIVATE CONTROL", UDim2.fromOffset(280,16), UDim2.fromOffset(15,416), 9)
footer.TextColor3, footer.ZIndex = Color3.fromRGB(117,144,123), 12
do
    local right=label(menu,"SILVER  /  MOBILE",UDim2.fromOffset(160,16),UDim2.new(1,-175,0,416),9)
    right.TextXAlignment,right.TextColor3,right.ZIndex=Enum.TextXAlignment.Right,Color3.fromRGB(139,160,144),12
end
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
local scopeButton = makeToggle("AUTO SCOPE", 19)
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
    {bright=Color3.fromRGB(151,255,188), fill=Color3.fromRGB(35,201,105)},
    {bright=Color3.fromRGB(255,138,175), fill=Color3.fromRGB(229,67,121)},
    {bright=Color3.fromRGB(138,201,255), fill=Color3.fromRGB(69,138,236)},
}
local function styleCard(item,title,value)
    local data=indicators[item]
    data.name.Text=title
    data.name.Position=UDim2.fromOffset(10,5)
    data.detail.Visible=false
    data.switch.Visible=false
    data.dot.Visible=false
    data.status.Text,data.status.TextColor3=value,Color3.fromRGB(150,161,232)
    data.status.Size=UDim2.fromOffset(72,18)
    data.status.Position=UDim2.new(1,-78,0.5,-9)
    data.status.TextXAlignment=Enum.TextXAlignment.Right
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
slider.Name, slider.BackgroundColor3, slider.BorderSizePixel = "OriginSlider", Color3.fromRGB(16,18,27), 0
slider.Size, slider.Position, slider.ZIndex = UDim2.fromOffset(450, 42), UDim2.fromOffset(15, 266), 12
slider.Parent = menu
round(slider, 8)
local sliderEdge = Instance.new("UIStroke")
sliderEdge.Color, sliderEdge.Transparency, sliderEdge.Parent = Color3.fromRGB(98,103,137), 0.35, slider
local sliderTitle = label(slider, "ORIGIN RADIUS", UDim2.fromOffset(170,14), UDim2.fromOffset(10,5), 9)
sliderTitle.TextColor3, sliderTitle.ZIndex = Color3.fromRGB(172,190,205), 13
local sliderValue = label(slider, "", UDim2.fromOffset(65,14), UDim2.new(1,-75,0,5), 9)
sliderValue.TextXAlignment, sliderValue.TextColor3, sliderValue.ZIndex = Enum.TextXAlignment.Right, Color3.fromRGB(129,144,245), 13
local track = Instance.new("Frame")
track.Name, track.BorderSizePixel, track.BackgroundColor3 = "Track", 0, Color3.fromRGB(36,40,61)
track.Position, track.Size, track.ZIndex, track.Parent = UDim2.fromOffset(12,28), UDim2.new(1,-24,0,4), 13, slider
round(track, 3)
local fill = Instance.new("Frame")
fill.BorderSizePixel, fill.BackgroundColor3, fill.ZIndex, fill.Parent = 0, Color3.fromRGB(102,74,213), 14, track
round(fill, 3)
local knob = Instance.new("Frame")
knob.AnchorPoint, knob.Size = Vector2.new(0.5,0.5), UDim2.fromOffset(13,13)
knob.BackgroundColor3, knob.BorderSizePixel, knob.ZIndex, knob.Parent = Color3.fromRGB(205,210,245), 0, 15, track
round(knob, 8)
do
    local fg=Instance.new("UIGradient")
    fg.Color=ColorSequence.new(Color3.fromRGB(106,210,145),Color3.fromRGB(174,226,191))
    fg.Parent=fill
    local ks=Instance.new("UIStroke")
    ks.Color,ks.Thickness,ks.Transparency,ks.Parent=Color3.fromRGB(110,160,255),2,0.45,knob
end
local function redrawSlider()
    local ratio = config.originRadius/9
    fill.Size, knob.Position = UDim2.fromScale(ratio,1), UDim2.fromScale(ratio,0.5)
    sliderValue.Text = string.format("%.1f st", config.originRadius)
end
redrawSlider()
table.insert(entries, {group="SETTINGS", button=slider})
slider.Visible = false
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
    showToggle(scopeButton, "AUTO SCOPE", extras.autoScope, false)
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

scopeButton.MouseButton1Click:Connect(function()
    extras.autoScope=not extras.autoScope
    state.scopeWeapon,state.scopeWaitAt=nil,nil
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

-- Общий ограничитель Auto Scope: один вызов для обоих циклов.
local function requestScope(weapon, now)
    if now-(state.scopeLastCall or -math.huge)<0.35 then return nil end
    state.scopeLastCall=now
    local ok,result=pcall(weapon.scope,weapon,true)
    return ok and result~=false
end

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
    if extras.autoScope and type(properties)=="table" and (properties.HasScope or properties.AimingOptions=="SniperScope") and not weapon.IsAiming and type(weapon.scope)=="function" then
        if state.scopeWeapon~=weapon then state.scopeWeapon=weapon;state.scopeWaitAt=now end
        if now-(state.scopeWaitAt or now)<1.2 then
            local scoped=requestScope(weapon,now)
            if scoped~=false then nextAutoAttempt=now+0.15;return end
        end
    else
        state.scopeWeapon,state.scopeWaitAt=nil,nil
    end
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
-- Автоприцеливание с оптикой, радар и журнал наблюдаемого изменения здоровья.
do
    local radarButton=makeToggle("RADAR",40)
    local hitsButton=makeToggle("HIT LOG",41)
    local hudState={radar=false,hits=false,range=500}
    state.hud=hudState
    local function refreshHud()
        showToggle(radarButton,"RADAR",hudState.radar,false)
        showToggle(hitsButton,"HIT LOG",hudState.hits,hudState.hits and not state.hitReady)
    end

    -- Круглый радар: игрок в центре, север экрана совпадает с направлением камеры.
    local radar=Instance.new("Frame")
    radar.Name,radar.Size,radar.Position="NoirRadar",UDim2.fromOffset(170,170),UDim2.new(0,16,0.47,0)
    radar.BackgroundColor3,radar.BackgroundTransparency,radar.BorderSizePixel,radar.ZIndex,radar.Parent=Color3.fromRGB(9,18,13),0.08,0,5,gui
    radar.Visible=false
    round(radar,85)
    local radarBorder=Instance.new("UIStroke")
    radarBorder.Color,radarBorder.Thickness,radarBorder.Transparency,radarBorder.Parent=Color3.fromRGB(143,192,158),1.5,0.22,radar
    local inner=Instance.new("Frame")
    inner.AnchorPoint,inner.Position,inner.Size=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(150,150)
    inner.BackgroundColor3,inner.BackgroundTransparency,inner.BorderSizePixel,inner.ZIndex,inner.Parent=Color3.fromRGB(16,32,22),0.12,0,6,radar
    round(inner,75)
    local ring=Instance.new("UIStroke")
    ring.Color,ring.Transparency,ring.Parent=Color3.fromRGB(101,146,111),0.55,inner
    local middle=Instance.new("Frame")
    middle.AnchorPoint,middle.Position,middle.Size=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(76,76)
    middle.BackgroundTransparency,middle.ZIndex,middle.Parent=1,7,inner
    round(middle,38)
    local middleEdge=Instance.new("UIStroke")
    middleEdge.Color,middleEdge.Transparency,middleEdge.Parent=Color3.fromRGB(94,137,102),0.68,middle
    for _,horizontal in ipairs({true,false}) do
        local line=Instance.new("Frame")
        line.AnchorPoint,line.Position=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5)
        line.Size=horizontal and UDim2.fromOffset(144,1) or UDim2.fromOffset(1,144)
        line.BorderSizePixel,line.BackgroundColor3,line.BackgroundTransparency,line.ZIndex,line.Parent=0,Color3.fromRGB(108,157,116),0.72,7,inner
    end
    local center=Instance.new("Frame")
    center.AnchorPoint,center.Position,center.Size=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(7,7)
    center.BackgroundColor3,center.BorderSizePixel,center.ZIndex,center.Parent=Color3.fromRGB(224,255,230),0,9,inner
    round(center,4)
    local heading=label(radar,"N",UDim2.fromOffset(20,16),UDim2.new(0.5,-10,0,10),10)
    heading.TextXAlignment,heading.TextColor3,heading.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(185,232,194),8
    local status=label(radar,"WAITING",UDim2.fromOffset(116,14),UDim2.new(0.5,-58,1,-30),8)
    status.TextXAlignment,status.TextColor3,status.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(164,193,169),8
    -- Прозрачный захват над всей поверхностью: никаких отдельных полос для перетаскивания.
    local dragSurface=Instance.new("TextButton")
    dragSurface.Name,dragSurface.Text,dragSurface.BackgroundTransparency="RadarDrag","",1
    dragSurface.AutoButtonColor,dragSurface.Active,dragSurface.Size,dragSurface.ZIndex,dragSurface.Parent=false,true,UDim2.fromScale(1,1),10,radar
    round(dragSurface,85)
    local dots={}
    local radarInput,radarStart,radarPos
    dragSurface.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            radarInput,radarStart,radarPos=input,input.Position,radar.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not radarInput then return end
        if input==radarInput or (radarInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) then
            local delta=input.Position-radarStart
            radar.Position=UDim2.new(radarPos.X.Scale,radarPos.X.Offset+delta.X,radarPos.Y.Scale,radarPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if radarInput and (input==radarInput or (radarInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then radarInput=nil end
    end)
    local function clearRadar()
        for model,rec in pairs(dots) do rec.frame:Destroy();dots[model]=nil end
    end
    radarButton.MouseButton1Click:Connect(function()
        hudState.radar=not hudState.radar
        radar.Visible=hudState.radar
        if not hudState.radar then radarInput=nil;clearRadar() end
        refreshHud()
    end)
    local function radarTeam(character,player)
        local t=player and player:GetAttribute("Team") or teamOf(character)
        if t~=nil then return tostring(t) end
        if player and player.Team then return tostring(player.Team.Name) end
        return nil
    end
    local function updateRadar()
        if not hudState.radar then return end
        local camera=Workspace.CurrentCamera
        local characters=Workspace:FindFirstChild("Characters")
        local own=(characters and characters:FindFirstChild(localPlayer.Name)) or localPlayer.Character
        local root=own and (own:FindFirstChild("HumanoidRootPart") or own:FindFirstChild("Head") or own.PrimaryPart)
        if not camera or not root or not root:IsA("BasePart") or tostring(own:GetAttribute("Dead"))=="true" then
            for _,rec in pairs(dots) do rec.frame.Visible=false end
            status.Text="WAITING FOR PLAYER"
            return
        end
        local look=camera.CFrame.LookVector
        local length=math.sqrt(look.X*look.X+look.Z*look.Z)
        if length<0.001 then look=camera.CFrame.UpVector;length=math.sqrt(look.X*look.X+look.Z*look.Z) end
        if length<0.001 then return end
        local fx,fz=look.X/length,look.Z/length
        local myTeam=radarTeam(own,localPlayer)
        local ffa=string.find(tostring(Workspace:GetAttribute("Gamemode")),"Deathmatch",1,true)~=nil
        local candidates,added={},{}
        local function add(model,player)
            local key=player or model
            if model and model:IsA("Model") and not added[model] and not added[key] then
                added[model]=true;added[key]=true
                table.insert(candidates,{model=model,player=player})
            end
        end
        if characters then
            for _,model in ipairs(characters:GetChildren()) do add(model,Players:FindFirstChild(model.Name)) end
        end
        for _,player in ipairs(Players:GetPlayers()) do add(player.Character,player) end
        local seen,count={},0
        for _,entry in ipairs(candidates) do
            local model,player=entry.model,entry.player
            local hp=tonumber(model:GetAttribute("Health"))
            local hum=model:FindFirstChildOfClass("Humanoid")
            if not hp and hum then hp=hum.Health end
            local otherTeam=radarTeam(model,player)
            local sameTeam=config.teamCheck and not ffa and myTeam~=nil and otherTeam~=nil and myTeam==otherTeam
            local valid=model~=own and model.Name~=localPlayer.Name and tostring(model:GetAttribute("Dead"))~="true"
                and (not hp or hp>0) and not sameTeam and (player~=nil or hp~=nil)
            if valid then
                local part=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model.PrimaryPart
                if part and part:IsA("BasePart") then
                    local delta=part.Position-root.Position
                    local right,forward=delta.X*(-fz)+delta.Z*fx,delta.X*fx+delta.Z*fz
                    local dist=math.sqrt(right*right+forward*forward)
                    local limit=math.max(1,dist/hudState.range)
                    local rec=dots[model]
                    if not rec then
                        local dot=Instance.new("Frame")
                        dot.Name,dot.AnchorPoint,dot.Size="RadarEnemy",Vector2.new(0.5,0.5),UDim2.fromOffset(7,7)
                        dot.BorderSizePixel,dot.ZIndex,dot.Parent=0,8,inner
                        round(dot,4);rec={frame=dot};dots[model]=rec
                    end
                    seen[model]=true;count+=1
                    rec.frame.Visible=true
                    rec.frame.Position=UDim2.fromOffset(75+(right/hudState.range/limit)*67,75-(forward/hudState.range/limit)*67)
                    -- Серый маркер означает неизвестную команду, а не гарантированного врага.
                    local unknown=config.teamCheck and not ffa and (not myTeam or not otherTeam)
                    rec.frame.BackgroundColor3=unknown and Color3.fromRGB(190,196,191) or Color3.fromRGB(255,122,110)
                    rec.frame.BackgroundTransparency=dist>hudState.range and 0.35 or 0
                end
            end
        end
        for model,rec in pairs(dots) do if not seen[model] then rec.frame:Destroy();dots[model]=nil end end
        status.Text=count>0 and (tostring(count).." DETECTED") or "NO CONTACTS"
    end

    local pending, notes = {}, {}
    local function healthOf(model)
        if not model then return nil end
        local hp=tonumber(model:GetAttribute("Health"))
        if hp then return hp end
        local human=model:FindFirstChildOfClass("Humanoid")
        return human and tonumber(human.Health) or nil
    end
    local function clearNotes()
        for _,item in ipairs(notes) do item:Destroy() end
        table.clear(notes);table.clear(pending)
    end
    hitsButton.MouseButton1Click:Connect(function()
        hudState.hits=not hudState.hits
        if not hudState.hits then clearNotes() end
        refreshHud()
    end)
    local function arrange()
        for index,item in ipairs(notes) do item.Position=UDim2.new(1,-222,0,90+(index-1)*35) end
    end
    local function notify(model,before,after)
        if not hudState.hits then return end
        local card=Instance.new("Frame")
        card.Name,card.Size= "NoirHitNotice",UDim2.fromOffset(206,30)
        card.BackgroundColor3,card.BackgroundTransparency,card.BorderSizePixel,card.ZIndex,card.Parent=Color3.fromRGB(15,12,26),0.08,0,7,gui
        round(card,7)
        local edge=Instance.new("UIStroke")
        edge.Color,edge.Transparency,edge.Parent=Color3.fromRGB(113,101,160),0.3,card
        local text=label(card,string.format("HP Δ  /  %s  ·  -%d  ·  %d HP",model.Name,math.floor(before-after+0.5),math.max(0,math.floor(after+0.5))),UDim2.new(1,-16,1,0),UDim2.fromOffset(8,0),10)
        text.TextColor3,text.ZIndex=Color3.fromRGB(190,198,249),8
        table.insert(notes,1,card)
        while #notes>4 do table.remove(notes):Destroy() end
        arrange()
        task.delay(3,function()
            for i,item in ipairs(notes) do if item==card then table.remove(notes,i);break end end
            card:Destroy();arrange()
        end)
    end
    -- Сопоставляем локальный луч и последующее уменьшение HP; автор урона не подтверждён сервером.
    state.noteLocalRay=function(result)
        if not hudState.hits or type(result)~="table" or type(result.Hits)~="table" then return end
        local characters=Workspace:FindFirstChild("Characters")
        if not characters then return end
        local own=characters:FindFirstChild(localPlayer.Name) or localPlayer.Character
        local myTeam=localPlayer:GetAttribute("Team") or teamOf(own)
        local ffa=string.find(tostring(Workspace:GetAttribute("Gamemode")),"Deathmatch",1,true)~=nil
        for _,hit in ipairs(result.Hits) do
            local part=type(hit)=="table" and hit.Instance
            if part and not hit.Exit then
                for _,model in ipairs(characters:GetChildren()) do
                    if isEnemy(model,own,ffa,myTeam) and part:IsDescendantOf(model) then
                        local hp=healthOf(model)
                        if hp and not pending[model] then pending[model]={hp=hp,at=os.clock()} end
                        break
                    end
                end
            end
        end
    end
    local lastRadar,lastHud,lastScope=0,0,0
    RunService.Heartbeat:Connect(function()
        local now=os.clock()
        if now-lastHud>1 then lastHud=now; refreshHud() end
        if now-lastRadar>0.12 then
            lastRadar=now
            local radarOk,radarError=pcall(updateRadar)
            if not radarOk and hudState.radar then
                status.Text="RADAR ERROR"
                if now-(state.lastRadarWarning or 0)>5 then
                    state.lastRadarWarning=now
                    warn("[Noir Radar] "..tostring(radarError))
                end
            end
            if hudState.hits then
                for model,shot in pairs(pending) do
                    local hp=model.Parent and healthOf(model)
                    if hp and hp<shot.hp then notify(model,shot.hp,hp);pending[model]=nil
                    elseif not model.Parent or now-shot.at>1.5 then pending[model]=nil end
                end
            end
        end
        if extras.autoScope and now-lastScope>0.35 then
            lastScope=now
            local target=state.target
            if not target or not target.Parent then local ok,v=pcall(selectTarget); if ok then target=v end end
            if target and target.Parent then
                local controller=state.rapid and state.rapid.controller
                local getter=controller and controller.peekCurrentEquippedForMovement
                if type(getter)=="function" then
                    local ok,weapon=pcall(getter)
                    local props=ok and type(weapon)=="table" and weapon.Properties
                    if props and (props.HasScope or props.AimingOptions=="SniperScope") and weapon.Player==localPlayer
                        and not weapon.IsAiming and not weapon.IsDestroyed and not weapon.IsReloading and type(weapon.scope)=="function" then
                        requestScope(weapon,now)
                    end
                end
            end
        end
    end)
    refreshHud()
end


-- Movement: прыжковая команда игры и камера от третьего лица.
do
    local movement = {bhop=false, third=false, distance=8, bhopReady=false, thirdReady=false}
    state.movement = movement
    local bhopButton = makeToggle("BHOP", 30)
    local thirdButton = makeToggle("THIRD PERSON", 31)
    local function refreshMovement()
        showToggle(bhopButton, "BHOP", movement.bhop, movement.bhop and not movement.bhopReady)
        showToggle(thirdButton, "THIRD PERSON", movement.third, movement.third and not movement.thirdReady)
    end
    state.thirdButton=thirdButton
    bhopButton.MouseButton1Click:Connect(function()
        movement.bhop=not movement.bhop
        refreshMovement()
    end)
    thirdButton.MouseButton1Click:Connect(function() movement.third=not movement.third; refreshMovement() end)
    refreshMovement()

    -- Bhop: повторяет прыжок только пока удерживается штатная кнопка прыжка.
    local lastGroundPulse = false
    local function editCommand(character, command)
        if not movement.bhop or type(character)~="table" or type(command)~="table" then
            lastGroundPulse=false; return
        end
        -- Не прерываем автоматическое разминирование прыжками.
        if localPlayer:GetAttribute("IsDefusingBomb")==true or localPlayer:GetAttribute("IsLocallyDefusingBomb")==true then
            lastGroundPulse=false; return
        end
        if character.Player and character.Player~=localPlayer then return end
        if character.JumpInputDown ~= true then lastGroundPulse=false; return end
        if character.Character and localPlayer.Character and character.Character~=localPlayer.Character then return end
        if type(command.Buttons)~="number" or type(character.OnGround)~="boolean" then return end
        local pulse=character.OnGround and not lastGroundPulse
        lastGroundPulse=pulse
        local jumpBit=1 -- Jump в MovementV2.
        command.Buttons = pulse and bit32.bor(command.Buttons,jumpBit) or bit32.band(command.Buttons,bit32.bnot(jumpBit))
    end
    local function installBhop(class)
        local original = class and class.SampleInput
        if type(original)~="function" then return false end
        local function wrap(old, character, ...)
            local results=table.pack(old(character,...))
            pcall(editCommand,character,results[1])
            return table.unpack(results,1,results.n)
        end
        local hookFn=hookfunction or replaceclosure
        if type(hookFn)=="function" then
            local previous
            local ok, old=pcall(function()
                return hookFn(original,function(character, ...) return wrap(previous,character,...) end)
            end)
            if ok and type(old)=="function" then previous=old; return true end
        end
        local replacement=function(character, ...) return wrap(original,character,...) end
        local ok=pcall(function() class.SampleInput=replacement end)
        return ok and class.SampleInput==replacement
    end
    task.spawn(function()
        while gui.Parent and not movement.bhopReady do
            local class=getModule("Classes","Character")
            if class then movement.bhopReady=installBhop(class) end
            refreshMovement()
            if not movement.bhopReady then task.wait(2) end
        end
    end)

    -- Ползунок расстояния камеры (5–18 studs).
    local slider=Instance.new("Frame")
    slider.Name, slider.BackgroundColor3, slider.BorderSizePixel = "ThirdDistanceSlider", Color3.fromRGB(16,18,27), 0
    slider.Size, slider.Position, slider.ZIndex, slider.Parent = UDim2.fromOffset(450,42), UDim2.fromOffset(15,194), 12, menu
    round(slider,8)
    local edge=Instance.new("UIStroke")
    edge.Color, edge.Transparency, edge.Parent = Color3.fromRGB(98,103,137), 0.35, slider
    local title=label(slider,"CAMERA DISTANCE",UDim2.fromOffset(170,14),UDim2.fromOffset(10,5),9)
    title.TextColor3,title.ZIndex=Color3.fromRGB(179,182,205),13
    local value=label(slider,"",UDim2.fromOffset(65,14),UDim2.new(1,-75,0,5),9)
    value.TextXAlignment,value.TextColor3,value.ZIndex=Enum.TextXAlignment.Right,Color3.fromRGB(129,144,245),13
    local track=Instance.new("Frame")
    track.Name,track.Position,track.Size="ThirdTrack",UDim2.fromOffset(12,28),UDim2.new(1,-24,0,4)
    track.BackgroundColor3,track.BorderSizePixel,track.ZIndex,track.Parent=Color3.fromRGB(36,40,61),0,13,slider
    round(track,3)
    local fill=Instance.new("Frame")
    fill.BackgroundColor3,fill.BorderSizePixel,fill.ZIndex,fill.Parent=Color3.fromRGB(102,74,213),0,14,track
    round(fill,3)
    local knob=Instance.new("Frame")
    knob.AnchorPoint,knob.Size=Vector2.new(0.5,0.5),UDim2.fromOffset(13,13)
    knob.BackgroundColor3,knob.BorderSizePixel,knob.ZIndex,knob.Parent=Color3.fromRGB(205,210,245),0,15,track
    round(knob,8)
    local function draw()
        local ratio=(movement.distance-5)/13
        fill.Size,knob.Position=UDim2.fromScale(ratio,1),UDim2.fromScale(ratio,0.5)
        value.Text=string.format("%.1f st",movement.distance)
    end
    draw()
    slider.Visible=false
    state.thirdSlider=slider
    table.insert(entries,{group="SETTINGS",button=slider})
    local activeInput
    local function slide(input)
        if track.AbsoluteSize.X<=0 then return end
        local ratio=math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        movement.distance=math.floor((5+13*ratio)*10+0.5)/10; draw()
    end
    slider.Active=true
    slider.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then activeInput=input; slide(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if activeInput and (input==activeInput or (activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then slide(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if activeInput and (input==activeInput or (activeInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then activeInput=nil end
    end)

    -- Видимый персонаж + скрытый viewmodel, возврат исходной прозрачности при выключении.
    local savedParts=setmetatable({}, {__mode="k"})
    local ray=RaycastParams.new()
    ray.FilterType=Enum.RaycastFilterType.Exclude
    local oldCamera, eye, shifted
    local function restoreEye()
        if oldCamera and eye and shifted then
            pcall(function() if oldCamera.CFrame==shifted then oldCamera.CFrame=eye end end)
        end
        oldCamera,eye,shifted=nil,nil,nil
    end
    state.restoreThirdEye = restoreEye
    local function restoreParts()
        for part,original in pairs(savedParts) do
            pcall(function() if part.Parent then part.LocalTransparencyModifier=original end end)
            savedParts[part]=nil
        end
    end
    local function paintParts(model,transparency,skipRoot)
        if not model or type(model.GetDescendants)~="function" then return end
        for _,part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and (not skipRoot or (part.Name~="HumanoidRootPart" and part.Name~="CameraPart")) then
                if savedParts[part]==nil then savedParts[part]=part.LocalTransparencyModifier end
                part.LocalTransparencyModifier=transparency
            end
        end
    end
    local function renderThird()
        restoreEye()
        local camera, character=Workspace.CurrentCamera,localPlayer.Character
        if not movement.third or not camera or not character or not character.Parent or character:GetAttribute("Dead")==true then
            restoreParts(); return
        end
        if state.redirected then return end
        local view=camera.CFrame
        local offset=view:VectorToWorldSpace(Vector3.new(0,0,movement.distance))
        if offset.Magnitude<0.01 then return end
        local ignore={character,camera}
        local debris=Workspace:FindFirstChild("Debris")
        if debris then table.insert(ignore,debris) end
        ray.FilterDescendantsInstances=ignore
        local hit=Workspace:Raycast(view.Position,offset,ray)
        local dist=hit and math.max(0.2,(hit.Position-view.Position).Magnitude-0.3) or offset.Magnitude
        local output=view.Rotation+(view.Position+offset.Unit*dist)
        oldCamera,eye,shifted=camera,view,output
        camera.CFrame=output
        paintParts(character,0,true)
        local controller=state.rapid and state.rapid.controller
        local getter=controller and controller.peekCurrentEquippedForMovement
        if type(getter)=="function" then
            local ok,weapon=pcall(getter)
            local model=ok and type(weapon)=="table" and weapon.Viewmodel and weapon.Viewmodel.Model
            if model then paintParts(model,1,false) end
        end
    end
    local ok=pcall(function()
        RunService:BindToRenderStep("NoirThirdPerson", Enum.RenderPriority.Last.Value, function()
            local success,err=pcall(renderThird)
            if not success then
                movement.third=false; restoreEye(); restoreParts(); refreshMovement()
                warn("[NOIR / Third person] "..tostring(err))
            end
        end)
    end)
    movement.thirdReady=ok
    refreshMovement()
    RunService.Heartbeat:Connect(function()
        restoreEye()
        if not movement.third then restoreParts() end
    end)
end


-- Настройки у элемента: шестерёнка открывает компактное окно с указателем и плавной анимацией.
do
    local tweenService=game:GetService("TweenService")
    local function tw(obj,seconds,props,style)
        local ok,t=pcall(tweenService.Create,tweenService,obj,TweenInfo.new(seconds,style or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props)
        if ok and t then t:Play() else for k,v in pairs(props) do pcall(function() obj[k]=v end) end end
    end
    local popup=Instance.new("Frame")
    popup.Name,popup.BackgroundColor3,popup.BorderSizePixel="NoirSettings",Color3.fromRGB(16,26,19),0
    popup.AnchorPoint=Vector2.new(0.5,0)
    popup.Size,popup.Position,popup.ZIndex,popup.Visible,popup.Parent=UDim2.fromOffset(216,76),UDim2.fromOffset(123,198),20,false,menu
    round(popup,12)
    local popScale=Instance.new("UIScale")
    popScale.Scale,popScale.Parent=1,popup
    local outline=Instance.new("UIStroke")
    outline.Color,outline.Thickness,outline.Transparency,outline.Parent=Color3.fromRGB(255,255,255),1.4,0.15,popup
    local outlineGrad=Instance.new("UIGradient")
    outlineGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(106,210,145)),ColorSequenceKeypoint.new(1,Color3.fromRGB(174,226,191))})
    outlineGrad.Rotation,outlineGrad.Parent=35,outline
    local arrow=Instance.new("Frame")
    arrow.AnchorPoint,arrow.Size,arrow.Position=Vector2.new(0.5,0.5),UDim2.fromOffset(9,9),UDim2.fromOffset(108,0)
    arrow.Rotation,arrow.BackgroundColor3,arrow.BorderSizePixel,arrow.ZIndex,arrow.Parent=45,Color3.fromRGB(106,210,145),0,23,popup
    round(arrow,2)
    local headDot=Instance.new("Frame")
    headDot.Size,headDot.Position,headDot.BackgroundColor3,headDot.BorderSizePixel,headDot.ZIndex,headDot.Parent=UDim2.fromOffset(5,5),UDim2.fromOffset(10,12),Color3.fromRGB(151,235,175),0,22,popup
    round(headDot,3)
    local heading=label(popup,"SETTINGS",UDim2.fromOffset(168,16),UDim2.fromOffset(20,6),9)
    heading.TextColor3,heading.ZIndex=Color3.fromRGB(226,232,255),22
    local divider=Instance.new("Frame")
    divider.Size,divider.Position,divider.BackgroundColor3,divider.BackgroundTransparency,divider.BorderSizePixel,divider.ZIndex,divider.Parent=UDim2.new(1,-20,0,1),UDim2.fromOffset(10,25),Color3.fromRGB(104,145,112),0.7,0,22,popup
    local dismiss=smallButton(popup,"×",UDim2.fromOffset(22,22),UDim2.new(1,-28,0,2))
    dismiss.Name,dismiss.ZIndex,dismiss.TextSize="SettingsClose",23,16
    dismiss.BackgroundColor3=Color3.fromRGB(30,47,34)
    local all={slider,state.thirdSlider,boxStyleButton,outlineStyleButton,chamsStyleButton,colorButton}
    for _,object in ipairs(all) do
        object.Parent=popup; object.Visible=false; object.ZIndex=21
        pcall(function()
            for _,child in ipairs(object:GetDescendants()) do
                if child:IsA("GuiObject") then child.ZIndex=math.max(child.ZIndex,22) end
            end
        end)
    end
    local gears={}
    local function tintGear(entry,color)
        entry.ringStroke.Color=color
        for _,tooth in ipairs(entry.teeth) do tooth.BackgroundColor3=color end
        entry.hub.BackgroundColor3=color
    end
    local active
    hideSettings=function()
        active=nil;popup.Visible=false
        for _,object in ipairs(all) do object.Visible=false end
        for _,entry in pairs(gears) do
            tintGear(entry,Color3.fromRGB(193,217,198))
            entry.button.BackgroundColor3=Color3.fromRGB(25,39,29)
        end
    end
    dismiss.MouseButton1Click:Connect(hideSettings)
    local function open(item,title,objects)
        if active==title then hideSettings();return end
        hideSettings();active=title
        heading.Text=title.."  /  SETTINGS"
        local height=#objects==1 and 76 or 92
        popup.Size=UDim2.fromOffset(216,height)
        local x=math.clamp(item.Position.X.Offset,10,menu.Size.X.Offset-226)
        local y=math.min(item.Position.Y.Offset+52,menu.Size.Y.Offset-height-12)
        popup.Position=UDim2.fromOffset(x+108,y)
        local gearCenter=item.Position.X.Offset+item.Size.X.Offset-66
        arrow.Position=UDim2.fromOffset(math.clamp(gearCenter-x,18,198),0)
        for i,object in ipairs(objects) do
            object.Visible=true
            if object==slider or object==state.thirdSlider then
                object.Position,object.Size=UDim2.fromOffset(5,30),UDim2.fromOffset(206,42)
            else
                object.Position,object.Size=UDim2.fromOffset(5,30+(i-1)*29),UDim2.fromOffset(206,27)
            end
        end
        local entry=gears[title]
        if entry then
            tintGear(entry,Color3.fromRGB(151,235,175))
            entry.button.BackgroundColor3=Color3.fromRGB(33,79,47)
        end
        popScale.Scale=0.88
        popup.Visible=true
        tw(popScale,0.22,{Scale=1},Enum.EasingStyle.Back)
    end
    local bindings={
        {originButton,"FORCE ORIGIN",{slider}}, {state.thirdButton,"THIRD PERSON",{state.thirdSlider}},
        {boxButton,"ESP BOX",{boxStyleButton,colorButton}}, {outlineButton,"OUTLINE",{outlineStyleButton,colorButton}},
        {chamsButton,"CHAMS",{chamsStyleButton,colorButton}},
    }
    for _,binding in ipairs(bindings) do
        local item,title,objects=binding[1],binding[2],binding[3]
        local more=smallButton(item,"",UDim2.fromOffset(28,28),UDim2.new(1,-80,0.5,-14))
        more.Name,more.ZIndex=title.."Settings",18
        more.BackgroundColor3=Color3.fromRGB(25,39,29)
        more.BackgroundTransparency=0.48
        local moreEdge=Instance.new("UIStroke")
        moreEdge.Color,moreEdge.Thickness,moreEdge.Transparency,moreEdge.Parent=Color3.fromRGB(118,157,126),1,0.6,more
        moreEdge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        moreEdge.Transparency=0.86
        local gear=Instance.new("Frame")
        gear.Name,gear.AnchorPoint,gear.Position,gear.Size="GearIcon",Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(16,16)
        gear.BackgroundTransparency,gear.ZIndex,gear.Parent=1,19,more
        gear.Rotation=0
        local gearColor=Color3.fromRGB(193,217,198)
        local ring=Instance.new("Frame")
        ring.AnchorPoint,ring.Position,ring.Size=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(9,9)
        ring.BackgroundTransparency,ring.ZIndex,ring.Parent=1,20,gear
        round(ring,6)
        local ringStroke=Instance.new("UIStroke")
        ringStroke.Color,ringStroke.Thickness,ringStroke.Parent=gearColor,1.3,ring
        local hub=Instance.new("Frame")
        hub.AnchorPoint,hub.Position,hub.Size=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(2,2)
        hub.BackgroundColor3,hub.BorderSizePixel,hub.ZIndex,hub.Parent=gearColor,0,20,gear
        round(hub,2)
        local teeth={}
        for i=0,7 do
            local angle=i*math.pi/4
            local tooth=Instance.new("Frame")
            tooth.AnchorPoint,tooth.Size=Vector2.new(0.5,0.5),UDim2.fromOffset(2,3)
            tooth.Position=UDim2.fromOffset(8+math.sin(angle)*6.2,8-math.cos(angle)*6.2)
            tooth.Rotation,tooth.BackgroundColor3,tooth.BorderSizePixel,tooth.ZIndex,tooth.Parent=i*45,gearColor,0,20,gear
            round(tooth,1)
            teeth[#teeth+1]=tooth
        end
        gears[title]={button=more,ringStroke=ringStroke,teeth=teeth,hub=hub}
        more.MouseEnter:Connect(function()
            if active~=title then tw(more,0.12,{BackgroundColor3=Color3.fromRGB(35,55,39)}) end
        end)
        more.MouseLeave:Connect(function()
            if active~=title then tw(more,0.12,{BackgroundColor3=Color3.fromRGB(25,39,29)}) end
        end)
        more.MouseButton1Click:Connect(function()
            local rotation=gear.Rotation+90
            tw(gear,0.3,{Rotation=rotation})
            open(item,title,objects)
        end)
    end
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
    marker.Size, marker.BackgroundTransparency, marker.BorderSizePixel = UDim2.fromOffset(126,24), 0.32, 0
    marker.BackgroundColor3, marker.TextColor3 = Color3.fromRGB(17,15,27), Color3.fromRGB(193,201,255)
    marker.Font, marker.TextSize, marker.ZIndex = Enum.Font.GothamBold, 10, 4
    marker.TextStrokeTransparency, marker.Visible, marker.Parent = 0.25, false, overlay
    round(marker,6)
    local markerEdge = Instance.new("UIStroke")
    markerEdge.Color, markerEdge.Transparency, markerEdge.Parent = Color3.fromRGB(128,111,198), 0.18, marker
    local hud = Instance.new("Frame")
    hud.Name, hud.AnchorPoint = "NoirBombTimer", Vector2.new(0.5,0)
    hud.Position, hud.Size = UDim2.new(0.5,0,0,64), UDim2.fromOffset(170,38)
    hud.BackgroundColor3, hud.BackgroundTransparency, hud.BorderSizePixel, hud.ZIndex = Color3.fromRGB(15,13,23), 0.08, 0, 4
    hud.Visible, hud.Parent = false, gui
    round(hud,8)
    local hudEdge=Instance.new("UIStroke")
    hudEdge.Color,hudEdge.Transparency,hudEdge.Parent=Color3.fromRGB(128,135,175),0.2,hud
    local hudText = label(hud, "", UDim2.new(1,-18,1,-5), UDim2.fromOffset(9,1), 11)
    hudText.TextXAlignment, hudText.ZIndex = Enum.TextXAlignment.Center, 5
    local hudTrack = Instance.new("Frame")
    hudTrack.Size, hudTrack.Position = UDim2.new(1,-16,0,3), UDim2.new(0,8,1,-7)
    hudTrack.BackgroundColor3, hudTrack.BorderSizePixel, hudTrack.ZIndex, hudTrack.Parent = Color3.fromRGB(37,41,68), 0, 5, hud
    round(hudTrack,3)
    local hudFill = Instance.new("Frame")
    hudFill.BackgroundColor3, hudFill.BorderSizePixel, hudFill.ZIndex, hudFill.Parent = Color3.fromRGB(104,157,227), 0, 6, hudTrack
    round(hudFill,3)
    local danger = Instance.new("Frame")
    danger.Name, danger.BackgroundColor3, danger.BackgroundTransparency = "BombDanger", Color3.fromRGB(255,60,60), 1
    danger.BorderSizePixel, danger.Size, danger.ZIndex, danger.Parent = 0, UDim2.fromScale(1,1), 0, gui
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
            hudFill.BackgroundColor3 = remaining and remaining < 10 and Color3.fromRGB(255,105,131) or Color3.fromRGB(104,157,227)
            hudEdge.Color = remaining and remaining < 10 and Color3.fromRGB(255,90,90) or Color3.fromRGB(128,135,175)
            -- under 5s: a faint full-screen red vignette breathes in time with the countdown, impossible to miss mid-fight
            danger.BackgroundTransparency = (remaining and remaining < 5) and (0.94 - 0.05*math.abs(math.sin(os.clock()*6))) or 1
        else
            danger.BackgroundTransparency = 1
        end
        local obj = bomb or cachedDropped
        local pos = positionOf(obj)
        marker.Visible = false
        if controls.esp and camera and pos then
            local screen, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen and screen.Z > 0 then
                local dist = math.floor((pos-camera.CFrame.Position).Magnitude)
                marker.Text = bomb and (remaining and controls.timer and string.format("C4  %.1fs  ·  %d st",remaining,dist) or "C4  ·  "..dist.." st") or "C4  DROP  ·  "..dist.." st"
                marker.Position = UDim2.fromOffset(screen.X,screen.Y-14)
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
    stroke.Color, stroke.Thickness, stroke.Parent = Color3.fromRGB(106, 233, 208), 1.5, box
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(106,233,208))
    strokeGrad.Parent = stroke
    local danger = Instance.new("UIStroke")
    danger.Name, danger.Color, danger.Thickness = "DangerGlow", Color3.fromRGB(255,70,70), 3
    danger.Transparency, danger.Parent = 1, box
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
    caption.TextStrokeTransparency = 0.05
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
    local entry = {box = box, shadow = shadow, stroke = stroke, strokeGrad = strokeGrad, danger = danger, corners = corners, caption = caption, distance = distance, hpText = hpText, healthBack = healthBack, healthFill = healthFill}
    esp[model] = entry
    return entry
end
local function boundsOnScreen(camera, model)
    local anchor = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    if not anchor or not anchor:IsA("BasePart") then return nil end
    local anchorPos = anchor.Position
    local anchorProjection = camera:WorldToViewportPoint(anchorPos)
    if anchorProjection.Z <= 1 then return nil end
    local minX, minY, maxX, maxY
    local headMin, headMax
    for _, name in ipairs(bodyNames) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") and (part.Name ~= "HumanoidRootPart" or part == anchor)
            and (part.Position - anchorPos).Magnitude < 12 and part.Size.Magnitude < 20 then
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
    local anchorScreen = anchorProjection
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
                        entry.highlight.FillTransparency = chamsStyle == 1 and 0.52 or (chamsStyle == 2 and 0.24 or 0.4 + math.sin(os.clock()*2.5)*0.10)
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
                        entry.lowHealth = (hp / math.max(1, maxHp)) < 0.3
                    else
                        entry.lowHealth = false
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
    if now-lastEsp < 0.033 then return end
    lastEsp = now
    local ok, err = pcall(updateEsp)
    if not ok and now-espWarnAt > 5 then espWarnAt=now; warn("[ESP] "..tostring(err)) end
    -- low-health danger glow: a slow breathing red outline on boxes of enemies under 30% hp, plus a
    -- slowly rotating gradient on the normal stroke so boxes read as "alive" rather than static rectangles
    local pulse = 0.45 + 0.4 * math.sin(now * 4.2)
    local rot = (now * 40) % 360
    for _, entry in pairs(esp) do
        if entry.box.Visible then
            if entry.strokeGrad then entry.strokeGrad.Rotation = rot end
            if entry.danger then
                entry.danger.Transparency = entry.lowHealth and (1 - pulse) or 1
            end
        end
    end
end)

-- Последняя страховка, если отправка пакета не состоялась.
RunService:BindToRenderStep("IndependentSilentRestore", Enum.RenderPriority.First.Value, restoreCamera)

-- Полноэкранная заставка NOIR: орбы, вращающееся кольцо, этапы загрузки. Тап пропускает её.
do
    local tweenService=game:GetService("TweenService")
    local function tw(obj,seconds,props,style,dir)
        local ok,t=pcall(tweenService.Create,tweenService,obj,TweenInfo.new(seconds,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props)
        if ok and t then t:Play() else for k,v in pairs(props) do pcall(function() obj[k]=v end) end end
    end
    local veil=Instance.new("Frame")
    veil.Name,veil.Size,veil.BackgroundColor3,veil.BorderSizePixel,veil.ZIndex,veil.Active=("NoirIntroVeil"),UDim2.fromScale(1,1),Color3.fromRGB(7,8,14),0,30,true
    veil.Parent=gui
    local veilGrad=Instance.new("UIGradient")
    veilGrad.Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(150,140,200))
    veilGrad.Rotation,veilGrad.Parent=90,veil
    local fades={}
    local function track(obj,prop) fades[#fades+1]={obj,prop} end
    local function orb(color,size,x,y)
        local o=Instance.new("Frame")
        o.AnchorPoint,o.Size,o.Position=Vector2.new(0.5,0.5),UDim2.fromOffset(size,size),UDim2.fromScale(x,y)
        o.BackgroundColor3,o.BackgroundTransparency,o.BorderSizePixel,o.ZIndex,o.Parent=color,0.86,0,30,veil
        round(o,size//2)
        track(o,"BackgroundTransparency")
        return o
    end
    local orbA=orb(Color3.fromRGB(124,92,255),460,0.22,0.3)
    local orbB=orb(Color3.fromRGB(56,189,248),380,0.8,0.72)
    local scan=Instance.new("Frame")
    scan.Size,scan.Position,scan.BackgroundColor3,scan.BackgroundTransparency,scan.BorderSizePixel,scan.ZIndex,scan.Parent=UDim2.new(1,0,0,2),UDim2.fromScale(0,-0.02),Color3.fromRGB(120,170,255),0.78,0,31,veil
    track(scan,"BackgroundTransparency")

    local center=Instance.new("Frame")
    center.Name,center.AnchorPoint,center.Position,center.Size="NoirIntro",Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(360,236)
    center.BackgroundTransparency,center.ZIndex,center.Parent=1,32,veil
    local introScale=Instance.new("UIScale")
    introScale.Scale,introScale.Parent=menuScale.Scale,center

    local ring=Instance.new("Frame")
    ring.AnchorPoint,ring.Position,ring.Size=Vector2.new(0.5,0),UDim2.new(0.5,0,0,0),UDim2.fromOffset(92,92)
    ring.BackgroundTransparency,ring.ZIndex,ring.Parent=1,33,center
    round(ring,46)
    local ringStroke=Instance.new("UIStroke")
    ringStroke.Color,ringStroke.Thickness,ringStroke.Transparency,ringStroke.Parent=Color3.fromRGB(255,255,255),3,1,ring
    local ringGrad=Instance.new("UIGradient")
    ringGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(124,92,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(56,189,248)),ColorSequenceKeypoint.new(1,Color3.fromRGB(124,92,255))})
    ringGrad.Parent=ringStroke
    track(ringStroke,"Transparency")
    local core=Instance.new("Frame")
    core.AnchorPoint,core.Position,core.Size=Vector2.new(0.5,0.5),UDim2.fromScale(0.5,0.5),UDim2.fromOffset(70,70)
    core.BackgroundColor3,core.BackgroundTransparency,core.BorderSizePixel,core.ZIndex,core.Parent=Color3.fromRGB(14,16,28),1,0,34,ring
    round(core,35)
    track(core,"BackgroundTransparency")
    local mark=label(core,"N",UDim2.fromScale(1,1),UDim2.fromOffset(0,0),30)
    mark.TextXAlignment,mark.TextColor3,mark.TextTransparency,mark.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(226,230,255),1,35
    track(mark,"TextTransparency")

    local title=label(center,"N O I R",UDim2.new(1,0,0,48),UDim2.fromOffset(0,112),34)
    title.TextXAlignment,title.TextColor3,title.TextTransparency,title.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(235,238,255),1,33
    local silver=Instance.new("UIGradient")
    silver.Color=ColorSequence.new(Color3.fromRGB(140,150,190),Color3.fromRGB(255,255,255))
    silver.Rotation,silver.Offset,silver.Parent=0,Vector2.new(-1,0),title
    track(title,"TextTransparency")
    local creator=label(center,"C R E A T O R     /     B L O X   S T R I K E",UDim2.new(1,0,0,16),UDim2.fromOffset(0,160),9)
    creator.TextXAlignment,creator.TextColor3,creator.TextTransparency,creator.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(138,148,190),1,33
    track(creator,"TextTransparency")

    local status=label(center,"INITIALIZING",UDim2.new(1,0,0,14),UDim2.fromOffset(0,186),9)
    status.TextXAlignment,status.TextColor3,status.TextTransparency,status.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(165,175,225),1,33
    track(status,"TextTransparency")
    local rail=Instance.new("Frame")
    rail.Position,rail.Size=UDim2.fromOffset(40,206),UDim2.new(1,-80,0,4)
    rail.BackgroundColor3,rail.BackgroundTransparency,rail.BorderSizePixel,rail.ZIndex,rail.Parent=Color3.fromRGB(30,33,54),1,0,33,center
    round(rail,2)
    track(rail,"BackgroundTransparency")
    local bar=Instance.new("Frame")
    bar.Size,bar.BackgroundColor3,bar.BackgroundTransparency,bar.BorderSizePixel,bar.ZIndex,bar.Parent=UDim2.fromScale(0,1),Color3.fromRGB(255,255,255),1,0,34,rail
    round(bar,2)
    local barGrad=Instance.new("UIGradient")
    barGrad.Color=ColorSequence.new(Color3.fromRGB(124,92,255),Color3.fromRGB(56,189,248))
    barGrad.Parent=bar
    track(bar,"BackgroundTransparency")
    local amount=label(center,"0%",UDim2.new(1,0,0,14),UDim2.fromOffset(0,218),9)
    amount.TextXAlignment,amount.TextColor3,amount.TextTransparency,amount.ZIndex=Enum.TextXAlignment.Center,Color3.fromRGB(130,140,185),1,33
    track(amount,"TextTransparency")

    local skipped,alive=false,true
    veil.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then skipped=true end
    end)
    local started=os.clock()
    local beat=RunService.Heartbeat:Connect(function()
        if not alive then return end
        local t=os.clock()-started
        ringGrad.Rotation=(t*220)%360
        orbA.Position=UDim2.fromScale(0.22+0.03*math.sin(t*0.9),0.3+0.03*math.cos(t*0.7))
        orbB.Position=UDim2.fromScale(0.8+0.03*math.cos(t*0.8),0.72+0.03*math.sin(t*1.1))
        scan.Position=UDim2.fromScale(0,(t*0.55)%1.1-0.05)
    end)
    local function finish()
        alive=false
        pcall(function() beat:Disconnect() end)
        pcall(function() veil:Destroy() end)
        menu.Visible=true
        local fullMenu=menuScale.Scale
        menuScale.Scale=fullMenu*0.94
        tw(menuScale,0.38,{Scale=fullMenu},Enum.EasingStyle.Back)
    end
    task.spawn(function()
        local ok,err=pcall(function()
            local full=introScale.Scale
            introScale.Scale=full*0.92
            tw(introScale,0.9,{Scale=full},Enum.EasingStyle.Back)
            tw(ringStroke,0.6,{Transparency=0})
            tw(core,0.6,{BackgroundTransparency=0})
            tw(mark,0.6,{TextTransparency=0})
            task.wait(0.18)
            tw(title,0.7,{TextTransparency=0})
            tw(silver,1.6,{Offset=Vector2.new(0.9,0)})
            task.wait(0.15)
            tw(creator,0.7,{TextTransparency=0})
            tw(status,0.5,{TextTransparency=0}); tw(amount,0.5,{TextTransparency=0})
            tw(rail,0.5,{BackgroundTransparency=0}); tw(bar,0.5,{BackgroundTransparency=0})
            local steps={{0.22,"INITIALIZING CORE"},{0.48,"LOADING MODULES"},{0.76,"SYNCING INTERFACE"},{1,"READY"}}
            for _,step in ipairs(steps) do
                if skipped then break end
                status.Text=step[2]
                amount.Text=tostring(math.floor(step[1]*100)).."%"
                tw(bar,0.42,{Size=UDim2.fromScale(step[1],1)})
                task.wait(0.5)
            end
            status.Text,amount.Text="READY","100%"
            bar.Size=UDim2.fromScale(1,1)
            if not skipped then task.wait(0.28) end
            for _,item in ipairs(fades) do tw(item[1],0.32,{[item[2]]=1}) end
            tw(veil,0.4,{BackgroundTransparency=1})
            tw(introScale,0.4,{Scale=introScale.Scale*1.08})
            task.wait(0.42)
        end)
        if not ok then warn("[Intro] "..tostring(err)) end
        finish()
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
    -- Перед расчётом выстрела возвращаем реальную точку глаза после third person.
    if state.restoreThirdEye then pcall(state.restoreThirdEye) end
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
                local function calculate(...)
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
                end
                local resultPack=table.pack(calculate(...))
                local bulletObject=select(1,...)
                if state.noteLocalRay and type(bulletObject)=="table" then
                    local weapon=bulletObject.Weapon
                    if type(weapon)=="table" and weapon.Player==localPlayer then pcall(state.noteLocalRay,resultPack[1]) end
                end
                return table.unpack(resultPack,1,resultPack.n)
            end)
        end)
        if good and type(old) == "function" then previousRay = old; state.forceReady = true; state.hitReady=true end
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

