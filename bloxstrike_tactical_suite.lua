--!strict
-- ============================================================================
-- BLOXSTRIKE TACTICAL SUITE (Modular Luau Edition)
-- Чистая модульная архитектура без обфускации и внешних закрытых API
-- Включает: ResourceGuard, ConfigManager, CombatEngine, VisualsEngine, TacticalUI
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer


-- ============================================================================
-- MODULE 1: RESOURCE GUARD & EVENT BUS
-- ============================================================================
local EventBus = {}
EventBus.__index = EventBus

export type EventBusType = {
	On: (self: EventBusType, topic: string, fn: (...any) -> ()) -> () -> (),
	Emit: (self: EventBusType, topic: string, ...any) -> (),
	Clear: (self: EventBusType) -> (),
}

function EventBus.new(): EventBusType
	return setmetatable({
		_topics = {} :: { [string]: { (...any) -> () } },
	}, EventBus) :: any
end

function EventBus:On(topic: string, fn: (...any) -> ()): () -> ()
	local list = self._topics[topic]
	if not list then
		list = {}
		self._topics[topic] = list
	end
	table.insert(list, fn)
	return function()
		local idx = table.find(list, fn)
		if idx then
			table.remove(list, idx)
		end
	end
end

function EventBus:Emit(topic: string, ...: any)
	local list = self._topics[topic]
	if not list then
		return
	end
	for _, fn in ipairs(table.clone(list)) do
		task.spawn(fn, ...)
	end
end

function EventBus:Clear()
	table.clear(self._topics)
end

local ResourceGuard = {}
ResourceGuard.__index = ResourceGuard

export type GuardType = {
	AddConn: (self: GuardType, conn: RBXScriptConnection) -> RBXScriptConnection,
	AddInst: <T extends Instance>(self: GuardType, inst: T) -> T,
	AddTask: (self: GuardType, thread: thread) -> thread,
	AddCleanup: (self: GuardType, fn: () -> ()) -> (),
	IsDestroyed: (self: GuardType) -> boolean,
	Destroy: (self: GuardType) -> (),
}

function ResourceGuard.new(): GuardType
	return setmetatable({
		_conns = {} :: { RBXScriptConnection },
		_insts = {} :: { Instance },
		_tasks = {} :: { thread },
		_cleanups = {} :: { () -> () },
		_destroyed = false,
	}, ResourceGuard) :: any
end

function ResourceGuard:IsDestroyed(): boolean
	return self._destroyed
end

function ResourceGuard:AddConn(conn: RBXScriptConnection): RBXScriptConnection
	if self._destroyed then
		if conn.Connected then
			conn:Disconnect()
		end
		return conn
	end
	table.insert(self._conns, conn)
	return conn
end

function ResourceGuard:AddInst<T extends Instance>(inst: T): T
	if self._destroyed then
		pcall(function()
			inst:Destroy()
		end)
		return inst
	end
	table.insert(self._insts, inst)
	return inst
end

function ResourceGuard:AddTask(thread: thread): thread
	if self._destroyed then
		pcall(task.cancel, thread)
		return thread
	end
	table.insert(self._tasks, thread)
	return thread
end

function ResourceGuard:AddCleanup(fn: () -> ())
	if self._destroyed then
		pcall(fn)
		return
	end
	table.insert(self._cleanups, fn)
end

function ResourceGuard:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	for _, c in ipairs(self._conns) do
		if c.Connected then
			c:Disconnect()
		end
	end
	table.clear(self._conns)

	for _, t in ipairs(self._tasks) do
		pcall(task.cancel, t)
	end
	table.clear(self._tasks)

	for _, fn in ipairs(self._cleanups) do
		pcall(fn)
	end
	table.clear(self._cleanups)

	for _, inst in ipairs(self._insts) do
		if inst and inst.Parent then
			pcall(function()
				inst:Destroy()
			end)
		end
	end
	table.clear(self._insts)
end


-- ============================================================================
-- MODULE 2: CONFIG MANAGER, PROFILES & WEAPON PRESETS
-- ============================================================================
local ConfigManager = {}

local Defaults: { [string]: any } = {
	-- Combat Core
	CombatEnabled = true,
	AimKey = Enum.KeyCode.E,
	RightClickAim = true,
	AimMode = "Smooth", -- "Smooth" | "Snap" | "Hybrid"
	PrimaryBone = "Head", -- "Head" | "UpperTorso" | "HumanoidRootPart" | "Nearest"
	FallbackBone = "UpperTorso",
	FovRadius = 155,
	MaxDistance = 550,
	Smoothness = 0.24,
	MicroJitter = 0.02,
	VelocityPrediction = 0.085,
	AccelPrediction = 0.015,
	VisibilityCheck = true,
	PenetrationCheck = false,
	TeamCheck = true,
	IgnoreForceField = true,
	GhostTrackDuration = 0.50,
	TargetSwitchDelay = 0.12,
	StickyTarget = true,

	-- Recoil & Trigger
	RecoilCompEnabled = true,
	RecoilPitchStrength = 0.65,
	RecoilYawStrength = 0.30,
	TriggerEnabled = false,
	TriggerKey = Enum.KeyCode.LeftAlt,
	TriggerHoldMode = true,
	TriggerDelayMs = 45,
	TriggerBurstCount = 1,
	TriggerMaxFov = 14,
	TriggerRequireVisible = true,

	-- Visuals / ESP
	EspEnabled = true,
	EspBoxes = true,
	EspCornerBoxes = true,
	EspNames = true,
	EspHealthBar = true,
	EspDistance = true,
	EspWeaponTag = true,
	EspSkeleton = true,
	EspSnaplines = false,
	EspOutOfViewArrows = true,
	EspGhostChams = true,
	EspMaxDistance = 650,
	EspEnemyColor = Color3.fromRGB(244, 63, 94),
	EspVisibleColor = Color3.fromRGB(16, 185, 129),
	EspGhostColor = Color3.fromRGB(245, 158, 11),

	-- HUD & Overlays
	ShowFovRing = true,
	DynamicFov = true,
	ShowCrosshair = true,
	ShowTargetCard = true,
	ShowWatermark = true,
	ShowKeybinds = true,
	ShowSpectators = true,
	ShowCombatLog = true,
	HitmarkerEnabled = true,
	MenuKey = Enum.KeyCode.RightShift,
	AccentColor = Color3.fromRGB(99, 102, 241),
	SecondaryAccent = Color3.fromRGB(56, 189, 248),
	MenuBlur = false,
}

-- Пресеты для быстрой смены стиля игры
local BuiltInPresets: { [string]: { [string]: any } } = {
	["Tactical Legit"] = {
		CombatEnabled = true,
		AimMode = "Smooth",
		PrimaryBone = "UpperTorso",
		FallbackBone = "Head",
		FovRadius = 110,
		Smoothness = 0.16,
		MicroJitter = 0.03,
		VisibilityCheck = true,
		TriggerEnabled = false,
		RecoilPitchStrength = 0.45,
	},
	["Precision Rifle"] = {
		CombatEnabled = true,
		AimMode = "Hybrid",
		PrimaryBone = "Head",
		FallbackBone = "UpperTorso",
		FovRadius = 155,
		Smoothness = 0.28,
		MicroJitter = 0.01,
		VisibilityCheck = true,
		TriggerEnabled = true,
		TriggerDelayMs = 35,
		RecoilPitchStrength = 0.75,
	},
	["Close Quarters"] = {
		CombatEnabled = true,
		AimMode = "Hybrid",
		PrimaryBone = "Nearest",
		FallbackBone = "HumanoidRootPart",
		FovRadius = 220,
		Smoothness = 0.36,
		MicroJitter = 0.0,
		VisibilityCheck = true,
		TriggerEnabled = true,
		TriggerDelayMs = 20,
		RecoilPitchStrength = 0.60,
	},
}

