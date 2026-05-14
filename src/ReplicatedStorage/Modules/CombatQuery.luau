--!strict

export type QueryMode = "Box" | "Radius" | "Ray" | "Block"

export type WeaponCombatConfig = {
	MaxDistanceMult: number?,
	WidthMult: number?,
	DamageMult: number?,
}

export type QueryConfig = {
	originPart: BasePart,
	mode: QueryMode?,
	range: number?,
	width: number?,
	height: number?,
	depth: number?,
	radius: number?,
	offset: Vector3?,
	allowMultipleHits: boolean?,
	filterInstances: { Instance }?,
	maxParts: number?,
}

export type ComboConfig = {
	range: number,
	width: number,
	height: number,
}

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local CombatQuery = {}

local DEBUG_FOLDER_NAME = "CombatQueryDebug"
local DEBUG_LIFETIME = 0.25
local DEBUG_VISUALS = RunService:IsStudio()

local DEFAULT_RANGE = 8
local DEFAULT_WIDTH = 6
local DEFAULT_HEIGHT = 5
local DEFAULT_MAX_PARTS = 100

local COMBO_CONFIGS: { [number]: ComboConfig } = {
	[1] = { range = 7.5, width = 6.5, height = 5.0 },
	[2] = { range = 8.5, width = 7.5, height = 5.0 },
	[3] = { range = 9.5, width = 9.0, height = 5.5 },
	[4] = { range = 11.5, width = 10.0, height = 6.0 },
}

type HitEntry = {
	model: Model,
	distance: number,
}

local function getTargetModelFromPart(part: BasePart?): Model?
	if not part then return nil end
	local model = part:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	if model:FindFirstChildOfClass("Humanoid") then
		return model
	end
	return nil
end

