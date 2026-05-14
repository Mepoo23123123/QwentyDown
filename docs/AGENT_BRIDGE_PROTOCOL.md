# Devin ↔ Windsurf Agent Bridge Protocol

This document defines the file-based workflow between:

- **Devin** — remote coding agent with GitHub/repository access.
- **Windsurf Agent** — local agent running on the user's PC with working Roblox Studio MCP access.
- **User** — project owner who makes product decisions and approves risky actions.

Use this bridge when Devin cannot directly connect to the user's local Roblox Studio MCP.

## Files

| File | Owner | Purpose |
| --- | --- | --- |
| `docs/DEVIN_TO_WINDSURF.md` | Devin | Commands, requests and context for the Windsurf Agent. |
| `docs/WINDSURF_TO_DEVIN.md` | Windsurf Agent | Results, errors, Studio observations and MCP output summaries. |
| `docs/DEVIN_CODE_DRAFTS.md` | Devin | Luau code drafts, patch plans and exact Studio paths for Windsurf to apply. |
| `docs/AGENT_BRIDGE_PROTOCOL.md` | Both | Shared rules for how the agents cooperate. |

## Core rule

Devin writes repository changes and structured instructions. Windsurf Agent applies or verifies Studio-side changes with Roblox Studio MCP, then writes results back to the repository files.

## Standard loop

1. User gives a task to Devin.
2. Devin reads project docs and uses `docs/roblox-research-before-code.md` when the task changes Roblox/Luau behavior.
3. Devin writes a request block in `docs/DEVIN_TO_WINDSURF.md`.
4. If code is needed, Devin writes the code/patch draft in `docs/DEVIN_CODE_DRAFTS.md`.
5. Windsurf Agent reads the request and code draft.
6. Windsurf Agent uses Roblox Studio MCP to inspect/apply/test in the open place.
7. Windsurf Agent records results in `docs/WINDSURF_TO_DEVIN.md`.
8. Devin reads the report, updates repository files/docs, and asks the user only when required.

## Request block format

```md
## YYYY-MM-DD HH:MM UTC — Request title

**Status:** Pending / In Progress / Blocked / Done
**Owner:** Devin / Windsurf Agent / User
**Scope:** scripts, modules, systems or Studio paths involved
**Relevant docs:** project docs or external references used

### Task
Concrete instruction for the receiving agent.

### Inputs
- Links to `docs/DEVIN_CODE_DRAFTS.md` sections
- Studio paths
- Expected behavior

### Required MCP checks
- `script_read`
- `multi_edit`
- `execute_luau`
- `start_stop_play`
- `console_output`
- `screen_capture`

### Done criteria
- Exact success conditions
- Required report fields
```

## Response block format

```md
## YYYY-MM-DD HH:MM UTC — Response to: Request title

**Status:** Done / Blocked / Failed / Needs User
**Studio state:** place open, play mode status, active Studio instance
**Scripts touched:** Studio paths or repository files

### Actions performed
- What MCP tools were used
- What scripts were read or edited
- What tests were run

### Results
- Observed behavior
- Console errors/warnings
- Screenshots or descriptions when relevant

### Follow-up
- What Devin should change next
- What the user must decide, if anything
```

## When to ask the user

Do not guess when a task requires user intent. Write a `Needs User` block and stop if any of these happen:

- A destructive or large rewrite is needed.
- A gameplay/design decision is ambiguous.
- Assets, models, animations, IDs or UI art are missing.
- Production DataStore, purchases, monetization or publishing is involved.
- Secrets, tokens, cookies, account credentials or private URLs are required.
- Roblox Studio place state differs from project docs in a way that changes the implementation plan.

## Safety rules

- Never write secrets, cookies or account tokens into repository files.
- Never expose privileged debug remotes to normal clients.
- Preserve server-authoritative gameplay.
- Validate client-to-server remote payloads server-side.
- Do not reintroduce removed combat systems listed in `docs/raycast-combat.md`.
- Keep changes minimal unless the user explicitly approves a redesign.
- Update docs when durable behavior changes.

## Conflict handling

If Devin and Windsurf Agent disagree:

1. Prefer actual Studio state over stale docs.
2. Prefer project rules in `ROBLOX_LUAU_KNOWLEDGE_BASE.md` and `docs/CODING_STANDARDS.md`.
3. Prefer official Roblox/Luau references over memory.
4. If still ambiguous, ask the user.