local State: { [string]: any } = table.clone(Defaults)
local SavedProfiles: { [string]: { [string]: any } } = {}
local Bus = EventBus.new()

function ConfigManager.Get(key: string): any
	return State[key]
end

function ConfigManager.Set(key: string, value: any)
	local def = Defaults[key]
	if def ~= nil and typeof(value) ~= typeof(def) then
		return
	end
	if State[key] == value then
		return
	end
	State[key] = value
	Bus:Emit("Changed", key, value)
	Bus:Emit("Changed:" .. key, value)
end

function ConfigManager.OnChanged(fn: (key: string, value: any) -> ()): () -> ()
	return Bus:On("Changed", fn)
end

function ConfigManager.OnKeyChanged(key: string, fn: (value: any) -> ()): () -> ()
	return Bus:On("Changed:" .. key, fn)
end

function ConfigManager.ApplyPreset(presetName: string): boolean
	local preset = BuiltInPresets[presetName]
	if not preset then
		return false
	end
	for k, v in pairs(preset) do
		ConfigManager.Set(k, v)
	end
	return true
end

function ConfigManager.GetPresetNames(): { string }
	local names = {}
	for k in pairs(BuiltInPresets) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

function ConfigManager.SaveProfile(name: string)
	SavedProfiles[name] = table.clone(State)
end

function ConfigManager.LoadProfile(name: string): boolean
	local prof = SavedProfiles[name]
	if not prof then
		return false
	end
	for k, v in pairs(prof) do
		ConfigManager.Set(k, v)
	end
	return true
end

function ConfigManager.ResetDefaults()
	for k, v in pairs(Defaults) do
		ConfigManager.Set(k, v)
	end
end

function ConfigManager.ExportJson(): string
	local serialized: { [string]: any } = {}
	for k, v in pairs(State) do
		if typeof(v) == "Color3" then
			serialized[k] = { __t = "Color3", r = v.R, g = v.G, b = v.B }
		elseif typeof(v) == "EnumItem" then
			serialized[k] = { __t = "KeyCode", name = v.Name }
		else
			serialized[k] = v
		end
	end
	return HttpService:JSONEncode(serialized)
end

function ConfigManager.ImportJson(raw: string): boolean
	local ok, data = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	for k, v in pairs(data) do
		if Defaults[k] ~= nil then
			if type(v) == "table" and v.__t == "Color3" then
				ConfigManager.Set(k, Color3.new(tonumber(v.r) or 0.4, tonumber(v.g) or 0.4, tonumber(v.b) or 0.9))
			elseif type(v) == "table" and v.__t == "KeyCode" then
				local kc = (Enum.KeyCode :: any)[v.name]
				if typeof(kc) == "EnumItem" then
					ConfigManager.Set(k, kc)
				end
			else
				ConfigManager.Set(k, v)
			end
		end
	end
	return true
end


-- ============================================================================
-- MODULE 3: COMBAT ENGINE (SCANNER, VISIBILITY, GHOST TRACKER, RECOIL, TRIGGER)
-- ============================================================================
export type TargetRecord = {
	Model: Model,
	Player: Player?,
	Name: string,
	Root: BasePart,
	AimPart: BasePart,
	Head: BasePart?,
	AimPos: Vector3,
	Velocity: Vector3,
	Acceleration: Vector3,
	ScreenPos: Vector2,
	FovDist: number,
	WorldDist: number,
	Visible: boolean,
	Health: number,
	MaxHealth: number,
	Armor: number,
	WeaponName: string,
	IsBot: boolean,
}

type MotionHistory = {
	LastPos: Vector3,
	LastVel: Vector3,
	Accel: Vector3,
	LastSeen: number,
	Name: string,
	Health: number,
	MaxHealth: number,
}

local CombatEngine = {}
local MotionCache: { [Model]: MotionHistory } = {}
local CombatLogs: { { time: string, text: string, kind: string } } = {}

local BONE_CANDIDATES = { "Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso" }

local function PushCombatLog(kind: string, text: string)
	local stamp = os.date("%H:%M:%S")
	table.insert(CombatLogs, 1, {
		time = tostring(stamp),
		text = text,
		kind = kind,
	})
	if #CombatLogs > 35 then
		table.remove(CombatLogs)
	end
end

function CombatEngine.GetLogs()
	return CombatLogs
end

local function DetectWeaponName(model: Model): string
	local tool = model:FindFirstChildOfClass("Tool")
	if tool then
		return tool.Name
	end
	local attrWeapon = model:GetAttribute("EquippedWeapon") or model:GetAttribute("Weapon")
	if type(attrWeapon) == "string" and #attrWeapon > 0 then
		return attrWeapon
	end
	return "Unarmed"
end

local function IsSameTeam(myChar: Model, targetModel: Model, targetPlayer: Player?): boolean
	if not ConfigManager.Get("TeamCheck") then
		return false
	end
	if targetPlayer and LocalPlayer.Team and targetPlayer.Team == LocalPlayer.Team then
		return true
	end
	local myTeam = myChar:GetAttribute("Team") or LocalPlayer:GetAttribute("Team")
	local theirTeam = targetModel:GetAttribute("Team") or (targetPlayer and targetPlayer:GetAttribute("Team"))
	if myTeam ~= nil and theirTeam ~= nil and myTeam == theirTeam then
		return true
	end
	return false
end

local function SelectBestBone(camera: Camera, model: Model): BasePart?
	local primaryName: string = ConfigManager.Get("PrimaryBone")
	local fallbackName: string = ConfigManager.Get("FallbackBone")

	if primaryName == "Nearest" then
		local vp = camera.ViewportSize
		local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
		local bestPart: BasePart? = nil
		local bestDist = math.huge
		for _, boneName in ipairs(BONE_CANDIDATES) do
			local p = model:FindFirstChild(boneName)
			if p and p:IsA("BasePart") then
				local sv, onScreen = camera:WorldToViewportPoint(p.Position)
				if onScreen and sv.Z > 0 then
					local d = (Vector2.new(sv.X, sv.Y) - center).Magnitude
					if d < bestDist then
						bestDist = d
						bestPart = p
					end
				end
			end
		end
		if bestPart then
			return bestPart
		end
	end

	local primary = model:FindFirstChild(primaryName)
	if primary and primary:IsA("BasePart") then
		return primary
	end

	local fallback = model:FindFirstChild(fallbackName)
	if fallback and fallback:IsA("BasePart") then
		return fallback
	end

	local hrp = model:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then
		return hrp
	end

	return model.PrimaryPart
end

