--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EnemyConfig = require(ReplicatedStorage.Modules.EnemyConfig)
local EnemyBrain = require(ReplicatedStorage.Modules.EnemyBrain)
local StatsService = require(script.Parent.StatsService)
local QuestService = require(script.Parent.QuestService)
local LootSpawner = require(script.Parent.LootSpawner)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local Util = require(ReplicatedStorage.Shared.Util)

type EnemyDefinition = EnemyConfig.EnemyDefinition
type SpawnZone = EnemyConfig.SpawnZone
type EnemyBrainObject = EnemyBrain.EnemyBrain

type ZoneRuntime = {
	Alive: number,
	LastSpawnAt: number,
}

type EnemyRecord = {
	Model: Model,
	Brain: EnemyBrainObject,
	Definition: EnemyDefinition,
	ZoneId: string,
	Dead: boolean,
}

local EnemyService = {}

local ENEMY_FOLDER_NAME = "RuntimeEnemies"
local DUMMY_NAME = "Dummy"
local START_DELAY_SECONDS = 2
local SPAWN_TICK_SECONDS = 1
local DEATH_CLEANUP_SECONDS = 3
local EXP_SHARE_RANGE = 35

local started = false
local zoneRuntime: { [string]: ZoneRuntime } = {}
local records: { [Model]: EnemyRecord } = {}
local serviceConnections: { RBXScriptConnection } = {}

