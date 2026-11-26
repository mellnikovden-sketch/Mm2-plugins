-- NoirFlick v5 · silent aim + ESP · Luau / Roblox executor (Delta-tuned)
-- protocol (CONFIRMED from the remote spy dumps):
--   ReplicatedStorage.Shared.Weapons.Net.Remote:FireServer("Hit", t, eyeCFrame, hitPos) <- damage call
--   own shots echo back: Remotes.WeaponFX OnClientEvent ("fire", myChar) -> free shot detection, no hooks
-- v5 changes (v4 loaded clean, hook=ok, no esp error, but both features still dead -> make it observable):
--   · telemetry line in console every 5s while sa/esp is on:
--       tgt:N lock:Name box:N hit:N rw:N echo:N dir:N
--       tgt  = alive targets found · lock = currently locked target name · box = esp boxes drawn now
--       hit  = real "Hit" calls the hook SAW (0 = game does not send damage through Net.Remote namecall)
--       rw   = rewrites applied to those calls · echo = own-shot echoes received · dir = direct hits fired
--   · every toggle prints its state to the console
--   · esp toggle self-test: red "esp ok" box flashes at screen center for 2s
--     (no flash = overlay dead · flash but no player boxes = target/w2s problem)
--   · cam lock (default on): camera snaps to the locked target every frame AFTER the camera update
--     (BindToRenderStep Camera+1). real crosshair on the real head -> the game's own hit lands.
--     no remote rewriting involved, cannot be rejected by any server validation.
--   · esp boxes now FILLED (BackgroundTransparency 0.85) + 2px stroke + name with distance
--   · hit test prints the target and distance before firing
-- tags: OK = Roblox client API, VERIFY = executor global, FILL = value to confirm

local Config = {
    SilentAim = {
        Fov       = 150,  -- px, radius around screen center
        ShowFov   = true,
        HitPart   = "Head", -- falls back to HumanoidRootPart
        WallCheck = true,
        Direct    = true,  -- direct FireServer mode: fire "Hit" on own shot echo, no hooks
        CamLock   = true,  -- camera snap to the locked target (unblockable path)
        TeamSafe  = false, -- skip teammates when picking a lock (off by your request)
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
    target = nil, -- { pos = Vector3, model = Instance, name = string }, refreshed every frame
}

-- telemetry counters (console output is the only channel that always reaches us)
local hitCalls, rewrites, echoes, directs = 0, 0, 0, 0
local boxN, lastTelem = 0, 0

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
            out[n] = { model = plr.Character, name = plr.DisplayName, plr = plr } -- OK
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
    e.box = espInstance("Frame", { ZIndex = 2 }) -- filled in updateEsp (v5: filled boxes)
    local stroke = Instance.new("UIStroke") -- OK
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = e.box
    e.stroke = stroke
    e.name = espInstance("TextLabel", {
        Size = UDim2.fromOffset(160, 16),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeTransparency = 0.3, -- OK
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
    if not onB or bv.Z <= 0 then hideEsp(e) return false end
    local h = tv.Y - bv.Y
    -- first person: a target right next to you spans way more than the screen
    if h < 6 or h > cam.ViewportSize.Y * 4 then hideEsp(e) return false end
    local w = h * 0.55
    local x0, y0 = tv.X - w / 2, tv.Y
    e.box.Position = UDim2.fromOffset(x0, y0)
    e.box.Size = UDim2.fromOffset(w, h)
    e.box.Visible = Config.Esp.Box
    -- locked target gets the accent color so you can SEE the aim lock
    local isTgt = State.target and State.target.model == model
    e.stroke.Color = isTgt and ACCENT or Color3.fromRGB(255, 255, 255)
    e.stroke.Thickness = isTgt and 2.5 or 2
    e.box.BackgroundColor3 = isTgt and ACCENT or Color3.fromRGB(255, 255, 255)
    e.box.BackgroundTransparency = isTgt and 0.7 or 0.85
    local dist = (hrp.Position - cam.CFrame.Position).Magnitude
    e.name.Text = ("%s · %dm"):format(name, math.floor(dist)) -- OK: Luau string interp
    e.name.Position = UDim2.fromOffset(tv.X - 80, y0 - 19)
    e.name.Visible = Config.Esp.Name
    local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) -- OK: Luau clamp
    e.hpBg.Position = UDim2.fromOffset(x0 - 8, y0)
    e.hpBg.Size = UDim2.fromOffset(5, h)
    e.hpBg.Visible = Config.Esp.Health
    e.hpFg.Position = UDim2.fromOffset(x0 - 7, y0 + (h - h * ratio))
    e.hpFg.Size = UDim2.fromOffset(3, h * ratio)
    -- Frame has BackgroundColor3 (v3 crashed here on Drawing-style .Color)
    e.hpFg.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - ratio)), math.floor(255 * ratio), 0)
    e.hpFg.Visible = Config.Esp.Health
    return true
