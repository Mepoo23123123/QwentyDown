--!strict
-- Services.CombatService — Серверная боевая система (рефакторинг)
-- luau-best-practices: Server Authority, Rate Limiting, Fail Fast
-- luau-type-expert: полная типизация, export types

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Types = require(ReplicatedStorage.Shared.Types)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(ReplicatedStorage.Shared.Util)
local CombatData = require(ReplicatedStorage.Modules.CombatData)
local CombatHelpers = require(game.ServerStorage:WaitForChild("Data"):WaitForChild("CombatHelpers"))

local RemoteManager = require(ReplicatedStorage.Remotes.RemoteManager)
local CombatQuery = require(ReplicatedStorage.Modules.CombatQuery)
local ItemData = require(ReplicatedStorage.Modules.ItemData)
local InventoryService = require(game.ServerScriptService.Systems.InventoryService)

local CombatService = {}

local function ShowDamage(character, value, isCrit)
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumber"
	billboard.Size = UDim2.fromOffset(100, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp
	
	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBlack
	text.TextSize = isCrit and 32 or 26
	text.TextColor3 = isCrit and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(255, 80, 80)
	text.TextStrokeTransparency = 0.5
	text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	text.TextScaled = true
	text.Text = tostring(value)
	text.Parent = billboard
	
	game:GetService("TweenService"):Create(billboard, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffset = Vector3.new(0, 5, 0),
	}):Play()
	game:GetService("TweenService"):Create(text, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0.8,
	}):Play()
	
	task.delay(1, function()
		if billboard and billboard.Parent then billboard:Destroy() end
	end)
end

-- ═══════════════════════════════════════════
-- STATE (private)
-- ═══════════════════════════════════════════
local Combos: { [Player]: Types.ComboState } = {}
local Cooldowns: { [Player]: { [string]: number } } = {}
local Stuns: { [Player]: { untilTime: number, hitType: Types.HitType } } = {}
local Blocking: { [Player]: boolean } = {}
local AttackBuffers: { [Player]: boolean } = {}

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════

local function GetComboState(p: Player): Types.ComboState
	if not Combos[p] then Combos[p] = { count = 0, lastHitTime = 0 } end
	return Combos[p]
end

local function GetCooldownRemaining(p: Player, action: string): number
	local expiresAt = (Cooldowns[p] and Cooldowns[p][action]) or 0
	return math.max(expiresAt - os.clock(), 0)
end

local function IsOnCooldown(p: Player, action: string): boolean
	return GetCooldownRemaining(p, action) > 0
end

local function SetCooldown(p: Player, action: string, duration: number)
	if not Cooldowns[p] then Cooldowns[p] = {} end
	Cooldowns[p][action] = os.clock() + duration
end

local function IsStunned(p: Player): boolean
	local s = Stuns[p]
	return s and os.clock() < s.untilTime
end

local function ApplyStun(p: Player, duration: number, hitType: Types.HitType)
	Stuns[p] = { untilTime = os.clock() + duration, hitType = hitType }
	RemoteManager.FireClient(p, "StunApplied", duration, hitType)
end

local function GetHRP(chr: Model?): BasePart?
	return chr and chr:FindFirstChild("HumanoidRootPart")
end


-- ═══════════════════════════════════════════
-- DAMAGE PROCESSING
-- ═══════════════════════════════════════════

local function IsBackstab(aHRP: BasePart, vHRP: BasePart): boolean
	return (aHRP.Position - vHRP.Position).Unit:Dot(vHRP.CFrame.LookVector) > 0.3
end

local function IsAirborne(hrp: BasePart): boolean
	local h = hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
	return h and h.FloorMaterial == Enum.Material.Air
end

