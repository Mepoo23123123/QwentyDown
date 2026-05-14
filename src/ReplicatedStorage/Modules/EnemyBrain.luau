--!strict

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local EnemyConfig = require(script.Parent.EnemyConfig)

export type EnemyState = "Idle" | "Pursue" | "Attack" | "Dead"
export type DamagePlayerCallback = (enemyModel: Model, targetPlayer: Player, damage: number) -> ()
export type BrainCallbacks = {
	DamagePlayer: DamagePlayerCallback?,
}

type HealthBar = {
	Billboard: BillboardGui,
	Fill: Frame,
	MaxHealth: number,
}

type AnimationTracks = {
	Idle: AnimationTrack?,
	Walk: AnimationTrack?,
	Attack: AnimationTrack?,
}

type EnemyBrainData = {
	Model: Model,
	Definition: EnemyDefinition,
	SpawnCFrame: CFrame,
	Callbacks: BrainCallbacks,
	State: EnemyState,
	Root: BasePart,
	Humanoid: Humanoid,
	HealthValue: NumberValue,
	Alive: boolean,
	NextAttackAt: number,
	Connections: { RBXScriptConnection },
	HealthBar: HealthBar?,
	Animations: AnimationTracks,
}

export type EnemyBrain = EnemyBrainData & {
	Start: (self: EnemyBrain) -> (),
	Destroy: (self: EnemyBrain) -> (),
	GetState: (self: EnemyBrain) -> EnemyState,
}

local EnemyBrain = {}
local BrainMethods = {}
BrainMethods.__index = BrainMethods

local UPDATE_SECONDS = 0.15
local ATTACK_GRACE_DISTANCE = 1.5

local function getCharacterRoot(player: Player): BasePart?
	local character = player.Character
	if not character then return nil end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health <= 0 then return nil end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function createHealthBar(model: Model, root: BasePart, displayName: string, maxHealth: number): HealthBar
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyHealth"
	billboard.Size = UDim2.fromOffset(120, 34)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.Parent = root

	local label = Instance.new("TextLabel")
	label.Name = "Name"
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = displayName
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.45
	label.Parent = billboard

	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 0, 8)
	bg.Position = UDim2.new(0, 0, 0, 20)
	bg.BackgroundColor3 = Color3.fromRGB(22, 20, 24)
	bg.BorderSizePixel = 0
	bg.Parent = billboard
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(215, 50, 72)
	fill.BorderSizePixel = 0
	fill.Parent = bg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	return {
		Billboard = billboard,
		Fill = fill,
		MaxHealth = maxHealth,
	}
end

local function updateHealthBar(healthBar: HealthBar?, health: number)
	if not healthBar then return end
	local ratio = math.clamp(health / healthBar.MaxHealth, 0, 1)
	healthBar.Fill.Size = UDim2.fromScale(ratio, 1)
	if ratio <= 0.25 then
		healthBar.Fill.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
	elseif ratio <= 0.55 then
		healthBar.Fill.BackgroundColor3 = Color3.fromRGB(255, 145, 60)
	else
		healthBar.Fill.BackgroundColor3 = Color3.fromRGB(215, 50, 72)
	end
end

local function playTrack(track: AnimationTrack?)
	if track and not track.IsPlaying then
		track:Play(0.15)
	end
end

local function stopTrack(track: AnimationTrack?)
	if track and track.IsPlaying then
		track:Stop(0.15)
	end
end

local function loadTrack(animator: Animator, animationId: string?, priority: Enum.AnimationPriority, looped: boolean): AnimationTrack?
	if not animationId or animationId == "" then return nil end
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	animation:Destroy()
	if not ok then
		warn("[EnemyBrain] failed to load animation: " .. tostring(track))
		return nil
	end
	track.Priority = priority
	track.Looped = looped
	return track
end

local function loadAnimations(humanoid: Humanoid, definition: EnemyConfig.EnemyDefinition): AnimationTracks
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animations = definition.Animations
	if not animations then
		return {}
	end

	return {
		Idle = loadTrack(animator, animations.Idle, Enum.AnimationPriority.Idle, true),
		Walk = loadTrack(animator, animations.Walk, Enum.AnimationPriority.Movement, true),
		Attack = loadTrack(animator, animations.Attack, Enum.AnimationPriority.Action, false),
	}
