# Project Overview

QwentyDown — Roblox RPG project with server-authoritative gameplay systems and client-side controllers for UX, input, UI, animation and VFX.

## Current source of truth

- `ROBLOX_LUAU_KNOWLEDGE_BASE.md` — top-level knowledge index.
- `docs/` — current project documentation.
- `.windsurf/workflows/roblox-research-before-code.md` — research-first workflow before meaningful Roblox/Luau code changes.

## High-level systems

- **Combat:** basic combo attacks, server-side combat queries, cooldowns, stun/knockback, combat VFX.
- **Skills:** skill casting, cooldowns, skill data and server validation.
- **Inventory:** items, equipment, consumables, crafting, UI, inventory updates.
- **Data:** player profile loading/saving and runtime service state.
- **Stats/Leveling:** stat allocation, level UI and stat formulas.
- **Loot:** drops, collection, loot tables and inventory rewards.
- **Enemies/Spawn:** enemy data, AI, spawn zones and zone tracking.
- **UI:** HUD, inventory, stats menu, class selector, NPC dialogue, VFX tuner.
- **VFX:** weapon trails, slash effects, hit effects, skill effects and preview tooling.

## Known Studio structure

- `ReplicatedStorage.Modules` — shared data/modules such as `ItemData`, `SkillData`, `CombatQuery`, `CombatData`, `WeaponVFX`, UI builders.
- `ReplicatedStorage.Remotes` — RemoteEvents/RemoteFunctions plus `RemoteManager`.
- `ReplicatedStorage.Shared` — shared types, constants and utility modules.
- `ServerScriptService.Systems` — authoritative server services.
- `StarterPlayer.StarterPlayerScripts.Controllers` — client controllers.

## Documentation rules

- Docs should describe actual project behavior, not aspirational architecture.
- If implementation changes, update affected system docs.
- External practices must be checked against Roblox Creator Docs, official Luau docs, or DeepWiki `luau-lang/luau` before being promoted to project rules.
