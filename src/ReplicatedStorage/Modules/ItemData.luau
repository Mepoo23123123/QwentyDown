--!strict
-- ItemData Module
-- Расширенная база данных предметов для инвентаря и крафта
-- Server-authoritative: все статы применяются на сервере

local ItemData = {}

-- ===== ЭКСПОРТИРУЕМЫЕ ТИПЫ =====

export type ItemRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"
export type ItemType = "Material" | "Consumable" | "Weapon" | "Armor" | "Accessory"
export type EquipmentSlot = "Weapon" | "Armor" | "Accessory"

export type ItemStats = {
	Attack: number?,
	Defense: number?,
	MagicPower: number?,
	Speed: number?,
	CritChance: number?,
	CritDamage: number?,
	DodgeChance: number?,
	MaxHP: number?,
	MaxMP: number?,
}

export type BaseStatBonuses = {
	STR: number?,
	AGI: number?,
	INT: number?,
	VIT: number?,
	LUK: number?,
}

export type WeaponAnimations = {
	ComboAnims: { string }?,   -- Override combo anims (4 entries)
	BlockAnim: string?,       -- Override block anim
	IdleAnim: string?,        -- Weapon idle stance
	WalkAnim: string?,        -- Weapon walk cycle
	UnsheathAnim: string?,    -- Play once on equip
}

export type WeaponCombatConfig = {
	MaxDistanceMult: number?,  -- Multiplier for raycast distance (default 1.0)
	WidthMult: number?,       -- Multiplier for raycast width (default 1.0)
	DamageMult: number?,      -- Multiplier for damage (default 1.0)
}

export type TrailConfig = {
	Enabled: boolean?,              -- Включен ли trail (default false)
	Lifetime: number?,              -- Длина шлейфа в секундах (default 0.3)
	LightEmission: number?,         -- Свечение 0-1 (default 0.8)
	LightInfluence: number?,        -- Влияние света 0-1 (default 0.2)
	FaceCamera: boolean?,          -- Повернут к камере (default true)
	Color: ColorSequence?,         -- Цвет шлейфа
	Transparency: NumberSequence?, -- Прозрачность шлейфа
	WidthScale: NumberSequence?,   -- Ширина шлейфа
	StartMarker: string?,          -- Имя маркера анимации для включения (default "TrailStart")
	EndMarker: string?,            -- Имя маркера анимации для выключения (default "TrailEnd")
}

-- VFX-эффект, привязанный к маркеру анимации
export type VFXEntry = {
	Marker: string,                  -- Имя маркера в анимации (напр. "SlashVFX")
	VFXPath: string,                -- Путь к шаблону в ReplicatedStorage (напр. "VFX.Slash.Slash-01")
	AttachTo: "RightArm" | "RightHand" | "Weapon" | "HitPoint",  -- Куда крепить
	OffsetCFrame: CFrame?,          -- Смещение относительно точки крепления
	Lifetime: number?,              -- Время жизни эффекта в сек (default 0.5)
	Scale: number?,
	TimeScale: number?,
	EmitCount: number?,
	ComboHit: number?,              -- Номер удара в комбо (1-4). nil = применяется ко всем ударам
}

-- Конфигурация VFX для оружия
export type VFXConfig = {
	SlashVFX: { VFXEntry }?,         -- Эффекты взмаха (слэш)
	HitVFX: { VFXEntry }?,           -- Эффекты попадания (импакт)
}

