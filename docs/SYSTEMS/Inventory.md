# Inventory System

Inventory manages player items, equipment, consumables, crafting, gold display and inventory UI.

## Authoritative scripts

- `ServerScriptService.Systems.InventoryService`
- `ReplicatedStorage.Modules.ItemData`

## Client scripts

- `StarterPlayer.StarterPlayerScripts.Controllers.InventoryController`
- `ReplicatedStorage.Modules.InventoryUIBuilder`

## Remotes

- `RequestInventoryUpdate`
- `InventoryUpdate`
- `EquipItem`
- `UnequipItem`
- `UseItem`
- `DeleteItem`
- `CraftItem`
- `CraftResult`

## Inventory constants

From `Shared.Constants`:

| Constant | Value | Description |
|----------|-------|-------------|
| `MAX_INVENTORY_SLOTS` | 30 | Max slots in inventory grid |
| `MAX_STACK_SIZE` | 99 | Max stack for stackable items |
| `EQUIPMENT_SLOTS` | {"Weapon", "Armor", "Accessory"} | Equipment slot names |

## ItemDefinition schema

From `ItemData`:

```lua
export type ItemRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"
export type ItemType = "Material" | "Consumable" | "Weapon" | "Armor" | "Accessory"
export type EquipmentSlot = "Weapon" | "Armor" | "Accessory"

export type ItemDefinition = {
    Id: string,
    Name: string,
    NameRu: string,
    Type: ItemType,
    Rarity: ItemRarity,
    Description: string,
    Value: number,           -- Price in gold
    IconId: number,          -- Roblox Asset ID (0 = placeholder)
    -- Consumable
    Effect: {[string]: number}?,  -- { HP = 50, MP = 30 }
    -- Equipment
    Slot: EquipmentSlot?,
    Stats: ItemStats?,            -- Derived stat bonuses (legacy)
    BaseStats: BaseStatBonuses?,   -- Base stat bonuses (STR/AGI/INT/VIT/LUK)
    -- Weapon
    ModelName: string?,
    GripOffset: CFrame?,
    Animations: WeaponAnimations?,
    CombatConfig: WeaponCombatConfig?,
    Trail: TrailConfig?,
    VFX: VFXConfig?,
    -- Material
    Craftable: boolean?,
}
```

## Rarity colors

| Rarity | Color |
|--------|-------|
| Common | RGB(150, 150, 155) |
| Uncommon | RGB(50, 200, 80) |
| Rare | RGB(70, 130, 255) |
| Epic | RGB(160, 80, 230) |
| Legendary | RGB(255, 180, 30) |

## Invariants

- Server owns item ownership and equipment state.
- Client inventory UI displays server-provided state.
- Client may request equip/use/delete/craft but server validates everything.
- `IconId` display is UI-only; item identity comes from `ItemData` and server state.

## UI pattern

- `InventoryUIBuilder` creates the visual hierarchy.
- `InventoryController` fills slots, tracks selected item, filters/sorts and connects buttons.
- Item images use `ImageLabel` where `IconId` is present; glyphs are fallback.
- Slot icons use `ScaleType.Crop` with `UICorner` matching slot rounding.

## Testing checklist

- Inventory opens/closes.
- Server inventory update populates slots.
- Empty slots clear image, glyph, quantity and rarity state.
- Equipped items are marked correctly.
- Item detail panel updates for selected item.
- Equip/use/delete requests work and server rejects invalid requests.

## Open questions

- Document exact item schema from `ItemData` after next data pass.
- Document crafting recipe structure and validation path.