local function buildFilter(attackerChar: Model, extra: { Instance }?): { Instance }
	local filter = table.create(1 + if extra then #extra else 0)
	table.insert(filter, attackerChar)
	if extra then
		for _, instance in extra do
			table.insert(filter, instance)
		end
	end
	return filter
end

local function buildRaycastParams(attackerChar: Model, extra: { Instance }?): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = buildFilter(attackerChar, extra)
	params.IgnoreWater = true
	return params
end

local function buildOverlapParams(attackerChar: Model, extra: { Instance }?, maxParts: number?): OverlapParams
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = buildFilter(attackerChar, extra)
	params.MaxParts = maxParts or DEFAULT_MAX_PARTS
	params.RespectCanCollide = false
	return params
end

local function getDebugFolder(): Folder
	local existing = workspace:FindFirstChild(DEBUG_FOLDER_NAME)
	if existing and existing:IsA("Folder") then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = DEBUG_FOLDER_NAME
	folder.Parent = workspace
	return folder
end

local function makeDebugPart(cframe: CFrame, size: Vector3, color: Color3, label: string?)
	if not DEBUG_VISUALS then return end

	local part = Instance.new("Part")
	part.Name = "CombatQueryDebug"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.78
	part.Size = size
	part.CFrame = cframe
	part.Parent = getDebugFolder()

	local selection = Instance.new("SelectionBox")
	selection.Adornee = part
	selection.Color3 = color
	selection.LineThickness = 0.05
	selection.SurfaceTransparency = 1
	selection.Parent = part

	if label then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "SizeLabel"
		billboard.Size = UDim2.fromOffset(160, 36)
		billboard.StudsOffset = Vector3.new(0, math.max(size.Y / 2, 1) + 0.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = part

		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 0.25
		text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		text.BorderSizePixel = 0
		text.Size = UDim2.fromScale(1, 1)
		text.Font = Enum.Font.GothamBold
		text.TextScaled = true
		text.TextColor3 = color
		text.TextStrokeTransparency = 0.3
		text.Text = label
		text.Parent = billboard
	end

	Debris:AddItem(part, DEBUG_LIFETIME)
end

local function drawDebugBox(cframe: CFrame, size: Vector3, color: Color3)
	makeDebugPart(cframe, size, color, string.format("W %.1f | L %.1f | H %.1f", size.X, size.Z, size.Y))
end

local function drawDebugRay(origin: Vector3, direction: Vector3, color: Color3)
	local length = direction.Magnitude
	if length <= 0 then return end
	local cframe = CFrame.lookAt(origin + direction / 2, origin + direction)
	makeDebugPart(cframe, Vector3.new(0.15, 0.15, length), color, string.format("Ray %.1f", length))
end

local function drawDebugSphere(center: Vector3, radius: number, color: Color3)
	if not DEBUG_VISUALS then return end
	local size = Vector3.new(radius * 2, radius * 2, radius * 2)
	local part = Instance.new("Part")
	part.Name = "CombatQueryDebug"
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.82
	part.Size = size
	part.CFrame = CFrame.new(center)
	part.Parent = getDebugFolder()
	Debris:AddItem(part, DEBUG_LIFETIME)
end

local function toSortedModels(hitDistances: { [Model]: number }, allowMultipleHits: boolean?): { Model }
	local entries: { HitEntry } = {}
	for model, distance in hitDistances do
		table.insert(entries, { model = model, distance = distance })
	end
	table.sort(entries, function(a: HitEntry, b: HitEntry): boolean
		return a.distance < b.distance
	end)

	local models: { Model } = {}
	for _, entry in entries do
		table.insert(models, entry.model)
		if not allowMultipleHits then
			break
		end
	end
	return models
end

local function addModelHit(hitDistances: { [Model]: number }, attackerChar: Model, originPosition: Vector3, model: Model?)
	if not model or model == attackerChar then return end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local root = model:FindFirstChild("HumanoidRootPart")
	local distance = if root and root:IsA("BasePart") then (root.Position - originPosition).Magnitude else 0
	local previous = hitDistances[model]
	if previous == nil or distance < previous then
		hitDistances[model] = distance
	end
end

local function castBox(attackerChar: Model, config: QueryConfig): { Model }
	local originPart = config.originPart
	local range = config.range or config.depth or DEFAULT_RANGE
	local width = config.width or DEFAULT_WIDTH
	local height = config.height or DEFAULT_HEIGHT
	local depth = config.depth or range
	local offset = config.offset or Vector3.new(0, 0, -depth / 2)
	local boxCFrame = originPart.CFrame * CFrame.new(offset)
	local boxSize = Vector3.new(width, height, depth)
	drawDebugBox(boxCFrame, boxSize, Color3.fromRGB(255, 80, 80))
	local params = buildOverlapParams(attackerChar, config.filterInstances, config.maxParts)
	local parts = workspace:GetPartBoundsInBox(boxCFrame, boxSize, params)

	local hitDistances: { [Model]: number } = {}
	for _, part in parts do
		addModelHit(hitDistances, attackerChar, originPart.Position, getTargetModelFromPart(part))
	end
	return toSortedModels(hitDistances, config.allowMultipleHits)
end

local function castRadius(attackerChar: Model, config: QueryConfig): { Model }
	local originPart = config.originPart
	local radius = config.radius or config.range or DEFAULT_RANGE
	local offset = config.offset or Vector3.zero
	local center = originPart.CFrame:PointToWorldSpace(offset)
	drawDebugSphere(center, radius, Color3.fromRGB(80, 160, 255))
	local params = buildOverlapParams(attackerChar, config.filterInstances, config.maxParts)
	local parts = workspace:GetPartBoundsInRadius(center, radius, params)

	local hitDistances: { [Model]: number } = {}
	for _, part in parts do
		addModelHit(hitDistances, attackerChar, originPart.Position, getTargetModelFromPart(part))
	end
	return toSortedModels(hitDistances, config.allowMultipleHits)
end

local function castRay(attackerChar: Model, config: QueryConfig): { Model }
	local originPart = config.originPart
	local range = config.range or DEFAULT_RANGE
	local direction = originPart.CFrame.LookVector * range
	local origin = originPart.Position
	drawDebugRay(origin, direction, Color3.fromRGB(80, 240, 255))
	local ignored = buildFilter(attackerChar, config.filterInstances)
	local hitDistances: { [Model]: number } = {}

	for _ = 1, if config.allowMultipleHits then 10 else 1 do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = ignored
		params.IgnoreWater = true

		local result = workspace:Raycast(origin, direction, params)
		if not result then
			break
		end

		local target = getTargetModelFromPart(result.Instance)
		if target and target ~= attackerChar then
			addModelHit(hitDistances, attackerChar, originPart.Position, target)
			table.insert(ignored, target)
			if not config.allowMultipleHits then
				break
			end
		else
			break
		end
	end

	return toSortedModels(hitDistances, config.allowMultipleHits)
end

local function castBlock(attackerChar: Model, config: QueryConfig): { Model }
	local originPart = config.originPart
	local range = config.range or DEFAULT_RANGE
	local width = config.width or DEFAULT_WIDTH
	local height = config.height or DEFAULT_HEIGHT
	local depth = config.depth or 2
	local offset = config.offset or Vector3.new(0, 0, -depth / 2)
	local blockCFrame = originPart.CFrame * CFrame.new(offset)
	local size = Vector3.new(width, height, depth)
	drawDebugBox(blockCFrame, size, Color3.fromRGB(255, 170, 70))
	drawDebugRay(blockCFrame.Position, originPart.CFrame.LookVector * range, Color3.fromRGB(255, 220, 80))
	local params = buildRaycastParams(attackerChar, config.filterInstances)
	local result = workspace:Blockcast(blockCFrame, size, originPart.CFrame.LookVector * range, params)
	local hitDistances: { [Model]: number } = {}
	if result then
		addModelHit(hitDistances, attackerChar, originPart.Position, getTargetModelFromPart(result.Instance))
	end
	return toSortedModels(hitDistances, false)
end

function CombatQuery.CastOnce(attacker: Player, config: QueryConfig): { Model }
	local attackerChar = attacker.Character
	if not attackerChar then return {} end
	if not config.originPart then return {} end

	local mode = config.mode or "Box"
	if mode == "Ray" then
		return castRay(attackerChar, config)
	elseif mode == "Radius" then
		return castRadius(attackerChar, config)
	elseif mode == "Block" then
		return castBlock(attackerChar, config)
	else
		return castBox(attackerChar, config)
	end
end

function CombatQuery.SetDebugVisuals(enabled: boolean)
	DEBUG_VISUALS = enabled and RunService:IsStudio()
end

function CombatQuery.CastComboOnce(attacker: Player, comboCount: number, originPart: BasePart, weaponConfig: WeaponCombatConfig?): { Model }
	local config = COMBO_CONFIGS[math.clamp(comboCount, 1, 4)]
	if not config then return {} end

	local rangeMult = if weaponConfig and weaponConfig.MaxDistanceMult then weaponConfig.MaxDistanceMult else 1
	local widthMult = if weaponConfig and weaponConfig.WidthMult then weaponConfig.WidthMult else 1
	local range = config.range * rangeMult
	local depth = range

	return CombatQuery.CastOnce(attacker, {
		originPart = originPart,
		mode = "Box",
		range = range,
		depth = depth,
		width = config.width * widthMult,
		height = config.height,
		offset = Vector3.new(0, 0, -depth / 2),
		allowMultipleHits = true,
		maxParts = DEFAULT_MAX_PARTS,
	})
end

return CombatQuery
