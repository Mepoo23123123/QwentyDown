---
description: Audit workflow for security, performance and architecture review
---

# Audit Workflow

Use this workflow periodically or before major releases to review QwentyDown for security, performance and architecture issues.

## 1. Remote security audit

Check all remotes in `ReplicatedStorage.Remotes`:

- Every client-to-server remote validates payload types and value ranges.
- No remote trusts client for gameplay-critical decisions.
- No remote exposes privileged operations without permission checks.
- Rate limiting is applied where needed (spam-prone actions).
- Update `docs/REMOTE_CONTRACTS.md` with findings.

## 2. Server authority audit

For each server system in `ServerScriptService.Systems`:

- Combat: raycasts and damage are server-side. No client hit claims trusted.
- Inventory: ownership, equip/use/delete/craft validated server-side.
- Stats: allocation validated server-side. No client stat manipulation.
- Skills: cooldown and hit validation server-side.
- Loot: collection validates distance/availability server-side.
- Data: persistence is server-side. No client direct data writes.

## 3. Memory leak audit

Check for common leak patterns:

- Connections not disconnected when no longer needed.
- Temporary Instances not destroyed after use.
- Tweens or tasks not cancelled on cleanup.
- VFX instances accumulating without lifetime cleanup.
- Event handlers accumulating on player join/leave cycles.

## 4. Performance audit

Check for common performance issues:

- Unbounded loops in RenderStepped/Heartbeat.
- Expensive operations per frame (raycasts, instance creation).
- Large table iterations per frame.
- Unnecessary remote traffic (polling vs event-driven).
- UI layout recalculation per frame instead of on change.

## 5. UI audit

Check UI for:

- Readable text at common 16:9 resolutions.
- No overlapping elements.
- Proper cleanup of UI connections on close.
- No console errors from UI creation or updates.
- Responsive scaling where needed.

## 6. Architecture consistency audit

Check that:

- Builder/Controller split is maintained (no logic in builders, no layout in controllers).
- Shared modules do not contain server-only logic.
- Client controllers do not make authoritative gameplay decisions.
- New scripts follow `--!strict` where practical.

## 7. Record findings

- Add findings to `docs/AUDITS.md`.
- Create fix tasks for critical issues.
- Update `docs/TESTING_CHECKLIST.md` with new checks if needed.
- Update `docs/CODING_STANDARDS.md` with new rules if needed.
