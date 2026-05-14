# QwentyDown — Гайд разработчика

> Полный справочник по архитектуре, файлам и процессу работы с проектом.

---

## 1. Структура проекта

```
QwentyDown/
├── docs/                          ← Документация
│   ├── DEVELOPER_GUIDE.md          ← Этот файл
│   ├── ARCHITECTURE.md             ← Архитектура и диаграммы
│   ├── REMOTE_CONTRACTS.md         ← Контракты RemoteEvent/Function
│   ├── DECISIONS.md                ← Лог архитектурных решений
│   ├── AUDITS.md                   ← Лог аудитов
│   └── SYSTEMS/                    ← Документация по системам
│       ├── Combat.md
│       ├── Enemies.md
│       ├── Inventory.md
│       ├── Loot.md
│       ├── Skills.md
│       ├── Stats.md
│       └── VFX.md
│
├── .windsurf/workflows/            ← Рабочие процессы Cascade
│   ├── testing.md
│   ├── docs-update.md
│   ├── audit.md
│   ├── roblox-research-before-code.md
│   └── raycast-combat.md
│
└── scripts/                        ← Локальные копии скриптов (для IDE)
```

### Roblox DataModel (в Studio)

```
ReplicatedStorage/
├── Modules/                        ← Общие модули (сервер + клиент)
│   ├── EnemyConfig                 ← Данные врагов и зон спавна
│   ├── EnemyBrain                  ← AI-логика врагов (state machine)
│   ├── ItemData                    ← Определения предметов
│   ├── SkillData                   ← Определения навыков
│   ├── ClassData                   ← Определения классов
│   ├── CombatConstants             ← Константы боя
│   ├── CombatData                  ← Расчёт урона
│   ├── CombatTypes                 ← Типы боя
│   ├── CombatQuery                 ← Серверная система combat query
│   ├── WeaponVFX                   ← VFX оружия (trail, slash)
│   ├── PlayerProfile               ← Профиль игрока, расчёт статов
│   ├── LootTable                   ← Таблицы лута
│   ├── EXPManager                  ← Начисление EXP
│   ├── NPCData / NPCTypes / NPCButton  ← NPC система
│   ├── AnimationData               ← ID анимаций
│   ├── StatsUIBuilder              ← UI статов
│   ├── InventoryUIBuilder          ← UI инвентаря
│   ├── StatsHelper                 ← Хелперы статов
│   ├── StatFormula                 ← Формулы расчёта
│   ├── Themes                      ← Темы UI
│   ├── GUIModule                   ← Общий модуль GUI
│   ├── RateLimiter                 ← Лимитер запросов
│   └── RemoteManager               ← Менеджер ремоутов
│
├── Remotes/                        ← RemoteEvent / RemoteFunction
│   ├── CombatAction                ← Клиент → Сервер (атака)
│   ├── DamageReceived              ← Сервер → Клиент (урон)
│   ├── StunApplied                 ← Сервер → Клиент (стан)
│   ├── ComboUpdated                ← Сервер → Клиент (комбо)
│   ├── SkillCast / SkillCooldown   ← Навыки
│   ├── SelectClass                 ← Выбор класса
│   ├── LootDropped / CollectLoot / CollectedLoot  ← Лут
│   ├── EquipItem / UnequipItem     ← Экипировка
│   ├── CraftItem / CraftResult     ← Крафт
│   ├── UseItem / DeleteItem        ← Использование/удаление
│   ├── RequestInventoryUpdate / InventoryUpdate     ← Инвентарь
│   ├── AllocateStatPoint / AllocateStatPoints       ← Статы
│   ├── UpdateStatsUI / UpdateLevelUI / LevelUpEvent ← UI обновления
│   ├── AcceptQuest / TurnInQuest / QuestUpdate      ← Квесты
│   ├── GetActiveQuests / GetCompletedQuest / HasProgressQuest  ← Квесты (Function)
│   └── ZoneChanged                 ← Смена зоны
│
├── Shared/                         ← Общие утилиты
│   ├── Types                       ← Глобальные типы
│   ├── Constants                    ← Глобальные константы
│   ├── Util                        ← Логгер, хелперы
│   └── Events                      ← BindableEvent реестр
│
├── ItemsModel/                     ← 3D-модели оружия
│   └── Zangetsu                    ← (MeshPart + TrailTip/TrailBase)
│
├── VFX/                            ← VFX-темплейты
│   ├── Slash/                      ← Слэш-эффекты
│   ├── Hit/                        ← Хит-эффекты
│   └── Skill/                      ← Скилл-эффекты
│
├── EnemyModels/                    ← Модели врагов (для клонирования)
│   └── Goblin                      ← R6 rig с Humanoid + Animator
│
├── SummonTemplates/                ← Суммоны (heal, shield, cage, hurt)
│
├── Objects/                        ← UI-объекты (NPC overhead, dialogue)
│
└── Events/                         ← BindableEvents (NPCDialogueEnded)

ServerScriptService/
├── Core/
│   ├── init                        ← Bootstrap сервера (загрузка сервисов)
│   └── ServiceBase                 ← Базовый класс сервисов
│
└── Systems/                        ← Серверные сервисы
    ├── DataService                 ← DataStore загрузка/сохранение
    ├── StatsService                ← Статы, HP/MP, урон, EXP
    ├── InventoryService            ← Инвентарь, экипировка
    ├── CombatService               ← Бой, комбо, dash, block, combat query
    ├── SkillService                ← Навыки, скиллы, суммоны
    ├── LevelService                ← Уровни, левел-ап
    ├── EnemyService                ← Спавн врагов, lifecycle, death, loot
    ├── LootService                 ← Подбор лута
    └── LootSpawner                 ← Спавн лут-объектов в мире

ServerStorage/
└── Data/
    └── DataStoreService_Custom     ← Кастомный DataStore

StarterPlayer/
├── StarterPlayerScripts/
│   ├── Core/
│   │   └── init                    ← Bootstrap клиента
│   └── Controllers/                ← Клиентские контроллеры
│       ├── CombatController        ← Управление боем, анимации, VFX
│       ├── SkillController         ← Скилл-бар, каст
│       ├── HUDController           ← HP/MP/Level bars
│       ├── LootController          ← Подбор лута
│       ├── NPCController           ← Диалоги NPC
│       ├── ClassSelectorController ← Выбор класса
│       ├── StatsController         ← Распределение статов (N)
│       ├── InventoryController     ← Инвентарь UI
│       └── VFXTunerController      ← Тюнинг VFX (K)
│
├── StarterCharacterScripts/
│   └── PlayerAnimations            ← Анимации персонажа
│
└── StarterCharacter/               ← R6 персонаж по умолчанию

StarterGui/                         ← UI-экраны
├── GameHUD                         ← HP/MP/Level/Gold
├── CombatUI                        ← Комбо-счётчик
├── ClassSelector                   ← Выбор класса
└── LootNotifications               ← Уведомления о луте
```

