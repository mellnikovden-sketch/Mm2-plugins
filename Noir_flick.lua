--[[ Noir / flick pack, menu build
    Target: Roblox Luau, executor-side, private/practice place.
    Remotes: copied verbatim from the Remote Spy "Generated" panel.
    Convention: Roblox CFrame is right-handed, Y-up, -Z is forward, angles are radians.
    CFrame.lookAt(origin, target) builds the rotation toward target, so there is no
    deg/rad conversion and no angle wrap anywhere below.
    Camera:WorldToScreenPoint(p) -> Vector3, boolean(in front). Screen offsets used
    for target scoring are normalized to [-1, 1] against ViewportSize, not radians.
]]

local CFG = {
    -- Everything OFF on load. Nothing fires until a menu click or a hotkey.
    MasterEnabled    = false,
    ESP              = false,
    SilentAim        = false,
    Flick            = false,

    MenuKey          = Enum.KeyCode.RightShift,
    ToggleMaster     = Enum.KeyCode.F1,
    ToggleESP        = Enum.KeyCode.F2,
    ToggleSilent     = Enum.KeyCode.F3,
    ToggleFlick      = Enum.KeyCode.F4,
    FlickKey         = Enum.KeyCode.Q,
    UnloadKey        = Enum.KeyCode.F5,

    AimPart          = "Head",
    MaxAimDistance   = 300,
    FlickCooldown    = 0.12,
    ESPRefresh       = 0.20,
    ESPMaxDistance   = 400,
    PatchHitInstance = false,  -- FILL: enable only after "Hit" arg 5 is confirmed
}

local M = {
    cfg = CFG, conns = {}, esp = {}, syncs = {},
    acc = 0, lastFlick = 0, hookReady = false, gui = nil, status = nil,
}
if _G.NoirFlick and type(_G.NoirFlick.Unload) == "function" then
    pcall(_G.NoirFlick.Unload) -- Double load: retire the old menu, loop and highlights.
end
_G.NoirFlick = M

local Players    = game:GetService("Players")          -- OK: Roblox service
local RunService = game:GetService("RunService")        -- OK
local UIS        = game:GetService("UserInputService")  -- OK
local RS         = game:GetService("ReplicatedStorage") -- OK
local unpack_    = table.unpack or unpack               -- OK: Luau table.unpack

-- OK: every name below comes from the Remote Spy output.
local function at(parent, ...)
    local cur = parent
    for i = 1, select("#", ...) do
        if not cur then return nil end
        local name = select(i, ...)
        local ok, child = pcall(function() return cur:WaitForChild(name, 2) end) -- OK
        if not ok then return nil end
        cur = child
    end
    return cur
end

local NetRemote = at(RS, "Shared", "Weapons", "Net", "Remote")
-- Remotes.WeaponFX and Remotes.PoseEvent stay untouched: both are cosmetic.

local function cam()
    return workspace.CurrentCamera -- OK: fetched fresh, survives respawn
end

local function headOf(char)
    if not char then return nil end
    local p = char:FindFirstChild(CFG.AimPart)    -- OK
    if p and p:IsA("BasePart") then return p end  -- OK
    return nil
end

local function alive(char)
    if not char or not char.Parent then return false end
    local h = char:FindFirstChildOfClass("Humanoid") -- OK
    if not h or h.Health <= 0 then return false end
    return headOf(char) ~= nil
end

local function friendly(p, char)
    if p and p == Players.LocalPlayer then return true end
    if char and char == Players.LocalPlayer.Character then return true end
    return false
end

