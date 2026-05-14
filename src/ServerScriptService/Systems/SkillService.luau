--!strict
-- Services.SkillService — Серверная обработка скилов (рефакторинг)
-- luau-best-practices: Server Authority, Rate Limiting
-- luau-type-expert: полная типизация

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(ReplicatedStorage.Shared.Util)
local SkillData = require(ReplicatedStorage.Modules.SkillData)
local ClassData = require(ReplicatedStorage.Modules.ClassData)
local CombatHelpers = require(game.ServerStorage:WaitForChild("Data"):WaitForChild("CombatHelpers"))
local StatsHelper = require(ReplicatedStorage.Modules.StatsHelper)
local RemoteManager = require(ReplicatedStorage.Remotes.RemoteManager)
local CombatQuery = require(ReplicatedStorage.Modules.CombatQuery)

local SkillService = {}

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════
local SkillCooldowns: { [Player]: { [string]: number } } = {}
local PlayerBuffs: { [Player]: { Types.BuffEntry } } = {}

-- Class → skill mapping
local CLASS_SKILL_MAP: Types.SkillMapping = {}
for classId, class in pairs(ClassData.Classes) do
	CLASS_SKILL_MAP[classId] = {
		[2] = class.StartingSkills[1],
		[3] = class.StartingSkills[2],
		[4] = class.StartingSkills[3],
	}
end

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════

local function GetPlayerClass(player: Player): string
	if player.Character and player.Character:GetAttribute("ClassId") then
		return player.Character:GetAttribute("ClassId")
	end
	return player:GetAttribute("ClassId") or "maki_zenin"
end

local function GetSkillForSlot(player: Player, slotNum: number): string?
	local classId = GetPlayerClass(player)
	local mapping = CLASS_SKILL_MAP[classId]
	return mapping and mapping[slotNum]
end

local function CanUseSkill(player: Player, skillId: string): boolean
	local skill = SkillData.GetSkill(skillId)
	if not skill then return false end
	if SkillCooldowns[player] and SkillCooldowns[player][skillId] then
		if os.clock() < SkillCooldowns[player][skillId] then return false end
	end
	local s = player:FindFirstChild("Stats")
	if s then
		local mp = s:FindFirstChild("MP")
		if mp and mp.Value < skill.ManaCost then return false end
	end
	return true
end

local function SpendMP(player: Player, amount: number): boolean
	local s = player:FindFirstChild("Stats")
	if not s then return false end
	local mp = s:FindFirstChild("MP")
	if mp and mp.Value >= amount then
		mp.Value -= amount
		return true
	end
	return false
end


-- ═══════════════════════════════════════════
-- SKILL EXECUTORS
-- ═══════════════════════════════════════════

local function CalcSkillDamage(attacker: Player, target: Model | Player, skill: Types.SkillDefinition): number
	local s = attacker:FindFirstChild("Stats")
	local attack = 10
	local mpVal = 5
	if s then
		attack = (s:FindFirstChild("Attack") and s.Attack.Value) or 10
		mpVal = (s:FindFirstChild("MagicPower") and s.MagicPower.Value) or 5
	end

	local def = 5
	local tStats = target:IsA("Player") and Util.GetStatsFolder(target) or target:FindFirstChild("Stats")
	if tStats then
		local d = tStats:FindFirstChild("Defense")
		if d then def = d.Value end
	end

	local base = attack + (mpVal * (skill.MagicPowerMult or 0))
	return Util.max(Util.floor(base * (100 / (100 + def))), 1)
end

local function ExecMelee(player: Player, skill: Types.SkillDefinition)
	local hrp = Util.GetHRP(player.Character)
	if not hrp then return end

	local hitModels = CombatQuery.CastOnce(player, {
		originPart = hrp,
		mode = "Box",
		range = skill.Range or 10,
		depth = skill.Range or 10,
		width = 7,
		height = 5,
		allowMultipleHits = false,
	})

	for _, model in hitModels do
		if model ~= player.Character and Util.GetTargetStats(model) then
			local dmg = CalcSkillDamage(player, model, skill)
			if skill.BackstabMult then dmg = Util.floor(dmg * skill.BackstabMult) end
			CombatHelpers.ApplyDamage(player, dmg, model)
			RemoteManager.FireClient(player, "DamageReceived", dmg, "skill", model)
		end
	end
end

