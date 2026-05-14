--!strict
-- SkillData Module
-- Данные всех скилов: cooldown, mana cost, урон, анимация, описание

local SkillData = {}

SkillData.Skills = {
	-- ===== MAKI ZENIN =====
	slash = {
		Id = "slash",
		Name = "Slash",
		NameRu = "Рубящий удар",
		Class = "maki_zenin",
		Slot = 2,        -- Action Bar slot (Z key)
		Type = "melee",   -- melee/ranged/buff/utility
		Damage = 0,       -- Множитель: 0 = комбо-урон от класса
		MagicPowerMult = 0,
		ManaCost = 5,
		Cooldown = 1.5,
		Range = 8,        -- studs
		Description = "Мощный круговой удар мечом",
		SoundId = 0,
		IconId = "rbxassetid://75954734479098",
		AnimationId = 122867841506821, -- Warrior Slash
	},
	power_strike = {
		Id = "power_strike",
		Name = "Power Strike",
		NameRu = "Сокрушающий удар",
		Class = "maki_zenin",
		Slot = 3,        -- X key
		Type = "melee",
		Damage = 0,
		MagicPowerMult = 0,
		ManaCost = 15,
		Cooldown = 4,
		Range = 10,
		Description = "Отбрасывает врагов назад с огромной силой",
		KnockbackForce = 40,
		SoundId = 0,
		IconId = "rbxassetid://113841965670925",
		VFXTemplateName = "StompMaki2Skill",
		VFXMarkerName = "Stomp",
		AnimationId = 79101954667424,
	},
	war_cry = {
		Id = "war_cry",
		Name = "War Cry",
		NameRu = "Боевой клич",
		Class = "maki_zenin",
		Slot = 4,        -- C key
		Type = "buff",
		Damage = 0,
		MagicPowerMult = 0,
		ManaCost = 20,
		Cooldown = 15,
		Range = 0,
		Description = "Увеличивает Attack на 50% на 8 секунд",
		BuffDuration = 8,
		BuffStat = "Attack",
		BuffMult = 1.5,
		SoundId = 0,
		IconId = "rbxassetid://101440889530876",
		AnimationId = 0,
	},

	-- ===== MAGE =====
	fireball = {
		Id = "fireball",
		Name = "Fireball",
		NameRu = "Огненный шар",
		Class = "mage",
		Slot = 2,
		Type = "ranged",
		Damage = 0,
		MagicPowerMult = 1.5,
		ManaCost = 15,
		Cooldown = 2,
		Range = 40,
		Description = "Огненный снаряд, летящий вперёд",
		ProjectileSpeed = 80,
		SoundId = 0,
		AnimationId = 0,
	},
	ice_lance = {
		Id = "ice_lance",
		Name = "Ice Lance",
		NameRu = "Ледяное копьё",
		Class = "mage",
		Slot = 3,
		Type = "ranged",
		Damage = 0,
		MagicPowerMult = 2.0,
		ManaCost = 25,
		Cooldown = 5,
		Range = 50,
		Description = "Ледяной снаряд, замораживает цель на 2 сек",
		ProjectileSpeed = 100,
		FreezeDuration = 2,
		SoundId = 0,
		AnimationId = 0,
	},
	mana_shield = {
		Id = "mana_shield",
		Name = "Mana Shield",
		NameRu = "Щит маны",
		Class = "mage",
		Slot = 4,
		Type = "buff",
		Damage = 0,
		MagicPowerMult = 0,
		ManaCost = 30,
		Cooldown = 12,
		Range = 0,
		Description = "Поглощает 50% входящего урона из MP на 6 секунд",
		BuffDuration = 6,
		ShieldPercent = 0.5,
		SoundId = 0,
		AnimationId = 0,
	},

	-- ===== RANGER =====
	quick_shot = {
		Id = "quick_shot",
		Name = "Quick Shot",
		NameRu = "Быстрый выстрел",
		Class = "ranger",
		Slot = 2,
		Type = "ranged",
		Damage = 0,
		MagicPowerMult = 1.0,
		ManaCost = 5,
		Cooldown = 1,
		Range = 60,
		Description = "Быстрый точный выстрел",
		ProjectileSpeed = 150,
		HighCrit = 20,          -- +20% шанс крита
		SoundId = 0,
		AnimationId = 0,
	},
	snipe = {
		Id = "snipe",
		Name = "Snipe",
		NameRu = "Снайперский выстрел",
		Class = "ranger",
		Slot = 3,
		Type = "ranged",
		Damage = 0,
		MagicPowerMult = 2.5,
		ManaCost = 20,
		Cooldown = 6,
		Range = 100,
		Description = "Мощный выстрел, пробивает сквозь врагов",
		ProjectileSpeed = 200,
		Pierce = true,
		SoundId = 0,
		AnimationId = 0,
	},
	trap = {
		Id = "trap",
		Name = "Trap",
		NameRu = "Ловушка",
		Class = "ranger",
		Slot = 4,
		Type = "utility",
		Damage = 0,
		MagicPowerMult = 1.5,
		ManaCost = 15,
		Cooldown = 10,
		Range = 15,
		Description = "Размещает ловушку, оглушает врагов на 2 сек",
		TrapDuration = 10,
		StunDuration = 2,
		SoundId = 0,
		AnimationId = 0,
	},

	-- ===== ASSASSIN =====
	shadow_step = {
		Id = "shadow_step",
		Name = "Shadow Step",
		NameRu = "Теневой шаг",
		Class = "assassin",
		Slot = 2,
		Type = "utility",
		Damage = 0,
		MagicPowerMult = 0,
		ManaCost = 20,
		Cooldown = 5,
		Range = 20,
		Description = "Телепорт за спину ближайшему врагу + удар",
		ShadowDamage = 0,
		ShadowAttackMult = 2.0,
		SoundId = 0,
		AnimationId = 126686960254136,
	},
	backstab = {
		Id = "backstab",
		Name = "Backstab",
		NameRu = "Удар в спину",
		Class = "assassin",
		Slot = 3,
		Type = "melee",
		Damage = 0,
		MagicPowerMult = 0,
		ManaCost = 15,
		Cooldown = 4,
		Range = 6,
		Description = "Удар за спиной с x3 уроном",
		BackstabMult = 3.0,
		SoundId = 0,
		AnimationId = 0,
	},
	smoke_bomb = {
		Id = "smoke_bomb",
		Name = "Smoke Bomb",
		NameRu = "Дымовая бомба",
		Class = "assassin",
		Slot = 4,
		Type = "utility",
		Damage = 0,
		MagicPowerMult = 0,
		ManaCost = 25,
		Cooldown = 15,
		Range = 0,
		Description = "Становишься невидимым на 4 секунды",
		InvisDuration = 4,
		SoundId = 0,
		AnimationId = 0,
	},
}

-- Получить скилл по ID
function SkillData.GetSkill(skillId)
	return SkillData.Skills[skillId]
end

-- Получить все скилы класса
function SkillData.GetClassSkills(classId)
	local skills = {}
	for id, skill in SkillData.Skills do
		if skill.Class == classId then
			table.insert(skills, skill)
		end
	end
	return skills
end

return SkillData