local function ProcessHit(attacker: Player, victimPlr: Player?, victimModel: Model?, comboCount: number, dmgMult: number?)
	local aHRP = GetHRP(attacker.Character)
	local vHRP = victimPlr and GetHRP(victimPlr.Character) or (victimModel and victimModel:FindFirstChild("HumanoidRootPart"))
	if not aHRP or not vHRP then return end

	local victim = victimPlr or victimModel :: Instance
	local comboIdx = Util.min(comboCount, Constants.COMBO_MAX)
	local skillMult = Constants.DAMAGE_PER_HIT[comboIdx] / 100

	local damage: number, hitType: Types.HitType = CombatData.CalculateDamage(attacker, victim, skillMult)

	-- Применяем множитель урона от оружия
	if dmgMult and dmgMult ~= 1.0 then
		damage = Util.floor(damage * dmgMult)
	end

	if victimPlr and Blocking[victimPlr] then
		local chip = Util.max(Util.min(damage * 0.05, damage), 1)
		local StatsService = require(game.ServerScriptService.Systems.StatsService)
		StatsService.DamageResource(victimPlr, "HP", chip)
		RemoteManager.FireClient(victimPlr, "DamageReceived", chip, "blocked", nil)
		return
	end

	if IsBackstab(aHRP, vHRP) then
		damage = Util.floor(damage * Constants.BACKSTAB_MULT)
		hitType = "crit"
	end
	if IsAirborne(vHRP) then
		damage = Util.floor(damage * Constants.AIR_DAMAGE_MULT)
	end

	if victimPlr then
		local StatsService = require(game.ServerScriptService.Systems.StatsService)
		StatsService.DamageResource(victimPlr, "HP", damage)
	else
		local vStats = victim:FindFirstChild("Stats")
		if vStats then
			local hp = vStats:FindFirstChild("HP")
			if hp then
				hp.Value = Util.max(hp.Value - damage, 0)
				if hp.Value <= 0 and victimModel then
					local nh = victimModel:FindFirstChildOfClass("Humanoid")
					if nh then nh.Health = 0 end
				end
			end
		end
	end

	if damage > 0 then
		CombatHelpers.AddEXP(attacker, Util.max(1, Util.floor(damage * 0.5)))
		local target = victimModel or (victimPlr and victimPlr.Character)
		if target then
			ShowDamage(target, damage, hitType == "crit")
		end
	end

	if victimPlr and victimPlr.Character then
		local StatsService = require(game.ServerScriptService.Systems.StatsService)
		local snapshot = StatsService.GetSnapshot(victimPlr)
		if snapshot.Resources.HP <= 0 then
			local nh = victimPlr.Character:FindFirstChildOfClass("Humanoid")
			if nh and nh.Health > 0 then nh.Health = 0 end
		end
	end

	local outcome = Constants.OUTCOMES[hitType] or Constants.OUTCOMES.hit
	if outcome.knockback and victimPlr then
		local kbDir = (vHRP.Position - aHRP.Position).Unit
		local kbForce = hitType == "crit" and Constants.CRITICAL_KB or Constants.BASE_KB
		if comboIdx == 4 then kbForce = Constants.CRITICAL_KB * 1.5 end

		local attachment = Instance.new("Attachment")
		attachment.Parent = vHRP
		local vf = Instance.new("VectorForce")
		vf.Force = Vector3.new(kbDir.X, 0, kbDir.Z) * kbForce * vHRP:GetMass()
		vf.Attachment0 = attachment
		vf.RelativeTo = Enum.ActuatorRelativeTo.World
		vf.Parent = vHRP
		local vfLift = Instance.new("VectorForce")
		vfLift.Force = Vector3.new(0, vHRP:GetMass() * workspace.Gravity * 0.4, 0)
		vfLift.Attachment0 = attachment
		vfLift.RelativeTo = Enum.ActuatorRelativeTo.World
		vfLift.Parent = vHRP
		Debris:AddItem(vf, 0.15)
		Debris:AddItem(vfLift, 0.15)
		Debris:AddItem(attachment, 0.15)
	end

	if outcome.stun and victimPlr then
		local dur = if hitType == "crit" then Constants.CRITICAL_STUN
			elseif comboIdx == 4 then Constants.KNOCKDOWN_STUN
			else Constants.HIT_STUN
		ApplyStun(victimPlr, dur, if hitType == "crit" then "critical" else "hit")
	end

	local targetModel = victimModel or (victimPlr and victimPlr.Character)
	RemoteManager.FireClient(attacker, "DamageReceived", damage, hitType, targetModel)
	if victimPlr and victimPlr ~= attacker then
		RemoteManager.FireClient(victimPlr, "DamageReceived", damage, hitType, nil)
	end

end

-- ═══════════════════════════════════════════
-- ACTION HANDLERS
-- ═══════════════════════════════════════════

local function GetWeaponConfig(plr: Player): CombatQuery.WeaponCombatConfig?
	local equipment = InventoryService.GetEquipment(plr)
	if not equipment.Weapon then return nil end
	local itemDef = ItemData.GetItem(equipment.Weapon)
	if not itemDef or not itemDef.CombatConfig then return nil end
	return itemDef.CombatConfig
end