export type ItemDefinition = {
	Id: string,
	Name: string,
	NameRu: string,
	Type: ItemType,
	Rarity: ItemRarity,
	Description: string,
	Value: number,  -- Цена в золоте
	IconId: number,  -- Roblox Asset ID (0 = placeholder)
	-- Для Consumable
	Effect: { [string]: number }?,  -- { HP = 50, MP = 30 }
	-- Для Equipment
	Slot: EquipmentSlot?,
	Stats: ItemStats?,        -- Устарело: бонусы к производным статам
	BaseStats: BaseStatBonuses?,  -- Бонусы к базовым статам (STR/AGI/INT/VIT/LUK)
	-- Для Weapon (визуал + бой)
	ModelName: string?,            -- Имя модели в ReplicatedStorage.ItemsModel
	GripOffset: CFrame?,           -- Смещение хвата относительно RightGripAttachment
	Animations: WeaponAnimations?, -- Кастомные анимации для оружия
	CombatConfig: WeaponCombatConfig?, -- Множители боя (дальность, ширина, урон)
	Trail: TrailConfig?,               -- Конфигурация шлейфа оружия
	VFX: VFXConfig?,                   -- Конфигурация VFX-эффектов оружия
	-- Для Material
	Craftable: boolean?,  -- Можно использовать в крафте
}

-- ===== ЦВЕТА РЕДКОСТИ =====
ItemData.RarityColors = {
	Common    = Color3.fromRGB(150, 150, 155),
	Uncommon  = Color3.fromRGB(50, 200, 80),
	Rare      = Color3.fromRGB(70, 130, 255),
	Epic      = Color3.fromRGB(160, 80, 230),
	Legendary = Color3.fromRGB(255, 180, 30),
}

