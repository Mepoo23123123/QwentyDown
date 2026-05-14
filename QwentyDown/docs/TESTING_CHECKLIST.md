# Testing Checklist

Use these checklists before marking Roblox/Luau tasks complete.

## Global checks

- Play Mode starts without relevant errors.
- Studio console checked after the feature path runs.
- No obvious infinite loops, runaway instance creation or connection leaks.
- Server/client responsibility is preserved.
- New behavior is documented if durable.

## UI changes

- UI opens and closes correctly.
- Main path works at common 16:9 resolution.
- Empty state works.
- Hover/click/selection states work.
- Text is readable and not clipped.
- Images respect intended scaling and clipping.
- No console errors from UI creation or updates.

## Combat changes

- Basic attack works.
- Cooldown works.
- Combo progression works.
- Server rejects invalid/spam requests.
- Hits are server-authoritative.
- Damage is not duplicated.
- VFX/animation does not desync badly from combat result.
- Dodge i-frames prevent player damage only during the server window.
- Enemy hits respect dodge i-frames and block state.
- Invalid `CombatAction` payloads are rejected without side effects.

## Inventory changes

- Inventory update loads from server.
- Equip/unequip works.
- Consumables only show/use when valid.
- Delete/craft validates ownership and quantity.
- Item icons and rarity colors display correctly.
- Equipped state is reflected in grid/equipment UI.

## VFX changes

- Effect spawns at intended attachment/world position.
- Effect lifetime cleanup works.
- Preview tools clean previous previews.
- No persistent orphaned particle emitters/parts.
- Performance remains acceptable under repeated use.

## Data changes

- Player join loads data or defaults safely.
- Player leaving saves data.
- Runtime state does not trust client data.
- Data shape changes include migration/default handling.

## Remote changes

- Payload types validated server-side.
- Invalid item/skill/stat names are rejected.
- Cooldown/rate-limit considered for spam-prone requests.
- `REMOTE_CONTRACTS.md` updated.

## Documentation changes

- Main index links to new docs.
- System docs updated if behavior changed.
- Research source recorded when external information influenced the solution.
