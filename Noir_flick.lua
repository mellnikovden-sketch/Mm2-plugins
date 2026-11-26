-- NoirFlick v4 · silent aim + ESP · Luau / Roblox executor (Delta-tuned)
-- protocol (CONFIRMED from the remote spy dumps):
--   ReplicatedStorage.Shared.Weapons.Net.Remote:FireServer("Hit", t, eyeCFrame, hitPos) <- damage call
--     eyeCFrame look vector points at hitPos; t = tick()-style epoch seconds (dump: 1795729945.914422)
--   own shots echo back: Remotes.WeaponFX OnClientEvent ("fire", myChar) -> free shot detection, no hooks
-- v4 changes (v3 console: hook=live but no redirect + "esp error: Color is not a valid member of Frame"):
--   · ESP crash fixed: hp bar used Drawing-style .Color on a Frame -> BackgroundColor3
--   · hook installs RAW first (Delta's newcclosure silently drops varargs -> probe passed,
--     redirect never matched); probe now also verifies varargs -> footer shows hook:ok/vars/DEAD
--   · direct FireServer mode: on your own "fire" echo fires Net.Remote:FireServer("Hit", ...)
--     straight at the locked target, no hook needed. plus a "hit test" button that fires one
--     manual hit through the full chain (target picker -> protocol -> remote)
--   · esp box stroke 1.5px, height cap 4x viewport (first-person close range)
-- tags: OK = Roblox client API, VERIFY = executor global, FILL = value to confirm

local Config = {
    SilentAim = {
        Fov       = 150,  -- px, radius around screen center
        ShowFov   = true,
        HitPart   = "Head", -- falls back to HumanoidRootPart
        WallCheck = true,
        Direct    = true, -- direct FireServer mode: fire "Hit" on own shot echo, no hooks
    },
    Esp = {
        Box    = true,
        Name   = true,
        Health = true,
    },
    Ui = {
        ShowKey = Enum.KeyCode.RightShift, -- OK: hides/shows the menu window itself, not the features
    },
}

-- double-load guard: unload previous instance, never two loops
local Env = _G
if type(getgenv) == "function" then Env = getgenv() end -- VERIFY: getgenv
if Env.NOIR_FLICK and Env.NOIR_FLICK.Unload then
    pcall(Env.NOIR_FLICK.Unload)
end

local Players     = game:GetService("Players")          -- OK
local RunService  = game:GetService("RunService")       -- OK
local UIS         = game:GetService("UserInputService") -- OK
local RS          = game:GetService("ReplicatedStorage") -- OK
local LocalPlayer = Players.LocalPlayer                 -- OK

local State = {
    sa     = false,
    esp    = false,
    target = nil, -- { pos = Vector3, model = Instance }, refreshed every frame
}

-- helpers ---------------------------------------------------------------

local function wallVisible(targetPos, targetModel)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local params = RaycastParams.new() -- OK
    params.FilterType = Enum.RaycastFilterType.Exclude -- OK
    local ignore = { cam } -- weapon viewmodels are usually parented to camera
    local myChar = LocalPlayer.Character
    if myChar then table.insert(ignore, myChar) end
    if targetModel then table.insert(ignore, targetModel) end
    params.FilterDescendantsInstances = ignore
    local origin = cam.CFrame.Position
    return workspace:Raycast(origin, targetPos - origin, params) == nil -- OK
end

-- remotes ----------------------------------------------------------------

local RemotesFolder = RS:WaitForChild("Remotes", 10) -- OK
local WeaponFX = RemotesFolder and RemotesFolder:WaitForChild("WeaponFX", 10) or nil

local NetRemote
do
    local shared  = RS:WaitForChild("Shared", 10)
    local weapons = shared and shared:WaitForChild("Weapons", 10)
    local net     = weapons and weapons:WaitForChild("Net", 10)
    NetRemote     = net and net:WaitForChild("Remote", 10) or nil
end

-- target candidates: player characters AND humanoid models under workspace --

local targetCount = 0