-- ===== БАЗА ДАННЫХ ПРЕДМЕТОВ (20+ предметов) =====
ItemData.Items = {

	-- ===== МАТЕРИАЛЫ =====

	hollow_mask = {
		Id = "hollow_mask",
		Name = "Hollow Mask",
		NameRu = "Маска Пустого",
		Type = "Material",
		Rarity = "Common",
		Description = "Осколки маски Пустого. Пульсируют тёмной энергией.",
		Value = 5,
		IconId = 74644823948966,
		Craftable = true,
	},

	shinigami_robe = {
		Id = "shinigami_robe",
		Name = "Shinigami Robe",
		NameRu = "Ткань Шинигами",
		Type = "Material",
		Rarity = "Common",
		Description = "Часть робы шинигами. Пропитана духовной энергией.",
		Value = 8,
		IconId = 88673217253658,
		Craftable = true,
	},

	grimoire_page_rare = {
		Id = "grimoire_page_rare",
		Name = "Rare Grimoire Page",
		NameRu = "Редкая страница Гримуара",
		Type = "Material",
		Rarity = "Uncommon",
		Description = "Страница из древнего гримуара. Содержит заклинания.",
		Value = 25,
		IconId = 91676474318177,
		Craftable = true,
	},

	demon_bone = {
		Id = "demon_bone",
		Name = "Demon Bone",
		NameRu = "Кость Демона",
		Type = "Material",
		Rarity = "Rare",
		Description = "Кость демона из подземелья. Источает антимагию.",
		Value = 50,
		IconId = 74644823948966,
		Craftable = true,
	},

	sukuna_finger = {
		Id = "sukuna_finger",
		Name = "Sukuna Finger",
		NameRu = "Палец Суккуны",
		Type = "Material",
		Rarity = "Epic",
		Description = "Палец Короля Проклятий. Пропитан мощнейшей проклятой энергией.",
		Value = 200,
		IconId = 91583893506913,
		Craftable = true,
	},

	reiatsu_shard = {
		Id = "reiatsu_shard",
		Name = "Reiatsu Shard",
		NameRu = "Осколок Рейацу",
		Type = "Material",
		Rarity = "Common",
		Description = "Кристаллизованная духовная энергия. Основа для крафта.",
		Value = 3,
		IconId = 126780457554404,
		Craftable = true,
	},

	grimoire_page = {
		Id = "grimoire_page",
		Name = "Grimoire Page",
		NameRu = "Страница Гримуара",
		Type = "Material",
		Rarity = "Common",
		Description = "Пустая страница гримуара. Впитывает магические чернила.",
		Value = 4,
		IconId = 96572862573802,
		Craftable = true,
	},

	cursed_energy_core = {
		Id = "cursed_energy_core",
		Name = "Cursed Energy Core",
		NameRu = "Ядро Проклятой Энергии",
		Type = "Material",
		Rarity = "Rare",
		Description = "Сгусток проклятой энергии. Пульсирует тёмной силой.",
		Value = 40,
		IconId = 74769803906125,
		Craftable = true,
	},

	-- ===== ЗЕЛЬЯ (Consumable) =====

	health_potion = {
		Id = "health_potion",
		Name = "Health Potion",
		NameRu = "Зелье здоровья",
		Type = "Consumable",
		Rarity = "Common",
		Description = "Восстанавливает 50 HP мгновенно.",
		Value = 15,
		IconId = 110405989828179,
		Effect = { HP = 50 },
	},

	mana_potion = {
		Id = "mana_potion",
		Name = "Mana Potion",
		NameRu = "Зелье маны",
		Type = "Consumable",
		Rarity = "Common",
		Description = "Восстанавливает 30 MP мгновенно.",
		Value = 12,
		IconId = 132616208773827,
		Effect = { MP = 30 },
	},

	greater_health_potion = {
		Id = "greater_health_potion",
		Name = "Greater Health Potion",
		NameRu = "Большое зелье здоровья",
		Type = "Consumable",
		Rarity = "Uncommon",
		Description = "Восстанавливает 150 HP мгновенно.",
		Value = 40,
		IconId = 135631273824192,
		Effect = { HP = 150 },
	},

	greater_mana_potion = {
		Id = "greater_mana_potion",
		Name = "Greater Mana Potion",
		NameRu = "Большое зелье маны",
		Type = "Consumable",
		Rarity = "Uncommon",
		Description = "Восстанавливает 80 MP мгновенно.",
		Value = 35,
		IconId = 0,
		Effect = { MP = 80 },
	},

	strength_elixir = {
		Id = "strength_elixir",
		Name = "Strength Elixir",
		NameRu = "Эликсир силы",
		Type = "Consumable",
		Rarity = "Rare",
		Description = "Временно увеличивает ATK на 20% на 60 сек.",
		Value = 60,
		IconId = 78718526662911,
		Effect = { Attack = 20 },  -- 20% bonus
	},

	-- ===== ОРУЖИЕ =====

	zangetsu = {
		Id = "zangetsu",
		Name = "Zangetsu",
		NameRu = "Зангетсу",
		Type = "Weapon",
		Rarity = "Uncommon",
		Description = "Запакуто Ичиго Куросаки. Огромный клинок сокрушительной силы. +5 STR.",
		Value = 100,
		IconId = 123016356997260,
		Slot = "Weapon",
		BaseStats = { STR = 5 },
		ModelName = "Zangetsu",
		GripOffset = CFrame.new(0, 0, 0),
		Animations = {
			ComboAnims = {
				"rbxassetid://131149967774144", -- Attack 1 (TrailStart/TrailEnd/SlashVFX markers)
				"rbxassetid://112800031554624",  -- Attack 2 (TrailStart/TrailEnd/SlashVFX markers)
				"rbxassetid://129298813721028",  -- Attack 3 (TrailStart/TrailEnd/SlashVFX markers)
				"rbxassetid://133554650814500", -- Attack 4
			},
			IdleAnim = "rbxassetid://121988745528147",
			WalkAnim = "rbxassetid://121353266618107",
			UnsheathAnim = "rbxassetid://105629284886055",
		},
		CombatConfig = { MaxDistanceMult = 1.0, DamageMult = 1.0 },
		Trail = {
			Enabled = true,
			Lifetime = 0.3,
			LightEmission = 0.8,
			LightInfluence = 0.2,
			FaceCamera = true,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 220, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255)),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.5, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			}),
			WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(0.5, 1.0),
				NumberSequenceKeypoint.new(1, 0.2),
			}),
			StartMarker = "TrailStart",
			EndMarker = "TrailEnd",
		},
		VFX = {
			SlashVFX = {
				{
					Marker = "SlashVFX",
					VFXPath = "VFX.Slash.Slash-01",
					AttachTo = "RightArm",
					OffsetCFrame = CFrame.new(-0.700, 1.500, 0.800) * CFrame.Angles(math.rad(150), math.rad(100), math.rad(0)),
					Lifetime = 0.400,
					Scale = 1,
					TimeScale = 1,
					EmitCount = 20,
					ComboHit = 1,
				},
				{
					Marker = "SlashVFX",
					VFXPath = "VFX.Slash.Slash-01",
					AttachTo = "RightArm",
					OffsetCFrame = CFrame.new(0.300, 2.600, -0.200) * CFrame.Angles(math.rad(95), math.rad(160), math.rad(-25)),
					Lifetime = 0.400,
					Scale = 1,
					TimeScale = 1,
					EmitCount = 20,
					ComboHit = 2,
				},
				{
					Marker = "SlashVFX",
					VFXPath = "VFX.Slash.Slash-01",
					AttachTo = "RightArm",
					OffsetCFrame = CFrame.new(0.300, 2.600, -0.200) * CFrame.Angles(math.rad(95), math.rad(160), math.rad(-25)),
					Lifetime = 0.400,
					Scale = 1,
					TimeScale = 1,
					EmitCount = 20,
					ComboHit = 3,
				},
				{
					Marker = "SlashVFX",
					VFXPath = "VFX.Slash.Slash-01",
					AttachTo = "RightArm",
					OffsetCFrame = CFrame.new(0.900, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0)),
					Lifetime = 0.400,
					Scale = 1,
					TimeScale = 1,
					EmitCount = 20,
					ComboHit = 4,
				},
			},
			HitVFX = {
				{
					Marker = "HitVFX",
					VFXPath = "VFX.Hit.HitEffect",
					AttachTo = "HitPoint",
					Lifetime = 0.5,
				},
			},
		},
	},

	demon_slayer_sword = {
		Id = "demon_slayer_sword",
		Name = "Demon-Slayer Sword",
		NameRu = "Меч Пожирателя Демонов",
		Type = "Weapon",
		Rarity = "Rare",
		Description = "Антимагический меч Асты. Рассекает любые заклинания. +8 STR, +3 AGI.",
		Value = 250,
		IconId = 0,
		Slot = "Weapon",
		BaseStats = { STR = 8, AGI = 3 },
		ModelName = "DemonSlayerSword",  -- TODO: добавить модель в ItemsModel
		GripOffset = CFrame.Angles(0, 0, math.rad(-90)),
		CombatConfig = { MaxDistanceMult = 1.2, DamageMult = 1.1 },
	},

	playful_cloud = {
		Id = "playful_cloud",
		Name = "Playful Cloud",
		NameRu = "Игривое Облако",
		Type = "Weapon",
		Rarity = "Rare",
		Description = "Особый ранг проклятый инструмент. Мощный ударный посох. +10 INT, +2 LUK.",
		Value = 280,
		IconId = 0,
		Slot = "Weapon",
		BaseStats = { INT = 10, LUK = 2 },
		ModelName = "PlayfulCloud",  -- TODO: добавить модель в ItemsModel
		GripOffset = CFrame.Angles(0, math.rad(-45), 0),
		CombatConfig = { MaxDistanceMult = 1.3, DamageMult = 0.9 },
	},

	inverted_spear = {
		Id = "inverted_spear",
		Name = "Inverted Spear of Heaven",
		NameRu = "Перевёрнутое Копьё Небес",
		Type = "Weapon",
		Rarity = "Epic",
		Description = "Проклятый инструмент особого ранга. Нейтрализует любую проклятую технику. +12 STR, +8 AGI.",
		Value = 500,
		IconId = 0,
		Slot = "Weapon",
		BaseStats = { STR = 12, AGI = 8 },
		ModelName = "InvertedSpear",  -- TODO: добавить модель в ItemsModel
		GripOffset = CFrame.Angles(0, 0, math.rad(-90)),
		CombatConfig = { MaxDistanceMult = 0.8, WidthMult = 1.3, DamageMult = 1.2 },
	},

	-- ===== БРОНЯ =====

	shihakusho = {
		Id = "shihakusho",
		Name = "Shihakusho",
		NameRu = "Шихакусё",
		Type = "Armor",
		Rarity = "Uncommon",
		Description = "Униформа шинигами. Усиливает духовную защиту. +3 VIT.",
		Value = 80,
		IconId = 96873151985657,
		Slot = "Armor",
		BaseStats = { VIT = 3 },
	},

	magic_knight_cloak = {
		Id = "magic_knight_cloak",
		Name = "Magic Knight Cloak",
		NameRu = "Плащ Рыцаря-Мага",
		Type = "Armor",
		Rarity = "Rare",
		Description = "Плащ ордена Рыцарей-Магов. Усиливает ману и защиту. +6 VIT, +2 STR.",
		Value = 200,
		IconId = 0,
		Slot = "Armor",
		BaseStats = { VIT = 6, STR = 2 },
	},

	sukuna_armor = {
		Id = "sukuna_armor",
		Name = "Sukuna Armor",
		NameRu = "Доспех Суккуны",
		Type = "Armor",
		Rarity = "Epic",
		Description = "Доспех, пропитанный проклятой энергией Короля Проклятий. +10 VIT, +5 STR.",
		Value = 450,
		IconId = 0,
		Slot = "Armor",
		BaseStats = { VIT = 10, STR = 5 },
	},

	-- ===== АКСЕССУАРЫ =====

	reiatsu_ring = {
		Id = "reiatsu_ring",
		Name = "Reiatsu Ring",
		NameRu = "Кольцо Рейацу",
		Type = "Accessory",
		Rarity = "Rare",
		Description = "Кольцо, концентрирующее духовное давление. +5 LUK, +2 AGI.",
		Value = 250,
		IconId = 121272394198265,
		Slot = "Accessory",
		BaseStats = { LUK = 5, AGI = 2 },
	},

	grimoire_charm = {
		Id = "grimoire_charm",
		Name = "Grimoire Charm",
		NameRu = "Амулет Гримуара",
		Type = "Accessory",
		Rarity = "Rare",
		Description = "Амулет с символикой гримуара. Усиливает магические способности. +8 INT, +2 VIT.",
		Value = 220,
		IconId = 0,
		Slot = "Accessory",
		BaseStats = { INT = 8, VIT = 2 },
	},

	curse_step_boots = {
		Id = "curse_step_boots",
		Name = "Curse Step Boots",
		NameRu = "Сапоги Проклятого Шага",
		Type = "Accessory",
		Rarity = "Uncommon",
		Description = "Сапоги, усиливающие технику Шунпо/Проклятого шага. +4 AGI, +1 LUK.",
		Value = 150,
		IconId = 0,
		Slot = "Accessory",
		BaseStats = { AGI = 4, LUK = 1 },
	},
}

-- ===== ФУНКЦИИ =====

-- Получить предмет по ID
function ItemData.GetItem(itemId: string): ItemDefinition?
	return ItemData.Items[itemId]
end

-- Получить все предметы определённого типа
function ItemData.GetItemsByType(itemType: ItemType): { ItemDefinition }
	local result: { ItemDefinition } = {}
	for _, item in ItemData.Items do
		if item.Type == itemType then
			table.insert(result, item)
		end
	end
	return result
end

-- Получить все предметы определённой редкости
function ItemData.GetItemsByRarity(rarity: ItemRarity): { ItemDefinition }
	local result: { ItemDefinition } = {}
	for _, item in ItemData.Items do
		if item.Rarity == rarity then
			table.insert(result, item)
		end
	end
	return result
end

-- Получить все материалы для крафта
function ItemData.GetCraftableMaterials(): { ItemDefinition }
	local result: { ItemDefinition } = {}
	for _, item in ItemData.Items do
		if item.Craftable then
			table.insert(result, item)
		end
	end
	return result
end

-- Получить цвет редкости
function ItemData.GetRarityColor(rarity: ItemRarity): Color3
	return ItemData.RarityColors[rarity] or Color3.fromRGB(150, 150, 155)
end

return ItemData
