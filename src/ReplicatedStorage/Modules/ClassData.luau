--!strict
-- ClassData ModuleScript
-- Данные всех классов: стартовые статы, описания, уникальные скилы

local ClassData = {}

-- 4 базовых класса в стиле аниме RPG
ClassData.Classes = {
	maki_zenin = {
		Id = "maki_zenin",
		Name = "Maki Zenin",
		NameRu = "Маки Дзенин",
		Description = "Мастер ближнего боя и проклятого оружия. Огромная физическая сила и скорость. Не обладает проклятой энергией, но компенсирует это небесным проклятием.",
		IconId = 0, -- Вставь ID иконки потом
		StartingStats = {
			STR = 8,
			AGI = 5,
			INT = 3,
			VIT = 7,
			LUK = 2,
		},
		StartingSkills = {
			"slash",       -- Базовый удар мечом
			"power_strike", -- Усиленный удар
			"war_cry",      -- Бафф атаки
		},
		StatGrowthPerLevel = {
			STR = 1.8,
			AGI = 0.8,
			INT = 0.3,
			VIT = 1.5,
			LUK = 0.4,
		},
	},
	mage = {
		Id = "mage",
		Name = "Mage",
		NameRu = "Маг",
		Description = "Повелитель стихий. Огромный магический урон, но хрупкий. Стиль: Gojo (JJK) или Aizen (Bleach).",
		IconId = 0,
		StartingStats = {
			STR = 2,
			AGI = 4,
			INT = 9,
			VIT = 4,
			LUK = 3,
		},
		StartingSkills = {
			"fireball",     -- Огненный шар
			"ice_lance",    -- Ледяное копьё
			"mana_shield",  -- Щит из маны
		},
		StatGrowthPerLevel = {
			STR = 0.2,
			AGI = 0.6,
			INT = 2.0,
			VIT = 0.8,
			LUK = 0.5,
		},
	},
	ranger = {
		Id = "ranger",
		Name = "Ranger",
		NameRu = "Стрелок",
		Description = "Мастер дальнего боя. Высокая точность и крит. Стиль: Usopp (One Piece) или Нежи (Naruto).",
		IconId = 0,
		StartingStats = {
			STR = 5,
			AGI = 8,
			INT = 4,
			VIT = 4,
			LUK = 5,
		},
		StartingSkills = {
			"quick_shot",    -- Быстрый выстрел
			"snipe",         -- Мощный точный выстрел
			"trap",          -- Ловушка
		},
		StatGrowthPerLevel = {
			STR = 0.8,
			AGI = 1.8,
			INT = 0.5,
			VIT = 0.6,
			LUK = 1.2,
		},
	},
	assassin = {
		Id = "assassin",
		Name = "Assassin",
		NameRu = "Ассасин",
		Description = "Скрытный убийца. Высокая скорость, крит и уклонение. Стиль: Itachi (Naruto) или Toji (JJK).",
		IconId = 0,
		StartingStats = {
			STR = 6,
			AGI = 9,
			INT = 3,
			VIT = 3,
			LUK = 6,
		},
		StartingSkills = {
			"shadow_step",   -- Телепорт за спину
			"backstab",      -- Удар в спину (x3 урон)
			"smoke_bomb",    -- Дымовая бомба (невидимость)
		},
		StatGrowthPerLevel = {
			STR = 1.2,
			AGI = 2.0,
			INT = 0.2,
			VIT = 0.4,
			LUK = 1.3,
		},
	},
}

-- Получить данные класса по ID
function ClassData.GetClass(classId)
	return ClassData.Classes[classId]
end

-- Получить список всех доступных классов
function ClassData.GetAllClasses()
	local list = {}
	for id, data in ClassData.Classes do
		table.insert(list, {
			Id = data.Id,
			Name = data.Name,
			NameRu = data.NameRu,
			Description = data.Description,
		})
	end
	return list
end

-- Расчёт статов на уровне (стартовые статы + рост за уровни)
function ClassData.CalculateStatsAtLevel(classId, level)
	local class = ClassData.GetClass(classId)
	if not class then return nil end

	local stats = {}
	for statName, baseValue in class.StartingStats do
		local growth = class.StatGrowthPerLevel[statName] or 0.5
		stats[statName] = math.floor(baseValue + growth * (level - 1))
	end
	return stats
end

-- Применить класс игроку (установить стартовые статы)
function ClassData.ApplyClass(player, classId)
	local class = ClassData.GetClass(classId)
	if not class then
		warn("[ClassData] Unknown class: " .. tostring(classId))
		return false
	end

	local stats = player:FindFirstChild("Stats")
	if not stats then return false end

	for statName, value in class.StartingStats do
		local stat = stats:FindFirstChild(statName)
		if stat then
			stat.Value = value
		end
	end

	return true
end

return ClassData