end

local function spawnAttackPulse(root: BasePart, color: Color3)
	local pulse = Instance.new("Part")
	pulse.Name = "EnemyAttackPulse"
	pulse.Shape = Enum.PartType.Ball
	pulse.Size = Vector3.new(2.2, 2.2, 2.2)
	pulse.CFrame = root.CFrame * CFrame.new(0, 0, -2.4)
	pulse.Anchored = true
	pulse.CanCollide = false
	pulse.CanQuery = false
	pulse.Material = Enum.Material.Neon
	pulse.Color = color
	pulse.Transparency = 0.35
	pulse.Parent = workspace
	Debris:AddItem(pulse, 0.18)
end

local function findClosestPlayer(root: BasePart, range: number): (Player?, BasePart?, number)
	local bestPlayer = nil
	local bestRoot = nil
	local bestDistance = range

	for _, player in Players:GetPlayers() do
		local targetRoot = getCharacterRoot(player)
		if targetRoot then
			local distance = (targetRoot.Position - root.Position).Magnitude
			if distance <= bestDistance then
				bestPlayer = player
				bestRoot = targetRoot
				bestDistance = distance
			end
		end
	end

	return bestPlayer, bestRoot, bestDistance
end

function EnemyBrain.new(model: Model, definition: EnemyConfig.EnemyDefinition, spawnCFrame: CFrame, callbacks: BrainCallbacks?): EnemyBrain
	local root = model:FindFirstChild("HumanoidRootPart")
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local stats = model:FindFirstChild("Stats")
	local healthValue = stats and stats:FindFirstChild("HP")

	assert(root and root:IsA("BasePart"), "Enemy model requires HumanoidRootPart")
	assert(humanoid, "Enemy model requires Humanoid")
	assert(healthValue and healthValue:IsA("NumberValue"), "Enemy model requires Stats.HP")

	local self = setmetatable({
		Model = model,
		Definition = definition,
		SpawnCFrame = spawnCFrame,
		Callbacks = callbacks or {},
		State = "Idle",
		Root = root,
		Humanoid = humanoid,
		HealthValue = healthValue,
		Alive = false,
		NextAttackAt = 0,
		Connections = {},
		HealthBar = nil,
		Animations = loadAnimations(humanoid, definition),
	}, BrainMethods) :: any

	return self
end

function BrainMethods:_setState(state: EnemyState)
	if self.State == state then return end
	self.State = state
	self.Model:SetAttribute("EnemyState", state)

	if state == "Pursue" then
		stopTrack(self.Animations.Idle)
		playTrack(self.Animations.Walk)
	elseif state == "Idle" then
		stopTrack(self.Animations.Walk)
		playTrack(self.Animations.Idle)
	elseif state == "Attack" then
		stopTrack(self.Animations.Walk)
		playTrack(self.Animations.Idle)
	elseif state == "Dead" then
		stopTrack(self.Animations.Idle)
		stopTrack(self.Animations.Walk)
		stopTrack(self.Animations.Attack)
	end
end

function BrainMethods:_face(position: Vector3)
	local current = self.Root.Position
	local target = Vector3.new(position.X, current.Y, position.Z)
	if (target - current).Magnitude < 0.05 then return end
	self.Humanoid.AutoRotate = true
end

function BrainMethods:_moveToward(targetPosition: Vector3)
	local flatTarget = Vector3.new(targetPosition.X, self.Root.Position.Y, targetPosition.Z)
	local distance = (flatTarget - self.Root.Position).Magnitude
	if distance <= self.Definition.AttackRange * 0.75 then
		self.Humanoid:MoveTo(self.Root.Position)
		return
	end
	self.Humanoid:MoveTo(flatTarget)
end

