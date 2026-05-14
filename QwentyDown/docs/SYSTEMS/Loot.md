# Loot System

Loot manages item drops, collection requests, loot tables and rewards into inventory.

## Authoritative scripts/modules

- `ServerScriptService.Systems.LootService`
- `ServerScriptService.Systems.LootSpawner`
- `ReplicatedStorage.Modules.LootTable`
- `ReplicatedStorage.Modules.ItemData`

## Client scripts

- `StarterPlayer.StarterPlayerScripts.Controllers.LootController`

## Remotes

- `LootDropped`
- `CollectLoot`
- `CollectedLoot`

## Loot constants

From `Shared.Constants`:

| Constant | Value | Description |
|----------|-------|-------------|
| `LOOT_COLLECT_RADIUS` | 5 | Max distance to collect loot |
| `LOOT_SERVER_BUFFER` | 3 | Server-side buffer distance |
| `LOOT_COLLECT_INTERVAL` | 0.5s | Min interval between collections |
| `LOOT_LIFETIME` | 120s | How long loot persists in world |
| `LOOT_FLOAT_HEIGHT` | 3 | Float height above ground |

## Invariants

- Server owns actual loot existence and rewards.
- Client may request collection but server validates availability.
- Dropped item IDs must exist in `ItemData`.
- Collection should not duplicate rewards.

## Testing checklist

- Loot drops from expected sources.
- Client sees loot UI/marker.
- Collection validates distance/availability.
- Inventory receives correct item/quantity.
- Loot cannot be collected twice.

## Open questions

- Document loot table format and drop roll rules.
- Document world loot lifetime and ownership rules.
