# Skills System

Skills manage player abilities, cooldowns, skill hit logic and skill VFX.

## Authoritative scripts/modules

- `ServerScriptService.Systems.SkillService`
- `ReplicatedStorage.Modules.SkillData`
- `ReplicatedStorage.Modules.CombatQuery`
- `ReplicatedStorage.Modules.CombatData`

## Client scripts

- `StarterPlayer.StarterPlayerScripts.Controllers.SkillController`

## Remotes

- `SkillCast`
- `SkillCooldown`

## SkillDefinition schema

From `Shared.Types`:

```lua
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
    Cooldown: number,
    ManaCost: number,
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
```

## Current skills (Maki Zenin)

From `SkillData`:

| Skill | Type | Slot | Mana | Cooldown | Range | Key |
|-------|------|------|------|----------|-------|-----|
| Slash | melee | 2 | 5 | 1.5s | 8 | Z |
| Power Strike | melee | 3 | 15 | 4s | 10 | X |
| War Cry | buff | 4 | 20 | 15s | 0 | C |

## Invariants

- Server validates skill availability and cooldown.
- Server owns hit/damage decisions for skill effects.
- `SkillService` uses `CombatQuery` for melee front-box and ranged ray checks.
- Client handles input and cooldown display.
- Skill definitions should be data-driven through `SkillData`.

## Testing checklist

- Skill casts when valid.
- Cooldown blocks spam.
- Invalid skills are rejected.
- Skill hit detection matches intended range.
- Ranged skills stop on walls.
- Piercing ranged skills can hit multiple characters in line.
- Skill VFX cleans up.

## Open questions

- Document full `SkillData` schema.
- Document per-class skill unlock/ownership rules.
