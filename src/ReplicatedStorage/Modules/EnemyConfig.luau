--!strict

local EnemyConfig = {}

export type EnemyTier = "swarm" | "fighter" | "guardian" | "brute"
export type EnemyId = "HollowMite" | "ForestGnawer" | "RuinSentinel" | "RiftOgre"

export type EnemyVisual = {
	BodyColor: Color3,
	AccentColor: Color3,
	Size: Vector3,
}

export type EnemyAnimations = {
	Idle: string?,
	Walk: string?,
	Attack: string?,
}

export type EnemyDefinition = {
	Id: EnemyId,
	DisplayName: string,
	Tier: EnemyTier,
	MaxHealth: number,
	Damage: number,
	Defense: number,
	MoveSpeed: number,
	AggroRange: number,
	AttackRange: number,
	AttackCooldown: number,
	LeashRange: number,
	RewardEXP: number,
	RewardGold: number,
	LootTableId: string,
	ModelName: string?,
	Animations: EnemyAnimations?,
	Visual: EnemyVisual,
}

export type SpawnZone = {
	Id: string,
	DisplayName: string,
	EnemyPool: { EnemyId },
	MaxAlive: number,
	RespawnSeconds: number,
	SpawnPoints: { Vector3 },
}

EnemyConfig.Enemies = {
	HollowMite = {
		Id = "HollowMite",
		DisplayName = "Пустотный клещ",
		Tier = "swarm",
		MaxHealth = 70,
		Damage = 5,
		Defense = 2,
		MoveSpeed = 11,
		AggroRange = 28,
		AttackRange = 4,
		AttackCooldown = 1.0,
		LeashRange = 55,
		RewardEXP = 14,
		RewardGold = 3,
		LootTableId = "Scout",
		ModelName = "Enememe",
		Visual = {
			BodyColor = Color3.fromRGB(88, 42, 112),
			AccentColor = Color3.fromRGB(195, 90, 255),
			Size = Vector3.new(2.5, 2.2, 2.5),
		},
	},
	ForestGnawer = {
		Id = "ForestGnawer",
		DisplayName = "Лесной грызун",
		Tier = "fighter",
		MaxHealth = 135,
		Damage = 9,
		Defense = 6,
		MoveSpeed = 9,
		AggroRange = 24,
		AttackRange = 4.5,
		AttackCooldown = 1.35,
		LeashRange = 50,
		RewardEXP = 26,
		RewardGold = 6,
		LootTableId = "Goblin",
		ModelName = "Goblin",
		Animations = {
			Idle = "rbxassetid://136302782152847",
			Walk = "rbxassetid://97282791010732",
			Attack = "rbxassetid://91032539899464",
		},
		Visual = {
			BodyColor = Color3.fromRGB(54, 105, 58),
			AccentColor = Color3.fromRGB(132, 209, 92),
			Size = Vector3.new(3.1, 3.6, 3.1),
		},
	},
	RuinSentinel = {
		Id = "RuinSentinel",
		DisplayName = "Страж руин",
		Tier = "guardian",
		MaxHealth = 260,
		Damage = 15,
		Defense = 16,
		MoveSpeed = 7,
		AggroRange = 22,
		AttackRange = 5,
		AttackCooldown = 1.9,
		LeashRange = 48,
		RewardEXP = 58,
		RewardGold = 14,
		LootTableId = "Knight",
		ModelName = "AnoterhEnemy",
		Visual = {
			BodyColor = Color3.fromRGB(92, 94, 104),
			AccentColor = Color3.fromRGB(120, 170, 255),
			Size = Vector3.new(3.4, 4.6, 3.4),
		},
	},
	RiftOgre = {
		Id = "RiftOgre",
		DisplayName = "Разломный огр",
		Tier = "brute",
		MaxHealth = 460,
		Damage = 23,
		Defense = 20,
		MoveSpeed = 6,
		AggroRange = 26,
		AttackRange = 6,
		AttackCooldown = 2.4,
		LeashRange = 60,
		RewardEXP = 145,
		RewardGold = 38,
		LootTableId = "MiniBoss",
		ModelName = "AnoterhEnemy",
		Visual = {
			BodyColor = Color3.fromRGB(104, 55, 43),
			AccentColor = Color3.fromRGB(255, 118, 65),
			Size = Vector3.new(4.3, 5.6, 4.3),
		},
	},
}

EnemyConfig.Zones = {
	graveyard_edge = {
		Id = "graveyard_edge",
		DisplayName = "Край кладбища",
		EnemyPool = { "HollowMite" },
		MaxAlive = 2,
		RespawnSeconds = 9,
		SpawnPoints = {
			Vector3.new(-13, 1, 86.9),
			Vector3.new(-8, 1, 96.3),
			Vector3.new(-2, 1, 88),
		},
	},
	forest_wound = {
		Id = "forest_wound",
		DisplayName = "Рана леса",
		EnemyPool = { "ForestGnawer" },
		MaxAlive = 3,
		RespawnSeconds = 12,
		SpawnPoints = {
			Vector3.new(67.5, 1, 9.1),
			Vector3.new(67.5, 1, 16.1),
			Vector3.new(74.5, 1, 10.1),
		},
	},
	rift_ruins = {
		Id = "rift_ruins",
		DisplayName = "Руины разлома",
		EnemyPool = { "RuinSentinel", "RiftOgre" },
		MaxAlive = 2,
		RespawnSeconds = 18,
		SpawnPoints = {
			Vector3.new(72, 1, -72),
			Vector3.new(75, 1, -79),
			Vector3.new(66, 1, -83),
		},
	},
}

function EnemyConfig.GetEnemy(id: string): EnemyDefinition?
	return EnemyConfig.Enemies[id]
end

function EnemyConfig.GetZone(id: string): SpawnZone?
	return EnemyConfig.Zones[id]
end

function EnemyConfig.GetZoneIds(): { string }
	local zoneIds = {}
	for zoneId in EnemyConfig.Zones do
		table.insert(zoneIds, zoneId)
	end
	return zoneIds
end

function EnemyConfig.GetRandomEnemyId(zone: SpawnZone): EnemyId?
	if #zone.EnemyPool == 0 then return nil end
	return zone.EnemyPool[math.random(1, #zone.EnemyPool)]
end

return EnemyConfig
