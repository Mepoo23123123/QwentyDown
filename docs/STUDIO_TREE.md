# Roblox Studio Tree Structure

Generated from Roblox Studio instance: Place2

## Core Services

### ReplicatedStorage
Shared data accessible to both client and server.

**Modules** (Data & Logic):
- `PlayerProfile.luau` - Player profile data management
- `ClassData.luau` - Character class definitions
- `Themes.luau` - UI theme configurations
- `StatFormula.luau` - Stat calculation formulas
- `EnemyBrain.luau` - Enemy AI behavior
- `CombatData.luau` - Combat system data
- `SkillData.luau` - Skill definitions
- `CombatQuery.luau` - Combat query utilities
- `OriginData.luau` - Origin character data
- `WeaponVFX.luau` - Weapon visual effects
- `LootTable.luau` - Loot drop tables
- `StatsUIBuilder.luau` - Stats UI construction
- `InventoryUIBuilder.luau` - Inventory UI construction
- `StatsHelper.luau` - Stat calculation helpers
- `EXPManager.luau` - Experience management
- `ItemData.luau` - Item database
- `AnimationData.luau` - Animation asset IDs
- `EnemyConfig.luau` - Enemy configurations
- `QuestData.luau` - Quest definitions

**Remotes** (Client-Server Communication):
- `RemoteManager.luau` - Remote event/function manager
- `UpdateStatsUI` - Stats UI updates
- `UpdateLevelUI` - Level UI updates
- `AllocateStatPoint` - Stat point allocation
- `LevelUpEvent` - Level up notifications
- `CombatAction` - Combat actions
- `DamageReceived` - Damage notifications
- `StunApplied` - Stun state updates
- `ComboUpdated` - Combo counter updates
- `SkillCast` - Skill casting
- `SkillCooldown` - Skill cooldown updates
- `SelectClass` - Class selection
- `AllocateStatPoints` - Bulk stat allocation
- `LootDropped` - Loot drop notifications
- `CollectedLoot` - Loot collection
- `CollectLoot` - Loot pickup requests
- `ZoneChanged` - Zone change notifications
- `UnequipItem` - Item unequipment
- `EquipItem` - Item equipment
- `CraftResult` - Crafting results
- `CraftItem` - Crafting requests
- `UseItem` - Item usage
- `RequestInventoryUpdate` - Inventory sync
- `DeleteItem` - Item deletion
- `InventoryUpdate` - Inventory updates
- `QuestDialogue` - Quest dialogue
- `QuestUpdate` - Quest progress updates
- `QuestToast` - Quest notifications
- `AcceptQuest` - Quest acceptance
- `TurnInQuest` - Quest completion
- `GetQuestState` - Quest state query (RemoteFunction)

**Shared** (Common Utilities):
- `Types.luau` - Shared type definitions
- `Constants.luau` - Game constants
- `Util.luau` - Utility functions
- `Events.luau` - Shared event definitions

**Assets**:
- `ItemsModel` - Weapon/item 3D models
- `VFX` - Visual effect templates (Slash, Hit, Skill)
- `EnemyModels` - Enemy character models (Goblin, Enememe, etc.)
- `SummonTemplates` - Summon ability templates (heal, shield, cage, hurt)
- `OriginCharacterModels` - Origin character models (TojiFushiguro, MakiPreAwakened, NaoyaZenin)

### ServerScriptService
Server-side scripts and services.

**Systems** (Server Services):
- `SkillService.luau` - Skill system management
- `LootSpawner.luau` - Loot spawn logic
- `CombatService.luau` - Combat system
- `DataService.luau` - Data persistence
- `LevelService.luau` - Level progression
- `LootService.luau` - Loot management
- `InventoryService.luau` - Inventory system
- `StatsService.luau` - Stats management
- `EnemyService.luau` - Enemy spawning/management
- `OriginService.luau` - Origin system
- `QuestService.luau` - Quest system

**Core**:
- `ServiceBase.luau` - Base service class
- `init.luau` - Server initialization script

### ServerStorage
Server-only data storage.

- `DataActor` - Data processing actor
- `Data` - Data storage folder
- `QuestNPC` - Quest NPC model
- `RBX_ANIMSAVES` - Animation save data

### StarterPlayer
Initial player scripts.

**StarterPlayerScripts** (Client Controllers):
- `CombatController.luau` - Combat input handling
- `SkillController.luau` - Skill input handling
- `HUDController.luau` - HUD management
- `LootController.luau` - Loot interaction
- `ClassSelectorController.luau` - Class selection UI
- `StatsController.luau` - Stats UI interaction
- `InventoryController.luau` - Inventory UI interaction
- `VFXTunerController.luau` - VFX tuning
- `OriginMenuController.luau` - Origin menu
- `QuestController.luau` - Quest UI interaction
- `init.luau` - Client initialization

**StarterCharacterScripts**:
- `PlayerAnimations.luau` - Character animation handling

### StarterGui
Initial player UI.

- `GameHUD` - Main HUD (ResourceBars, LevelBadge, StatPointsLabel, GoldLabel)
- `CombatUI` - Combat interface (ComboCounter)
- `ClassSelector` - Class selection screen
- `LootNotifications` - Loot pickup notifications
- `StatMenuPrototype` - Stats menu prototype script

### Workspace
Game world objects.

- `Terrain` - Terrain mesh
- `Rig` - Player rig reference
- Various effect folders (Yona VFX Pack, JJK Animations R6, etc.)
- Environment meshes (PolygonDungeon assets)

## Exported Modules Summary

### Phase 1: ReplicatedStorage/Modules (10 modules)
The following modules from `ReplicatedStorage/Modules` have been exported to `src/ReplicatedStorage/Modules/`:

1. **LootTable.luau** - Loot drop configuration
2. **StatsUIBuilder.luau** - Stats UI factory
3. **InventoryUIBuilder.luau** - Inventory UI factory
4. **StatsHelper.luau** - Stat calculation utilities
5. **EXPManager.luau** - Experience management
6. **AnimationData.luau** - Animation asset IDs
7. **EnemyConfig.luau** - Enemy definitions & spawn zones
8. **QuestData.luau** - Quest & NPC definitions
9. **EnemyBrain.luau** - Enemy AI state machine
10. **ItemData.luau** - Item database (562 lines, 20+ items)

### Phase 2: Combat & Skill System (11 files)

#### ServerScriptService/Systems (3 services)
11. **CombatService.luau** - Server combat logic, damage, combos, cooldowns
12. **SkillService.luau** - Server skill execution, buff management
13. **EnemyService.luau** - Enemy spawning, AI management, death handling

#### StarterPlayer/StarterPlayerScripts/Controllers (2 controllers)
14. **CombatController.luau** - Client combat input, combo display, animation
15. **SkillController.luau** - Skill input handling, ActionBar UI, VFX triggers

#### ReplicatedStorage/Modules (6 modules)
16. **CombatData.luau** - Damage formulas, stun types, hit outcomes
17. **CombatQuery.luau** - Hit detection (Box/Radius/Ray/Block), debug visuals
18. **PlayerProfile.luau** - Player data structure, stat formulas, EXP curves
19. **ClassData.luau** - Class definitions, starting stats, skill mappings
20. **SkillData.luau** - Skill definitions (12 skills across 4 classes)
21. **WeaponVFX.luau** - Weapon trail & VFX management, animation markers

**Total**: 21 files exported (6,099 lines of Luau code)

All exported modules preserve strict Luau typing and typed API exports.