local function collect()
    local out, n = {}, 0
    local myChar = LocalPlayer.Character
    local playerChars = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            playerChars[plr.Character] = true
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            n = n + 1
            out[n] = { model = plr.Character, name = plr.DisplayName } -- OK
        end
    end
    for _, m in ipairs(workspace:GetChildren()) do -- OK
        if m ~= myChar and not playerChars[m]
            and m:FindFirstChildOfClass("Humanoid")
            and m:FindFirstChild("HumanoidRootPart") then
            n = n + 1
            out[n] = { model = m, name = m.Name, npc = true }
        end
    end
    return out
end

-- ESP overlay (instances, no Drawing) ----------------------------------------

local overlay = Instance.new("ScreenGui") -- OK
overlay.Name = "NoirFlickEsp"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true -- W2S viewport coords == gui coords, no inset math
overlay.DisplayOrder = 998 -- under the menu (999)
overlay.Parent = LocalPlayer:WaitForChild("PlayerGui") -- OK: PlayerGui always renders

local EspPool = {}

local function killEsp(model)
    local e = EspPool[model]
    if not e then return end
    for _, obj in ipairs({ e.box, e.name, e.hpBg, e.hpFg }) do
        if obj then pcall(function() obj:Destroy() end) end
    end
    EspPool[model] = nil
end

local function hideEsp(e)
    for _, obj in ipairs({ e.box, e.name, e.hpBg, e.hpFg }) do
        if obj then obj.Visible = false end
    end
end

local function espInstance(class, props)
    local o = Instance.new(class) -- OK
    o.BackgroundTransparency = 1
    o.BorderSizePixel = 0
    o.Visible = false
    for k, v in pairs(props) do o[k] = v end
    o.Parent = overlay
    return o
end

local function getEspObjects(model)
    local e = EspPool[model]
    if e then return e end
    e = {}
    e.box = espInstance("Frame", { ZIndex = 2 })
    local stroke = Instance.new("UIStroke") -- OK
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Parent = e.box
    e.stroke = stroke
    e.name = espInstance("TextLabel", {
        Size = UDim2.fromOffset(140, 14),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeTransparency = 0.4, -- OK
        Text = "",
        ZIndex = 3,
    })
    e.hpBg = espInstance("Frame", {
        BackgroundTransparency = 0.2,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 2,
    })
    e.hpFg = espInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        ZIndex = 3,
    })
    EspPool[model] = e
    return e
end

local ACCENT = Color3.fromRGB(255, 63, 96)

local function updateEsp(model, name, cam, hum, hrp, head)
    local e = getEspObjects(model)
    -- viewport convention: origin top-left, Y grows down
    local tv = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
    local bv, onB = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
    if not onB or bv.Z <= 0 then hideEsp(e) return end
    local h = tv.Y - bv.Y
    -- first person: a target right next to you spans way more than the screen
    if h < 6 or h > cam.ViewportSize.Y * 4 then hideEsp(e) return end
    local w = h * 0.55
    local x0, y0 = tv.X - w / 2, tv.Y
    e.box.Position = UDim2.fromOffset(x0, y0)
    e.box.Size = UDim2.fromOffset(w, h)
    e.box.Visible = Config.Esp.Box
    -- locked target gets the accent color so you can SEE the aim lock
    local isTgt = State.target and State.target.model == model
    e.stroke.Color = isTgt and ACCENT or Color3.fromRGB(255, 255, 255)
    e.name.Text = name
    e.name.Position = UDim2.fromOffset(tv.X - 70, y0 - 17)
    e.name.Visible = Config.Esp.Name
    local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) -- OK: Luau clamp
    e.hpBg.Position = UDim2.fromOffset(x0 - 6, y0)
    e.hpBg.Size = UDim2.fromOffset(4, h)
    e.hpBg.Visible = Config.Esp.Health
    e.hpFg.Position = UDim2.fromOffset(x0 - 5, y0 + (h - h * ratio))
    e.hpFg.Size = UDim2.fromOffset(2, h * ratio)
    -- Frame has BackgroundColor3 (v3 crashed here on Drawing-style .Color)
    e.hpFg.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - ratio)), math.floor(255 * ratio), 0)
    e.hpFg.Visible = Config.Esp.Health
end

-- fov ring (square frame + full UICorner + UIStroke = circle, no Drawing)