function BrainMethods:_attack(targetPlayer: Player, targetRoot: BasePart)
	local now = os.clock()
	if now < self.NextAttackAt then return end

	local distance = (targetRoot.Position - self.Root.Position).Magnitude
	if distance > self.Definition.AttackRange + ATTACK_GRACE_DISTANCE then return end

	self.NextAttackAt = now + self.Definition.AttackCooldown
	self:_face(targetRoot.Position)
	if self.Animations.Attack then
		if self.Animations.Attack.IsPlaying then
			self.Animations.Attack:Stop(0.03)
		end
		self.Animations.Attack:Play(0.05)
	end
	spawnAttackPulse(self.Root, self.Definition.Visual.AccentColor)

	if self.Callbacks.DamagePlayer then
		self.Callbacks.DamagePlayer(self.Model, targetPlayer, self.Definition.Damage)
	end
end

function BrainMethods:_step(dt: number)
	if self.HealthValue.Value <= 0 or self.Humanoid.Health <= 0 then
		self:_setState("Dead")
		self.Alive = false
		return
	end

	local targetPlayer, targetRoot, distance = findClosestPlayer(self.Root, self.Definition.AggroRange)
	local healthRatio = self.HealthValue.Value / self.Definition.MaxHealth
	if self.HealthBar then
		self.HealthBar.Billboard.Enabled = targetPlayer ~= nil or healthRatio < 1
		updateHealthBar(self.HealthBar, self.HealthValue.Value)
	end

	if not targetPlayer or not targetRoot then
		self:_setState("Idle")
		self.Model:SetAttribute("TargetUserId", nil)
		return
	end

	self.Model:SetAttribute("TargetUserId", targetPlayer.UserId)

	local leashDistance = (self.Root.Position - self.SpawnCFrame.Position).Magnitude
	if leashDistance > self.Definition.LeashRange then
		self:_setState("Idle")
		self.Humanoid:MoveTo(self.SpawnCFrame.Position)
		return
	end

	if distance <= self.Definition.AttackRange then
		self:_setState("Attack")
		self:_attack(targetPlayer, targetRoot)
	else
		self:_setState("Pursue")
		self:_moveToward(targetRoot.Position)
	end
end

function BrainMethods:_loop()
	local last = os.clock()
	while self.Alive and self.Model.Parent do
		local now = os.clock()
		local dt = math.clamp(now - last, UPDATE_SECONDS, 0.5)
		last = now

		local ok, err = pcall(function()
			self:_step(dt)
		end)
		if not ok then
			warn("[EnemyBrain] step failed for " .. self.Model.Name .. ": " .. tostring(err))
			self.Alive = false
			break
		end

		task.wait(UPDATE_SECONDS)
	end
end

function BrainMethods:Start()
	if self.Alive then return end
	self.Alive = true
	self.HealthBar = createHealthBar(self.Model, self.Root, self.Definition.DisplayName, self.Definition.MaxHealth)
	self.Model:SetAttribute("EnemyState", self.State)
	playTrack(self.Animations.Idle)

	table.insert(self.Connections, self.HealthValue.Changed:Connect(function()
		local health = math.clamp(self.HealthValue.Value, 0, self.Definition.MaxHealth)
		self.HealthValue.Value = health
		self.Humanoid.Health = health
		updateHealthBar(self.HealthBar, health)
		if health <= 0 then
			self:_setState("Dead")
			self.Alive = false
		end
	end))

	table.insert(self.Connections, self.Humanoid.Died:Connect(function()
		self:_setState("Dead")
		self.Alive = false
	end))

	table.insert(self.Connections, self.Model.AncestryChanged:Connect(function()
		if not self.Model.Parent then
			self:Destroy()
		end
	end))

	task.spawn(function()
		self:_loop()
	end)
end

function BrainMethods:Destroy()
	if self.State ~= "Dead" then
		self:_setState("Dead")
	end
	self.Alive = false

	for _, connection in self.Connections do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(self.Connections)

	if self.HealthBar then
		self.HealthBar.Billboard:Destroy()
		self.HealthBar = nil
	end

	for _, track in self.Animations do
		if track.IsPlaying then
			track:Stop(0)
		end
		track:Destroy()
	end
	self.Animations = {}
end

function BrainMethods:GetState(): EnemyState
	return self.State
end

return EnemyBrain