local function getEnemyFolder(): Folder
	local folder = workspace:FindFirstChild(ENEMY_FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end
	local newFolder = Instance.new("Folder")
	newFolder.Name = ENEMY_FOLDER_NAME
	newFolder.Parent = workspace
	return newFolder
end

local function makePart(name: string, size: Vector3, color: Color3, cframe: CFrame): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = true
	part.CanTouch = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function createStats(model: Model, definition: EnemyDefinition): NumberValue
	local oldStats = model:FindFirstChild("Stats")
	if oldStats then
		oldStats:Destroy()
	end

	local stats = Instance.new("Folder")
	stats.Name = "Stats"
	stats.Parent = model

	local baseStats = {
		STR = math.max(1, math.floor(definition.Damage)),
		AGI = math.max(1, math.floor(definition.MoveSpeed)),
		INT = 1,
		VIT = math.max(1, math.floor(definition.MaxHealth / 20)),
		LUK = 1,
	}
	local derived = PlayerProfile.CalculateDerivedStats(baseStats)

	for name, value in baseStats do
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = name
		numberValue.Value = value
		numberValue.Parent = stats
	end

	for name, value in derived do
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = name
		numberValue.Value = value
		numberValue.Parent = stats
	end

	local hp = Instance.new("NumberValue")
	hp.Name = "HP"
	hp.Value = definition.MaxHealth
	hp.Parent = stats

	local maxHp = stats:FindFirstChild("MaxHP")
	if maxHp and maxHp:IsA("NumberValue") then
		maxHp.Value = definition.MaxHealth
	else
		local value = Instance.new("NumberValue")
		value.Name = "MaxHP"
		value.Value = definition.MaxHealth
		value.Parent = stats
	end

	local defense = stats:FindFirstChild("Defense")
	if defense and defense:IsA("NumberValue") then
		defense.Value = definition.Defense
	else
		local value = Instance.new("NumberValue")
		value.Name = "Defense"
		value.Value = definition.Defense
		value.Parent = stats
	end

	return hp
end

local function getTemplateModel(modelName: string?): Model?
	if not modelName then return nil end
	local folder = ReplicatedStorage:FindFirstChild("EnemyModels")
	if not folder then return nil end
	local template = folder:FindFirstChild(modelName)
	if template and template:IsA("Model") then
		return template
	end
	return nil
end

local function configureModelParts(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			if descendant.Name == "HumanoidRootPart" then
				descendant.Transparency = 1
				descendant.CanQuery = false
			end
		end
	end

	-- If model has Motor6D joints (R6 rig), skip welding — Motor6D handles it
	local hasMotor6D = false
	for _, child in model:GetDescendants() do
		if child:IsA("Motor6D") then
			hasMotor6D = true
			break
		end
	end

	if not hasMotor6D then
		local root = model:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			for _, descendant in model:GetDescendants() do
				if descendant:IsA("BasePart") and descendant ~= root then
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = root
					weld.Part1 = descendant
					weld.Parent = descendant
				end
			end
		end
	end
end

local function pivotModelBottomTo(model: Model, groundCFrame: CFrame)
	model:PivotTo(groundCFrame)
	local boxCFrame, boxSize = model:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	local yOffset = groundCFrame.Position.Y - bottomY + 0.05
	model:PivotTo(groundCFrame + Vector3.new(0, yOffset, 0))
end

local function applyEnemyMetadata(model: Model, definition: EnemyDefinition, spawnCFrame: CFrame)
	local root = model:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		model.PrimaryPart = root
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		humanoid = Instance.new("Humanoid")
		humanoid.Parent = model
	end
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = definition.MaxHealth
	humanoid.Health = definition.MaxHealth
	humanoid.DisplayName = definition.DisplayName
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = definition.MoveSpeed
	if not humanoid:FindFirstChildOfClass("Animator") then
		Instance.new("Animator").Parent = humanoid
	end

	createStats(model, definition)

	model:SetAttribute("IsEnemy", true)
	model:SetAttribute("EnemyId", definition.Id)
	model:SetAttribute("EnemyType", definition.Id)
	model:SetAttribute("LootTableId", definition.LootTableId)
	model:SetAttribute("EnemyTier", definition.Tier)
	model:SetAttribute("EnemyState", "Idle")

	model.Parent = getEnemyFolder()
	pivotModelBottomTo(model, spawnCFrame)
end

local function createEnemyModel(definition: EnemyDefinition, spawnCFrame: CFrame): Model
	local template = getTemplateModel(definition.ModelName)
	if template then
		local cloned = template:Clone()
		cloned.Name = definition.DisplayName
		configureModelParts(cloned)
		applyEnemyMetadata(cloned, definition, spawnCFrame)
		return cloned
	end

	local model = Instance.new("Model")
	model.Name = definition.DisplayName

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = CFrame.new()
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Parent = model
	model.PrimaryPart = root

	local size = definition.Visual.Size
	local body = makePart("Body", size, definition.Visual.BodyColor, CFrame.new(0, size.Y / 2, 0))
	body.Parent = model

	local headSize = math.max(size.X, size.Z) * 0.55
	local head = makePart("Head", Vector3.new(headSize, headSize, headSize), definition.Visual.AccentColor, CFrame.new(0, size.Y + headSize * 0.55, 0))
	head.Shape = Enum.PartType.Ball
	head.Parent = model

	local core = makePart("Core", Vector3.new(size.X * 0.45, size.Y * 0.2, size.Z * 0.45), definition.Visual.AccentColor, CFrame.new(0, size.Y * 0.62, -size.Z * 0.51))
	core.Material = Enum.Material.Neon
	core.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model

	configureModelParts(model)
	applyEnemyMetadata(model, definition, spawnCFrame)

	return model
end

local function getSpawnCFrame(zone: SpawnZone): CFrame
	local point = zone.SpawnPoints[math.random(1, #zone.SpawnPoints)]
	return CFrame.new(point)
end

local function getClosestPlayers(position: Vector3, range: number): { Player }
	local result = {}
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			if (root.Position - position).Magnitude <= range then
				table.insert(result, player)
			end
		end
	end
	return result
end

local function damagePlayer(enemyModel: Model, player: Player, damage: number)
	StatsService.DamageResource(player, "HP", damage)
	local snapshot = StatsService.GetSnapshot(player)
	if snapshot and snapshot.Resources.HP <= 0 then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end
	Util.Log("EnemyService", enemyModel.Name .. " hit " .. player.Name .. " for " .. tostring(damage))
end

local function destroyRecord(record: EnemyRecord)
	record.Brain:Destroy()
	records[record.Model] = nil
	if record.Model.Parent then
		record.Model:Destroy()
	end
end

local function rewardPlayers(record: EnemyRecord)
	local root = record.Model:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return end
	for _, player in getClosestPlayers(root.Position, EXP_SHARE_RANGE) do
		StatsService.AddEXP(player, record.Definition.RewardEXP)
		QuestService.OnEnemyKilled(player, record.Definition.Id)
	end
end

local function handleDeath(record: EnemyRecord)
	if record.Dead then return end
	record.Dead = true
	record.Brain:Destroy()

	local runtime = zoneRuntime[record.ZoneId]
	if runtime then
		runtime.Alive = math.max(0, runtime.Alive - 1)
		runtime.LastSpawnAt = os.clock()
	end

	rewardPlayers(record)
	LootSpawner.DropLoot(record.Model)
	Debris:AddItem(record.Model, DEATH_CLEANUP_SECONDS)
	records[record.Model] = nil
end

local function spawnEnemy(zoneId: string, zone: SpawnZone)
	local enemyId = EnemyConfig.GetRandomEnemyId(zone)
	if not enemyId then return end
	local definition = EnemyConfig.GetEnemy(enemyId)
	if not definition then return end

	local spawnCFrame = getSpawnCFrame(zone)
	local model = createEnemyModel(definition, spawnCFrame)
	local brain = EnemyBrain.new(model, definition, spawnCFrame, {
		DamagePlayer = damagePlayer,
	})

	local record: EnemyRecord = {
		Model = model,
		Brain = brain,
		Definition = definition,
		ZoneId = zoneId,
		Dead = false,
	}
	records[model] = record

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		table.insert(serviceConnections, humanoid.Died:Connect(function()
			handleDeath(record)
		end))
	end

	local stats = model:FindFirstChild("Stats")
	local hp = stats and stats:FindFirstChild("HP")
	if hp and hp:IsA("NumberValue") then
		table.insert(serviceConnections, hp.Changed:Connect(function()
			if hp.Value <= 0 then
				handleDeath(record)
			end
		end))
	end

	local runtime = zoneRuntime[zoneId]
	if runtime then
		runtime.Alive += 1
		runtime.LastSpawnAt = os.clock()
	end

	brain:Start()
end

local function setupDummy()
	local dummy = workspace:FindFirstChild(DUMMY_NAME)
	if not dummy or not dummy:IsA("Model") then return end
	if dummy:FindFirstChild("Stats") then return end

	local stats = Instance.new("Folder")
	stats.Name = "Stats"
	stats.Parent = dummy

	local hp = Instance.new("NumberValue")
	hp.Name = "HP"
	hp.Value = 9999
	hp.Parent = stats

	local maxHp = Instance.new("NumberValue")
	maxHp.Name = "MaxHP"
	maxHp.Value = 9999
	maxHp.Parent = stats

	local defense = Instance.new("NumberValue")
	defense.Name = "Defense"
	defense.Value = 0
	defense.Parent = stats

	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		humanoid = Instance.new("Humanoid")
		humanoid.Parent = dummy
	end
	humanoid.MaxHealth = 9999
	humanoid.Health = 9999
	humanoid.DisplayName = "Training Dummy"

	table.insert(serviceConnections, hp.Changed:Connect(function()
		if hp.Value <= 0 then
			hp.Value = 9999
			humanoid.Health = humanoid.MaxHealth
		end
	end))
end

local function spawnLoop()
	task.wait(START_DELAY_SECONDS)
	while started do
		for _, zoneId in EnemyConfig.GetZoneIds() do
			local zone = EnemyConfig.GetZone(zoneId)
			local runtime = zoneRuntime[zoneId]
			if zone and runtime then
				local missingCount = zone.MaxAlive - runtime.Alive
				local canSpawn = missingCount > 0 and os.clock() - runtime.LastSpawnAt >= zone.RespawnSeconds
				if canSpawn then
					for _ = 1, missingCount do
						spawnEnemy(zoneId, zone)
					end
				end
			end
		end
		task.wait(SPAWN_TICK_SECONDS)
	end
end

function EnemyService:Start()
	if started then return end
	started = true

	setupDummy()
	for _, zoneId in EnemyConfig.GetZoneIds() do
		zoneRuntime[zoneId] = {
			Alive = 0,
			LastSpawnAt = -9999,
		}
	end

	task.spawn(spawnLoop)
	Util.Log("EnemyService", "New enemy system started")
end

function EnemyService:Stop()
	started = false

	for _, connection in serviceConnections do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(serviceConnections)

	for _, record in records do
		destroyRecord(record)
	end
	table.clear(records)
	table.clear(zoneRuntime)

	local folder = workspace:FindFirstChild(ENEMY_FOLDER_NAME)
	if folder then
		folder:Destroy()
	end
end

return EnemyService