---

## 2. Архитектура

### Паттерн: Service → Controller

```
┌──────────────────────────────────────────────────────────┐
│  СЕРВЕР                                                   │
│                                                           │
│  Core.init ──загружает──▶ все Systems/*Service            │
│     │                         │                           │
│     │                         ├── DataService (DataStore) │
│     │                         ├── StatsService (HP/MP/EXP)│
│     │                         ├── CombatService (бой)     │
│     │                         ├── EnemyService (враги)    │
│     │                         ├── InventoryService        │
│     │                         ├── SkillService            │
│     │                         ├── LevelService            │
│     │                         ├── LootService / LootSpawner│
│     │                         │                           │
│     │                         └── используют Modules/*    │
│     │                                                   │
│     └── Remotes/ ◀──▶ Controllers                       │
│                                                           │
├──────────────────────────────────────────────────────────┤
│  КЛИЕНТ                                                   │
│                                                           │
│  StarterPlayerScripts/Core.init ──загружает──▶ Controllers│
│     │                              │                      │
│     │                              ├── CombatController   │
│     │                              ├── SkillController    │
│     │                              ├── HUDController      │
│     │                              ├── LootController     │
│     │                              ├── NPCController      │
│     │                              ├── ClassSelectorCtrl  │
│     │                              ├── StatsController    │
│     │                              ├── InventoryController │
│     │                              └── VFXTunerController │
│     │                                                    │
│     └── Отправляет Remotes → Сервер обрабатывает         │
└──────────────────────────────────────────────────────────┘
```

### Правило: Сервер — авторитет

- **Всё важное** (урон, статы, инвентарь, спавн, EXP) считается на сервере
- Клиент только **отправляет запросы** через RemoteEvent и **показывает результат**
- Никогда не доверяй данным от клиента — всегда валидируй на сервере

---