local function HandleAttack(plr: Player)
	if IsStunned(plr) then
		AttackBuffers[plr] = nil
		return
	end

	local cooldownRemaining = GetCooldownRemaining(plr, "attack")
	if cooldownRemaining > 0 then
		if not AttackBuffers[plr] then
			AttackBuffers[plr] = true
			task.delay(cooldownRemaining, function()
				if not plr.Parent or not AttackBuffers[plr] then return end
				AttackBuffers[plr] = nil
				HandleAttack(plr)
			end)
		end
		return
	end

	AttackBuffers[plr] = nil
	local hrp = GetHRP(plr.Character)
	if not hrp then return end

	local combo = GetComboState(plr)
	if os.clock() - combo.lastHitTime > Constants.COMBO_TIMEOUT then combo.count = 0 end
	combo.count = (combo.count % Constants.COMBO_MAX) + 1
	combo.lastHitTime = os.clock()
	SetCooldown(plr, "attack", Constants.COMBO_COOLDOWN)

	RemoteManager.FireClient(plr, "ComboUpdated", combo.count)

	local weaponConfig = GetWeaponConfig(plr)
	local hitModels = CombatQuery.CastComboOnce(plr, combo.count, hrp, weaponConfig)

	-- Множитель урона от оружия
	local dmgMult = if weaponConfig and weaponConfig.DamageMult then weaponConfig.DamageMult else 1.0

	for _, model in hitModels do
		local victimPlr = Players:GetPlayerFromCharacter(model)
		if victimPlr and victimPlr ~= plr then
			ProcessHit(plr, victimPlr, nil, combo.count, dmgMult)
		elseif model:FindFirstChild("Stats") and model:FindFirstChildOfClass("Humanoid") then
			ProcessHit(plr, nil, model, combo.count, dmgMult)
		end
	end

	-- HitVFX: один раз за атаку, с задержкой для синхронизации с анимацией
	if #hitModels > 0 then
		local firstHit = hitModels[1]
		local vHRP = firstHit:FindFirstChild("HumanoidRootPart")
		if vHRP then
			local hitCFrame = vHRP.CFrame * CFrame.new(0, 0, 1.5)
			task.delay(Constants.HIT_VFX_DELAY or 0.2, function()
				RemoteManager.FireClient(plr, "HitVFX", hitCFrame)
			end)
		end
	end
end

local function HandleDash(plr: Player)
	if IsStunned(plr) or IsOnCooldown(plr, "dash") then return end
	local hrp = GetHRP(plr.Character)
	if not hrp then return end
	local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	SetCooldown(plr, "dash", Constants.DASH_COOLDOWN)
	local dir = hum.MoveDirection.Magnitude > 0.1 and hum.MoveDirection.Unit or hrp.CFrame.LookVector
	ApplyStun(plr, Constants.DASH_STUN, "dash_iframe")

	local attachment = Instance.new("Attachment")
	attachment.Parent = hrp
	local vf = Instance.new("VectorForce")
	vf.Force = dir * Constants.DASH_SPEED * hrp:GetMass()
	vf.Attachment0 = attachment
	vf.RelativeTo = Enum.ActuatorRelativeTo.World
	vf.Parent = hrp
	Debris:AddItem(vf, 0.15)
	Debris:AddItem(attachment, 0.15)
	
end

local function HandleBlockStart(plr: Player)
	if IsStunned(plr) then return end
	Blocking[plr] = true
end

local function HandleBlockEnd(plr: Player)
	Blocking[plr] = nil
end

-- ═══════════════════════════════════════════
-- REGEN LOOP
-- ═══════════════════════════════════════════

local function StartRegenLoop()
	task.spawn(function()
		while true do
			task.wait(Constants.HP_REGEN_INTERVAL)
			for _, p in Players:GetPlayers() do
				local StatsService = require(game.ServerScriptService.Systems.StatsService)
				local vit = StatsService.GetTotalBase(p, "VIT")
				local int = StatsService.GetTotalBase(p, "INT")
				
				StatsService.RestoreResource(p, "HP", Constants.HP_REGEN_AMOUNT)
				StatsService.RestoreResource(p, "MP", Constants.MP_REGEN_BASE + int * Constants.MP_REGEN_INT_MULT)
			end
		end
	end)
end

-- ═══════════════════════════════════════════
-- SERVICE LIFECYCLE
-- ═══════════════════════════════════════════

function CombatService:Start()
	RemoteManager.CreateEvent("HitVFX")

	RemoteManager.OnServerEvent("CombatAction", function(plr: Player, action: Types.CombatActionType)
		if not RemoteManager.CheckRateLimit(plr, "combat_" .. tostring(action), Constants.RATE_LIMIT_COMBAT) then return end

		if action == "attack" then HandleAttack(plr)
		elseif action == "dash" then HandleDash(plr)
		elseif action == "block_start" then HandleBlockStart(plr)
		elseif action == "block_end" then HandleBlockEnd(plr)
		end
	end)

	Players.PlayerRemoving:Connect(function(p: Player)
		Combos[p] = nil
		Cooldowns[p] = nil
		Stuns[p] = nil
		Blocking[p] = nil
		AttackBuffers[p] = nil
		RemoteManager.CleanupPlayer(p)
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function(char: Model)
			local stats = player:WaitForChild("Stats", 10)
			if not stats then return end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end

			local hp = stats:FindFirstChild("HP")
			local maxHP = stats:FindFirstChild("MaxHP")
			local mp = stats:FindFirstChild("MP")
			local maxMP = stats:FindFirstChild("MaxMP")

			if hp and maxHP then hp.Value = maxHP.Value end
			if mp and maxMP then mp.Value = maxMP.Value end

			humanoid.Died:Connect(function()
				if hp then hp.Value = 0 end
			end)

			if hp then
				hp.Changed:Connect(function(newValue: number)
					if newValue <= 0 and humanoid.Health > 0 then
						humanoid.Health = 0
					end
				end)
			end
		end)
	end)

	StartRegenLoop()
	Util.Log("CombatService", "Started")
end

return CombatService
