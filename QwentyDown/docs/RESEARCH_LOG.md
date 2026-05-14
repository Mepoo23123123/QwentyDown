# Research Log

Use this file to record research-first work before important Roblox/Luau implementation tasks.

## Entry format

```md
## YYYY-MM-DD — Task title

**Task:** what is being changed

**Project context:** scripts/modules/systems involved

**Sources checked:** Roblox docs, Luau docs, DeepWiki, DevForum, source inspection

**Findings:** concise relevant facts

**Decision:** how findings affected implementation

**Follow-up docs:** docs updated after the task
```

## Source priority

1. Roblox Creator Docs / API Reference
2. Official Luau documentation
3. DeepWiki `luau-lang/luau`
4. Roblox DevForum as secondary evidence
5. Open-source/community examples only after cross-checking

## Current baseline

- DeepWiki `luau-lang/luau` should be used for Luau internals, type system, analyzer/linter, frontend/module-system and tooling questions.
- Roblox Creator Docs/API Reference should be used for engine APIs and instance behavior.
- Project source inspection remains required before editing existing systems.

## 2026-05-14 — combat-defense-core-v1

**Task:** Split dodge i-frames from stun/action lock and route enemy damage through combat outcome checks.

**Project context:** `CombatService`, `EnemyService`, `Shared.Constants`, `Shared.Types`, combat remotes and docs.

**Sources checked:** Roblox Creator Docs for `VectorForce`, `RemoteEvent`, and cleanup behavior via `Debris`; official Luau type checking docs; DeepWiki `luau-lang/luau` type system notes; exported project source and combat roadmap.

**Findings:** `VectorForce` applies constant force and should remain short-lived/cleaned up. `RemoteEvent` is the right one-way server/client notification path for dodge and damage feedback. Luau `--!strict` benefits from explicit exported union/state types. Existing project code already cleans dash forces with `Debris` and uses server-owned combat state.

**Decision:** Keep the existing dash impulse, but add server runtime state for `invulnerableUntil`, `actionLockUntil`, and `recoveryUntil`. Add `dodged` as an explicit hit feedback type and route enemy player damage through `CombatService.ApplyEnemyDamageToPlayer`.

**Follow-up docs:** `SYSTEMS/Combat.md`, `REMOTE_CONTRACTS.md`, `TESTING_CHECKLIST.md`.
