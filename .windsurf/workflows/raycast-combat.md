---
description: How to work with the Raycast combat system in QwentyDown
---

# Raycast Combat System — Cascade Skill

## Architecture Overview

- **No RaycastHitboxV4** — pure `workspace:Raycast` only
- **Server-authoritative** — all raycasts run on server (CombatService, SkillService)
- **Combo-configured** — each combo hit (1..4) has its own `ComboConfig` with ray origins, distance, width
- **Wrapper module** — `ReplicatedStorage.Modules.RaycastCombat` is the single entry point

## Key Files

| File | Role |
|------|------|
| `ReplicatedStorage.Modules.RaycastCombat` | Core raycast wrapper (ComboCastOnce, CastOnce) |
| `ServerScriptService.Systems.CombatService` | Combo attacks via `RaycastCombat.ComboCastOnce` |
| `ServerScriptService.Systems.SkillService` | Skill attacks via `RaycastCombat.CastOnce` |
| `ReplicatedStorage.Modules.SkillData` | Skill definitions (Range, Damage, BackstabMult, etc.) |
| `ReplicatedStorage.Modules.CombatData` | Damage formulas |
| `ReplicatedStorage.Modules.CombatConstants` | Combo timing, stun, knockback constants |
| `ReplicatedStorage.Shared.Constants` | COMBO_MAX, DAMAGE_PER_HIT, OUTCOMES, etc. |
| `ReplicatedStorage.Shared.Types` | Type definitions (ComboState, HitType, SkillDefinition) |

## API Reference

### ComboCastOnce (for basic attacks)
```lua
local hitModels = RaycastCombat.ComboCastOnce(attacker: Player, comboCount: number, originPart: BasePart): { Model }
```
- `comboCount` is clamped to 1..4 internally
- Uses `COMBO_CONFIGS[comboCount]` for ray origins and distance
- Returns deduplicated list of target Models (with Humanoid)

### CastOnce (for skills)
```lua
local hitModels = RaycastCombat.CastOnce(attacker: Player, config: RaycastConfig): { Model }
```
- `config.originPart` (required) — usually HumanoidRootPart
- `config.maxDistance` (default 10)
- `config.filterInstances` (optional) — extra exclusion list
- Single raycast from originPart.Position along LookVector

## Combo Configs Structure

```lua
local COMBO_CONFIGS: { [number]: ComboConfig } = {
    [1] = { originOffsets = {...}, maxDistance = 7.5, width = 5.5 },
    [2] = { originOffsets = {...}, maxDistance = 8.5, width = 6.5 },
    [3] = { originOffsets = {...}, maxDistance = 9.5, width = 8.0 },
    [4] = { originOffsets = {...}, maxDistance = 11.5, width = 10.0 },
}
```

### Tuning Guide
- **Too short** → increase `maxDistance`
- **Too narrow** → spread `originOffsets` X values wider
- **Missing low targets** → add offset with negative Y
- **Missing high targets** → add offset with Y > 1.0
- **Combo4 too strong** → reduce `maxDistance` or remove an offset

## How to Add a New Skill with Raycast

1. Define skill in `ReplicatedStorage.Modules.SkillData`
2. In `SkillService.ExecMelee` or `ExecRanged`, call:
```lua
local hitModels = RaycastCombat.CastOnce(player, {
    originPart = hrp,
    maxDistance = skill.Range or 20,
})
```
3. Process hits, apply damage/effects

## How to Add Combo5+

1. Add `[5]` entry in `COMBO_CONFIGS`
2. Update `COMBO_MAX` in `Shared.Constants`
3. Add `DAMAGE_PER_HIT[5]` in Constants
4. Ensure `combo.count` can reach 5 in CombatService

## User Preferences

- **No hacks/crutches** — rewrite cleanly if needed
- **Ask before major changes** — user wants to be consulted
- **Server authority** — never trust client for damage/hit validation
- **HumanoidRootPart-based** origins for all raycasts

## Removed Systems (do NOT reintroduce)

- Old hitbox system (Touched-based) — fully removed from CombatService, SkillService, Constants, CombatData
- RaycastHitboxV4 — was in ReplicatedStorage but removed by user; RaycastCombat no longer depends on it
- Visual debug beams — removed per user request

## Testing Checklist

- [ ] Play mode → combo 1..4 hits enemies
- [ ] Skills Z/X/C hit at correct range
- [ ] No errors in Output about RaycastHitboxV4
- [ ] Damage numbers appear on hit
- [ ] Knockback/stun works on combo 4
- [ ] Backstab multiplier applies correctly
