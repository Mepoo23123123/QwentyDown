# Devin Code Drafts

This file stores Luau drafts and patch plans that Devin wants the local Windsurf Agent to apply or verify with Roblox Studio MCP.

Do not treat drafts as final until Windsurf Agent reports successful Studio application/testing in `docs/WINDSURF_TO_DEVIN.md`.

## Draft block template

````md
## YYYY-MM-DD HH:MM UTC — Draft title

**Status:** Draft / Ready for Windsurf / Applied / Superseded
**Target:** Studio path or repository file
**Reason:** why this change is needed
**Related request:** section in `docs/DEVIN_TO_WINDSURF.md`

### Patch plan

### Code

```lua
-- Luau code here
```

### Expected behavior

### Testing instructions
````

## Rules

- Use exact Studio paths, for example `ReplicatedStorage.Modules.RaycastCombat`.
- Prefer `--!strict` for new modules where practical.
- Keep requires/imports at the top.
- Preserve server authority for gameplay.
- Validate client-to-server remote payloads server-side.
- Keep changes minimal unless user approved a larger rewrite.
- For raycast combat, follow `docs/raycast-combat.md`.

## Current draft

No code draft is active yet.