local fovRing, ringStroke
do
    fovRing = espInstance("Frame", { ZIndex = 1 })
    local corner = Instance.new("UICorner") -- OK
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fovRing
    ringStroke = Instance.new("UIStroke") -- OK
    ringStroke.Color = Color3.fromRGB(255, 255, 255)
    ringStroke.Thickness = 1
    ringStroke.Transparency = 0.2
    ringStroke.Parent = fovRing
end

-- target picker ------------------------------------------------------------

local function pickTarget(candidates)
    State.target = nil
    if not State.sa then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestD, bestHead, bestModel = math.huge, nil, nil
    for _, cand in ipairs(candidates) do
        local model = cand.model
        local hum  = model:FindFirstChildOfClass("Humanoid")
        local hrp  = model:FindFirstChild("HumanoidRootPart")
        local head = model:FindFirstChild(Config.SilentAim.HitPart) or hrp
        if hum and hrp and head and hum.Health > 0 then
            local sp, on = cam:WorldToViewportPoint(head.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d <= Config.SilentAim.Fov and d < bestD then
                    if not Config.SilentAim.WallCheck or wallVisible(head.Position, model) then
                        bestD, bestHead, bestModel = d, head, model
                    end
                end
            end
        end
    end
    if bestHead then State.target = { pos = bestHead.Position, model = bestModel } end
end

-- direct FireServer mode ------------------------------------------------------
-- no hooks: fire the CONFIRMED "Hit" call ourselves at the locked target.
-- trigger: our own "fire" echo from WeaponFX (free shot detection via OnClientEvent).

local function directHit()
    if not (NetRemote and State.target) then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local eye = cam.CFrame.Position -- first person: camera == eye
    local hitPos = State.target.pos
    if (eye - hitPos).Magnitude < 0.05 then return end -- no degenerate lookAt
    -- FILL: dump t was tick()-style epoch seconds; VERIFY server tolerance
    NetRemote:FireServer("Hit", tick(), CFrame.lookAt(eye, hitPos), hitPos)
end

local echoConn
if WeaponFX then
    -- own shots echo back: WeaponFX OnClientEvent ("fire", myChar, ...)
    echoConn = WeaponFX.OnClientEvent:Connect(function(action, who, ...) -- OK
        if not (Config.SilentAim.Direct and State.sa and State.target) then return end
        if action == "fire" and who == LocalPlayer.Character then
            directHit()
        end
    end)
end

-- silent aim hook (secondary path: redirect the game's own Hit calls) -----------

local oldNamecall
local hookInstalled, hookLive, hookVarOK = false, false, false
local hookIntercepts = 0
local probeArgs = -1

local function reaim(self, ...)
    hookIntercepts = hookIntercepts + 1 -- probe counter: proves the hook fires at all
    local a1 = select(1, ...)
    if a1 == "nfprobe" then
        probeArgs = select("#", ...) -- probe also verifies varargs survive the wrapper
    end
    if State.sa and State.target then
        local m = ""
        if type(getnamecallmethod) == "function" then m = getnamecallmethod() end -- VERIFY: executor global
        if (m == "" or m == "FireServer") and (self == NetRemote or self == WeaponFX) then
            local hitPos = State.target.pos
            if self == NetRemote and a1 == "Hit" then
                local cf = select(3, ...)
                local v4 = select(4, ...)
                if typeof(cf) == "CFrame" and typeof(v4) == "Vector3"
                    and (cf.Position - hitPos).Magnitude > 0.05 then -- no degenerate lookAt
                    -- keep the real eye position, re-aim the look vector
                    -- convention: CFrame.lookAt(from, to), -Z forward, right-handed (Luau default)
                    local t = table.pack(...) -- OK: preserves nil holes + n
                    t[3] = CFrame.lookAt(cf.Position, hitPos)
                    t[4] = hitPos
                    return oldNamecall(self, table.unpack(t, 1, t.n)) -- OK
                end
            elseif self == WeaponFX and a1 == "impact" then
                local p3 = select(3, ...)
                if typeof(p3) == "Vector3" then
                    local t = table.pack(...)
                    t[3] = hitPos
                    return oldNamecall(self, table.unpack(t, 1, t.n))
                end
            elseif self == WeaponFX and a1 == "tracer" then
                local p4 = select(4, ...)
                if typeof(p4) == "Vector3" then
                    local t = table.pack(...)
                    t[4] = hitPos
                    return oldNamecall(self, table.unpack(t, 1, t.n))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end

if NetRemote then
    if type(hookmetamethod) == "function" then -- VERIFY: executor global
        -- RAW first: on some executors (Delta) newcclosure silently drops varargs,
        -- the install succeeds, the redirect never matches anything
        local okRaw = pcall(function()
            oldNamecall = hookmetamethod(game, "__namecall", reaim)
        end)
        if okRaw then hookInstalled = true else
            if type(newcclosure) == "function" then -- VERIFY: executor global
                local okClosure = pcall(function()
                    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(reaim))
                end)
                if okClosure then hookInstalled = true end
            end
        end
    end
    -- self-test: does the hook intercept, and do varargs survive?
    if hookInstalled then
        local dummy = Instance.new("RemoteEvent") -- OK: client-only, never replicated
        pcall(function() dummy:FireServer("nfprobe", 8, 9) end) -- OK
        dummy:Destroy()
        hookLive = hookIntercepts > 0 and probeArgs >= 0
        hookVarOK = probeArgs == 3
        if not hookLive then
            warn("[NoirFlick] hook never intercepts namecalls -> direct mode is the path (hook:DEAD)")
        elseif not hookVarOK then
            warn("[NoirFlick] hook drops varargs -> redirect dead, direct mode is the path (hook:vars)")
        end
    else
        warn("[NoirFlick] hookmetamethod not available -> direct mode is the path (hook:no)")
    end
else
    warn("[NoirFlick] Net.Remote not found -> silent aim inert, ESP still up")
end

-- main loop -----------------------------------------------------------------

local statusRef = nil -- footer label from buildUi, refreshed live
local frame = 0
local espErr = nil

local function hookStateText()
    if not hookInstalled then return "no" end
    if not hookLive then return "DEAD" end
    return hookVarOK and "ok" or "vars"
end

local function statusText()
    return ("net:%s fx:%s hook:%s tgt:%d"):format(
        NetRemote and "ok" or "no",
        WeaponFX and "ok" or "no",
        hookStateText(),
        targetCount)
end

local function step()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local candidates = collect()
    targetCount = #candidates
    pickTarget(candidates)
    if fovRing and ringStroke then
        local r = Config.SilentAim.Fov
        fovRing.Size = UDim2.fromOffset(r * 2, r * 2)
        fovRing.Position = UDim2.fromOffset(cam.ViewportSize.X / 2 - r, cam.ViewportSize.Y / 2 - r)
        fovRing.Visible = State.sa and Config.SilentAim.ShowFov
        ringStroke.Color = State.target and ACCENT or Color3.fromRGB(255, 255, 255)
    end
    local seen = {}
    if State.esp then
        for _, cand in ipairs(candidates) do
            local model = cand.model
            local hum  = model:FindFirstChildOfClass("Humanoid")
            local hrp  = model:FindFirstChild("HumanoidRootPart")
            local head = model:FindFirstChild("Head") or hrp
            if hum and hrp and head and hum.Health > 0 then
                seen[model] = true
                local okE, err = pcall(updateEsp, model, cand.name, cam, hum, hrp, head)
                if not okE and not espErr then
                    espErr = err -- surface once instead of swallowing forever
                    warn("[NoirFlick] esp error: " .. tostring(err))
                end
            end
        end
    end
    for model in pairs(EspPool) do
        if not seen[model] then killEsp(model) end
    end
    frame = frame + 1
    if statusRef and frame % 15 == 0 then
        statusRef.Text = statusText()
    end
end

-- some executors skip RenderStepped, some Heartbeat; run on both, step() is idempotent
local renderConn = RunService.RenderStepped:Connect(step) -- OK
local beatConn   = RunService.Heartbeat:Connect(step)     -- OK

-- ui ------------------------------------------------------------------------

local TweenService = game:GetService("TweenService") -- OK

local Theme = {
    bg     = Color3.fromRGB(16, 16, 21),
    panel  = Color3.fromRGB(26, 26, 34),
    stroke = Color3.fromRGB(48, 48, 60),
    text   = Color3.fromRGB(238, 238, 244),
    sub    = Color3.fromRGB(140, 140, 158),
    accent = ACCENT,
    off    = Color3.fromRGB(52, 52, 64),
}

local guiRef  = nil  -- menu ScreenGui, destroyed in Unload
local uiConns = {}   -- UIS-level connections (drag / slider / show key), disconnected in Unload

local function buildUi()
    local function mk(class, props, parent)
        local o = Instance.new(class) -- OK
        if props then
            for k, v in pairs(props) do o[k] = v end
        end
        if parent then o.Parent = parent end
        return o
    end

    -- InputBegan fires for touch AND mouse; Activated is unreliable on some mobile executors
    local function pressable(btn, fn)
        btn.InputBegan:Connect(function(input) -- OK
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fn()
            end
        end)
    end

    local W, HEADER_H, BODY_H = 236, 38, 328
    -- BODY_H math: padding 10+10, gaps 6*9, sections 12*2, toggles 26*5, slider 34,
    --              hit test 24, unload 30, status 12 = 328
    local FULL_H = HEADER_H + BODY_H

    -- PlayerGui, not CoreGui: CoreGui can silently not render on some mobile executors
    local gui = mk("ScreenGui", {
        Name = "NoirFlickUi",
        ResetOnSpawn = false,
        IgnoreGuiInset = true, -- raw touch/mouse coords align with AbsolutePosition, slider math stays simple
        DisplayOrder = 999,
    }, LocalPlayer:WaitForChild("PlayerGui")) -- OK

    local main = mk("Frame", {
        Size = UDim2.fromOffset(W, 0), -- opens with a grow tween to FULL_H
        Position = UDim2.new(0.5, -W / 2, 0.5, -FULL_H / 2),
        BackgroundColor3 = Theme.bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
    }, gui)
    mk("UICorner", { CornerRadius = UDim.new(0, 10) }, main)
    mk("UIStroke", { Color = Theme.stroke, Transparency = 0.25 }, main)

    -- header: drag zone
    local header = mk("Frame", {
        Size = UDim2.new(1, 0, 0, HEADER_H),
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
    }, main)
    mk("UICorner", { CornerRadius = UDim.new(0, 10) }, header)
    mk("Frame", { -- patch: square off the header's bottom corners
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
    }, header)
    mk("Frame", { -- hairline under the header
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.stroke,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, header)
    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        RichText = true,
        Text = 'noir<font color="#FF3F60">.flick</font>',
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.text,
    }, header)

    local function headerBtn(txt, xOffset)
        local b = mk("TextButton", {
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.new(1, xOffset, 0.5, -12),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            Text = txt,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.sub,
            AutoButtonColor = false,
        }, header)
        b.MouseEnter:Connect(function() -- OK
            b.BackgroundTransparency = 0.88
            b.TextColor3 = Theme.text
        end)
        b.MouseLeave:Connect(function()
            b.BackgroundTransparency = 1
            b.TextColor3 = Theme.sub
        end)
        return b
    end
    local collapseBtn = headerBtn("–", -54)
    local hideBtn     = headerBtn("×", -28)

    -- body: vertical list
    local body = mk("Frame", {
        Position = UDim2.fromOffset(0, HEADER_H),
        Size = UDim2.new(1, 0, 1, -HEADER_H),
        BackgroundTransparency = 1,
    }, main)
    mk("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, body)
    mk("UIPadding", {
        PaddingTop    = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft   = UDim.new(0, 12),
        PaddingRight  = UDim.new(0, 12),
    }, body)

    local order = 0
    local function nextOrder()
        order = order + 1
        return order
    end

    local function section(text)
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 12),
            LayoutOrder = nextOrder(),
            Font = Enum.Font.GothamMedium,
            Text = text,
            TextSize = 11,
            TextColor3 = Theme.sub,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, body)
    end

    local function toggleRow(text, initial, onChange)
        local row = mk("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
            LayoutOrder = nextOrder(),
        }, body)
        local label = mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -56, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextSize = 13,
            TextColor3 = Theme.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local pill = mk("TextButton", {
            Size = UDim2.fromOffset(40, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = initial and Theme.accent or Theme.off,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, row)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)
        mk("UIStroke", { Color = Theme.stroke, Transparency = 0.35 }, pill)
        local knob = mk("Frame", {
            Size = UDim2.fromOffset(14, 14),
            Position = initial and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.text,
            BorderSizePixel = 0,
        }, pill)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
        local state = initial
        local function render()
            local ti = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- OK
            TweenService:Create(pill, ti, { BackgroundColor3 = state and Theme.accent or Theme.off }):Play()
            TweenService:Create(knob, ti, {
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3),
            }):Play()
        end
        pressable(pill, function()
            state = not state
            render()
            onChange(state)
        end)
        row.MouseEnter:Connect(function() label.TextColor3 = Color3.new(1, 1, 1) end)
        row.MouseLeave:Connect(function() label.TextColor3 = Theme.text end)
        return row
    end

    local function sliderRow(text, minV, maxV, initial, onChange)
        local row = mk("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 34),
            LayoutOrder = nextOrder(),
        }, body)
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -70, 0, 16),
            Font = Enum.Font.Gotham,
            Text = text,
            TextSize = 13,
            TextColor3 = Theme.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local value = mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 0, 16),
            Position = UDim2.new(1, -60, 0, 0),
            Font = Enum.Font.Gotham,
            Text = tostring(initial),
            TextSize = 13,
            TextColor3 = Theme.accent,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        local track = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundColor3 = Theme.off,
            BorderSizePixel = 0,
        }, row)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
        local fill = mk("Frame", {
            Size = UDim2.new((initial - minV) / (maxV - minV), 0, 1, 0),
            BackgroundColor3 = Theme.accent,
            BorderSizePixel = 0,
        }, track)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
        local knob = mk("Frame", {
            Size = UDim2.fromOffset(10, 10),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new((initial - minV) / (maxV - minV), 0, 0.5, 0),
            BackgroundColor3 = Theme.text,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, track)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

        local dragging = false
        local function apply(x)
            -- x is a raw viewport coordinate; IgnoreGuiInset makes AbsolutePosition match it
            local ratio = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local v = math.floor(minV + (maxV - minV) * ratio + 0.5)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            knob.Position = UDim2.new(ratio, 0, 0.5, 0)
            value.Text = tostring(v)
            onChange(v)
        end
        track.InputBegan:Connect(function(input) -- OK: mouse and touch
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                apply(input.Position.X)
            end
        end)
        uiConns[#uiConns + 1] = UIS.InputChanged:Connect(function(input) -- OK
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                apply(input.Position.X)
            end
        end)
        uiConns[#uiConns + 1] = UIS.InputEnded:Connect(function(input) -- OK
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        return row
    end

    -- rows
    section("aim")
    toggleRow("silent aim", State.sa, function(on)
        State.sa = on
        if not on then State.target = nil end
    end)
    sliderRow("fov", 20, 400, Config.SilentAim.Fov, function(v)
        Config.SilentAim.Fov = v
    end)
    toggleRow("wall check", Config.SilentAim.WallCheck, function(on)
        Config.SilentAim.WallCheck = on
    end)
    toggleRow("fov ring", Config.SilentAim.ShowFov, function(on)
        Config.SilentAim.ShowFov = on
    end)
    toggleRow("direct hit", Config.SilentAim.Direct, function(on)
        Config.SilentAim.Direct = on
    end)

    -- hit test: one manual "Hit" through the full chain (picker -> protocol -> remote)
    local hitBtn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = nextOrder(),
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Text = "hit test",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.sub,
        AutoButtonColor = false,
    }, body)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, hitBtn)
    mk("UIStroke", { Color = Theme.stroke, Transparency = 0.3 }, hitBtn)
    pressable(hitBtn, function()
        if not State.target then
            pickTarget(collect()) -- standalone test works even with silent aim toggled off
        end
        directHit()
    end)

    section("esp")
    toggleRow("esp", State.esp, function(on)
        State.esp = on
    end)

    -- unload button
    local unloadBtn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = nextOrder(),
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Text = "unload",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.sub,
        AutoButtonColor = false,
    }, body)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, unloadBtn)
    mk("UIStroke", { Color = Theme.stroke, Transparency = 0.3 }, unloadBtn)
    unloadBtn.MouseEnter:Connect(function()
        local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(unloadBtn, ti, { BackgroundColor3 = Color3.fromRGB(52, 18, 26), TextColor3 = Theme.accent }):Play()
    end)
    unloadBtn.MouseLeave:Connect(function()
        local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(unloadBtn, ti, { BackgroundColor3 = Theme.panel, TextColor3 = Theme.sub }):Play()
    end)
    pressable(unloadBtn, function()
        if Env.NOIR_FLICK and Env.NOIR_FLICK.Unload then Env.NOIR_FLICK.Unload() end
    end)

    -- live status footer: net/fx remotes, hook state, target count
    local status = mk("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 12),
        LayoutOrder = nextOrder(),
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Theme.sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "net:? fx:? hook:? tgt:?",
    }, body)
    statusRef = status

    -- collapse / hide
    local collapsed = false
    pressable(collapseBtn, function()
        collapsed = not collapsed
        body.Visible = not collapsed
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(W, collapsed and HEADER_H or FULL_H),
        }):Play()
    end)
    pressable(hideBtn, function()
        gui.Enabled = false
    end)
    uiConns[#uiConns + 1] = UIS.InputBegan:Connect(function(input, gp) -- OK
        if gp or input.KeyCode ~= Config.Ui.ShowKey then return end
        gui.Enabled = not gui.Enabled
    end)

    -- drag by the header
    do
        local dragging, dragStart, startPos = false, nil, nil
        header.InputBegan:Connect(function(input) -- OK: mouse and touch
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        uiConns[#uiConns + 1] = UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        uiConns[#uiConns + 1] = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- open animation
    main.Size = UDim2.fromOffset(W, 0)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(W, FULL_H),
    }):Play()

    guiRef = gui
