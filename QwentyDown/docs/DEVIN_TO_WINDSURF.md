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

## 2026-05-14 20:51 UTC — Export Studio scripts and structure to repository

**Status:** Pending
**Owner:** Windsurf Agent
**Scope:** Full Roblox Studio script source export for QwentyDown
**Relevant docs:** `docs/AGENT_BRIDGE_PROTOCOL.md`, `docs/PROJECT_OVERVIEW.md`, `docs/ARCHITECTURE.md`, `docs/REMOTE_CONTRACTS.md`, `docs/testing.md`

### Task

Export the current QwentyDown Roblox Studio script source and DataModel structure into the GitHub repository so Devin can inspect and edit the real project code.

This is an export/snapshot task. Do not rewrite gameplay logic. Do not make design changes. Do not run broad formatting over existing scripts.

### Inputs

- Active Studio instance from readiness check: `QwentyDown`.
- Target repository root: `QwentyDown/`.
- Preferred export root: `QwentyDown/src/`.
- Documentation outputs:
  - `QwentyDown/docs/STUDIO_TREE.md`
  - `QwentyDown/docs/STUDIO_EXPORT_REPORT.md`

### Export structure

Use this mapping for script source files:

| Studio container | Repository path |
| --- | --- |
| `ReplicatedStorage` | `src/ReplicatedStorage/` |
| `ServerScriptService` | `src/ServerScriptService/` |
| `ServerStorage` | `src/ServerStorage/` |
| `StarterPlayer` | `src/StarterPlayer/` |
| `StarterGui` | `src/StarterGui/` |
| `Workspace` scripts only | `src/Workspace/` |

File extensions:

| Roblox class | Extension |
| --- | --- |
| `ModuleScript` | `.lua` |
| `Script` | `.server.lua` |
| `LocalScript` | `.client.lua` |

Path naming rules:

- Preserve Studio hierarchy as folders.
- Use script instance names as file names.
- If names contain characters that are unsafe for file paths, replace them with `_` and record the original name in `docs/STUDIO_EXPORT_REPORT.md`.
- If duplicate file paths occur, add a numeric suffix and record the conflict.

### Required MCP checks

Use Roblox Studio MCP tools as available:

- `list_roblox_studios`
- `set_active_studio`
- `search_game_tree` or equivalent tree inspection
- `script_search` / `script_grep` as needed
- `script_read` for every exported `Script`, `LocalScript`, and `ModuleScript`
- `console_output` after export, if available

### What to export

Export all source-bearing Roblox scripts under these areas:

- `ReplicatedStorage.Modules`
- `ReplicatedStorage.Shared`
- `ReplicatedStorage.Remotes` documentation if scripts/modules exist there
- `ServerScriptService.Core`
- `ServerScriptService.Systems`
- `ServerStorage.Data`
- `StarterPlayer.StarterPlayerScripts`
- `StarterPlayer.StarterCharacterScripts`
- `StarterGui` scripts/controllers if any
- any `Workspace` scripts that are part of QwentyDown systems

Do not export binary assets, meshes, textures, animations, plugin files, generated cache files, or secrets.

### Documentation to write

Create `docs/STUDIO_TREE.md` with:

- concise DataModel tree for relevant containers
- class names for each item
- script paths for exported scripts
- important non-script folders/models referenced by docs, such as enemy models, VFX, items, remotes and UI roots

Create `docs/STUDIO_EXPORT_REPORT.md` with:

- export timestamp
- active Studio instance id/name
- number of scripts exported by class
- list of exported Studio paths and repository paths
- list of skipped non-script assets
- any failed `script_read` calls with reason
- console warnings/errors observed
- whether Play Mode was started; default should be no unless required

### Safety rules

- Do not paste Roblox account credentials, cookies, API keys, tokens or private URLs.
- Do not export plugin internals unless they are part of QwentyDown gameplay code.
- Do not change Studio gameplay code during this task.
- If a script contains obvious secrets, do not commit the secret. Write a `Needs User` response instead and identify only the Studio path.

### Done criteria

Commit and push the exported files to `origin/main`, then write a response in `docs/WINDSURF_TO_DEVIN.md` with:

- `Status: Done` if export succeeded, or `Needs User`/`Failed` with reason
- commit hash
- number of scripts exported
- key paths created under `src/`
- any skipped or failed scripts
- any console warnings/errors
