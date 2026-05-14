# UI System

UI is client-owned presentation. Gameplay state shown in UI should come from authoritative server updates where relevant.

## Key scripts/modules

- `StarterPlayer.StarterPlayerScripts.Controllers.HUDController`
- `StarterPlayer.StarterPlayerScripts.Controllers.InventoryController`
- `StarterPlayer.StarterPlayerScripts.Controllers.StatsController`
- `StarterPlayer.StarterPlayerScripts.Controllers.ClassSelectorController`
- `StarterPlayer.StarterPlayerScripts.Controllers.NPCController`
- `StarterPlayer.StarterPlayerScripts.Controllers.LootController`
- `ReplicatedStorage.Modules.InventoryUIBuilder`
- `ReplicatedStorage.Modules.StatsUIBuilder`
- `ReplicatedStorage.Modules.Themes`
- `ReplicatedStorage.Design.StyleSheet`
- `ReplicatedStorage.Design.BaseStyleSheet`

## Invariants

- UI builders create visual components.
- Controllers own event wiring and state updates.
- UI should be resilient to missing/empty data.
- UI changes should be checked visually in Play Mode.

## Testing checklist

- UI opens/closes and does not block unrelated controls unintentionally.
- Text is readable and not clipped.
- Images scale/clamp as intended.
- Hover/click states work.
- Console has no relevant UI errors.

## Open questions

- Document current design token strategy between `Themes`, builder constants and `ReplicatedStorage.Design` stylesheets.
- Decide which UI should migrate to shared style rules and which should remain script-built.