local function CheckVisibility(camera: Camera, targetPart: BasePart, localChar: Model?, targetModel: Model): boolean
	if not ConfigManager.Get("VisibilityCheck") then
		return true
	end

	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local exclude: { Instance } = {}
	if localChar then
		table.insert(exclude, localChar)
	end
	table.insert(exclude, camera)
	params.FilterDescendantsInstances = exclude

	local hit = Workspace:Raycast(origin, direction, params)
	if not hit then
		return true
	end
	if hit.Instance:IsDescendantOf(targetModel) then
		return true
	end

	-- Если включена проверка простреливаемых/тонких преград
	if ConfigManager.Get("PenetrationCheck") then
		local inst = hit.Instance
		if inst:IsA("BasePart") and (not inst.CanCollide or inst.Transparency >= 0.65 or inst.Size.Magnitude < 3.5) then
			table.insert(exclude, inst)
			params.FilterDescendantsInstances = exclude
			local secondHit = Workspace:Raycast(origin, direction, params)
			if not secondHit or secondHit.Instance:IsDescendantOf(targetModel) then
				return true
			end
		end
	end

	return false
end

function CombatEngine.CollectTargets(camera: Camera, extraFolders: { Instance }?): { TargetRecord }
	local out: { TargetRecord } = {}
	local localChar = LocalPlayer.Character
	if not localChar then
		return out
	end

	local vp = camera.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local maxDist: number = ConfigManager.Get("MaxDistance")
	local maxFov: number = ConfigManager.Get("FovRadius")
	local velPred: number = ConfigManager.Get("VelocityPrediction")
	local accPred: number = ConfigManager.Get("AccelPrediction")
	local ignoreFF: boolean = ConfigManager.Get("IgnoreForceField")

	local now = os.clock()
	local seen: { [Model]: boolean } = {}

	local function evaluateModel(model: Model, plr: Player?)
		if seen[model] or model == localChar then
			return
		end
		seen[model] = true

		local hum = model:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			MotionCache[model] = nil
			return
		end

		if ignoreFF and model:FindFirstChildOfClass("ForceField") then
			return
		end

		if IsSameTeam(localChar, model, plr) then
			return
		end

		local root = model:FindFirstChild("HumanoidRootPart")
		local aimPart = SelectBestBone(camera, model)
		if not (root and root:IsA("BasePart")) or not aimPart then
			return
		end

		local worldDist = (aimPart.Position - camera.CFrame.Position).Magnitude
		if worldDist > maxDist then
			return
		end

		local vel = aimPart.AssemblyLinearVelocity
		local prev = MotionCache[model]
		local accel = Vector3.zero
		if prev then
			local dt = math.max(0.001, now - prev.LastSeen)
			if dt < 0.5 then
				accel = (vel - prev.LastVel) / dt
			end
		end

		local predictedPos = aimPart.Position + (vel * velPred) + (0.5 * accel * accPred * accPred)

		MotionCache[model] = {
			LastPos = predictedPos,
			LastVel = vel,
			Accel = accel,
			LastSeen = now,
			Name = plr and plr.DisplayName or model.Name,
			Health = hum.Health,
			MaxHealth = hum.MaxHealth,
		}

		local sv, onScreen = camera:WorldToViewportPoint(predictedPos)
		if not onScreen or sv.Z <= 0 then
			return
		end

		local screenPos = Vector2.new(sv.X, sv.Y)
		local fovDist = (screenPos - center).Magnitude
		if fovDist > maxFov then
			return
		end

		local visible = CheckVisibility(camera, aimPart, localChar, model)
		local headPart = model:FindFirstChild("Head")
		local armorVal = tonumber(model:GetAttribute("Armor")) or 0

		table.insert(out, {
			Model = model,
			Player = plr,
			Name = plr and plr.DisplayName or model.Name,
			Root = root,
			AimPart = aimPart,
			Head = (headPart and headPart:IsA("BasePart")) and headPart or nil,
			AimPos = predictedPos,
			Velocity = vel,
			Acceleration = accel,
			ScreenPos = screenPos,
			FovDist = fovDist,
			WorldDist = worldDist,
			Visible = visible,
			Health = hum.Health,
			MaxHealth = hum.MaxHealth,
			Armor = armorVal,
			WeaponName = DetectWeaponName(model),
			IsBot = (plr == nil),
		})
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			evaluateModel(plr.Character, plr)
		end
	end

	-- Поддержка ботов/NPC из переданных папок и тегов CollectionService
	if extraFolders then
		for _, folder in ipairs(extraFolders) do
			for _, child in ipairs(folder:GetChildren()) do
				if child:IsA("Model") then
					evaluateModel(child, Players:GetPlayerFromCharacter(child))
				end
			end
		end
	end

	for _, tagged in ipairs(CollectionService:GetTagged("Combatant")) do
		if tagged:IsA("Model") then
			evaluateModel(tagged, Players:GetPlayerFromCharacter(tagged))
		end
	end

	table.sort(out, function(a, b)
		if a.Visible ~= b.Visible then
			return a.Visible
		end
		return a.FovDist < b.FovDist
	end)

	return out
end

function CombatEngine.GetGhostTarget(camera: Camera): (Vector3?, string?)
	local grace: number = ConfigManager.Get("GhostTrackDuration")
	if grace <= 0 then
		return nil, nil
	end

	local now = os.clock()
	local vp = camera.ViewportSize
	local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	local bestPos: Vector3? = nil
	local bestName: string? = nil
	local bestScore = math.huge

	for model, hist in pairs(MotionCache) do
		local age = now - hist.LastSeen
		if age > grace or not model.Parent then
			MotionCache[model] = nil
		else
			local extrapolated = hist.LastPos + (hist.LastVel * age)
			local sv, onScreen = camera:WorldToViewportPoint(extrapolated)
			if onScreen and sv.Z > 0 then
				local d = (Vector2.new(sv.X, sv.Y) - center).Magnitude
				if d <= ConfigManager.Get("FovRadius") and d < bestScore then
					bestScore = d
					bestPos = extrapolated
					bestName = hist.Name
				end
			end
		end
	end

	return bestPos, bestName
end

function CombatEngine.GetMotionCache()
	return MotionCache
end


-- ============================================================================
-- MODULE 4: VISUALS & TACTICAL ESP ENGINE (GUI-BASED, SAFE & CLEAN)
-- ============================================================================
local VisualsEngine = {}

type EspSlot = {
	RootFrame: Frame,
	BoxStroke: UIStroke,
	NameLabel: TextLabel,
	InfoLabel: TextLabel,
	HpBg: Frame,
	HpFill: Frame,
}

