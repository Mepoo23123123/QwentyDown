# Remote Contracts

This document tracks RemoteEvents and RemoteFunctions under `ReplicatedStorage.Remotes` and the expected server/client responsibilities.

## Rules

- Treat all client-to-server payloads as untrusted.
- Server validates types, ownership, cooldowns, distance and permissions.
- Server sends authoritative state back to clients.
- Update this file whenever a remote is added, removed or its payload changes.

## Combat remotes

### `CombatAction`

- **Direction:** Client -> Server
- **Payload:** `action: CombatActionType` where `CombatActionType = "attack" | "dash" | "block_start" | "block_end"`
- **Server validates:** action string, player state, stun/action lock, cooldown, rate limit, combo state, equipped weapon, server-side hit detection.
- **Server flow:**
  - `attack`: checks stun → checks cooldown (buffers if on cooldown) → increments combo → raycast → process hit → fire `ComboUpdated`, `DamageReceived`, `HitVFX`.
  - `dash`: checks stun/action lock/cooldown → applies dash force + server-side invulnerability/action-lock/recovery windows.
  - `block_start`/`block_end`: toggles block state.

### `DamageReceived`

- **Direction:** Server -> Client
- **Payload:** `damage: number, hitType: HitType, targetModel: Model?`
- **Purpose:** notify damage feedback to attacker and victim.
- **Hit types:** `"hit" | "crit" | "blocked" | "skill" | "knockdown" | "dodged"`.

### `StunApplied`

- **Direction:** Server -> Client
- **Payload:** `duration: number, stunType: string`
- **Purpose:** notify stun feedback/state.

### `DodgeState`

- **Direction:** Server -> Client
- **Payload:** `iframeDuration: number, recoveryDuration: number`
- **Purpose:** notify dodge timing feedback. Server remains authoritative for invulnerability.

### `ComboUpdated`

- **Direction:** Server -> Client
- **Payload:** `comboCount: number`
- **Purpose:** sync combo count to client presentation.

### `HitVFX`

- **Direction:** Server -> Client
- **Payload:** `hitCFrame: CFrame`
- **Purpose:** spawn hit VFX at hit position on client.

## Skill remotes

### `SkillCast`

- **Direction:** Client -> Server
- **Purpose:** request skill cast.
- **Server validates:** skill ownership/class, cooldown, state, range/hit rules.

### `SkillCooldown`

- **Direction:** Server -> Client
- **Purpose:** sync skill cooldown UI/state.

## Inventory remotes

### `RequestInventoryUpdate`

- **Direction:** Client -> Server
- **Purpose:** request current inventory/equipment/gold state.

### `InventoryUpdate`

- **Direction:** Server -> Client
- **Purpose:** authoritative inventory/equipment/gold update.

### `EquipItem`

- **Direction:** Client -> Server
- **Payload:** `itemId: string`
- **Server validates:** item exists, player owns item, item has compatible slot.

### `UnequipItem`

- **Direction:** Client -> Server
- **Payload:** `slotName: string`
- **Server validates:** slot exists and belongs to player equipment state.

### `UseItem`

- **Direction:** Client -> Server
- **Payload:** `itemId: string`
- **Server validates:** item exists, player owns item, item is usable/consumable.

### `DeleteItem`

- **Direction:** Client -> Server
- **Payload:** `itemId: string`, optional quantity.
- **Server validates:** ownership and quantity.

### `CraftItem`

- **Direction:** Client -> Server
- **Payload:** craft target/item id.
- **Server validates:** recipe, materials, inventory capacity.

### `CraftResult`

- **Direction:** Server -> Client
- **Purpose:** result feedback for crafting.

## Stats and level remotes

### `UpdateStatsUI`

- **Direction:** Server -> Client
- **Purpose:** authoritative stat UI sync.

### `UpdateLevelUI`

- **Direction:** Server -> Client
- **Purpose:** level/EXP UI sync.

### `AllocateStatPoint` / `AllocateStatPoints`

- **Direction:** Client -> Server
- **Server validates:** available points, stat name, amount and player state.

### `LevelUpEvent`

- **Direction:** Server -> Client
- **Purpose:** level-up notification.

## Class remotes

### `SelectClass`

- **Direction:** Client -> Server
- **Server validates:** class exists, player can select/change class.

## Loot remotes

### `LootDropped`

- **Direction:** Server -> Client
- **Purpose:** show loot drop.

### `CollectLoot`

- **Direction:** Client -> Server
- **Server validates:** loot exists, distance/ownership/availability.

### `CollectedLoot`

- **Direction:** Server -> Client
- **Purpose:** collection result feedback.

## Zone remotes

### `ZoneChanged`

- **Direction:** Server -> Client
- **Purpose:** notify active zone changes.

## Quest/NPC remotes

### `AcceptQuest`

- **Direction:** Client -> Server
- **Server validates:** quest exists and can be accepted.

### `TurnInQuest`

- **Direction:** Client -> Server
- **Server validates:** quest progress and rewards.

### `QuestUpdate`

- **Direction:** Server -> Client
- **Purpose:** sync quest state.

### `GetCompletedQuest`

- **Type:** RemoteFunction
- **Direction:** Client -> Server -> Client

### `HasProgressQuest`

- **Type:** RemoteFunction
- **Direction:** Client -> Server -> Client

### `GetActiveQuests`

- **Type:** RemoteFunction
- **Direction:** Client -> Server -> Client