end

-- esp self-test: flash a box at screen center so "is the overlay alive" is answerable
local testBox, testLabel
local function espFlash()
    if not testBox then
        testBox = espInstance("Frame", {
            ZIndex = 5,
            Size = UDim2.fromOffset(140, 90),
            Position = UDim2.new(0.5, -70, 0.5, -45),
            BackgroundColor3 = ACCENT,
            BackgroundTransparency = 0.35,
        })
        testLabel = espInstance("TextLabel", {
            ZIndex = 6,
            Size = UDim2.fromOffset(140, 20),
            Position = UDim2.new(0.5, -70, 0.5, -10),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = "esp ok",
        })
    end
    testBox.Visible = true
    testLabel.Visible = true
    task.delay(2, function() -- OK: task library
        if testBox then testBox.Visible = false end
        if testLabel then testLabel.Visible = false end
    end)
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
    local bestD, bestHead, bestModel, bestName = math.huge, nil, nil, nil
    for _, cand in ipairs(candidates) do
        -- TeamSafe off by default (your request); on = teammates never get the lock
        if not (Config.SilentAim.TeamSafe and cand.plr and LocalPlayer.Team
            and cand.plr.Team ~= nil and cand.plr.Team == LocalPlayer.Team) then
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
                            bestD, bestHead, bestModel, bestName = d, head, model, cand.name
                        end
                    end
                end
            end
        end
    end
    if bestHead then
        State.target = { pos = bestHead.Position, model = bestModel, name = bestName }
    end
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
    directs = directs + 1
end

local echoConn
if WeaponFX then
    -- own shots echo back: WeaponFX OnClientEvent ("fire", myChar, ...)
    echoConn = WeaponFX.OnClientEvent:Connect(function(action, who, ...) -- OK
        if action == "fire" and who == LocalPlayer.Character then
            echoes = echoes + 1 -- count every own-shot echo, direct off or on
            if Config.SilentAim.Direct and State.sa and State.target then
                directHit()
            end
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
                hitCalls = hitCalls + 1 -- telemetry: the game really sends damage through here
                local cf = select(3, ...)
                local v4 = select(4, ...)
                if typeof(cf) == "CFrame" and typeof(v4) == "Vector3"
                    and (cf.Position - hitPos).Magnitude > 0.05 then -- no degenerate lookAt
                    -- keep the real eye position, re-aim the look vector
                    -- convention: CFrame.lookAt(from, to), -Z forward, right-handed (Luau default)
                    local t = table.pack(...) -- OK: preserves nil holes + n
                    t[3] = CFrame.lookAt(cf.Position, hitPos)
                    t[4] = hitPos
                    rewrites = rewrites + 1
                    return oldNamecall(self, table.unpack(t, 1, t.n)) -- OK
                end
            elseif self == WeaponFX and a1 == "impact" then
                local p3 = select(3, ...)
                if typeof(p3) == "Vector3" then
                    local t = table.pack(...)
                    t[3] = hitPos
                    rewrites = rewrites + 1
                    return oldNamecall(self, table.unpack(t, 1, t.n))
                end
            elseif self == WeaponFX and a1 == "tracer" then
                local p4 = select(4, ...)
                if typeof(p4) == "Vector3" then
                    local t = table.pack(...)
                    t[4] = hitPos
                    rewrites = rewrites + 1
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
            warn("[NoirFlick] hook never intercepts namecalls -> cam lock + direct are the paths (hook:DEAD)")
        elseif not hookVarOK then
            warn("[NoirFlick] hook drops varargs -> cam lock + direct are the paths (hook:vars)")
        end
    else
        warn("[NoirFlick] hookmetamethod not available -> cam lock + direct are the paths (hook:no)")
    end
else
    warn("[NoirFlick] Net.Remote not found -> cam lock still aims, ESP still up")
end

-- main loop -----------------------------------------------------------------

local statusRef = nil -- footer label from buildUi, refreshed live
local frame = 0
local espErr = nil
local camLockBound = false

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
    -- cam lock fallback when BindToRenderStep is unavailable
    if not camLockBound and Config.SilentAim.CamLock and State.sa and State.target then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, State.target.pos)
    end
    boxN = 0
    local seen = {}
    if State.esp then
        for _, cand in ipairs(candidates) do
            local model = cand.model
            local hum  = model:FindFirstChildOfClass("Humanoid")
            local hrp  = model:FindFirstChild("HumanoidRootPart")
            local head = model:FindFirstChild("Head") or hrp
            if hum and hrp and head and hum.Health > 0 then
                seen[model] = true
                local okE, shown = pcall(updateEsp, model, cand.name, cam, hum, hrp, head)
                if okE and shown then
                    boxN = boxN + 1
                elseif not okE and not espErr then
                    espErr = shown -- surface once instead of swallowing forever
                    warn("[NoirFlick] esp error: " .. tostring(espErr))
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
    -- telemetry: one line every 5s while anything is on, console is our ground truth
    if (State.sa or State.esp) and tick() - lastTelem >= 5 then
        lastTelem = tick()
        print(("[NoirFlick] tgt:%d lock:%s box:%d hit:%d rw:%d echo:%d dir:%d"):format(
            targetCount,
            State.target and State.target.name or "-",
            boxN, hitCalls, rewrites, echoes, directs))
    end
