--!strict
-- PlayerProfile ModuleScript
-- Шаблон структуры данных игрока

local PlayerProfile = {}

-- Базовые статы персонажа
local BASE_STATS = {
	STR = 5,     -- Сила (физический урон)
	AGI = 5,     -- Ловкость (скорость, крит, уклонение)
	INT = 5,     -- Интеллект (магический урон, макс. MP)
	VIT = 5,     -- Выносливость (макс. HP, реген)
	LUK = 5,     -- Удача (шанс крита, дроп)
}

-- Формулы расчёта боевых характеристик от статов
function PlayerProfile.CalculateDerivedStats(stats: { [string]: number }): { [string]: number }
	return {
		MaxHP       = 100 + (stats.VIT * 15),
		MaxMP       = 50  + (stats.INT * 10),
		Attack      = 10  + (stats.STR * 3),
		MagicPower  = 5   + (stats.INT * 4),
		Defense     = 5   + (stats.VIT * 2),
		Speed       = 16  + (stats.AGI * 0.5),
		CritChance  = math.min(50, 2 + stats.LUK * 0.8 + stats.AGI * 0.3),   -- %
		CritDamage  = 150 + (stats.STR * 2 + stats.LUK * 1),                  -- %
		DodgeChance = math.min(40, stats.AGI * 1.2 + stats.LUK * 0.5),       -- %
		LuckBonus   = 1 + stats.LUK * 0.02,                                  -- множитель дропа
	}
end

-- Создаёт новый профиль игрока (для нового аккаунта)
function PlayerProfile.CreateNew(classId)
	return {
		-- Аккаунт
		PlayerId = 0,              -- Заполняется при входе
		ClassId = classId or "maki_zenin",  -- Текущий класс
		OriginClanId = "Zenin",
		OriginCharacterId = "zenin_naobito",
		ClassUnlocks = {"maki_zenin"},    -- Разблокированные классы

		-- Прокачка
		Level = 1,
		EXP = 0,
		StatPoints = 0,           -- Нераспределённые очки статов

		-- Статы
		Stats = table.clone(BASE_STATS),

		-- Ресурсы (восстанавливаются)
		HP = nil,       -- Заполняется при входе из MaxHP
		MP = nil,       -- Заполняется при входе из MaxMP
		Gold = 100,     -- Валюта

		-- Скилы (разблокированные + уровни)
		Skills = {},       -- { [skillId] = level }
		SkillPoints = 1,   -- Очки для прокачки скилов

		-- Инвентарь
		Inventory = {},    -- { [itemId] = quantity }
		Equipment = {
			Weapon = nil,
			Armor  = nil,
			Accessory = nil,
		},
		InventorySlots = 30, -- Макс слотов

		-- Прогресс мира
		CurrentZone = 1,
		ZonesUnlocked = {1},
		BossesDefeated = {},      -- ID побеждённых боссов

		-- Статистика
		TotalPlayTime = 0,
		EnemiesDefeated = 0,
		BossesDefeatedTotal = 0,
		Deaths = 0,

		-- Настройки
		Settings = {
			MusicVolume = 0.5,
			SFXVolume = 0.7,
			CameraShake = true,
		},
	}
end

-- Вычисляет сколько EXP нужно для следующего уровня
function PlayerProfile.EXPRequired(level)
	-- Формула: базовый EXP * (уровень ^ 1.4), постепенно растёт
	return math.floor(100 * (level ^ 1.4) + 50 * level)
end

return PlayerProfile