## 3. Как добавить нового врага

### Шаг 1: Положи модель в `ReplicatedStorage.EnemyModels`

1. Создай/импортируй Model в Studio
2. Убедись что у модели есть:
   - `HumanoidRootPart` (Part)
   - `Humanoid` с `Animator` внутри
   - R6 rig (Head, Torso, Arms, Legs + Motor6D)
3. Перетащи модель в `ReplicatedStorage.EnemyModels/`
4. В скриптах модели: все `BasePart` должны быть `Anchored=false`

### Шаг 2: Добавь определение в `EnemyConfig`

Файл: `ReplicatedStorage.Modules.EnemyConfig`

```lua
EnemyConfig.Enemies = {
    -- ... существующие враги ...
    MyNewEnemy = {
        Id = "MyNewEnemy",
        DisplayName = "Мой новый враг",
        Tier = "fighter",              -- swarm | fighter | guardian | brute
        MaxHealth = 200,
        Damage = 12,
        Defense = 8,
        MoveSpeed = 10,
        AggroRange = 30,
        AttackRange = 5,
        AttackCooldown = 1.2,
        LeashRange = 55,
        RewardEXP = 35,
        RewardGold = 10,
        LootTableId = "Goblin",        -- ключ из LootTable
        ModelName = "Goblin",          -- имя модели в EnemyModels/ (nil = процедурная)
        Animations = {                 -- опционально
            Idle = "rbxassetid://XXXXX",
            Walk = "rbxassetid://XXXXX",
            Attack = "rbxassetid://XXXXX",
        },
        Visual = {                     -- для процедурных моделей (без ModelName)
            BodyColor = Color3.fromRGB(54, 105, 58),
            AccentColor = Color3.fromRGB(132, 209, 92),
            Size = Vector3.new(3.1, 3.6, 3.1),
        },
    },
}
```

### Шаг 3: Добавь врага в зону спавна

```lua
EnemyConfig.Zones = {
    my_zone = {
        Id = "my_zone",
        DisplayName = "Моя зона",
        EnemyPool = { "MyNewEnemy" },   -- список ID врагов
        MaxAlive = 3,                    -- максимум одновременно
        RespawnSeconds = 10,
        SpawnPoints = {
            Vector3.new(100, 1, 50),    -- координаты спавна
        },
    },
}
```

### Шаг 4: Добавь лут (если нужно)

Файл: `ReplicatedStorage.Modules.LootTable` — добавь запись с ключом = `LootTableId`

### Шаг 5: Обнови тип `EnemyId`

В `EnemyConfig` строка 6:
```lua
export type EnemyId = "HollowMite" | "ForestGnawer" | "RuinSentinel" | "RiftOgre" | "MyNewEnemy"
```

---

## 4. Как добавить новое оружие

### Шаг 1: Создай 3D-модель

1. Импортируй MeshPart в Studio
2. Добавь внутрь:
   - `Attachment` с именем `TrailTip`
   - `Attachment` с именем `TrailBase`
   - `Part` с именем `Handle` (для grip)
3. Положи в `ReplicatedStorage.ItemsModel/` с уникальным именем

### Шаг 2: Добавь в `ItemData`

Файл: `ReplicatedStorage.Modules.ItemData`

```lua
Items = {
    -- ... существующие предметы ...
    my_sword = {
        Id = "my_sword",
        Name = "Мой меч",
        NameRu = "Мой меч",
        Rarity = "Rare",
        Type = "Weapon",
        EquipmentSlot = "Weapon",
        ModelPath = "ReplicatedStorage.ItemsModel.MySword",
        Animations = {
            CombatAnimation = "rbxassetid://XXXXX",
        },
        CombatConfig = {
            ComboMax = 4,
            DamagePerHit = 15,
            AttackRange = 12,
            Cooldown = 0.8,
        },
        TrailConfig = {
            Enabled = true,
            Lifetime = 0.3,
            Color = ColorSequence.new(Color3.fromRGB(255, 100, 50)),
            Width = 1.5,
        },
        -- ... остальные поля по шаблону ItemData
    },
}
```

### Шаг 3: Добавь анимации

Если у оружия уникальные анимации — добавь ID в `AnimationData` и в `CombatConfig` предмета.

---

## 5. Как добавить новый навык (Skill)

### Шаг 1: Определи в `SkillData`

Файл: `ReplicatedStorage.Modules.SkillData`

