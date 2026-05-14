# Decision Log

Record durable project decisions here.

## Format

```md
## YYYY-MM-DD — Decision title

**Status:** Accepted / Superseded / Rejected

**Context:** why this decision was needed

**Decision:** what we chose

**Consequences:** tradeoffs and follow-up work

**Related docs/scripts:** links or Studio paths
```

## 2026-05-03 — Documentation reset

**Status:** Accepted

**Context:** old root markdown documents were deleted so the project docs can be rebuilt cleanly.

**Decision:** `ROBLOX_LUAU_KNOWLEDGE_BASE.md` is the root knowledge index. New docs live under `docs/`.

**Consequences:** deleted old docs should not be used as source of truth. New durable practices must be added to the new docs structure.

**Related docs/scripts:** `ROBLOX_LUAU_KNOWLEDGE_BASE.md`, `docs/README.md`.

## 2026-05-03 — Research-first before important Roblox/Luau code

**Status:** Accepted

**Context:** project code should use current Roblox/Luau practices, not stale assumptions.

**Decision:** before meaningful Roblox/Luau changes, consult Roblox Creator Docs/API Reference, official Luau docs, DeepWiki `luau-lang/luau`, and DevForum only as secondary support.

**Consequences:** implementation may take a little longer, but should reduce outdated API usage and repeated mistakes.

**Related docs/scripts:** `.windsurf/workflows/roblox-research-before-code.md`, `docs/RESEARCH/*`.

## 2026-05-03 — UI Builder/Controller split

**Status:** Accepted

**Context:** Inventory and stats UI use dedicated builders and controllers.

**Decision:** visual hierarchy and reusable UI components belong in builder modules; state, events and data updates belong in controllers.

**Consequences:** redesigns should mostly touch builders, while gameplay/UI logic stays in controllers.

**Related docs/scripts:** `ReplicatedStorage.Modules.InventoryUIBuilder`, `StarterPlayer.StarterPlayerScripts.Controllers.InventoryController`, `ReplicatedStorage.Modules.StatsUIBuilder`, `StarterPlayer.StarterPlayerScripts.Controllers.StatsController`.