local function candidates()
    local out, seen = {}, {}
    local function add(char, p)
        if not char or seen[char] or not alive(char) or friendly(p, char) then return end
        local head = headOf(char)
        if not head then return end
        seen[char] = true
        out[#out + 1] = { char = char, player = p, part = head, pos = head.Position }
    end
    for _, p in ipairs(Players:GetPlayers()) do add(p.Character, p) end -- OK
    -- The screenshots show character models parented straight to Workspace.
    for _, m in ipairs(workspace:GetChildren()) do                       -- OK
        if m:IsA("Model") then
            add(m, Players:GetPlayerFromCharacter(m))                     -- OK: native
        end
    end
    return out
end

function M.pickTarget()
    local c = cam()
    if not c then return nil end
    local origin, vp = c.CFrame.Position, c.ViewportSize -- OK
    if vp.X <= 0 or vp.Y <= 0 then return nil end
    local best, score = nil, math.huge
    for _, t in ipairs(candidates()) do
        local d = (t.pos - origin).Magnitude
        if d <= CFG.MaxAimDistance then
            local ok, sp, front = pcall(function()
                local v, f = c:WorldToScreenPoint(t.pos) -- OK
                return v, f
            end)
            if ok and front and sp then
                -- Normalized screen offset: 0 = crosshair, 1 = screen edge.
                local dx = (sp.X - vp.X * 0.5) / (vp.X * 0.5)
                local dy = (sp.Y - vp.Y * 0.5) / (vp.Y * 0.5)
                local s = math.sqrt(dx * dx + dy * dy) + d * 0.0005
                if s < score then best, score = t, s end
            end
        end
    end
    return best
end

local function dropESP(char)
    local e = M.esp[char]
    if not e then return end
    pcall(function() if e.tag then e.tag:Destroy() end end) -- OK
    pcall(function() if e.hl then e.hl:Destroy() end end)   -- OK
    M.esp[char] = nil
end

local function clearESP()
    for char in pairs(M.esp) do dropESP(char) end
end

local function makeESP(t)
    if M.esp[t.char] then return end
    M.esp[t.char] = {}
    local ok = pcall(function()
        local hl = Instance.new("Highlight")                  -- OK: native
        hl.Name = "NoirHL"
        hl.FillColor = Color3.fromRGB(255, 70, 90)            -- OK
        hl.OutlineColor = Color3.fromRGB(255, 225, 225)       -- OK
        hl.FillTransparency = 0.75
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop    -- OK: native enum
        hl.Adornee = t.char                                   -- OK
        hl.Parent = t.char
        M.esp[t.char].hl = hl

        local tag = Instance.new("BillboardGui")              -- OK
        tag.Name = "NoirTag"
        tag.Size = UDim2.new(0, 160, 0, 20)                    -- OK
        tag.StudsOffset = Vector3.new(0, 2.2, 0)               -- OK
        tag.AlwaysOnTop = true
        tag.MaxDistance = CFG.ESPMaxDistance
        local txt = Instance.new("TextLabel")                -- OK
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = t.player and t.player.Name or t.char.Name
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextStrokeTransparency = 0.35
        txt.TextScaled = true
        txt.Parent = tag
        tag.Parent = t.part
        M.esp[t.char].tag = tag
    end)
    if not ok then dropESP(t.char) end
end

local function reconcile()
    if not (CFG.MasterEnabled and CFG.ESP) then
        clearESP()
        return
    end
    for char in pairs(M.esp) do
        if not alive(char) then dropESP(char) end
    end
    for _, t in ipairs(candidates()) do makeESP(t) end
end

local function flick()
    if os.clock() - M.lastFlick < CFG.FlickCooldown then return end
    local c, t = cam(), M.pickTarget()
    if not c or not t then return end
    M.lastFlick = os.clock()
    -- Only the rotation changes: position is preserved, lookAt aims -Z at the head.
    pcall(function() c.CFrame = CFrame.lookAt(c.CFrame.Position, t.pos) end) -- OK
end

-- VERIFY: hookmetamethod / getnamecallmethod are executor globals, not Roblox API.
-- Check with: print(type(hookmetamethod), type(getnamecallmethod), type(newcclosure))
local function namecall(self, ...)
    local a = table.pack(...) -- OK: Luau; a.n preserves trailing nil arguments
    local okM, method = pcall(getnamecallmethod)
    if not okM then method = "" end
    local old = _G.NoirNamecallOld
    if not old then return end
    local inst = _G.NoirFlick
    if inst and self == NetRemote and method == "FireServer"
        and inst.cfg.MasterEnabled and inst.cfg.SilentAim
        and a[1] == "Hit" and a.n >= 4 then
        local ok, patched = pcall(function()
            local t = inst.pickTarget()
            if not t then return false end
            -- FILL: "Hit" arg 5 is cut off in the screenshots, so it is untouched.
            if typeof(a[3]) == "CFrame" then                  -- OK: Luau typeof
                a[3] = CFrame.lookAt(a[3].Position, t.pos)   -- OK
            end
            if typeof(a[4]) == "Vector3" then a[4] = t.pos end
            if inst.cfg.PatchHitInstance and typeof(a[5]) == "Instance" then
                a[5] = t.part
            end
            return true
        end)
        if ok and patched then return old(self, unpack_(a, 1, a.n)) end
    end
    return old(self, unpack_(a, 1, a.n))
end

if type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
    if _G.NoirNamecallOld == nil then -- One hook per executor session, never stacked.
        local ok, old = pcall(hookmetamethod, game, "__namecall", namecall)
        if ok and type(old) == "function" then _G.NoirNamecallOld = old end
    end
    M.hookReady = _G.NoirNamecallOld ~= nil
end

-- One state setter per flag: the menu and the hotkeys drive the same path.
local function setMaster(v)
    CFG.MasterEnabled = v and true or false
    if not CFG.MasterEnabled then clearESP() end
end

local function setESP(v)
    CFG.ESP = v and true or false
    if not CFG.ESP then clearESP() end
end

local function setSilent(v)
    CFG.SilentAim = v and true or false
    if CFG.SilentAim and not M.hookReady then CFG.SilentAim = false end
end

local function setFlick(v)
    CFG.Flick = v and true or false
end

local function cycle(field, values)
    for i = 1, #values do
        if CFG[field] == values[i] then
            CFG[field] = values[(i % #values) + 1]
            return
        end
    end
    CFG[field] = values[1]
end

-- VERIFY: gethui is executor-provided, CoreGui can be locked on this client.
-- Check with: print(type(gethui), pcall(function() return game:GetService("CoreGui") end))
local function guiHost()
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h and typeof(h) == "Instance" then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local probe = Instance.new("Folder") -- OK
        local ok2 = pcall(function() probe.Parent = cg end)
        pcall(function() probe:Destroy() end)
        if ok2 then return cg end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui") -- OK: fallback
end

function M.sync()
    if not M.gui or not M.gui.Parent then return end
    for _, paint in ipairs(M.syncs) do pcall(paint) end
    if M.status and M.status.Parent then
        pcall(function()
            M.status.Text = "  hook: " .. (M.hookReady and "ok" or "nil")
                .. "   targets: " .. tostring(#candidates())
        end)
    end
end

local function buildMenu()
    local sg = Instance.new("ScreenGui") -- OK: native
    sg.Name = "NoirMenu"
    sg.ResetOnSpawn = false              -- OK
    sg.DisplayOrder = 100                -- OK
    sg.Enabled = true
    sg.Parent = guiHost()
    M.gui = sg

    local root = Instance.new("Frame") -- OK
    root.Name = "Root"
    root.Size = UDim2.new(0, 268, 0, 340) -- OK
    root.Position = UDim2.new(0, 24, 0, 120)
    root.BackgroundColor3 = Color3.fromRGB(16, 18, 24) -- OK
    root.BorderSizePixel = 0
    root.Active = true
    root.Parent = sg

    local title = Instance.new("TextLabel") -- OK
    title.Size = UDim2.new(1, -20, 0, 24)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left -- OK
    title.TextColor3 = Color3.fromRGB(235, 238, 248)
    title.TextSize = 15
    title.Text = "  noir / flick"
    title.Parent = root

    local rows = {}
    local function row(caption, isOn, onClick)
        local b = Instance.new("TextButton") -- OK
        b.Name = "Row" .. tostring(#rows + 1)
        b.Size = UDim2.new(1, -20, 0, 30)
        b.Position = UDim2.new(0, 10, 0, 40 + #rows * 36)
        b.BorderSizePixel = 0
        b.TextXAlignment = Enum.TextXAlignment.Left -- OK
        b.TextSize = 14
        b.Parent = root
        rows[#rows + 1] = b

        local function paint()
            local cap = type(caption) == "function" and caption() or caption
            local on = nil
            if isOn then on = isOn() end
            if on == nil then
                b.Text = "  " .. cap
                b.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
                b.TextColor3 = Color3.fromRGB(215, 220, 233)
            else
                b.Text = "  " .. cap .. (on and "   [on]" or "   [off]")
                b.BackgroundColor3 = on and Color3.fromRGB(46, 92, 70) or Color3.fromRGB(30, 34, 44)
                b.TextColor3 = on and Color3.fromRGB(180, 255, 210) or Color3.fromRGB(215, 220, 233)
            end
        end
        M.syncs[#M.syncs + 1] = paint
        b.MouseButton1Click:Connect(function() -- OK
            pcall(onClick)
            M.sync()
        end)
    end

    row("master", function() return CFG.MasterEnabled end,
        function() setMaster(not CFG.MasterEnabled) end)
    row("esp", function() return CFG.ESP end,
        function() setESP(not CFG.ESP) end)
    row("silent aim", function() return CFG.SilentAim end,
        function() setSilent(not CFG.SilentAim) end)
    row("flick", function() return CFG.Flick end,
        function() setFlick(not CFG.Flick) end)
    row(function() return "aim part: " .. CFG.AimPart end, nil,
        function()
            cycle("AimPart", { "Head", "HumanoidRootPart" })
            clearESP() -- Rebuild tags on the newly selected part.
        end)
    row(function() return "max dist: " .. tostring(CFG.MaxAimDistance) end, nil,
        function() cycle("MaxAimDistance", { 150, 300, 600 }) end)
    row(function() return "flick cd: " .. tostring(CFG.FlickCooldown) end, nil,
        function() cycle("FlickCooldown", { 0.08, 0.12, 0.25 }) end)
    row("unload", nil, function() M.Unload() end)

    local status = Instance.new("TextLabel") -- OK
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 40 + #rows * 36)
    status.BackgroundTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Left -- OK
    status.TextColor3 = Color3.fromRGB(140, 148, 165)
    status.TextSize = 12
    status.Text = "  hook: ?"
    status.Parent = root
    M.status = status

    root.Size = UDim2.new(0, 268, 0, 40 + #rows * 36 + 28)
    M.sync()
end

local function onInput(io, processed)
    if processed then return end
    local k = io.KeyCode
    if k == CFG.MenuKey then
        if M.gui and M.gui.Parent then M.gui.Enabled = not M.gui.Enabled end -- OK
        return
    end
    if k == CFG.UnloadKey then
        M.Unload()
        return
    end
    if k == CFG.ToggleMaster then
        setMaster(not CFG.MasterEnabled)
    elseif k == CFG.ToggleESP then
        setESP(not CFG.ESP)
    elseif k == CFG.ToggleSilent then
        setSilent(not CFG.SilentAim)
    elseif k == CFG.ToggleFlick then
        setFlick(not CFG.Flick)
    elseif k == CFG.FlickKey and CFG.MasterEnabled and CFG.Flick then
        flick()
    end
    M.sync()
end

buildMenu()
M.conns[#M.conns + 1] = UIS.InputBegan:Connect(onInput) -- OK
M.conns[#M.conns + 1] = Players.LocalPlayer.CharacterAdded:Connect(function()
    clearESP() -- Respawn: drop stale highlight, the loop rebuilds on the new character.
end) -- OK
M.conns[#M.conns + 1] = RunService.Heartbeat:Connect(function(dt)
    M.acc = M.acc + (dt or 0)
    if M.acc < CFG.ESPRefresh then return end
    M.acc = 0
    local ok = pcall(reconcile)
    if not ok then clearESP() end
end) -- OK

function M.Unload()
    CFG.MasterEnabled, CFG.ESP, CFG.SilentAim, CFG.Flick = false, false, false, false
    M.acc, M.lastFlick = 0, 0
    clearESP()
    for i = 1, #M.conns do
        pcall(function() M.conns[i]:Disconnect() end) -- OK
    end
    M.conns = {}
    M.syncs = {}
    pcall(function() if M.gui then M.gui:Destroy() end end) -- OK
    M.gui, M.status = nil, nil
    if _G.NoirFlick == M then _G.NoirFlick = nil end
    -- The single __namecall wrapper stays installed but is a pure passthrough:
    -- all flags are off and _G.NoirFlick is nil. Reload reuses _G.NoirNamecallOld,
    -- so a double load never stacks hooks, menus or Heartbeat loops.
end

return M
