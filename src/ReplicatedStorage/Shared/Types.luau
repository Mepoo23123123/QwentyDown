--!strict
-- Shared.Types — Единый источник всех типов проекта
-- luau-type-expert: export type, generics, union types, function types

local Types = {}

-- ═══════════════════════════════════════════
-- RESULT PATTERN (Error Handling)
-- ═══════════════════════════════════════════
export type ResultSuccess<T> = {
	ok: true,
	value: T,
}

export type ResultError = {
	ok: false,
	error: string,
}

export type Result<T> = ResultSuccess<T> | ResultError

-- ═══════════════════════════════════════════
-- BASE STATS & PLAYER PROFILE
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

export type PlayerProfile = {
	ClassId: string,
	OriginClanId: string?,
	OriginCharacterId: string?,
	Level: number,
	EXP: number,
	StatPoints: number,
	SkillPoints: number,
	Gold: number,
	HP: number,
	MP: number,
	Stats: BaseStats,
	CurrentZone: number,
}

-- ═══════════════════════════════════════════
-- COMBAT TYPES
-- ═══════════════════════════════════════════
export type HitType = "hit" | "crit" | "blocked" | "skill" | "knockdown" | "dodged"
export type CombatActionType = "attack" | "dash" | "block_start" | "block_end"
export type CombatLockType = "attack" | "dash" | "block" | "stun"
export type StunType = "hit" | "critical" | "knockdown" | "dash_recovery"

export type ComboState = {
	count: number,
	lastHitTime: number,
}

export type CombatRuntimeState = {
	actionLockUntil: number,
	actionLockType: CombatLockType?,
	invulnerableUntil: number,
	recoveryUntil: number,
}


export type DamageOutcome = {
	knockback: boolean,
	stun: boolean,
}

-- ═══════════════════════════════════════════
-- SKILL TYPES
-- ═══════════════════════════════════════════
export type SkillType = "melee" | "ranged" | "buff" | "utility"

export type SkillDefinition = {
	Id: string,
	Name: string,
	NameRu: string,
	Class: string,
	Slot: number,
	Type: SkillType,
	Damage: number,
	MagicPowerMult: number,
	ManaCost: number,
	Cooldown: number,
	Range: number,
	Description: string,
	ProjectileSpeed: number?,
	Pierce: boolean?,
	BuffStat: string?,
	BuffMult: number?,
	BuffDuration: number?,
	InvisDuration: number?,
	TrapDuration: number?,
	StunDuration: number?,
	FreezeDuration: number?,
	KnockbackForce: number?,
	BackstabMult: number?,
	ShieldPercent: number?,
	HighCrit: number?,
	ShadowDamage: number?,
	ShadowAttackMult: number?,
	VFXTemplateName: string?,
	VFXMarkerName: string?,
	SoundId: number,
	AnimationId: number,
	IconId: string | number?,
}

export type BuffEntry = {
	stat: string,
	mult: number,
	endTime: number,
	baseSnapshot: { [string]: number }?,
}

export type SkillMapping = { [string]: { [number]: string } }

-- ═══════════════════════════════════════════
-- CLASS TYPES
-- ═══════════════════════════════════════════
export type ClassDefinition = {
	Id: string,
	Name: string,
	NameRu: string,
	Description: string,
	Color: Color3,
	StartingStats: BaseStats,
	StartingSkills: { string },
}

-- ═══════════════════════════════════════════
-- ITEM & INVENTORY TYPES
-- ═══════════════════════════════════════════
export type ItemType = "Weapon" | "Armor" | "Accessory" | "Consumable" | "Material"
export type ItemRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"
export type EquipmentSlot = "Weapon" | "Armor" | "Accessory"

export type ItemDefinition = {
	Id: string,
	Name: string,
	NameRu: string,
	Type: ItemType,
	Rarity: ItemRarity,
	Description: string,
	IconId: number?,
	Slot: EquipmentSlot?,
	Stats: { [string]: number }?,
	Effect: { [string]: number }?,
}

export type InventoryData = { [string]: number }
export type EquipmentData = { Weapon: string?, Armor: string?, Accessory: string? }

-- Для передачи инвентаря клиенту
export type InventoryEntry = {
	Id: string,
	Quantity: number,
}

export type EquipmentEntry = {
	Id: string,
}

-- ═══════════════════════════════════════════
-- CRAFTING TYPES
-- ═══════════════════════════════════════════
export type MaterialRequirement = {
	ItemId: string,
	Quantity: number,
}

export type RecipeDefinition = {
	Id: string,
	Name: string,
	NameRu: string,
	Materials: { MaterialRequirement },
	GoldCost: number,
	ResultItem: string,
	ResultQuantity: number,
}

-- ═══════════════════════════════════════════
-- ENEMY TYPES
-- ═══════════════════════════════════════════
export type EnemyType = "Scout" | "Goblin" | "Knight" | "MiniBoss"

export type EnemyDefinition = {
	Type: EnemyType,
	Name: string,
	NameRu: string,
	HP: number,
	Damage: number,
	Defense: number,
	Speed: number,
	RewardEXP: number,
	AggroRange: number,
	AttackRange: number,
	AttackCooldown: number,
	LootTableId: string?,
}

-- ═══════════════════════════════════════════
-- SPAWN TYPES
-- ═══════════════════════════════════════════
export type SpawnZone = {
	Id: string,
	Name: string,
	NameRu: string,
	MaxEnemies: number,
	SpawnCooldown: number,
	EnemyTypes: { EnemyType },
	SpawnPoints: { Vector3 },
}

-- ═══════════════════════════════════════════
-- LOOT TYPES
-- ═══════════════════════════════════════════
export type LootEntry = {
	ItemId: string,
	QuantityMin: number,
	QuantityMax: number,
	Chance: number,
}

export type EnemyLootTable = { [string]: { LootEntry } }

-- ═══════════════════════════════════════════
-- GUI REFERENCES
-- ═══════════════════════════════════════════
export type HUDRefs = {
	HPFill: Frame,
	HPText: TextLabel,
	MPFill: Frame,
	MPText: TextLabel,
	EXPFill: Frame,
	LevelNum: TextLabel,
	StatPointsLabel: TextLabel,
	GoldLabel: TextLabel,
}

-- ═══════════════════════════════════════════
-- UTILITY TYPES
-- ═══════════════════════════════════════════
export type MaidTask = RBXScriptConnection | Instance | (() -> ()) | { destroy: (self: any) -> () } | nil

export type ServiceBase = {
	Start: (self: any) -> (),
	Stop: (self: any) -> (),
}

export type ControllerBase = {
	Init: (self: any) -> (),
	Start: (self: any) -> (),
}

return Types