```lua
Skills = {
    -- ... существующие навыки ...
    my_skill = {
        Id = "my_skill",
        Name = "My Skill",
        NameRu = "Мой навык",
        Class = "Warrior",           -- какой класс может использовать
        Slot = 1,                     -- слот на actionBar (1-4)
        Type = "Active",              -- Active | Passive
        Damage = 50,
        ManaCost = 30,
        Cooldown = 8,
        Range = 20,
        Description = "Описание навыка",
        SoundId = "rbxassetid://XXXXX",
        IconId = "rbxassetid://XXXXX",
        AnimationId = "rbxassetid://XXXXX",
    },
}
```

### Шаг 2: VFX (опционально)

Положи VFX-темплейт в `ReplicatedStorage.VFX.Skill/` и укажи `VFXTemplateName` в навыке.

---

## 6. Как добавить новый класс

Файл: `ReplicatedStorage.Modules.ClassData`

```lua
Classes = {
    my_class = {
        Id = "my_class",
        Name = "My Class",
        NameRu = "Мой класс",
        Description = "Описание",
        IconId = "rbxassetid://XXXXX",
        StartingStats = { STR = 5, AGI = 3, INT = 2, VIT = 4, LUK = 1 },
        StartingSkills = { "skill_1", "skill_2" },
        StatGrowthPerLevel = { STR = 2, AGI = 1, INT = 1, VIT = 2, LUK = 1 },
    },
}
```

---

## 7. Ключевые модули и их роли

| Модуль | Где | Роль |
|--------|-----|------|
| `EnemyConfig` | ReplicatedStorage.Modules | Данные врагов + зоны спавна |
| `EnemyBrain` | ReplicatedStorage.Modules | AI state machine (Idle→Pursue→Attack→Dead) |
| `ItemData` | ReplicatedStorage.Modules | Все предметы, оружие, их статов |
| `SkillData` | ReplicatedStorage.Modules | Все навыки |
| `ClassData` | ReplicatedStorage.Modules | Классы персонажей |
| `CombatConstants` | ReplicatedStorage.Modules | Числа боя (комбо, стан, крит) |
| `CombatData` | ReplicatedStorage.Modules | Формула расчёта урона |
| `CombatQuery` | ReplicatedStorage.Modules | Серверные проверки попаданий |
| `PlayerProfile` | ReplicatedStorage.Modules | Расчёт производных статов |
| `LootTable` | ReplicatedStorage.Modules | Таблицы лута (RollLoot) |
| `EXPManager` | ReplicatedStorage.Modules | Обёртка над StatsService.AddEXP |
| `Types` | ReplicatedStorage.Shared | Глобальные типы |
| `Constants` | ReplicatedStorage.Shared | Глобальные константы |
| `Util` | ReplicatedStorage.Shared | Логгер `Util.Log(source, msg)` |
| `ServiceBase` | ServerScriptService.Core | Базовый класс для сервисов |

---

## 8. Порядок загрузки сервисов

`ServerScriptService.Core.init` загружает в таком порядке:

1. **DataService** — DataStore, загрузка профиля
2. **StatsService** — статы, HP/MP, реген
3. **InventoryService** — инвентарь, экипировка
4. **CombatService** — бой, комбо, raycast
5. **SkillService** — навыки, каст
6. **LevelService** — уровни
7. **EnemyService** — спавн врагов, AI, смерть
8. **LootService** — подбор лута

> ⚠️ Не меняй порядок без причины — сервисы зависят друг от друга.

---

## 9. RemoteEvent контракты

Полная документация: `docs/REMOTE_CONTRACTS.md`

Ключевые:

| Remote | Направление | Payload |
|--------|-------------|---------|
| `CombatAction` | Клиент→Сервер | `CombatActionType` string |
| `DamageReceived` | Сервер→Клиент | `damage, hitType, targetModel` |
| `SkillCast` | Клиент→Сервер | `skillId, targetPos` |
| `SelectClass` | Клиент→Сервер | `classId` |
| `EquipItem` | Клиент→Сервер | `itemId` |
| `CollectLoot` | Клиент→Сервер | `lootPart` |
| `AllocateStatPoint` | Клиент→Сервер | `statName` |

---

## 10. Работа с Cascade (AI-ассистентом)

### Workflow-файлы

В `.windsurf/workflows/` лежат процессы:

