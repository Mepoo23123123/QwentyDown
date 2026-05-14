# Data System

Data system owns player profile loading, runtime data state and persistence.

## Authoritative scripts

- `ServerScriptService.Systems.DataService`
- `ReplicatedStorage.Modules.PlayerProfile`

## Related systems

- Inventory
- Stats
- Leveling
- Class selection
- Quests if persisted

## Invariants

- Server owns persisted data state.
- Client never directly edits persistent data.
- Data shape changes require defaults/migration handling.
- Save/load failures should fail safely and visibly in logs.

## Testing checklist

- Player join initializes data.
- Missing data creates defaults.
- Runtime systems receive expected data shape.
- Player leave saves data.
- Data changes do not break old profiles.

## Open questions

- Document current profile schema.
- Document save timing/autosave behavior.
- Document failure handling and retry policy.