local function ExecRanged(player: Player, skill: Types.SkillDefinition)
	local hrp = Util.GetHRP(player.Character)
	if not hrp then return end

	local hitModels = CombatQuery.CastOnce(player, {
		originPart = hrp,
		mode = "Ray",
		range = skill.Range or 40,
		allowMultipleHits = not not skill.Pierce,
	})

	for _, model in hitModels do
		if model ~= player.Character and Util.GetTargetStats(model) then
			local dmg = CalcSkillDamage(player, model, skill)
			CombatHelpers.ApplyDamage(player, dmg, model)
			RemoteManager.FireClient(player, "DamageReceived", dmg, "skill", model)
			if not skill.Pierce then break end
		end
	end
end

local function ExecBuff(player: Player, skill: Types.SkillDefinition)
	if skill.BuffStat and skill.BuffMult then
		if not PlayerBuffs[player] then PlayerBuffs[player] = {} end
		local s = player:FindFirstChild("Stats")
		local baseSnapshot: { [string]: number }? = nil
		if s then
			baseSnapshot = {
				STR = (s:FindFirstChild("STR") and s.STR.Value) or 5,
				AGI = (s:FindFirstChild("AGI") and s.AGI.Value) or 5,
				INT = (s:FindFirstChild("INT") and s.INT.Value) or 5,
				VIT = (s:FindFirstChild("VIT") and s.VIT.Value) or 5,
				LUK = (s:FindFirstChild("LUK") and s.LUK.Value) or 5,
			}
			local atk = s:FindFirstChild(skill.BuffStat)
			if atk then atk.Value = atk.Value * skill.BuffMult end
		end
		table.insert(PlayerBuffs[player], {
			stat = skill.BuffStat,
			mult = skill.BuffMult,
			endTime = os.clock() + skill.BuffDuration,
			baseSnapshot = baseSnapshot,
		})
		RemoteManager.FireClient(player, "UpdateStatsUI")
	end

	if skill.InvisDuration and player.Character then
		for _, c in player.Character:GetDescendants() do
			if c:IsA("BasePart") then c.Transparency = 1
			elseif c:IsA("Decal") or c:IsA("Texture") then c.Transparency = 1 end
		end
		task.delay(skill.InvisDuration, function()
			if player.Character then
				for _, c in player.Character:GetDescendants() do
					if c:IsA("BasePart") then c.Transparency = 0
					elseif c:IsA("Decal") or c:IsA("Texture") then c.Transparency = 0 end
				end
			end
		end)
	end
end

-- ═══════════════════════════════════════════
-- BUFF TICKER
-- ═══════════════════════════════════════════

local function StartBuffTicker()
	task.spawn(function()
		while true do
			task.wait(1)
			for p, buffs in PlayerBuffs do
				local s = p:FindFirstChild("Stats")
				if not s then continue end
				for i = #buffs, 1, -1 do
					if os.clock() >= buffs[i].endTime then
						local buff = table.remove(buffs, i)
						if buff.baseSnapshot then
							for statName, statValue in buff.baseSnapshot do
								local sv = s:FindFirstChild(statName)
								if sv then sv.Value = statValue end
							end
						end
						StatsHelper.RecalculateDerivedStats(p)
						RemoteManager.FireClient(p, "UpdateStatsUI")
					end
				end
			end
		end
	end)
end

-- ═══════════════════════════════════════════
-- SERVICE LIFECYCLE
-- ═══════════════════════════════════════════

function SkillService:Start()
	RemoteManager.OnServerEvent("SkillCast", function(player: Player, slotNum: number)
		if not RemoteManager.CheckRateLimit(player, "skill_cast", Constants.RATE_LIMIT_SKILL) then return end
		if typeof(slotNum) ~= "number" or slotNum < 2 or slotNum > 4 then return end

		local skillId = GetSkillForSlot(player, slotNum)
		if not skillId then return end

		local skill = SkillData.GetSkill(skillId)
		if not skill then return end

		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		if not CanUseSkill(player, skillId) then return end
		if not SpendMP(player, skill.ManaCost) then return end

		if not SkillCooldowns[player] then SkillCooldowns[player] = {} end
		SkillCooldowns[player][skillId] = os.clock() + skill.Cooldown
		RemoteManager.FireClient(player, "SkillCooldown", slotNum, skill.Cooldown)

		if skill.Type == "ranged" then ExecRanged(player, skill)
		elseif skill.Type == "melee" then ExecMelee(player, skill)
		elseif skill.Type == "buff" or skill.Type == "utility" then ExecBuff(player, skill)
		end
	end)

	Players.PlayerRemoving:Connect(function(p: Player)
		SkillCooldowns[p] = nil
		PlayerBuffs[p] = nil
		RemoteManager.CleanupPlayer(p)
	end)

	StartBuffTicker()
	Util.Log("SkillService", "Started")
end

return SkillService
