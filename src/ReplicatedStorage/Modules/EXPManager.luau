--!strict
-- EXPManager — единый модуль для расчёта EXP и левел-апа
-- Используется: LevelManager, CombatHelpers, SpawnManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local StatsHelper = require(ReplicatedStorage.Modules.StatsHelper)

local EXPManager = {}

local STAT_POINTS_PER_LEVEL = 3
local SKILL_POINTS_PER_LEVEL = 1

-- RemoteEvents
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local LevelUpEvent = Remotes:WaitForChild("LevelUpEvent")

-- Добавить EXP игроку. Возвращает true если был level up
function EXPManager.AddEXP(player: Player, amount: number)
	local StatsService = require(game.ServerScriptService.Systems.StatsService)
	return StatsService.AddEXP(player, amount)
end

return EXPManager