function VisualsEngine.Mount(guard: GuardType, parentGui: ScreenGui)
	local espLayer = guard:AddInst(Instance.new("Folder"))
	espLayer.Name = "EspOverlayLayer"
	espLayer.Parent = parentGui

	local slots: { [Model]: EspSlot } = {}

	local function getOrCreateSlot(model: Model): EspSlot
		local existing = slots[model]
		if existing then
			return existing
		end

		local frame = Instance.new("Frame")
		frame.Name = "EspBox"
		frame.BackgroundTransparency = 1
		frame.Visible = false
		frame.Parent = espLayer

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.5
		stroke.Color = ConfigManager.Get("EspEnemyColor")
		stroke.Parent = frame

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, 40, 0, 16)
		nameLbl.Position = UDim2.new(0.5, 0, 0, -18)
		nameLbl.AnchorPoint = Vector2.new(0.5, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 11
		nameLbl.TextStrokeTransparency = 0.35
		nameLbl.TextColor3 = Color3.fromRGB(245, 247, 255)
		nameLbl.Parent = frame

		local infoLbl = Instance.new("TextLabel")
		infoLbl.Size = UDim2.new(1, 50, 0, 15)
		infoLbl.Position = UDim2.new(0.5, 0, 1, 2)
		infoLbl.AnchorPoint = Vector2.new(0.5, 0)
		infoLbl.BackgroundTransparency = 1
		infoLbl.Font = Enum.Font.Gotham
		infoLbl.TextSize = 10
		infoLbl.TextStrokeTransparency = 0.4
		infoLbl.TextColor3 = Color3.fromRGB(210, 218, 235)
		infoLbl.Parent = frame

		local hpBg = Instance.new("Frame")
		hpBg.Size = UDim2.new(0, 3, 1, 0)
		hpBg.Position = UDim2.fromOffset(-6, 0)
		hpBg.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
		hpBg.BorderSizePixel = 0
		hpBg.Parent = frame

		local hpFill = Instance.new("Frame")
		hpFill.Size = UDim2.fromScale(1, 1)
		hpFill.AnchorPoint = Vector2.new(0, 1)
		hpFill.Position = UDim2.fromScale(0, 1)
		hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
		hpFill.BorderSizePixel = 0
		hpFill.Parent = hpBg

		local slot: EspSlot = {
			RootFrame = frame,
			BoxStroke = stroke,
			NameLabel = nameLbl,
			InfoLabel = infoLbl,
			HpBg = hpBg,
			HpFill = hpFill,
		}
		slots[model] = slot
		return slot
	end

	guard:AddCleanup(function()
		for _, slot in pairs(slots) do
			slot.RootFrame:Destroy()
		end
		table.clear(slots)
	end)

	return {
		Update = function(camera: Camera, targets: { TargetRecord })
			local activeModels: { [Model]: boolean } = {}
			local espOn = ConfigManager.Get("EspEnabled") == true

			if espOn then
				for _, t in ipairs(targets) do
					if t.WorldDist <= ConfigManager.Get("EspMaxDistance") then
						local topPos = t.Root.Position + Vector3.new(0, 2.7, 0)
						local botPos = t.Root.Position - Vector3.new(0, 3.0, 0)
						local topSv, on1 = camera:WorldToViewportPoint(topPos)
						local botSv, on2 = camera:WorldToViewportPoint(botPos)

						if (on1 or on2) and topSv.Z > 0 and botSv.Z > 0 then
							activeModels[t.Model] = true
							local slot = getOrCreateSlot(t.Model)
							local h = math.max(14, math.abs(botSv.Y - topSv.Y))
							local w = math.max(10, h * 0.56)

							slot.RootFrame.Position = UDim2.fromOffset(topSv.X - w * 0.5, topSv.Y)
							slot.RootFrame.Size = UDim2.fromOffset(w, h)
							slot.RootFrame.Visible = true

							local color = t.Visible and ConfigManager.Get("EspVisibleColor") or ConfigManager.Get("EspEnemyColor")
							slot.BoxStroke.Enabled = ConfigManager.Get("EspBoxes")
							slot.BoxStroke.Color = color

							slot.NameLabel.Visible = ConfigManager.Get("EspNames")
							slot.NameLabel.Text = t.IsBot and ("[BOT] " .. t.Name) or t.Name

							local infoParts: { string } = {}
							if ConfigManager.Get("EspDistance") then
								table.insert(infoParts, ("%dm"):format(math.round(t.WorldDist)))
							end
							if ConfigManager.Get("EspWeaponTag") then
								table.insert(infoParts, t.WeaponName)
							end
							slot.InfoLabel.Visible = (#infoParts > 0)
							slot.InfoLabel.Text = table.concat(infoParts, "  •  ")

							slot.HpBg.Visible = ConfigManager.Get("EspHealthBar")
							local hpRatio = math.clamp(t.Health / math.max(1, t.MaxHealth), 0, 1)
							slot.HpFill.Size = UDim2.fromScale(1, hpRatio)
							slot.HpFill.BackgroundColor3 = Color3.fromHSV(hpRatio * 0.33, 0.85, 0.95)
						end
					end
				end
			end

			for model, slot in pairs(slots) do
				if not activeModels[model] then
					if not model.Parent then
						slot.RootFrame:Destroy()
						slots[model] = nil
					else
						slot.RootFrame.Visible = false
					end
				end
			end
		end,
	}
end


-- ============================================================================
-- MODULE 5: CUSTOM TACTICAL UI FRAMEWORK (TacticalUI)
-- ============================================================================
local TacticalUI = {}

local function corner(inst: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = inst
end

local function stroke(inst: Instance, col: Color3, tr: number?, thick: number?)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Transparency = tr or 0.35
	s.Thickness = thick or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

function TacticalUI.Mount(guard: GuardType, getCombatState: () -> (TargetRecord?, string?))
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local gui = guard:AddInst(Instance.new("ScreenGui"))
	gui.Name = "BloxstrikeTacticalSuite"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local visuals = VisualsEngine.Mount(guard, gui)

	-- 1. Круг FOV
	local fovRing = guard:AddInst(Instance.new("Frame"))
	fovRing.Name = "FovRing"
	fovRing.AnchorPoint = Vector2.new(0.5, 0.5)
	fovRing.Position = UDim2.fromScale(0.5, 0.5)
	fovRing.BackgroundTransparency = 1
	fovRing.Parent = gui
	corner(fovRing, 9999)
	local fovStroke = stroke(fovRing, ConfigManager.Get("AccentColor"), 0.3, 1.5)

	-- 2. Тактический прицел
	local crosshair = guard:AddInst(Instance.new("Frame"))
	crosshair.Name = "TacticalCrosshair"
	crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshair.Position = UDim2.fromScale(0.5, 0.5)
	crosshair.Size = UDim2.fromOffset(4, 4)
	crosshair.BackgroundColor3 = ConfigManager.Get("SecondaryAccent")
	crosshair.BorderSizePixel = 0
	crosshair.Parent = gui
	corner(crosshair, 99)

	-- 3. Ватермарка
	local watermark = guard:AddInst(Instance.new("Frame"))
	watermark.Name = "Watermark"
	watermark.Size = UDim2.fromOffset(340, 32)
	watermark.Position = UDim2.new(1, -356, 0, 14)
	watermark.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
	watermark.BackgroundTransparency = 0.1
	watermark.Parent = gui
	corner(watermark, 8)
	local wmStroke = stroke(watermark, ConfigManager.Get("AccentColor"), 0.35, 1)

	local wmText = Instance.new("TextLabel")
	wmText.Size = UDim2.new(1, -16, 1, 0)
	wmText.Position = UDim2.fromOffset(8, 0)
	wmText.BackgroundTransparency = 1
	wmText.Font = Enum.Font.GothamBold
	wmText.TextSize = 12
	wmText.TextColor3 = Color3.fromRGB(238, 242, 255)
	wmText.TextXAlignment = Enum.TextXAlignment.Left
	wmText.Text = "BLOXSTRIKE TACTICAL  |  -- FPS  |  -- ms"
	wmText.Parent = watermark

	-- 4. Карточка захваченной цели
	local targetCard = guard:AddInst(Instance.new("Frame"))
	targetCard.Name = "TargetCard"
	targetCard.Size = UDim2.fromOffset(230, 56)
	targetCard.Position = UDim2.new(0.5, -115, 0.5, 175)
	targetCard.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
	targetCard.BackgroundTransparency = 0.12
	targetCard.Visible = false
	targetCard.Parent = gui
	corner(targetCard, 9)
	local tcStroke = stroke(targetCard, ConfigManager.Get("AccentColor"), 0.3, 1.2)

	local tcTitle = Instance.new("TextLabel")
	tcTitle.Size = UDim2.new(1, -16, 0, 20)
	tcTitle.Position = UDim2.fromOffset(8, 4)
	tcTitle.BackgroundTransparency = 1
	tcTitle.Font = Enum.Font.GothamBold
	tcTitle.TextSize = 12
	tcTitle.TextColor3 = Color3.fromRGB(245, 247, 255)
	tcTitle.TextXAlignment = Enum.TextXAlignment.Left
	tcTitle.Parent = targetCard

	local tcSub = Instance.new("TextLabel")
	tcSub.Size = UDim2.new(1, -16, 0, 16)
	tcSub.Position = UDim2.fromOffset(8, 22)
	tcSub.BackgroundTransparency = 1
	tcSub.Font = Enum.Font.Gotham
	tcSub.TextSize = 11
	tcSub.TextColor3 = Color3.fromRGB(190, 198, 220)
	tcSub.TextXAlignment = Enum.TextXAlignment.Left
	tcSub.Parent = targetCard

	local tcHpBg = Instance.new("Frame")
	tcHpBg.Size = UDim2.new(1, -16, 0, 6)
	tcHpBg.Position = UDim2.fromOffset(8, 42)
	tcHpBg.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
	tcHpBg.Parent = targetCard
	corner(tcHpBg, 3)

	local tcHpFill = Instance.new("Frame")
	tcHpFill.Size = UDim2.fromScale(1, 1)
	tcHpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	tcHpFill.Parent = tcHpBg
	corner(tcHpFill, 3)

	-- 5. Оверлей биндов и наблюдателей
	local sideHud = guard:AddInst(Instance.new("Frame"))
	sideHud.Name = "SideHud"
	sideHud.Size = UDim2.fromOffset(215, 130)
	sideHud.Position = UDim2.new(0, 14, 0.5, -65)
	sideHud.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
	sideHud.BackgroundTransparency = 0.14
	sideHud.Parent = gui
	corner(sideHud, 8)
	stroke(sideHud, Color3.fromRGB(48, 55, 76), 0.25, 1)

	local sideHudTitle = Instance.new("TextLabel")
	sideHudTitle.Size = UDim2.new(1, -14, 0, 22)
	sideHudTitle.Position = UDim2.fromOffset(7, 4)
	sideHudTitle.BackgroundTransparency = 1
	sideHudTitle.Font = Enum.Font.GothamBold
	sideHudTitle.TextSize = 11
	sideHudTitle.TextColor3 = ConfigManager.Get("AccentColor")
	sideHudTitle.TextXAlignment = Enum.TextXAlignment.Left
	sideHudTitle.Text = "ACTIVE BINDS & STATUS"
	sideHudTitle.Parent = sideHud

	local sideHudBody = Instance.new("TextLabel")
	sideHudBody.Size = UDim2.new(1, -14, 1, -28)
	sideHudBody.Position = UDim2.fromOffset(7, 26)
	sideHudBody.BackgroundTransparency = 1
	sideHudBody.Font = Enum.Font.Gotham
	sideHudBody.TextSize = 11
	sideHudBody.TextColor3 = Color3.fromRGB(218, 224, 242)
	sideHudBody.TextXAlignment = Enum.TextXAlignment.Left
	sideHudBody.TextYAlignment = Enum.TextYAlignment.Top
	sideHudBody.Parent = sideHud

	-- 6. Главное окно меню
	local window = guard:AddInst(Instance.new("Frame"))
	window.Name = "MainWindow"
	window.Size = UDim2.fromOffset(620, 420)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.BackgroundColor3 = Color3.fromRGB(13, 15, 21)
	window.Parent = gui
	corner(window, 12)
	stroke(window, Color3.fromRGB(48, 55, 76), 0.2, 1.2)

	local headerBar = Instance.new("Frame")
	headerBar.Size = UDim2.new(1, 0, 0, 44)
	headerBar.BackgroundColor3 = Color3.fromRGB(19, 22, 31)
	headerBar.BorderSizePixel = 0
	headerBar.Parent = window
	corner(headerBar, 12)

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Size = UDim2.new(1, -180, 1, 0)
	headerTitle.Position = UDim2.fromOffset(16, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = Enum.Font.GothamBold
	headerTitle.TextSize = 14
	headerTitle.TextColor3 = Color3.fromRGB(245, 247, 255)
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Text = "BLOXSTRIKE  //  TACTICAL COMMAND SUITE"
	headerTitle.Parent = headerBar

	local unloadBtn = Instance.new("TextButton")
	unloadBtn.Size = UDim2.fromOffset(82, 26)
	unloadBtn.Position = UDim2.new(1, -94, 0.5, -13)
	unloadBtn.BackgroundColor3 = Color3.fromRGB(185, 28, 28)
	unloadBtn.Font = Enum.Font.GothamBold
	unloadBtn.TextSize = 11
	unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	unloadBtn.Text = "UNLOAD"
	unloadBtn.Parent = headerBar
	corner(unloadBtn, 6)

	guard:AddConn(unloadBtn.MouseButton1Click:Connect(function()
		guard:Destroy()
	end))

	-- Перетаскивание главного окна
	do
		local dragging = false
		local dragOrigin = Vector2.zero
		local startPos = UDim2.zero

		guard:AddConn(headerBar.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragOrigin = Vector2.new(inp.Position.X, inp.Position.Y)
				startPos = window.Position
			end
		end))

		guard:AddConn(UserInputService.InputChanged:Connect(function(inp)
			if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local delta = Vector2.new(inp.Position.X, inp.Position.Y) - dragOrigin
				window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end))

		guard:AddConn(UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end))
	end

	-- Навигация вкладок
	local nav = Instance.new("Frame")
	nav.Size = UDim2.new(0, 145, 1, -56)
	nav.Position = UDim2.fromOffset(10, 50)
	nav.BackgroundColor3 = Color3.fromRGB(18, 21, 29)
	nav.Parent = window
	corner(nav, 10)

	local navLayout = Instance.new("UIListLayout")
	navLayout.Padding = UDim.new(0, 6)
	navLayout.Parent = nav

	local navPad = Instance.new("UIPadding")
	navPad.PaddingTop = UDim.new(0, 8)
	navPad.PaddingLeft = UDim.new(0, 8)
	navPad.PaddingRight = UDim.new(0, 8)
	navPad.Parent = nav

	local bodyHolder = Instance.new("Frame")
	bodyHolder.Size = UDim2.new(1, -172, 1, -56)
	bodyHolder.Position = UDim2.fromOffset(162, 50)
	bodyHolder.BackgroundColor3 = Color3.fromRGB(18, 21, 29)
	bodyHolder.Parent = window
	corner(bodyHolder, 10)

	local tabPages: { [string]: ScrollingFrame } = {}
	local tabBtns: { [string]: TextButton } = {}
	local currentTab = "Combat"

	local function openTab(name: string)
		currentTab = name
		for k, page in pairs(tabPages) do
			page.Visible = (k == name)
		end
		for k, btn in pairs(tabBtns) do
			local active = (k == name)
			btn.BackgroundColor3 = active and ConfigManager.Get("AccentColor") or Color3.fromRGB(26, 30, 42)
			btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(195, 203, 224)
		end
	end

	local function makeTab(name: string): ScrollingFrame
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 34)
		btn.BackgroundColor3 = Color3.fromRGB(26, 30, 42)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(195, 203, 224)
		btn.Text = name
		btn.Parent = nav
		corner(btn, 8)
		tabBtns[name] = btn

		local sf = Instance.new("ScrollingFrame")
		sf.Name = name .. "Page"
		sf.Size = UDim2.fromScale(1, 1)
		sf.BackgroundTransparency = 1
		sf.ScrollBarThickness = 4
		sf.CanvasSize = UDim2.fromOffset(0, 0)
		sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sf.Visible = false
		sf.Parent = bodyHolder

		local lay = Instance.new("UIListLayout")
		lay.Padding = UDim.new(0, 8)
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Parent = sf

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = sf

		tabPages[name] = sf

		guard:AddConn(btn.MouseButton1Click:Connect(function()
			openTab(name)
		end))

		return sf
	end

	-- Фабрика виджетов
	local function addSectionHeader(parent: Instance, text: string)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 20)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 11
		lbl.TextColor3 = ConfigManager.Get("SecondaryAccent")
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = string.upper(text)
		lbl.Parent = parent
	end

	local function addToggle(parent: Instance, label: string, key: string)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(234, 238, 250)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = parent
		corner(btn, 7)

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = btn

		local st = stroke(btn, Color3.fromRGB(52, 58, 78), 0.5, 1)

		local function sync()
			local on = ConfigManager.Get(key) == true
			btn.Text = ("%s:  %s"):format(label, on and "ENABLED" or "DISABLED")
			st.Color = on and ConfigManager.Get("AccentColor") or Color3.fromRGB(52, 58, 78)
			st.Transparency = on and 0.2 or 0.55
		end
		sync()

		guard:AddCleanup(ConfigManager.OnKeyChanged(key, sync))
		guard:AddConn(btn.MouseButton1Click:Connect(function()
			ConfigManager.Set(key, not (ConfigManager.Get(key) == true))
		end))
	end

	local function addSlider(parent: Instance, label: string, key: string, minV: number, maxV: number, dec: number)
		local box = Instance.new("Frame")
		box.Size = UDim2.new(1, 0, 0, 44)
		box.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
		box.Parent = parent
		corner(box, 7)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -20, 0, 20)
		lbl.Position = UDim2.fromOffset(10, 2)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextColor3 = Color3.fromRGB(234, 238, 250)
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = box

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -20, 0, 8)
		track.Position = UDim2.fromOffset(10, 27)
		track.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
		track.Parent = box
		corner(track, 4)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(0, 1)
		fill.BackgroundColor3 = ConfigManager.Get("AccentColor")
		fill.Parent = track
		corner(fill, 4)

		local fmt = "%." .. tostring(dec) .. "f"
		local function sync()
			local v = math.clamp(tonumber(ConfigManager.Get(key)) or minV, minV, maxV)
			local a = (maxV == minV) and 0 or ((v - minV) / (maxV - minV))
			fill.Size = UDim2.fromScale(a, 1)
			fill.BackgroundColor3 = ConfigManager.Get("AccentColor")
			lbl.Text = ("%s:  " .. fmt):format(label, v)
		end
		sync()

		guard:AddCleanup(ConfigManager.OnKeyChanged(key, sync))

		local dragging = false
		local function setFromX(x: number)
			local a = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
			local raw = minV + (maxV - minV) * a
			local mult = 10 ^ dec
			ConfigManager.Set(key, math.round(raw * mult) / mult)
		end

		guard:AddConn(track.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				setFromX(inp.Position.X)
			end
		end))
		guard:AddConn(UserInputService.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				setFromX(inp.Position.X)
			end
		end))
		guard:AddConn(UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end))
	end

	local function addDropdown(parent: Instance, label: string, key: string, options: { string })
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(234, 238, 250)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = parent
		corner(btn, 7)

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = btn

		local function sync()
			btn.Text = ("%s:  [ %s ]"):format(label, tostring(ConfigManager.Get(key)))
		end
		sync()

		guard:AddCleanup(ConfigManager.OnKeyChanged(key, sync))
		guard:AddConn(btn.MouseButton1Click:Connect(function()
			local cur = tostring(ConfigManager.Get(key))
			local idx = table.find(options, cur) or 1
			ConfigManager.Set(key, options[(idx % #options) + 1])
		end))
	end

	local function addBind(parent: Instance, label: string, key: string)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(234, 238, 250)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = parent
		corner(btn, 7)

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = btn

		local waiting = false
		local function sync()
			local kc: Enum.KeyCode = ConfigManager.Get(key)
			btn.Text = waiting and (label .. ":  <Press any key>") or ("%s:  [%s]"):format(label, kc.Name)
		end
		sync()

		guard:AddCleanup(ConfigManager.OnKeyChanged(key, sync))
		guard:AddConn(btn.MouseButton1Click:Connect(function()
			waiting = true
			sync()
		end))
		guard:AddConn(UserInputService.InputBegan:Connect(function(inp, proc)
			if not waiting or proc then
				return
			end
			if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
				waiting = false
				ConfigManager.Set(key, inp.KeyCode)
				sync()
			end
		end))
	end

	-- Наполнение вкладок
	local combatTab = makeTab("Combat")
	addSectionHeader(combatTab, "Targeting & Aim")
	addToggle(combatTab, "Combat Assist", "CombatEnabled")
	addToggle(combatTab, "Right-Click Hold Aim", "RightClickAim")
	addDropdown(combatTab, "Aim Mode", "AimMode", { "Smooth", "Hybrid", "Snap" })
	addDropdown(combatTab, "Primary Hitbox", "PrimaryBone", { "Head", "UpperTorso", "HumanoidRootPart", "Nearest" })
	addDropdown(combatTab, "Fallback Hitbox", "FallbackBone", { "UpperTorso", "HumanoidRootPart", "Head" })
	addSlider(combatTab, "FOV Radius (px)", "FovRadius", 25, 500, 0)
	addSlider(combatTab, "Max Distance (studs)", "MaxDistance", 50, 1200, 0)
	addSlider(combatTab, "Smoothness", "Smoothness", 0.03, 1.0, 2)
	addSlider(combatTab, "Micro Jitter", "MicroJitter", 0.0, 0.15, 2)
	addSectionHeader(combatTab, "Prediction & Filtering")
	addSlider(combatTab, "Velocity Prediction (s)", "VelocityPrediction", 0.0, 0.35, 3)
	addSlider(combatTab, "Accel Prediction (s)", "AccelPrediction", 0.0, 0.10, 3)
	addSlider(combatTab, "Ghost Track Memory (s)", "GhostTrackDuration", 0.0, 1.5, 2)
	addToggle(combatTab, "Visibility Check", "VisibilityCheck")
	addToggle(combatTab, "Thin Cover Penetration", "PenetrationCheck")
	addToggle(combatTab, "Team Check", "TeamCheck")
	addToggle(combatTab, "Ignore Spawn Shield", "IgnoreForceField")
	addToggle(combatTab, "Sticky Target Lock", "StickyTarget")

	local weaponTab = makeTab("Weapon")
	addSectionHeader(weaponTab, "Recoil Compensation")
	addToggle(weaponTab, "Recoil Control", "RecoilCompEnabled")
	addSlider(weaponTab, "Vertical Pitch Comp", "RecoilPitchStrength", 0.0, 1.0, 2)
	addSlider(weaponTab, "Horizontal Yaw Comp", "RecoilYawStrength", 0.0, 1.0, 2)
	addSectionHeader(weaponTab, "Triggerbot")
	addToggle(weaponTab, "Triggerbot", "TriggerEnabled")
	addToggle(weaponTab, "Require Trigger Key Hold", "TriggerHoldMode")
	addSlider(weaponTab, "Trigger Delay (ms)", "TriggerDelayMs", 0, 250, 0)
	addSlider(weaponTab, "Trigger FOV (px)", "TriggerMaxFov", 3, 45, 0)
	addToggle(weaponTab, "Trigger Visible Only", "TriggerRequireVisible")

	local visualsTab = makeTab("Visuals")
	addSectionHeader(visualsTab, "World & Player ESP")
	addToggle(visualsTab, "Master ESP", "EspEnabled")
	addToggle(visualsTab, "2D Bounding Boxes", "EspBoxes")
	addToggle(visualsTab, "Player / Bot Names", "EspNames")
	addToggle(visualsTab, "Health Bars", "EspHealthBar")
	addToggle(visualsTab, "Distance Readout", "EspDistance")
	addToggle(visualsTab, "Equipped Weapon Tag", "EspWeaponTag")
	addSlider(visualsTab, "ESP Max Distance", "EspMaxDistance", 100, 1200, 0)
	addSectionHeader(visualsTab, "Screen Overlays")
	addToggle(visualsTab, "FOV Circle", "ShowFovRing")
	addToggle(visualsTab, "Dynamic FOV Scaling", "DynamicFov")
	addToggle(visualsTab, "Center Dot Crosshair", "ShowCrosshair")
	addToggle(visualsTab, "Target Info Card", "ShowTargetCard")
	addToggle(visualsTab, "Top Watermark", "ShowWatermark")
	addToggle(visualsTab, "Keybinds & Status HUD", "ShowKeybinds")

	local configsTab = makeTab("Configs")
	addSectionHeader(configsTab, "Keybinds")
	addBind(configsTab, "Aim Assist Key", "AimKey")
	addBind(configsTab, "Triggerbot Key", "TriggerKey")
	addBind(configsTab, "Menu Toggle Key", "MenuKey")
	addSectionHeader(configsTab, "Built-in Presets")

	for _, presetName in ipairs(ConfigManager.GetPresetNames()) do
		local pBtn = Instance.new("TextButton")
		pBtn.Size = UDim2.new(1, 0, 0, 32)
		pBtn.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
		pBtn.Font = Enum.Font.GothamBold
		pBtn.TextSize = 12
		pBtn.TextColor3 = Color3.fromRGB(220, 228, 248)
		pBtn.Text = "Load Preset:  " .. presetName
		pBtn.Parent = configsTab
		corner(pBtn, 7)

		guard:AddConn(pBtn.MouseButton1Click:Connect(function()
			ConfigManager.ApplyPreset(presetName)
			PushCombatLog("CFG", "Applied preset: " .. presetName)
		end))
	end

	addSectionHeader(configsTab, "JSON & Reset")
	local exportBtn = Instance.new("TextButton")
	exportBtn.Size = UDim2.new(1, 0, 0, 34)
	exportBtn.BackgroundColor3 = ConfigManager.Get("AccentColor")
	exportBtn.Font = Enum.Font.GothamBold
	exportBtn.TextSize = 12
	exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	exportBtn.Text = "Copy Config JSON to Clipboard"
	exportBtn.Parent = configsTab
	corner(exportBtn, 8)

	guard:AddConn(exportBtn.MouseButton1Click:Connect(function()
		local json = ConfigManager.ExportJson()
		local clip = (getgenv and (getgenv() :: any).setclipboard) or (setclipboard :: any)
		if type(clip) == "function" then
			pcall(clip, json)
			exportBtn.Text = "Copied JSON!"
		else
			warn("[Bloxstrike Config JSON]:", json)
			exportBtn.Text = "Printed to Output!"
		end
		task.delay(1.5, function()
			if exportBtn.Parent then
				exportBtn.Text = "Copy Config JSON to Clipboard"
			end
		end)
	end))

	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(1, 0, 0, 32)
	resetBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
	resetBtn.Font = Enum.Font.GothamBold
	resetBtn.TextSize = 12
	resetBtn.TextColor3 = Color3.fromRGB(240, 244, 255)
	resetBtn.Text = "Reset All Settings to Default"
	resetBtn.Parent = configsTab
	corner(resetBtn, 8)

	guard:AddConn(resetBtn.MouseButton1Click:Connect(function()
		ConfigManager.ResetDefaults()
		PushCombatLog("CFG", "Settings reset to defaults")
	end))

	openTab("Combat")

	-- Переключение видимости меню
	guard:AddConn(UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end
		if inp.KeyCode == ConfigManager.Get("MenuKey") then
			window.Visible = not window.Visible
		end
	end))

	-- Цикл обновления HUD
	local fpsAcc = 0
	local fpsCount = 0
	local fpsValue = 60

	guard:AddConn(RunService.RenderStepped:Connect(function(dt: number)
		fpsAcc += dt
		fpsCount += 1
		if fpsAcc >= 0.4 then
			fpsValue = math.round(fpsCount / fpsAcc)
			fpsAcc = 0
			fpsCount = 0
		end

		local cam = Workspace.CurrentCamera
		local r: number = ConfigManager.Get("FovRadius")
		if ConfigManager.Get("DynamicFov") and cam then
			r = r * (70 / math.max(30, cam.FieldOfView))
		end
		fovRing.Size = UDim2.fromOffset(r * 2, r * 2)
		fovRing.Visible = ConfigManager.Get("ShowFovRing") and ConfigManager.Get("CombatEnabled")
		crosshair.Visible = ConfigManager.Get("ShowCrosshair")

		watermark.Visible = ConfigManager.Get("ShowWatermark")
		if watermark.Visible then
			local ping = 0
			pcall(function()
				ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			wmText.Text = ("BLOXSTRIKE SUITE  |  %d FPS  |  %d ms"):format(fpsValue, ping)
		end

		sideHud.Visible = ConfigManager.Get("ShowKeybinds")
		if sideHud.Visible then
			local aimK: Enum.KeyCode = ConfigManager.Get("AimKey")
			local trigK: Enum.KeyCode = ConfigManager.Get("TriggerKey")
			local menuK: Enum.KeyCode = ConfigManager.Get("MenuKey")
			sideHudBody.Text = (
				"Aim Assist:  %s [%s]
Triggerbot:  %s [%s]
Recoil Ctrl: %s
ESP Visuals: %s
Toggle Menu: [%s]"
			):format(
				ConfigManager.Get("CombatEnabled") and "ON" or "OFF",
				aimK.Name,
				ConfigManager.Get("TriggerEnabled") and "ON" or "OFF",
				trigK.Name,
				ConfigManager.Get("RecoilCompEnabled") and "ON" or "OFF",
				ConfigManager.Get("EspEnabled") and "ON" or "OFF",
				menuK.Name
			)
		end

		local lockedTarget, ghostName = getCombatState()
		if ConfigManager.Get("ShowTargetCard") and (lockedTarget or ghostName) then
			targetCard.Visible = true
			if lockedTarget then
				tcTitle.Text = ("%s  %s"):format(lockedTarget.Name, lockedTarget.Visible and "[VISIBLE]" or "[OCCLUDED]")
				tcSub.Text = ("%d HP  •  %dm  •  %s"):format(
					math.round(lockedTarget.Health),
					math.round(lockedTarget.WorldDist),
					lockedTarget.WeaponName
				)
				local ratio = math.clamp(lockedTarget.Health / math.max(1, lockedTarget.MaxHealth), 0, 1)
				tcHpFill.Size = UDim2.fromScale(ratio, 1)
				tcHpFill.BackgroundColor3 = lockedTarget.Visible and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(245, 158, 11)
			elseif ghostName then
				tcTitle.Text = ghostName .. "  [GHOST TRACK]"
				tcSub.Text = "Extrapolating last known vector..."
				tcHpFill.Size = UDim2.fromScale(0.5, 1)
				tcHpFill.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
			end
		else
			targetCard.Visible = false
		end
	end))

	return visuals
end


-- ============================================================================
-- MODULE 6: MAIN COMBAT LOOP & ENTRYPOINT
-- ============================================================================
local RootGuard = Guard.new()

local lockedTarget: TargetRecord? = nil
local lastGhostName: string? = nil
local lastTriggerShot = 0
local lastCameraCFrame: CFrame? = nil

-- Поиск контейнеров ботов/комбатантов, если используются в режиме
local extraContainers: { Instance } = {}
for _, folderName in ipairs({ "Combatants", "Bots", "NPCs", "Enemies" }) do
	local found = Workspace:FindFirstChild(folderName)
	if found then
		table.insert(extraContainers, found)
	end
end

local visualsController = TacticalUI.Mount(RootGuard, function()
	return lockedTarget, lastGhostName
end)

local function isAimActive(): boolean
	if not ConfigManager.Get("CombatEnabled") then
		return false
	end
	if ConfigManager.Get("RightClickAim") and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		return true
	end
	local aimKey: Enum.KeyCode = ConfigManager.Get("AimKey")
	return UserInputService:IsKeyDown(aimKey)
end

local function isTriggerActive(): boolean
	if not ConfigManager.Get("TriggerEnabled") then
		return false
	end
	if not ConfigManager.Get("TriggerHoldMode") then
		return true
	end
	local trigKey: Enum.KeyCode = ConfigManager.Get("TriggerKey")
	return UserInputService:IsKeyDown(trigKey)
end

RootGuard:AddConn(RunService.RenderStepped:Connect(function()
	local cam = Workspace.CurrentCamera
	if not cam then
		lockedTarget = nil
		lastGhostName = nil
		return
	end

	local targets = CombatEngine.CollectTargets(cam, extraContainers)
	visualsController.Update(cam, targets)

	-- Выбор цели с поддержкой Sticky Lock
	local chosen: TargetRecord? = nil
	if ConfigManager.Get("StickyTarget") and lockedTarget and lockedTarget.Model.Parent then
		for _, cand in ipairs(targets) do
			if cand.Model == lockedTarget.Model then
				chosen = cand
				break
			end
		end
	end
	if not chosen then
		chosen = targets[1]
	end
	lockedTarget = chosen

	-- Компенсация отдачи при активной стрельбе (ЛКМ)
	if ConfigManager.Get("RecoilCompEnabled") and lastCameraCFrame and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		local _, prevPitch, prevYaw = lastCameraCFrame:ToOrientation()
		local _, curPitch, curYaw = cam.CFrame:ToOrientation()
		local dPitch = curPitch - prevPitch
		local dYaw = curYaw - prevYaw
		if dPitch > 0.0004 then
			local fixPitch = -dPitch * ConfigManager.Get("RecoilPitchStrength")
			local fixYaw = -dYaw * ConfigManager.Get("RecoilYawStrength")
			cam.CFrame = cam.CFrame * CFrame.Angles(fixPitch, fixYaw, 0)
		end
	end

	-- Наведение
	if isAimActive() then
		local aimWorldPos: Vector3? = nil
		if chosen then
			aimWorldPos = chosen.AimPos
			lastGhostName = nil
		else
			local ghostPos, gName = CombatEngine.GetGhostTarget(cam)
			aimWorldPos = ghostPos
			lastGhostName = gName
		end

		if aimWorldPos then
			local jitter: number = ConfigManager.Get("MicroJitter")
			if jitter > 0 then
				aimWorldPos += Vector3.new(
					(math.random() - 0.5) * jitter,
					(math.random() - 0.5) * jitter,
					(math.random() - 0.5) * jitter
				)
			end

			local mode: string = ConfigManager.Get("AimMode")
			local smooth: number = ConfigManager.Get("Smoothness")
			local alpha = math.clamp(smooth, 0.01, 1)
			if mode == "Snap" then
				alpha = 1
			elseif mode == "Hybrid" and chosen and chosen.FovDist < 28 then
				alpha = math.clamp(smooth * 1.65, 0.05, 1)
			end

			local curCf = cam.CFrame
			local goalCf = CFrame.lookAt(curCf.Position, aimWorldPos)
			cam.CFrame = curCf:Lerp(goalCf, alpha)
		end
	else
		lastGhostName = nil
	end

	-- Triggerbot
	if isTriggerActive() and chosen then
		local visOk = (not ConfigManager.Get("TriggerRequireVisible")) or chosen.Visible
		if visOk and chosen.FovDist <= ConfigManager.Get("TriggerMaxFov") then
			local nowMs = os.clock() * 1000
			if (nowMs - lastTriggerShot) >= ConfigManager.Get("TriggerDelayMs") then
				lastTriggerShot = nowMs
				local clickFn = (getgenv and (getgenv() :: any).mouse1click) or (mouse1click :: any)
				if type(clickFn) == "function" then
					task.spawn(clickFn)
				end
			end
		end
	end

	lastCameraCFrame = cam.CFrame
end))

PushCombatLog("SYS", "Bloxstrike Tactical Suite initialized")
