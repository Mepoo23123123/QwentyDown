--!strict
-- WeaponVFX — Управление визуальными эффектами оружия (Trail + Slash/Hit VFX)
-- Создаёт Trail из конфига ItemData, спавнит VFX по Animation Markers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemData = require(ReplicatedStorage.Modules.ItemData)

local WeaponVFX = {}

-- ===== ТИПЫ =====
export type ActiveTrail = {
	trail: Trail,
	startMarker: string,
	endMarker: string,
}

-- ===== СОСТОЯНИЕ =====
local activeTrails: { [string]: ActiveTrail } = {}
local activeVFX: { [string]: { Instance } } = {}  -- weaponId → spawned VFX instances

-- ===== КОНСТАНТЫ =====
local ATTACHMENT_TIP = "TrailTip"
local ATTACHMENT_BASE = "TrailBase"
local VFX_CONTAINER_NAME = "TempVFX"
local EQUIPPED_WEAPON_NAME = "EquippedWeapon"

-- ===== ПРИВАТНЫЕ ФУНКЦИИ =====

--- Найти все BasePart/MeshPart внутри EquippedWeapon в персонаже
local function FindWeaponParts(character: Model): { Instance }
	local weapon = character:FindFirstChild(EQUIPPED_WEAPON_NAME)
	if not weapon then
		print("[WeaponVFX] No EquippedWeapon found in character")
		return {}
	end
	print("[WeaponVFX] Found EquippedWeapon: " .. weapon.Name)
	local parts: { Instance } = {}
	if weapon:IsA("BasePart") or weapon:IsA("MeshPart") then
		table.insert(parts, weapon)
	end
	for _, desc in weapon:GetDescendants() do
		if desc:IsA("BasePart") or desc:IsA("MeshPart") then
			table.insert(parts, desc)
		end
	end
	print("[WeaponVFX] Weapon parts found: " .. #parts)
	return parts
end

--- Найти пару Attachment на оружии
local function FindAttachments(weaponParts: { Instance }): (Attachment?, Attachment?)
	local tip: Attachment? = nil
	local base: Attachment? = nil
	for _, part in weaponParts do
		if not tip then
			tip = part:FindFirstChild(ATTACHMENT_TIP) :: Attachment?
		end
		if not base then
			base = part:FindFirstChild(ATTACHMENT_BASE) :: Attachment?
		end
		if tip and base then break end
	end
	return tip, base
end

--- Создать Trail из конфига
local function CreateTrail(tipAtt: Attachment, baseAtt: Attachment, config: ItemData.TrailConfig): Trail
	local trail = Instance.new("Trail")
	trail.Name = "SwordTrail"
	trail.Attachment0 = tipAtt
	trail.Attachment1 = baseAtt

	trail.Lifetime = config.Lifetime or 0.3
	trail.LightEmission = config.LightEmission or 0.8
	trail.LightInfluence = config.LightInfluence or 0.2
	trail.FaceCamera = if config.FaceCamera ~= nil then config.FaceCamera else true

	if config.Color then
		trail.Color = config.Color
	end
	if config.Transparency then
		trail.Transparency = config.Transparency
	end
	if config.WidthScale then
		trail.WidthScale = config.WidthScale
	end

	trail.Enabled = false
	trail.Parent = tipAtt.Parent
	return trail
end

--- Получить точку крепления на персонаже по имени
local function GetAttachPoint(character: Model, attachTo: string): CFrame
	if attachTo == "RightArm" then
		local part = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
		if part then
			return part:IsA("BasePart") and part.CFrame or CFrame.new()
		end
	elseif attachTo == "RightHand" then
		local part = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
		if part then
			return part:IsA("BasePart") and part.CFrame or CFrame.new()
		end
	elseif attachTo == "Weapon" then
		local weapon = character:FindFirstChild(EQUIPPED_WEAPON_NAME)
		if weapon then
			local handle = weapon:FindFirstChild("Handle") or weapon:FindFirstChildWhichIsA("BasePart")
			if handle and handle:IsA("BasePart") then
				return handle.CFrame
			end
		end
	end
	-- Fallback: позиция персонажа
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		return rootPart.CFrame
	end
	return CFrame.new()
end

--- Найти шаблон VFX в ReplicatedStorage по пути
local function FindVFXTemplate(vfxPath: string): Instance?
	local current: Instance = ReplicatedStorage
	for segment in vfxPath:gmatch("[^.]+") do
		current = current:FindFirstChild(segment)
		if not current then return nil end
	end
	return current
end

--- Получить/создать контейнер для временных VFX
local function GetVFXContainer(): Folder
	local container = workspace:FindFirstChild(VFX_CONTAINER_NAME)
	if not container then
		container = Instance.new("Folder")
		container.Name = VFX_CONTAINER_NAME
		container.Parent = workspace
	end
	return container
end

local function ScaleNumberSequence(sequence: NumberSequence, scale: number): NumberSequence
	local keypoints: { NumberSequenceKeypoint } = {}
	for _, keypoint in sequence.Keypoints do
		table.insert(keypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope * scale))
	end
	return NumberSequence.new(keypoints)
