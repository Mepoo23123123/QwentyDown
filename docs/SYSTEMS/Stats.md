# Stats and Leveling System

Stats and leveling manage player attributes, point allocation, formulas, level UI and progression.

## Authoritative scripts/modules

- `ServerScriptService.Systems.StatsService`
- `ServerScriptService.Systems.LevelService`
- `ReplicatedStorage.Modules.StatsHelper`
- `ReplicatedStorage.Modules.StatFormula`
- `ReplicatedStorage.Modules.EXPManager`

## Client scripts/modules

- `StarterPlayer.StarterPlayerScripts.Controllers.StatsController`
- `ReplicatedStorage.Modules.StatsUIBuilder`

## Remotes

- `UpdateStatsUI`
- `UpdateLevelUI`
- `AllocateStatPoint`
- `AllocateStatPoints`
- `LevelUpEvent`

## Invariants

- Server validates available stat points.
- Server owns final stat values.
- Client displays authoritative stats.
- Formula changes should be documented because they affect balance.

## Testing checklist

- Stats UI opens and displays current state.
- Stat allocation works only with available points.
- Invalid stat names/amounts are rejected.
- Level-up updates UI.
- Derived stats recalculate correctly.

## Open questions

- Document full stat list and formulas.
- Document class interactions with stats.
