--!strict
-- CombatData
-- Формулы боя, настройки хитбоксов, расчёт урона

local CombatData = {}

-- ===== DAMAGE CALCULATION =====
-- Формула: (Attack × SkillMultiplier) × (100 / (100 + Defense)) × Crit × Multiplier
-- Всё считается на сервере — клиент никогда не trusts

-- attacker: Player (Stats лежит в player.Stats)
-- defender: Player | Model (Stats лежит в player.Stats или model.Stats для NPC)
function CombatData.CalculateDamage(attacker: Player, defender: Player | Model, skillMult: number): (number, string)
	local attackerStats = attacker:FindFirstChild("Stats")
	local defenderStats = defender:FindFirstChild("Stats")

	if not attackerStats or not defenderStats then
		return 1, "miss" -- минимальный урон если нет статов
	end

	-- Базовая атака
	local attack: number = (attackerStats:FindFirstChild("Attack") and attackerStats.Attack.Value) or 10
	local defense: number = (defenderStats:FindFirstChild("Defense") and defenderStats.Defense.Value) or 5

	-- Крит
	local critChance: number = (attackerStats:FindFirstChild("CritChance") and attackerStats.CritChance.Value) or 5
	local isCrit: boolean = math.random(1, 100) <= critChance
	local critMult: number = isCrit and ((attackerStats:FindFirstChild("CritDamage") and attackerStats.CritDamage.Value) or 150) / 100 or 1

	-- Основной урон
	local baseDmg = attack * (skillMult or 1)
	local dmg = baseDmg * (100 / (100 + defense)) * critMult

	return math.max(math.floor(dmg), 1), isCrit and "crit" or "hit"
end

-- ===== OUTCOMES =====
-- Что происходит при разном типе попадания

CombatData.OUTCOMES = {
	hit = { 
		stun = true, 
		knockback = true,
		comboReset = false,
	},
	crit = { 
		stun = true, 
		knockback = true,
		comboReset = false,
	},
	blocked = { 
		damage = 0.05,        -- 5% урона
		stun = false,
		knockback = false,
		postureDmg = 15,      -- Постура при блоке
	},
	dodged = { 
		damage = 0,
		stun = false,
		knockback = false,
	},
}

-- ===== STUN TYPES =====
-- Types of stun: "hit", "air", "critical", "knockdown", "aerial_land"
CombatData.STUN_TYPES = {
	hit = { duration = 0.25, name = "HitStun" },
	air = { duration = 0.45, name = "AirStun" },
	critical = { duration = 0.55, name = "HeavyStun" },
	knockdown = { duration = 1.0, name = "Knockdown" },
	aerial_land = { duration = 0.8, name = "LandStun" },
}

return CombatData