end

local function ApplyVFXOptions(vfx: Instance, scale: number?, timeScale: number?, emitCount: number?)
	local effectiveScale = if scale and scale > 0 then scale else 1
	if math.abs(effectiveScale - 1) > 0.001 then
		if vfx:IsA("Model") then
			pcall(function()
				vfx:ScaleTo(effectiveScale)
			end)
		elseif vfx:IsA("BasePart") then
			vfx.Size *= effectiveScale
		end

		for _, desc in vfx:GetDescendants() do
			if desc:IsA("ParticleEmitter") then
				desc.Size = ScaleNumberSequence(desc.Size, effectiveScale)
				desc.Speed = NumberRange.new(desc.Speed.Min * effectiveScale, desc.Speed.Max * effectiveScale)
			elseif desc:IsA("Trail") then
				desc.WidthScale = ScaleNumberSequence(desc.WidthScale, effectiveScale)
			elseif desc:IsA("Beam") then
				desc.Width0 *= effectiveScale
				desc.Width1 *= effectiveScale
			end
		end
	end

	local effectiveTimeScale = if timeScale and timeScale > 0 then timeScale else 1
	local effectiveEmitCount = if emitCount and emitCount > 0 then emitCount else 0
	for _, desc in vfx:GetDescendants() do
		if desc:IsA("ParticleEmitter") then
			desc.TimeScale = effectiveTimeScale
			if desc.Rate > 0 then
				desc.Enabled = true
			end
			if effectiveEmitCount > 0 then
				desc:Emit(effectiveEmitCount)
			elseif desc.Rate <= 0 then
				local attr = desc:GetAttribute("EmitCount")
				desc:Emit(if typeof(attr) == "number" then attr else 20)
			end
		end
	end
end

local function CreateTempPart(name: string, targetCFrame: CFrame): Part
	local tempPart = Instance.new("Part")
	tempPart.Name = name
	tempPart.Size = Vector3.new(0.1, 0.1, 0.1)
	tempPart.Transparency = 1
	tempPart.Anchored = true
	tempPart.CanCollide = false
	tempPart.CanTouch = false
	tempPart.CanQuery = false
	tempPart.CFrame = targetCFrame
	tempPart.Parent = GetVFXContainer()
	return tempPart
end

local function MountAttachmentVFX(vfx: Instance, targetCFrame: CFrame, marker: string): Part
	local tempPart = CreateTempPart("VFX_" .. marker, targetCFrame)
	vfx.Parent = tempPart

	-- Keep Attachments inside their original parent so rotation is preserved.
	-- Only reparent if the vfx IS an Attachment itself (no inner structure to break).
	if vfx:IsA("Attachment") then
		vfx.CFrame = CFrame.new() -- reset local offset, world pos comes from tempPart
	end

	return tempPart
end

-- ===== TRAIL =====

