---
description: Research-first workflow before Roblox/Luau code changes
---

# Roblox/Luau Research-First Workflow

Use this workflow before writing or modifying Roblox/Luau code in QwentyDown, especially when touching APIs, architecture, networking, UI, physics/raycasting, animation, DataStore, performance, security, or unfamiliar systems.

## 1. Define the change scope

- Identify the exact Roblox service/API, Luau feature, module, controller, or service being changed.
- Identify authoritative project files and Studio scripts involved.
- For destructive or large rewrites, ask for explicit confirmation and define backup/rollback strategy first.

## 2. Check project source of truth

Read relevant project docs before code when the change is not trivial:

- `AI_SAFETY_RULES.md`
- `PROJECT_KNOWLEDGE_BASE.md`
- `GAME_DATA_REFERENCE.md`
- subsystem-specific docs such as `RAYCAST_COMBAT.md`, `WEAPON_VFX_PRODUCTION_GUIDE.md`, `ANIMATION_VFX_GUIDE.md`

## 3. Check current external references

Before implementing Roblox/Luau code, use the best available current sources:

- Roblox Creator Docs / API Reference for Roblox APIs and engine behavior.
- Official Luau documentation for language and type-system behavior.
- DeepWiki repo `luau-lang/luau` for Luau internals, type system, compiler, VM, linter, and tool behavior.
- Roblox DevForum only as supporting evidence; prefer staff/experienced posts and check dates.

## 4. Validate against QwentyDown architecture

Apply findings only if they fit these project rules:

- Server is authoritative for combat, inventory, stats, class selection, loot validation, and persistence.
- Client controllers handle UX, input, preview, animation/VFX display, and local UI state.
- Remotes go through `RemoteManager` where project architecture already uses it.
- Prefer strict Luau modules and explicit cleanup for connections, instances, tweens, and tasks.
- Do not add legacy/unverified third-party systems without approval.

## 5. Implement narrowly

- Make the smallest safe change that solves the task.
- Keep code runnable after every edit.
- Preserve existing style unless the task explicitly asks for a redesign/refactor.
- Avoid adding comments or documentation unless requested.

## 6. Test and inspect

- Use Roblox Studio MCP to run Play Mode when relevant.
- Check Studio console after changes.
- For UI/VFX changes, capture or visually inspect the result.
- For server-authoritative logic, verify server-side validation paths.

## 7. Update knowledge base after important discoveries

When a durable lesson is learned, update `ROBLOX_LUAU_KNOWLEDGE_BASE.md` or a subsystem-specific doc with:

- Date/context
- Source consulted
- Project impact
- Final rule/pattern
- Files/scripts affected
