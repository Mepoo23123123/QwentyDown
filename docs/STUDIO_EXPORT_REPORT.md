# Roblox Studio Export Report

**Date**: 2026-05-15 (Updated)  
**Project**: QwentyDown  
**Export Method**: Roblox Studio MCP via script_read and execute_luau

## Export Summary

Successfully exported 21 files from Roblox Studio across multiple directories.

### Phase 1: ReplicatedStorage/Modules (10 modules)

| Module | Lines | Description | Notes |
|--------|-------|-------------|-------|
| LootTable.luau | 172 | Loot drop configuration | - |
| StatsUIBuilder.luau | 289 | Stats UI factory functions | - |
| InventoryUIBuilder.luau | 535 | Inventory UI factory functions | - |
| StatsHelper.luau | 216 | Stat calculation utilities | - |
| EXPManager.luau | 23 | Experience management | - |
| AnimationData.luau | 32 | Animation asset IDs for combat | - |
| EnemyConfig.luau | 197 | Enemy definitions & spawn zones | - |
| QuestData.luau | 150 | Quest & NPC definitions | - |
| EnemyBrain.luau | 423 | Enemy AI state machine | Fixed type qualification |
| ItemData.luau | 562 | Item database (20+ items) | Retrieved via execute_luau |

**Phase 1 Total**: 2,599 lines

### Phase 2: Combat & Skill System (11 files)

#### ServerScriptService/Systems (3 services)

| Module | Lines | Description | Notes |
|--------|-------|-------------|-------|
| CombatService.luau | 407 | Server combat logic, damage, combos, cooldowns | - |
| SkillService.luau | 260 | Server skill execution, buff management | - |
| EnemyService.luau | 484 | Enemy spawning, AI management, death handling | - |

#### StarterPlayer/StarterPlayerScripts/Controllers (2 controllers)

| Module | Lines | Description | Notes |
|--------|-------|-------------|-------|
| CombatController.luau | 496 | Client combat input, combo display, animation | - |
| SkillController.luau | 505 | Skill input handling, ActionBar UI, VFX triggers | - |

#### ReplicatedStorage/Modules (6 modules)

| Module | Lines | Description | Notes |
|--------|-------|-------------|-------|
| CombatData.luau | 75 | Damage formulas, stun types, hit outcomes | - |
| CombatQuery.luau | 351 | Hit detection (Box/Radius/Ray/Block), debug visuals | - |
| PlayerProfile.luau | 95 | Player data structure, stat formulas, EXP curves | - |
| ClassData.luau | 169 | Class definitions, starting stats, skill mappings | - |
| SkillData.luau | 250 | Skill definitions (12 skills across 4 classes) | - |
| WeaponVFX.luau | 408 | Weapon trail & VFX management, animation markers | - |

**Phase 2 Total**: 3,500 lines

## Grand Total

**Total Files Exported**: 21 files  
**Total Lines**: 6,099 lines of Luau code

## Issues Encountered

### ItemData Truncation
- **Issue**: `script_read` tool truncated ItemData.luau at ~2573 bytes
- **Resolution**: Used `execute_luau` to read `ModuleScript.Source` property directly
- **Result**: Full 562-line file successfully exported

### EnemyBrain Type Errors
- **Issue**: Lint warnings about undefined type `EnemyDefinition`
- **Resolution**: Qualified type as `EnemyConfig.EnemyDefinition` in all declarations
- **Locations Fixed**: Lines 8, 28, 153, 208
- **Result**: All lint errors resolved

## File Structure

```
e:/QwentyDown/src/ReplicatedStorage/Modules/
├── LootTable.luau
├── StatsUIBuilder.luau
├── InventoryUIBuilder.luau
├── StatsHelper.luau
├── EXPManager.luau
├── AnimationData.luau
├── EnemyConfig.luau
├── QuestData.luau
├── EnemyBrain.luau
├── ItemData.luau
├── CombatData.luau
├── CombatQuery.luau
├── PlayerProfile.luau
├── ClassData.luau
├── SkillData.luau
└── WeaponVFX.luau

e:/QwentyDown/src/ServerScriptService/Systems/
├── CombatService.luau
├── SkillService.luau
└── EnemyService.luau

e:/QwentyDown/src/StarterPlayer/StarterPlayerScripts/Controllers/
├── CombatController.luau
└── SkillController.luau
```

## Code Quality

- **Strict Mode**: All modules use `--!strict` directive
- **Type Safety**: Full Luau typing preserved
- **Typed API**: All exported types explicitly defined
- **Comments**: Russian and English comments preserved verbatim

## Module Dependencies

Based on code analysis:
- `EnemyBrain.luau` depends on `EnemyConfig.luau` (type qualification)
- `StatsUIBuilder.luau` uses `StatsHelper.luau`
- `InventoryUIBuilder.luau` uses `ItemData.luau`
- All modules use shared types from `ReplicatedStorage.Shared.Types`

## Next Steps

1. ✅ Export server-side services from `ServerScriptService/Systems/` (Phase 2 complete)
2. ✅ Export client controllers from `StarterPlayer/` (Phase 2 complete)
3. Export UI templates from `StarterGui/`
4. Export remaining ServerScriptService services (StatsService, QuestService, LootSpawner, etc.)
5. Export remaining ReplicatedStorage modules (Themes, StatFormula, OriginData, etc.)
6. Set up local development environment for offline work

## Verification

All exported files have been verified to:
- Contain complete source code (no truncation)
- Preserve original line endings and formatting
- Maintain strict type annotations
- Include all comments and documentation

## Export Method Notes

- **script_read**: Used for most modules (lines 1-300, 301-562 for large files)
- **execute_luau**: Used for ItemData to bypass byte limit via `ModuleScript.Source`
- **multi_edit**: Used for EnemyBrain type fixes
- **write_to_file**: Used for all file creation

Export completed successfully without data loss.