end

-- some executors skip RenderStepped, some Heartbeat; run on both, step() is idempotent
local renderConn = RunService.RenderStepped:Connect(step) -- OK
local beatConn   = RunService.Heartbeat:Connect(step)     -- OK

-- cam lock (primary path): bound AFTER the camera update so our snap wins the frame
pcall(function()
    RunService:BindToRenderStep("NoirFlickCam", Enum.RenderPriority.Camera.Value + 1, function() -- OK
        if Config.SilentAim.CamLock and State.sa and State.target then
            local cam = workspace.CurrentCamera
            if cam then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, State.target.pos)
            end
        end
    end)
    camLockBound = true
end)

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

    local W, HEADER_H, BODY_H = 236, 32, 320
    -- BODY_H math: padding 8+8, gaps 4*12, sections 10*2, toggles 22*6, slider 28,
    --              hit test 20, unload 24, status 10 = 320. FULL 352 fits landscape phones.
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
        Size = UDim2.new(1, -76, 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        RichText = true,
        Text = 'noir<font color="#FF3F60">.flick</font>',
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.text,
    }, header)

    local function headerBtn(txt, xOffset)
        local b = mk("TextButton", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, xOffset, 0.5, -11),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            Text = txt,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
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
    local collapseBtn = headerBtn("–", -50)
    local hideBtn     = headerBtn("×", -26)

    -- body: vertical list
    local body = mk("Frame", {
        Position = UDim2.fromOffset(0, HEADER_H),
        Size = UDim2.new(1, 0, 1, -HEADER_H),
        BackgroundTransparency = 1,
    }, main)
    mk("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, body)
    mk("UIPadding", {
        PaddingTop    = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 10),
        PaddingRight  = UDim.new(0, 10),
    }, body)

    local order = 0
    local function nextOrder()
        order = order + 1
        return order
    end

    local function section(text)
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 10),
            LayoutOrder = nextOrder(),
            Font = Enum.Font.GothamMedium,
            Text = text,
            TextSize = 10,
            TextColor3 = Theme.sub,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, body)
    end

    local function toggleRow(text, initial, onChange)
        local row = mk("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = nextOrder(),
        }, body)
        local label = mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -54, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextSize = 12,
            TextColor3 = Theme.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local pill = mk("TextButton", {
            Size = UDim2.fromOffset(40, 18),
            Position = UDim2.new(1, -40, 0.5, -9),
            BackgroundColor3 = initial and Theme.accent or Theme.off,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, row)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)
        mk("UIStroke", { Color = Theme.stroke, Transparency = 0.35 }, pill)
        local knob = mk("Frame", {
            Size = UDim2.fromOffset(12, 12),
            Position = initial and UDim2.new(1, -15, 0.5, -6) or UDim2.fromOffset(3, 3),
            BackgroundColor3 = Theme.text,
            BorderSizePixel = 0,
        }, pill)
        mk("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
        local state = initial
        local function render()
            local ti = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- OK
            TweenService:Create(pill, ti, { BackgroundColor3 = state and Theme.accent or Theme.off }):Play()
            TweenService:Create(knob, ti, {
                Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.fromOffset(3, 3),
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
            Size = UDim2.new(1, 0, 0, 28),
            LayoutOrder = nextOrder(),
        }, body)
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -70, 0, 14),
            Font = Enum.Font.Gotham,
            Text = text,
            TextSize = 12,
            TextColor3 = Theme.text,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local value = mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 0, 14),
            Position = UDim2.new(1, -60, 0, 0),
            Font = Enum.Font.Gotham,
            Text = tostring(initial),
            TextSize = 12,
            TextColor3 = Theme.accent,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        local track = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 18),
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
            Size = UDim2.fromOffset(9, 9),
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
        print("[NoirFlick] sa=" .. tostring(on))
    end)
    sliderRow("fov", 20, 400, Config.SilentAim.Fov, function(v)
        Config.SilentAim.Fov = v
    end)
    toggleRow("wall check", Config.SilentAim.WallCheck, function(on)
        Config.SilentAim.WallCheck = on
        print("[NoirFlick] wall=" .. tostring(on))
    end)
    toggleRow("fov ring", Config.SilentAim.ShowFov, function(on)
        Config.SilentAim.ShowFov = on
    end)
    toggleRow("direct hit", Config.SilentAim.Direct, function(on)
        Config.SilentAim.Direct = on
        print("[NoirFlick] direct=" .. tostring(on))
    end)
    toggleRow("cam lock", Config.SilentAim.CamLock, function(on)
        Config.SilentAim.CamLock = on
        print("[NoirFlick] camlock=" .. tostring(on))
    end)
    toggleRow("skip team", Config.SilentAim.TeamSafe, function(on)
        Config.SilentAim.TeamSafe = on
        print("[NoirFlick] skipteam=" .. tostring(on))
    end)

    -- hit test: one manual "Hit" through the full chain (picker -> protocol -> remote)
    local hitBtn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
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
        if State.target then
            local cam = workspace.CurrentCamera
            local dist = cam and math.floor((State.target.pos - cam.CFrame.Position).Magnitude) or 0
            print(("[NoirFlick] hit test -> %s %dm"):format(State.target.name, dist))
            directHit()
        else
            print("[NoirFlick] hit test: no target (aim near an enemy or raise fov)")
        end
    end)

    section("esp")
    toggleRow("esp", State.esp, function(on)
        State.esp = on
        print("[NoirFlick] esp=" .. tostring(on))
        if on then espFlash() end -- self-test: red "esp ok" box at screen center for 2s
    end)

    -- unload button
    local unloadBtn = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = nextOrder(),
        BackgroundColor3 = Theme.panel,
        BorderSizePixel = 0,
        Text = "unload",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
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
        Size = UDim2.new(1, 0, 0, 10),
        LayoutOrder = nextOrder(),
        Font = Enum.Font.Code,
        TextSize = 10,
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
    State.sa = false -- gates every path off permanently
    State.esp = false
    State.target = nil
    pcall(function() RunService:UnbindFromRenderStep("NoirFlickCam") end) -- OK
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
            print("[NoirFlick] sa=" .. tostring(State.sa))
        elseif input.KeyCode == Enum.KeyCode.V then
            State.esp = not State.esp
            print("[NoirFlick] esp=" .. tostring(State.esp))
            if State.esp then espFlash() end
        end
    end)
end

do
    local cands = collect()
    local plrN, npcN = 0, 0
    for _, c in ipairs(cands) do
        if c.npc then npcN = npcN + 1 else plrN = plrN + 1 end
    end
    print(("[NoirFlick] v5 ui=%s net=%s fx=%s hook=%s cam=%s"):format(
        okUi and "ok" or "FAIL", tostring(NetRemote), tostring(WeaponFX),
        hookStateText(), camLockBound and "bind" or "step"))
    print(("[NoirFlick] players=%d npcs=%d · toggle sa/esp on and watch the 5s line: tgt lock box hit rw echo dir"):format(plrN, npcN))
end
