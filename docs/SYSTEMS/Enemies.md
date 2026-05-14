# Enemies and Spawn System

Enemy and spawn systems manage enemy definitions, AI behavior, zones and spawn points.

## Authoritative scripts/modules

- `ServerScriptService.Systems.EnemyService`
- `ServerScriptService.Systems.SpawnService`
- `ReplicatedStorage.Modules.EnemyData`
- `ReplicatedStorage.Modules.EnemyAI`
- `ReplicatedStorage.Modules.SpawnData`
- `ReplicatedStorage.Modules.ZoneTracker`

## Remotes

- `ZoneChanged`

## EnemyDefinition schema

From `EnemyData`:

```lua
export type EnemyDefinition = {
    Id: string,
    Name: string,
    Type: string?,           -- "small" | "medium" | "large" | "boss"
    HP: number,
    Damage: number,
    Speed: number,
    AttackRange: number,
    AggroRange: number,
    AttackFrequency: number,
    RewardEXP: number,
    RewardGold: number,
    IsPassive: boolean?,
    IsElite: boolean?,
    IsBoss: boolean?,
    ComboAttacks: number?,
    PhaseThreshold: number?,
    RageSpeedMult: number?,
    RageDamageMult: number?,
}
```

## Current enemies

From `EnemyData`:

| Enemy | Type | HP | Damage | Speed | Aggro | EXP | Gold |
|-------|------|----|--------|-------|-------|-----|------|
| TrainingDummy | passive | 9999 | 0 | 0 | 0 | 0 | 0 |
| Scout | small | 80 | 6 | 18 | 25 | 15 | 3 |
| Goblin | medium | 150 | — | — | — | — | — |

## Invariants

- Server owns enemy spawning and AI state.
- Enemy rewards should route through authoritative combat/loot systems.
- Spawn zones should respect configured limits.
- Zone tracking should not trust client position claims.

## Testing checklist

- Zones initialize with expected spawn points.
- Enemies spawn within configured max counts.
- Enemies can be damaged/defeated.
- Rewards/drop logic triggers once.
- Zone changes notify client correctly.

## Open questions

- Document enemy schema.
- Document spawn zone schema.
- Document AI behavior states and performance constraints.