--- Инициализировать Trail для оружия при экипировке
--- Ждёт появления EquippedWeapon в персонаже (до 3 секунд)
function WeaponVFX.SetupTrail(character: Model, weaponId: string): boolean
	WeaponVFX.CleanupTrail(weaponId)

	local itemDef = ItemData.GetItem(weaponId)
	if not itemDef or not itemDef.Trail or not itemDef.Trail.Enabled then
		print("[WeaponVFX] No Trail config for " .. weaponId)
		return false
	end

	-- Ждём EquippedWeapon в персонаже
	local weapon = character:FindFirstChild(EQUIPPED_WEAPON_NAME)
	if not weapon then
		weapon = character:WaitForChild(EQUIPPED_WEAPON_NAME, 3)
		if not weapon then
			warn("[WeaponVFX] EquippedWeapon not found after waiting for " .. weaponId)
			return false
		end
	end

	print("[WeaponVFX] Found EquippedWeapon for trail: " .. weapon.Name)
	local parts = FindWeaponParts(character)
	if #parts == 0 then
		warn("[WeaponVFX] No parts in weapon for " .. weaponId)
		return false
	end

	local tipAtt, baseAtt = FindAttachments(parts)
	if not tipAtt or not baseAtt then
		warn("[WeaponVFX] No TrailTip/TrailBase attachments found for weapon: " .. weaponId .. " (parts=" .. #parts .. ")")
		return false
	end
	print("[WeaponVFX] Attachments found: TrailTip=" .. tostring(tipAtt ~= nil) .. " TrailBase=" .. tostring(baseAtt ~= nil))

	local trail = CreateTrail(tipAtt, baseAtt, itemDef.Trail :: ItemData.TrailConfig)

	activeTrails[weaponId] = {
		trail = trail,
		startMarker = itemDef.Trail.StartMarker or "TrailStart",
		endMarker = itemDef.Trail.EndMarker or "TrailEnd",
	}

	print("[WeaponVFX] Trail setup OK for " .. weaponId)
	return true
end

--- Включить trail (по маркеру TrailStart)
function WeaponVFX.EnableTrail(weaponId: string)
	local active = activeTrails[weaponId]
	if active then
		active.trail.Enabled = true
	end
end

--- Выключить trail (по маркеру TrailEnd)
function WeaponVFX.DisableTrail(weaponId: string)
	local active = activeTrails[weaponId]
	if active then
		active.trail.Enabled = false
	end
end

--- Удалить trail при снятии оружия
function WeaponVFX.CleanupTrail(weaponId: string)
	local active = activeTrails[weaponId]
	if active then
		if active.trail and active.trail.Parent then
			active.trail:Destroy()
		end
		activeTrails[weaponId] = nil
	end
end

--- Получить имена маркеров trail
function WeaponVFX.GetMarkerNames(weaponId: string): (string?, string?)
	local active = activeTrails[weaponId]
	if not active then return nil, nil end
	return active.startMarker, active.endMarker
end

-- ===== VFX (Slash / Hit) =====

--- Спавнит VFX-эффект по конфигурации VFXEntry
--- character — персонаж игрока, entry — конфиг из ItemData
--- hitPosition — опционально, для HitPoint типа крепления
function WeaponVFX.SpawnVFX(character: Model, entry: ItemData.VFXEntry, hitPosition: CFrame?): Instance?
	local template = FindVFXTemplate(entry.VFXPath)
	if not template then
		warn("[WeaponVFX] VFX template not found: " .. entry.VFXPath)
		return nil
	end

	local vfx = template:Clone()
	local spawnedRoot: Instance = vfx

	local targetCFrame: CFrame
	if entry.AttachTo == "HitPoint" and hitPosition then
		targetCFrame = hitPosition
	else
		targetCFrame = GetAttachPoint(character, entry.AttachTo)
	end

	if entry.OffsetCFrame then
		targetCFrame = targetCFrame * entry.OffsetCFrame
	end

	ApplyVFXOptions(vfx, entry.Scale, entry.TimeScale, entry.EmitCount)

	if vfx:IsA("BasePart") or vfx:IsA("MeshPart") then
		vfx.Anchored = true
		vfx.CanCollide = false
		vfx.CanTouch = false
		vfx.CanQuery = false
		vfx.CFrame = targetCFrame
		vfx.Parent = GetVFXContainer()
	elseif vfx:IsA("Model") then
		vfx.Parent = GetVFXContainer()
		vfx:PivotTo(targetCFrame)
	elseif vfx:IsA("Attachment") or vfx:IsA("Folder") then
		spawnedRoot = MountAttachmentVFX(vfx, targetCFrame, entry.Marker)
	else
		vfx.Parent = GetVFXContainer()
	end

	local lifetime = entry.Lifetime or 0.5
	task.delay(lifetime, function()
		if spawnedRoot and spawnedRoot.Parent then
			spawnedRoot:Destroy()
		end
	end)
	return spawnedRoot
end

--- Очистить все активные VFX для оружия
function WeaponVFX.CleanupVFX(weaponId: string)
	local instances = activeVFX[weaponId]
	if instances then
		for _, inst in instances do
			if inst and inst.Parent then
				inst:Destroy()
			end
		end
		activeVFX[weaponId] = nil
	end
end

--- Полная очистка при снятии оружия (Trail + VFX)
function WeaponVFX.CleanupAll(weaponId: string)
	WeaponVFX.CleanupTrail(weaponId)
	WeaponVFX.CleanupVFX(weaponId)
end

--- Получить все VFX-маркеры для оружия (для подключения к AnimationTrack)
--- Возвращает таблицу: markerName → { entries }
function WeaponVFX.GetVFXMarkerMap(weaponId: string): { [string]: { ItemData.VFXEntry } }
	local itemDef = ItemData.GetItem(weaponId)
	if not itemDef or not itemDef.VFX then
		return {}
	end

	local markerMap: { [string]: { ItemData.VFXEntry } } = {}

	if itemDef.VFX.SlashVFX then
		for _, entry in itemDef.VFX.SlashVFX do
			local marker = entry.Marker
			if not markerMap[marker] then
				markerMap[marker] = {}
			end
			table.insert(markerMap[marker], entry)
		end
	end

	if itemDef.VFX.HitVFX then
		for _, entry in itemDef.VFX.HitVFX do
			local marker = entry.Marker
			if not markerMap[marker] then
				markerMap[marker] = {}
			end
			table.insert(markerMap[marker], entry)
		end
	end

	return markerMap
end

return WeaponVFX
