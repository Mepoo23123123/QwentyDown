--!strict
-- 「Колесо Статов」— StatsHelper v2.0
-- Единый модуль для работы со статами игрока
-- luau-best-practices: Strict mode, typed API

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)

local StatsHelper = {}

-- ═══════════════════════════════════════════
-- TYPES
-- ═══════════════════════════════════════════

export type BaseStats = {
	STR: number,
	AGI: number,
	INT: number,
	VIT: number,
	LUK: number,
}

export type DerivedStats = {
	MaxHP: number,
	MaxMP: number,
	Attack: number,
	MagicPower: number,
	Defense: number,
	Speed: number,
	CritChance: number,
	CritDamage: number,
	DodgeChance: number,
	LuckBonus: number,
}

-- ═══════════════════════════════════════════
-- CONSTANTS
-- ═══════════════════════════════════════════

local BASE_STAT_NAMES: {string} = {"STR", "AGI", "INT", "VIT", "LUK"}

local DEFAULT_BASE_STATS: BaseStats = {
	STR = 5,
	AGI = 5,
	INT = 5,
	VIT = 5,
	LUK = 5,
}

local DEFAULT_EQUIP_BONUSES: BaseStats = {
	STR = 0,
	AGI = 0,
	INT = 0,
	VIT = 0,
	LUK = 0,
}

-- ═══════════════════════════════════════════
-- PRIVATE STATE
-- ═══════════════════════════════════════════

local _equipmentBonuses: { [Player]: BaseStats } = {}

-- ═══════════════════════════════════════════
-- PRIVATE HELPERS
-- ═══════════════════════════════════════════

local function _getStatsFolder(player: Player): Folder?
	return player:FindFirstChild("Stats")
end

local function _createStatsFolder(player: Player): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Stats"
	folder.Parent = player
	
	-- Create base stats
	for _, name in BASE_STAT_NAMES do
		local v = Instance.new("NumberValue")
		v.Name = name
		v.Value = DEFAULT_BASE_STATS[name]
		v.Parent = folder
	end
	
	-- Create derived stats placeholders
	local derivedNames = {"MaxHP", "MaxMP", "Attack", "MagicPower", "Defense", "Speed", "CritChance", "CritDamage", "DodgeChance", "LuckBonus", "HP", "MP", "StatPoints", "Level", "XP"}
	for _, name in derivedNames do
		local v = Instance.new("NumberValue")
		v.Name = name
		v.Value = 0
		v.Parent = folder
	end
	
	return folder
end

-- ═══════════════════════════════════════════
-- PUBLIC API — BASE STATS
-- ═══════════════════════════════════════════

--- Получить папку Stats (создаст если не существует)
function StatsHelper.GetStatsFolder(player: Player): Folder
	local folder = _getStatsFolder(player)
	if not folder then
		folder = _createStatsFolder(player)
	end
	return folder
end

--- Считать базовые статы из папки игрока
function StatsHelper.ReadBaseStats(player: Player): BaseStats
	local stats = _getStatsFolder(player)
	if not stats then return table.clone(DEFAULT_BASE_STATS) :: BaseStats end
	
	local result: BaseStats = table.clone(DEFAULT_BASE_STATS) :: BaseStats
	for _, name in BASE_STAT_NAMES do
		local sv = stats:FindFirstChild(name)
		if sv and sv:IsA("NumberValue") then
			result[name] = sv.Value
		end
	end
	return result
end

--- Записать базовые статы в папку игрока
function StatsHelper.WriteBaseStats(player: Player, baseStats: BaseStats)
	local stats = StatsHelper.GetStatsFolder(player)
	for _, name in BASE_STAT_NAMES do
		local sv = stats:FindFirstChild(name)
		if not sv then
			sv = Instance.new("NumberValue")
			sv.Name = name
			sv.Parent = stats
		end
		if sv:IsA("NumberValue") then
			sv.Value = baseStats[name] or DEFAULT_BASE_STATS[name]
		end
	end
end

-- ═══════════════════════════════════════════
-- PUBLIC API — EQUIPMENT BONUSES
-- ═══════════════════════════════════════════

function StatsHelper.SetEquipmentBonuses(player: Player, bonuses: BaseStats)
	_equipmentBonuses[player] = {
		STR = bonuses.STR or 0,
		AGI = bonuses.AGI or 0,
		INT = bonuses.INT or 0,
		VIT = bonuses.VIT or 0,
		LUK = bonuses.LUK or 0,
	}
end

function StatsHelper.GetEquipmentBonuses(player: Player): BaseStats
	local bonuses = _equipmentBonuses[player]
	if bonuses then
		return table.clone(bonuses) :: BaseStats
	end
	return table.clone(DEFAULT_EQUIP_BONUSES) :: BaseStats
end

function StatsHelper.ClearEquipmentBonuses(player: Player)
	_equipmentBonuses[player] = nil
end

-- ═══════════════════════════════════════════
-- PUBLIC API — TOTAL & DERIVED
-- ═══════════════════════════════════════════

--- Базовые + бонусы экипировки
function StatsHelper.ReadTotalBaseStats(player: Player): BaseStats
	local base = StatsHelper.ReadBaseStats(player)
	local equip = StatsHelper.GetEquipmentBonuses(player)
	return {
		STR = base.STR + equip.STR,
		AGI = base.AGI + equip.AGI,
		INT = base.INT + equip.INT,
		VIT = base.VIT + equip.VIT,
		LUK = base.LUK + equip.LUK,
	}
end

--- Пересчитать производные статы от итоговых базовых
function StatsHelper.RecalculateDerivedStats(player: Player)
	local totalBase = StatsHelper.ReadTotalBaseStats(player)
	local derived: DerivedStats = PlayerProfile.CalculateDerivedStats(totalBase)
	local stats = StatsHelper.GetStatsFolder(player)
	
	for name: string, value: number in derived do
		local sv = stats:FindFirstChild(name)
		if sv and sv:IsA("NumberValue") then
			sv.Value = value
		else
			local v = Instance.new("NumberValue")
			v.Name = name
			v.Value = value
			v.Parent = stats
		end
	end
end

--- Получить текущее значение конкретного стата (base + equip)
function StatsHelper.GetStatValue(player: Player, statName: string): number
	local base = StatsHelper.ReadBaseStats(player)
	local equip = StatsHelper.GetEquipmentBonuses(player)
	return (base[statName] or 0) + (equip[statName] or 0)
end

--- Получить текущее значение производного стата
function StatsHelper.GetDerivedValue(player: Player, derivedName: string): number
	local stats = _getStatsFolder(player)
	if not stats then return 0 end
	local sv = stats:FindFirstChild(derivedName)
	return (sv and sv:IsA("NumberValue")) and sv.Value or 0
end

return StatsHelper
