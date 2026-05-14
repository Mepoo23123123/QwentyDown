--!strict
-- LootTable Module
-- Теперь адаптер: item-данные берутся из ItemData (единый источник).
-- Здесь оставлены только: EnemyLoot пулы + RollLoot логика + конвертация типов.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemData = require(ReplicatedStorage.Modules.ItemData)

local LootTable = {}

-- ===== РЕДКОСТЬ =====
export type Rarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

LootTable.RarityColors = {
	Common    = Color3.fromRGB(150, 150, 155),
	Uncommon  = Color3.fromRGB(50, 200, 80),
	Rare      = Color3.fromRGB(70, 130, 255),
	Epic      = Color3.fromRGB(160, 80, 230),
	Legendary = Color3.fromRGB(255, 180, 30),
}

LootTable.RarityGlowIntensity = {
	Common    = 0,
	Uncommon  = 0.5,
	Rare      = 1,
	Epic      = 2,
	Legendary = 3,
}

-- ===== КОНВЕРТЕР ТИПОВ (Loot -> ItemData) =====
-- ItemData использует PascalCase типы: "Weapon", "Armor", "Accessory", "Consumable", "Material"
-- Loot legacy использовал lowercase: "equipment", "consumable", "material"
local function ToItemType(lootType: string): ItemData.ItemType
	local map: { [string]: ItemData.ItemType } = {
		equipment = "Weapon",    -- fallback, ниже уточняем по Slot
		consumable = "Consumable",
		material = "Material",
		currency = "Material",   -- fallback
	}
	return map[lootType] or (lootType :: any)
end

-- ===== ПРЕДМЕТ (адаптер поверх ItemData) =====
export type LootItem = {
	Id: string,
	Name: string,
	NameRu: string,
	Type: "material" | "consumable" | "equipment" | "currency",
	Rarity: Rarity,
	IconId: number,
	Description: string,
	Value: number,
	Stackable: boolean,
	MaxStack: number,
	Effect: { [string]: number }?,
	Stats: { [string]: number }?,
	Slot: "Weapon" | "Armor" | "Accessory"?,
}

-- Дефолты для Stackable/MaxStack если не заданы в ItemData
local DEFAULT_STACK = {
	Material     = { Stackable = true,  MaxStack = 99 },
	Consumable   = { Stackable = true,  MaxStack = 20 },
	Weapon       = { Stackable = false, MaxStack = 1 },
	Armor        = { Stackable = false, MaxStack = 1 },
	Accessory    = { Stackable = false, MaxStack = 1 },
}

function LootTable.GetItem(itemId: string): LootItem?
	local def = ItemData.GetItem(itemId)
	if not def then
		return nil
	end

	local defaults = DEFAULT_STACK[def.Type] or { Stackable = true, MaxStack = 99 }

	-- Определяем legacy loot type
	local lootType: LootItem.Type
	if def.Type == "Material" then
		lootType = "material"
	elseif def.Type == "Consumable" then
		lootType = "consumable"
	elseif def.Type == "Weapon" or def.Type == "Armor" or def.Type == "Accessory" then
		lootType = "equipment"
	else
		lootType = "material"
	end

	return {
		Id = def.Id,
		Name = def.Name,
		NameRu = def.NameRu,
		Type = lootType,
		Rarity = def.Rarity :: Rarity,
		IconId = def.IconId,
		Description = def.Description,
		Value = def.Value,
		Stackable = defaults.Stackable,
		MaxStack = defaults.MaxStack,
		Effect = def.Effect,
		Stats = def.BaseStats,
		Slot = def.Slot,
	}
end

-- ===== ТАБЛИЦЫ ДРОПА ПО ВРАГАМ =====
export type LootEntry = {
	ItemId: string,
	Chance: number,
	MinQty: number,
	MaxQty: number,
}

LootTable.EnemyLoot = {
	Scout = {
		{ ItemId = "shinigami_robe", Chance = 70, MinQty = 1, MaxQty = 2 },
		{ ItemId = "health_potion", Chance = 30, MinQty = 1, MaxQty = 1 },
		{ ItemId = "mana_potion", Chance = 20, MinQty = 1, MaxQty = 1 },
	},
	Goblin = {
		{ ItemId = "hollow_mask", Chance = 75, MinQty = 1, MaxQty = 3 },
		{ ItemId = "health_potion", Chance = 35, MinQty = 1, MaxQty = 2 },
		{ ItemId = "mana_potion", Chance = 25, MinQty = 1, MaxQty = 1 },
		{ ItemId = "shihakusho", Chance = 5, MinQty = 1, MaxQty = 1 },
		{ ItemId = "zangetsu", Chance = 50, MinQty = 1, MaxQty = 1 },  -- ТЕСТ: 50% дроп
	},
	Knight = {
		{ ItemId = "grimoire_page_rare", Chance = 50, MinQty = 1, MaxQty = 1 },
		{ ItemId = "greater_health_potion", Chance = 40, MinQty = 1, MaxQty = 1 },
		{ ItemId = "zangetsu", Chance = 8, MinQty = 1, MaxQty = 1 },
		{ ItemId = "reiatsu_ring", Chance = 3, MinQty = 1, MaxQty = 1 },
	},
	MiniBoss = {
		{ ItemId = "demon_bone", Chance = 80, MinQty = 1, MaxQty = 1 },
		{ ItemId = "sukuna_finger", Chance = 25, MinQty = 1, MaxQty = 1 },
		{ ItemId = "greater_health_potion", Chance = 60, MinQty = 1, MaxQty = 2 },
		{ ItemId = "reiatsu_ring", Chance = 10, MinQty = 1, MaxQty = 1 },
	},
}

-- ===== ФУНКЦИИ =====

function LootTable.RollLoot(enemyType: string): { { Item: LootItem, Quantity: number } }
	local lootPool = LootTable.EnemyLoot[enemyType]
	if not lootPool then
		warn("[LootTable] No loot table for enemy type: " .. tostring(enemyType))
		return {}
	end

	local drops: { { Item: LootItem, Quantity: number } } = {}

	for _, entry in lootPool do
		if math.random(1, 100) <= entry.Chance then
			local item = LootTable.GetItem(entry.ItemId)
			if item then
				local qty = if entry.MinQty == entry.MaxQty
					then entry.MinQty
					else math.random(entry.MinQty, entry.MaxQty)

				table.insert(drops, { Item = item, Quantity = qty })
			end
		end
	end

	return drops
end

function LootTable.GetRarityColor(rarity: Rarity): Color3
	return LootTable.RarityColors[rarity] or Color3.fromRGB(150, 150, 155)
end

return LootTable
