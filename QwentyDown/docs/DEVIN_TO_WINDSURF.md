# Devin to Windsurf Agent

This file is the command channel from Devin to the local Windsurf Agent that has working Roblox Studio MCP access.

Windsurf Agent should read the newest request block first, execute it using the open Roblox Studio place and MCP tools, then write the result to `docs/WINDSURF_TO_DEVIN.md`.

## Standing instructions for Windsurf Agent

1. Read `ROBLOX_LUAU_KNOWLEDGE_BASE.md`.
2. Read `docs/AGENT_BRIDGE_PROTOCOL.md`.
3. Read task-specific docs:
   - `docs/roblox-research-before-code.md` before meaningful Roblox/Luau edits.
   - `docs/testing.md` after code changes.
   - `docs/docs-update.md` after significant changes.
   - `docs/audit.md` for audits.
   - `docs/raycast-combat.md` for raycast combat work.
4. Use Roblox Studio MCP for Studio-side truth:
   - `list_roblox_studios`
   - `set_active_studio`
   - `script_read`
   - `script_search`
   - `script_grep`
   - `multi_edit`
   - `execute_luau`
   - `start_stop_play`
   - `console_output`
   - `screen_capture`
5. If Devin provides code in `docs/DEVIN_CODE_DRAFTS.md`, apply it only to the stated Studio path or repository file.
6. Report every applied edit, test and console issue in `docs/WINDSURF_TO_DEVIN.md`.
7. If user input is needed, write a `Needs User` response and stop.

## Current request template

```md
## YYYY-MM-DD HH:MM UTC — Request title

**Status:** Pending
**Owner:** Windsurf Agent
**Scope:** 
**Relevant docs:** 

### Task

### Inputs

### Required MCP checks

### Done criteria
```

## 2026-05-14 19:50 UTC — Verify bridge readiness

**Status:** Done
**Owner:** Windsurf Agent
**Scope:** Roblox Studio MCP connection and QwentyDown docs
**Relevant docs:** `docs/AGENT_BRIDGE_PROTOCOL.md`, `docs/testing.md`

### Task

Confirm that the local Windsurf Agent can use Roblox Studio MCP for QwentyDown.

### Inputs

- The user has Roblox Studio open with MCP enabled.
- Devin cannot directly reach local Roblox Studio MCP, so this file bridge is the fallback workflow.

### Required MCP checks

- `list_roblox_studios`
- `set_active_studio` if more than one Studio instance exists
- `script_search` for one known QwentyDown script/module if the place is open
- `console_output` if Play Mode is already running

### Done criteria

Write a response in `docs/WINDSURF_TO_DEVIN.md` with:

- whether MCP tools are available
- active Studio instance name/id
- whether QwentyDown place appears loaded
- any immediate connection or permission errors