| Файл | Когда использовать |
|------|--------------------|
| `testing.md` | После каждого изменения — запустить Play Mode, проверить |
| `docs-update.md` | После значимых изменений — обновить документацию |
| `audit.md` | Периодически — аудит безопасности и производительности |
| `roblox-research-before-code.md` | Перед написанием кода — проверить API Roblox |
| `raycast-combat.md` | При работе с raycast-боевой системой |

### Как просить Cascade

- **"Добавь врага X"** → Cascade добавит в EnemyConfig + зону + лут
- **"Исправь баг с Y"** → Cascade найдёт причину и исправит
- **"Сделай аудит"** → Cascade запустит `/audit` workflow
- **"Обнови доки"** → Cascade запустит `/docs-update` workflow

### Важные правила Cascade

1. Всегда использует `--!strict` в Luau
2. Сервер — авторитет, клиент только показывает
3. Не трогает системы без необходимости
4. Перед кодом — исследует (workflow `roblox-research-before-code`)
5. Пишет минимальные изменения, не переписывает файлы целиком

### File bridge с Devin

Если Devin не имеет прямого доступа к локальному Roblox Studio MCP, использовать file-based bridge:

| Файл | Назначение |
|------|------------|
| `docs/AGENT_BRIDGE_PROTOCOL.md` | Общий протокол взаимодействия Devin ↔ Windsurf Agent |
| `docs/DEVIN_TO_WINDSURF.md` | Команды Devin для Windsurf Agent |
| `docs/WINDSURF_TO_DEVIN.md` | Отчёты Windsurf Agent для Devin |
| `docs/DEVIN_CODE_DRAFTS.md` | Luau drafts/patch plans от Devin |

Windsurf Agent применяет/проверяет изменения через Roblox Studio MCP и пишет результат обратно в `docs/WINDSURF_TO_DEVIN.md`.

---

## 11. Частые задачи

### Изменить статы врага
→ Правишь `ReplicatedStorage.Modules.EnemyConfig.Enemies[Id]`

### Изменить точку спавна
→ Правишь `EnemyConfig.Zones[zoneId].SpawnPoints`

### Изменить урон оружия
→ Правишь `ItemData.Items[itemId].CombatConfig.DamagePerHit`

### Изменить EXP за врага
→ Правишь `EnemyConfig.Enemies[Id].RewardEXP`

### Изменить лут
→ Правишь `LootTable` (модуль) + `EnemyConfig.Enemies[Id].LootTableId`

### Добавить зону спавна
→ Добавляешь запись в `EnemyConfig.Zones`

### Изменить формулу урона
→ `CombatData.CalculateDamage` или `CombatConstants`

---

## 12. Отладка

### Консоль в Studio
- Output показывает логи вида `[EnemyService] ...`, `[CombatController] ...`
- `Util.Log(source, msg)` — стандартный логгер

### Атрибуты врагов (видны в Explorer)
- `IsEnemy` = true
- `EnemyId` = "ForestGnawer"
- `EnemyState` = "Idle" / "Pursue" / "Attack" / "Dead"
- `LootTableId` = "Goblin"
- `EnemyTier` = "swarm" / "fighter" / "guardian" / "brute"

### Структура врага в Explorer
```
Model "Лесной грызун"
├── HumanoidRootPart (transparent, CanQuery=false)
├── Head / Torso / Arms / Legs (R6 rig с Motor6D)
├── Humanoid
│   └── Animator
├── Stats (Folder)
│   ├── STR / AGI / INT / VIT / LUK (NumberValue)
│   ├── HP / MaxHP / Defense (NumberValue)
│   └── ...derived stats
└── Attributes: IsEnemy, EnemyId, EnemyState, LootTableId, EnemyTier
```

---

## 13. Горячие клавиши в игре

| Клавиша | Действие |
|---------|----------|
| ЛКМ | Атака (M1) |
| 1-4 | Скиллы |
| Q | Dash |
| F | Block |
| N | Меню статов |
| K | VFX тюнер |
| E | Взаимодействие / подобрать лут |

---

## 14. Известные пакеты в проекте

| Пакет | Где | Назначение |
|-------|-----|------------|
| CombatQuery | ReplicatedStorage.Modules.CombatQuery | Серверные боевые запросы |
| Orange AI | Workspace | NPC AI система |
| Yona VFX Pack | Workspace.Yona VFX Pack | VFX-ассеты |
| PolygonDungeon | Workspace.exportfromOtherProject | Мап-ассеты |

---

*Последнее обновление: 2026-05-04*