end

-- unload ----------------------------------------------------------------

local unloaded = false
local function Unload()
    if unloaded then return end
    unloaded = true
    State.sa = false -- gates the namecall hook and the direct mode off permanently
    State.esp = false
    State.target = nil
    if renderConn then renderConn:Disconnect() end
    if beatConn then beatConn:Disconnect() end
    if echoConn then echoConn:Disconnect() end
    for _, c in ipairs(uiConns) do
        pcall(function() c:Disconnect() end)
    end
    for model in pairs(EspPool) do killEsp(model) end
    if guiRef then pcall(function() guiRef:Destroy() end) end
    if overlay then pcall(function() overlay:Destroy() end) end
    Env.NOIR_FLICK = nil
    print("[NoirFlick] unloaded")
end
Env.NOIR_FLICK = { Unload = Unload }

-- init ------------------------------------------------------------------

local okUi = pcall(buildUi)
if not okUi then
    warn("[NoirFlick] ui build failed, hotkey fallback armed (Q/V)")
    uiConns[#uiConns + 1] = UIS.InputBegan:Connect(function(input, gp) -- OK
        if gp then return end -- ignore typing into Roblox UI
        if input.KeyCode == Enum.KeyCode.Q then
            State.sa = not State.sa
            if not State.sa then State.target = nil end
        elseif input.KeyCode == Enum.KeyCode.V then
            State.esp = not State.esp
        end
    end)
end

do
    local cands = collect()
    local plrN, npcN = 0, 0
    for _, c in ipairs(cands) do
        if c.npc then npcN = npcN + 1 else plrN = plrN + 1 end
    end
    print(("[NoirFlick] v4 ui=%s net=%s fx=%s hook=%s"):format(
        okUi and "ok" or "FAIL", tostring(NetRemote), tostring(WeaponFX), hookStateText()))
    print(("[NoirFlick] players=%d npcs=%d · direct hit %s · test with the 'hit test' button"):format(
        plrN, npcN, Config.SilentAim.Direct and "on" or "off"))
end
