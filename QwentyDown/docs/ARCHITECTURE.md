# Architecture

QwentyDown uses a server-authoritative Roblox architecture: the server owns gameplay truth, while the client owns presentation, input and local UI state.

## Server authority

Server systems validate and apply gameplay state:

- `ServerScriptService.Systems.CombatService`
- `ServerScriptService.Systems.SkillService`
- `ServerScriptService.Systems.InventoryService`
- `ServerScriptService.Systems.DataService`
- `ServerScriptService.Systems.StatsService`
- `ServerScriptService.Systems.LevelService`
- `ServerScriptService.Systems.LootService`
- `ServerScriptService.Systems.EnemyService`
- `ServerScriptService.Systems.SpawnService`

Server-side responsibilities:

- Damage and hit validation through server-side combat queries.
- Inventory ownership, equip/use/delete/craft operations.
- Player data loading/saving.
- Stat allocation and level progression.
- Loot rewards and collection validation.
- Enemy and spawn management.

## Client responsibilities

Client controllers handle UX and presentation:

- `CombatController`
- `SkillController`
- `HUDController`
- `InventoryController`
- `StatsController`
- `ClassSelectorController`
- `LootController`
- `NPCController`
- `VFXTunerController`

Client-side responsibilities:

- Input capture and local feedback.
- UI construction, filtering, sorting and selection state.
- Animation playback and visual effects.
- Non-authoritative previews and tuning tools.

## Shared modules

`ReplicatedStorage.Modules` and `ReplicatedStorage.Shared` contain reusable data, formulas and wrappers:

- Data definitions: `ItemData`, `SkillData`, `EnemyData`, `ClassData`, `LootTable`, `SpawnData`.
- Combat utilities: `CombatQuery`, `CombatData`, `CombatTypes`.
- UI builders: `InventoryUIBuilder`, `StatsUIBuilder`.
- VFX: `WeaponVFX`.
- Shared primitives: `Types`, `Constants`, `Util`, `Events`.

## Networking

Remote communication is centralized around `ReplicatedStorage.Remotes` and project usage of `RemoteManager`.

Rules:

- Client may request actions.
- Server validates every gameplay-relevant request.
- Server sends authoritative state updates back to client.
- Do not trust client item IDs, stat requests, hit claims, distances or cooldown state.

## UI pattern

Preferred split:

- Builder modules create visual hierarchy and reusable components.
- Controllers own state, input bindings and data-driven updates.

Current examples:

- `InventoryUIBuilder` + `InventoryController`
- `StatsUIBuilder` + `StatsController`

## VFX pattern

- Server decides authoritative combat outcomes.
- Client/server may spawn visual feedback depending on current implementation.
- VFX modules should clean spawned instances and avoid persistent orphaned effects.

## Documentation invariant

When architecture changes, update:

- this file
- affected `docs/SYSTEMS/*.md`
- `REMOTE_CONTRACTS.md` if remotes changed
- `DECISIONS.md` if the change introduces a durable architectural decision
