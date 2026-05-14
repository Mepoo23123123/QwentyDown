---
description: Testing workflow for QwentyDown changes
---

# Testing Workflow

Use this workflow after making Roblox/Luau code changes in QwentyDown to verify correctness before marking tasks complete.

## 1. Pre-flight checks

- Confirm Studio MCP connection is active.
- Confirm the change scope: which scripts/modules were modified.
- Identify which systems are affected (combat, inventory, UI, VFX, data, etc.).

## 2. Start Play Mode

- Use `mcp0_start_stop_play` with `is_start: true`.
- Wait for game to load.

## 3. Console check

- Use `mcp0_get_console_output` to check for errors/warnings.
- If errors are related to the change, fix before proceeding.

## 4. Functional testing by system

Run the relevant checklist from `docs/TESTING_CHECKLIST.md`:

### Combat changes
- Attack works
- Cooldown works
- Combo progression works
- Server rejects invalid actions

### Inventory changes
- Inventory opens/closes
- Items display correctly (icon, glyph, quantity, rarity)
- Equip/unequip works
- Server rejects invalid requests

### VFX changes
- Effect spawns at correct location
- Effect cleans up after lifetime
- No orphaned effects on repeated use

### UI changes
- UI opens/closes
- Text readable and not clipped
- Images scale/clamp as intended
- Hover/click states work

### Data changes
- Player join loads data
- Player leave saves data
- Missing data creates defaults

## 5. Stop Play Mode

- Use `mcp0_start_stop_play` with `is_start: false`.

## 6. Record results

- If bugs found: fix and re-test.
- If durable lesson learned: update `docs/RESEARCH_LOG.md` or relevant system doc.
- If testing reveals a new invariant: add to `docs/TESTING_CHECKLIST.md`.
