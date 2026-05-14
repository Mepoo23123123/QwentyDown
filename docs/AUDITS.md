# Audits

This document tracks periodic audit results and the audit schedule for QwentyDown.

## Audit schedule

Use the `/audit` workflow (`.windsurf/workflows/audit.md`) for structured reviews.

Recommended frequency:
- **Before major releases**: full audit pass.
- **After significant system changes**: targeted audit of affected systems.
- **Monthly**: quick security and performance check.

## Audit areas

### 1. Remote security

Check all remotes in `ReplicatedStorage.Remotes`:
- Client-to-server remotes validate payload types and ranges.
- No remote trusts client for gameplay-critical decisions.
- Rate limiting applied to spam-prone actions.
- No privileged debug actions exposed to normal clients.

### 2. Server authority

For each server system:
- Combat: raycasts and damage are server-side.
- Inventory: ownership and operations validated server-side.
- Stats: allocation validated server-side.
- Skills: cooldown and hit validation server-side.
- Loot: collection validates distance/availability server-side.
- Data: persistence is server-side.

### 3. Memory leaks

Common patterns to check:
- Connections not disconnected.
- Temporary Instances not destroyed.
- Tweens or tasks not cancelled.
- VFX accumulating without cleanup.
- Event handlers accumulating on join/leave.

### 4. Performance

Common issues to check:
- Unbounded loops in RenderStepped/Heartbeat.
- Expensive operations per frame.
- Large table iterations per frame.
- Unnecessary remote traffic.
- UI recalculation per frame instead of on change.

### 5. UI

Check for:
- Readable text at 16:9.
- No overlapping elements.
- Proper connection cleanup on close.
- No console errors from UI.
- Responsive scaling where needed.

### 6. Architecture consistency

Check that:
- Builder/Controller split is maintained.
- Shared modules do not contain server-only logic.
- Client controllers do not make authoritative decisions.
- New scripts follow `--!strict` where practical.

## Audit log format

```md
## YYYY-MM-DD — Audit scope

**Scope:** which areas were audited

**Findings:** list of issues found

**Critical:** issues that need immediate fix

**Improvements:** non-critical improvements

**Status:** Pass / Fail / Partial
```

## Current audit entries

No audits have been recorded yet. Run the `/audit` workflow to generate the first entry.
