# Combat Audit + Elden Ring / DMC Roadmap

Date: 2026-05-14  
Scope: exported combat, skill, enemy AI, combat query, and weapon VFX code from `src/`.

## Executive summary

QwentyDown already has a useful action-RPG combat foundation: server-side combat decisions, combo state, client-side input/animation feedback, block, dash, enemy spawning/AI, skill casting, weapon VFX, and typed Luau modules.

To reach the requested **Elden Ring + Devil May Cry** direction, the combat should not be rewritten all at once. The safest path is to keep the existing server-authoritative base and add a new combat state layer around it: stamina, lock-on, dodge i-frames, posture/guard-break, enemy telegraphs, animation windows, combo cancel rules, launcher/aerial rules, and style scoring.

The first vertical slice should be:

1. one sword moveset,
2. one lock-on target,
3. dodge roll with real server-side invulnerability frames,
4. stamina for attack/dodge/block,
5. one enemy with telegraphed attacks,
6. posture/guard-break,
7. a small style meter that rewards varied hits without changing damage balance too much.

## Sources reviewed

- `QwentyDown/docs/raycast-combat.md`
- `QwentyDown/docs/audit.md`
- `QwentyDown/docs/roblox-research-before-code.md`
- `QwentyDown/docs/SYSTEMS/Combat.md`
- `src/ServerScriptService/Systems/CombatService.luau`
- `src/StarterPlayer/StarterPlayerScripts/Controllers/CombatController.luau`
- `src/ReplicatedStorage/Modules/CombatQuery.luau`
- `src/ReplicatedStorage/Modules/CombatData.luau`
- `src/ServerScriptService/Systems/SkillService.luau`
- `src/ServerScriptService/Systems/EnemyService.luau`
- `src/ReplicatedStorage/Modules/EnemyBrain.luau`
- Roblox Creator Docs: `WorldRoot:Raycast`, `WorldRoot:Blockcast`, overlap queries
- Luau official type checking docs

## Current combat architecture

### Server authority

Combat is already mostly server-authoritative:

- `CombatService` owns combo count, attack cooldowns, dash cooldown, block state, stun state, damage, knockback, and hit processing.
- Client sends intent through `CombatAction`; server chooses the result.
- `SkillService` validates skill slot, cooldown, MP, class mapping, and hit query before damage.
- `EnemyService` and `EnemyBrain` own enemy spawn, pursuit, attack timing, death, loot, and rewards.

This is the correct foundation for both Souls-like and stylish action combat.

### Client presentation

`CombatController` handles:

- left click attack buffering,
- local combo animation playback,
- block animation on `F`,
- dash request on `R`,
- combo counter UI,
- weapon idle/walk/unsheath animations,
- trail/VFX marker binding,
- hit VFX from server.

This client/controller split is also a good foundation. It should stay presentation-focused.

### Hit detection

`CombatQuery` supports four modes:

- `Box` via `workspace:GetPartBoundsInBox`,
- `Radius` via `workspace:GetPartBoundsInRadius`,
- `Ray` via `workspace:Raycast`,
- `Block` via `workspace:Blockcast`.

Current basic combos call `CastComboOnce`, which currently forces `mode = "Box"`.

This conflicts with the current project workflow doc that says combat should be pure server-side `workspace:Raycast` only and should not reintroduce visual debug beams. It is not fatal for gameplay, but it is a design inconsistency that must be resolved before the combat redesign becomes large.

## Strengths to keep

### 1. Good server/client responsibility split

The client mostly sends intent and plays feedback. The server validates cooldowns, state, hits, and damage. This matches project rules and should not be weakened.

### 2. Existing combo loop

The game already has:

- combo count,
- combo timeout,
- per-hit damage scaling,
- local attack buffering,
- combo UI,
- animation tracks per combo hit.

This can evolve into DMC-style chains and cancel windows instead of being replaced immediately.

### 3. Existing block/dash/stun hooks

`CombatService` already has tables for `Blocking`, `Stuns`, and `Cooldowns`, plus handlers for `dash`, `block_start`, and `block_end`. These are the right anchor points for stamina, i-frames, guard-break, and dodge-cancel logic.

### 4. Enemy system exists

`EnemyBrain` already has Idle/Pursue/Attack/Dead states, target acquisition, attack cooldown, animations, health bar, and callback-based damage application. This is enough to start adding Souls-like enemy telegraphs without building an AI system from zero.

### 5. Weapon VFX and animation markers exist

`WeaponVFX` is already tied to animation markers in `CombatController`. That gives a path for better hit windows, active frames, trails, and stylish hit feedback.

## Critical gaps and risks

### 1. Dash currently uses stun as pseudo i-frame state

Dash calls `ApplyStun(plr, Constants.DASH_STUN, "dash_iframe")`.

That means "cannot act because stunned" and "is invulnerable while dodging" are mixed into one concept. For Elden Ring feel, these must be separate:

- `ActionLock`: cannot start another action.
- `InvulnerableUntil`: damage/hit ignore window.
- `MovementImpulse`: dash/roll movement.
- `RecoveryUntil`: post-roll recovery.

### 2. No real dodge invulnerability check in damage path

`ProcessHit` checks block, backstab, airborne, HP, knockback, and stun. It does not check whether the defender is in an i-frame state before applying damage. Enemy damage also directly calls `StatsService.DamageResource` from `EnemyService.damagePlayer`.

Result: dash may feel like movement/cooldown, but it is not a reliable Souls-like dodge.

### 3. No stamina resource

The current system uses HP/MP and cooldowns. Elden Ring feel needs stamina as the main short-term combat resource:

- attack costs stamina,
- dodge costs stamina,
- block drains stamina on hit,
- stamina regenerates after a short delay,
- heavy actions can be denied if stamina is too low.

Cooldown-only combat feels arcade/simple; stamina creates commitment and pacing.

### 4. Block has no direction, stamina drain, posture, or guard-break

Current block is a boolean. If the victim is blocking, damage becomes chip damage.

Missing:

- frontal angle check,
- stamina drain,
- posture damage,
- guard-break stun,
- perfect block/parry window,
- block release recovery.

### 5. Enemy attacks are instant damage at attack time

`EnemyBrain:_attack` plays an animation, spawns a pulse, and immediately calls the damage callback if the player is in range.

For Souls-like combat, enemy attacks need phases:

1. windup/telegraph,
2. active hit window,
3. recovery,
4. server-side range/angle check at the active frame.

Without telegraph windows, dodging and parrying cannot feel fair.

### 6. Hit query system conflicts with raycast workflow

The project docs say pure `workspace:Raycast` only, no old hitbox/Touched/debug beams. Current `CombatQuery` uses overlap box/radius and debug parts. The redesign should decide one of two paths:

- update the docs to allow Roblox spatial queries and shapecasts, or
- refactor `CombatQuery` back to the documented raycast-only wrapper.

Given the user preference already says raycast-only, the safer path is a clean raycast sweep module for melee.

### 7. No lock-on system

There is no target selection, target cycling, camera assist, or facing assist. Souls-like combat needs lock-on early because dodge direction, enemy telegraphs, strafing, and weapon reach all feel different with lock-on.

### 8. No animation cancel/window model

`CombatController` currently plays combo animation and auto-stops after a fixed delay. The server cooldown is fixed. There is no shared data for:

- startup frames,
- active frames,
- recovery frames,
- cancel windows,
- dodge cancel timing,
- combo branch timing,
- launcher/aerial follow-up timing.

DMC feel requires these windows to be data-driven.

### 9. No launcher/aerial combat loop

There is an airborne damage multiplier, but no explicit launcher state, juggle state, air combo, gravity/float tuning, or landing recovery.

### 10. No style meter

There is combo UI, but no DMC-style scoring model. Style should reward variety, timing, no-damage streaks, aerial hits, parries, backstabs, and skill use.

### 11. Export still misses support modules

The most important combat files are now exported, but some dependencies are still not in `src/`:

- `ReplicatedStorage.Shared.Constants`
- `ReplicatedStorage.Shared.Types`
- `ReplicatedStorage.Shared.Util`
- `ReplicatedStorage.Remotes.RemoteManager`
- `ServerStorage.Data.CombatHelpers`
- several non-combat services.

This does not block roadmap planning, but it will block safe implementation if we need to edit constants/types/remotes.

## Target combat pillars

### Elden Ring pillar

Combat should feel deliberate and readable:

- lock-on target focus,
- stamina-limited actions,
- dodge with i-frames and recovery,
- block with stamina/posture cost,
- parry/perfect block for high-skill defense,
- enemy windups and punish windows,
- heavy hits causing posture damage and knockdowns,
- server-authoritative enemy and player hit validation.

### Devil May Cry pillar

Combat should reward expression:

- fast combo chains,
- launcher into aerial follow-ups,
- cancel windows,
- skill weaving,
- style meter,
- weapon-specific routes,
- VFX/audio hit feedback,
- rank decay if the player repeats one action.

### QwentyDown adaptation

The design should not copy either game directly. QwentyDown should become:

- **Souls-like defense and enemy readability**,
- **DMC-like player expression and combo scoring**,
- **Roblox-safe server authority and performance**,
- **Luau strict, data-driven movesets**.

## Recommended architecture

### New modules

#### `ReplicatedStorage.Modules.CombatMovesets`

Data-only definitions for weapons and skills:

- action id,
- stamina cost,
- startup/active/recovery timings,
- cancel windows,
- hit query pattern,
- damage multiplier,
- posture damage,
- launch/knockback data,
- animation id,
- VFX marker expectations.

#### `ServerScriptService.Systems.CombatStateService`

Server-owned state for each player:

- current action,
- action lock until,
- invulnerable until,
- stamina,
- stamina regen delay,
- posture,
- lock-on target id,
- style state,
- last action history.

This can be inside `CombatService` at first, but should become its own service once it grows.

#### `ReplicatedStorage.Modules.RaycastCombat`

Single server-side melee query wrapper aligned with project docs:

- multi-ray sweep for melee arcs,
- optional `workspace:Blockcast` only if project docs are updated to allow shapecasts,
- dedupe target models,
- wall/obstruction awareness,
- no client-side hit claims,
- debug disabled by default and only enabled through Studio-only flags.

#### `ReplicatedStorage.Modules.CombatStyleData`

Style scoring data:

- rank thresholds,
- decay rules,
- action repetition penalty,
- bonuses for parry, backstab, launcher, air hit, no-damage streak, skill weave.

### Existing modules to evolve

#### `CombatService`

Move from immediate attack handling to action lifecycle:

1. validate intent,
2. check stamina/state/cooldown,
3. start action,
4. schedule active hit window,
5. execute server hit query,
6. apply outcome,
7. enter recovery/cancel window.

#### `CombatController`

Keep it presentation-only:

- send input intent,
- play predicted animation only after local precheck,
- reconcile with server `CombatStateUpdated`,
- show stamina/posture/style UI,
- lock-on camera and target indicator.

#### `EnemyBrain`

Move from instant attack callback to telegraphed attacks:

- `Windup`,
- `Active`,
- `Recovery`,
- optional `Staggered`.

Enemy damage should call a central combat damage function so player i-frames/block/parry are respected.

## Roadmap

### Phase 0 — Complete source mirror and constants export

Goal: make the repo safe for implementation.

Tasks:

- Export `Shared.Constants`, `Shared.Types`, `Shared.Util`, `Remotes.RemoteManager`, and `ServerStorage.Data.CombatHelpers`.
- Decide whether canonical docs live under `QwentyDown/docs/` only or root `docs/`.
- Update `STUDIO_EXPORT_REPORT.md` with missing dependencies.

Exit criteria:

- all files required by combat services can be read and edited from repo,
- no ambiguity about docs/bridge paths.

### Phase 1 — Combat state cleanup

Goal: separate stun, i-frames, action lock, recovery, and cooldown.

Tasks:

- add server state fields:
  - `ActionLockUntil`,
  - `InvulnerableUntil`,
  - `RecoveryUntil`,
  - `CurrentAction`,
  - `Blocking`,
  - `Posture`.
- replace dash-as-stun with dodge action state.
- make all damage paths check `InvulnerableUntil`.
- route enemy damage through combat outcome processing.

Exit criteria:

- dodge can avoid enemy/player damage during i-frame window,
- stun still prevents actions but is no longer used as a fake i-frame flag.

### Phase 2 — Stamina + posture + guard-break

Goal: add Souls-like resource pacing.

Tasks:

- add stamina values to player stats or combat runtime state,
- stamina costs for light attack, dash, block hold, block hit,
- stamina regen delay after spending,
- block frontal angle validation,
- posture damage on block/heavy hit,
- guard-break stun when posture reaches zero.

Exit criteria:

- player cannot spam dodge/attack forever,
- blocking from the wrong angle fails,
- repeated blocking can break guard.

### Phase 3 — Lock-on vertical slice

Goal: make movement/combat readable around one target.

Tasks:

- server validates lock-on target exists, alive, and within range,
- client target indicator,
- camera soft lock,
- optional strafe movement while locked,
- target cycling later.

Exit criteria:

- player can lock one enemy,
- attacks and dodge directions feel consistent while locked,
- server never trusts arbitrary client target ids without validation.

### Phase 4 — Enemy telegraphs

Goal: make defense fair.

Tasks:

- add enemy attack definitions:
  - windup,
  - active,
  - recovery,
  - range,
  - angle,
  - damage,
  - posture damage.
- change `EnemyBrain:_attack` to schedule active damage instead of instant damage.
- add visual/audio telegraph hooks.

Exit criteria:

- enemy attacks are dodgeable on reaction,
- player can punish recovery windows,
- enemy damage respects i-frames and block.

### Phase 5 — Data-driven player movesets

Goal: prepare DMC-like combat.

Tasks:

- create sword light combo moveset data,
- define startup/active/recovery/cancel windows per hit,
- move combo hit query timing server-side,
- add cancel rules:
  - attack → next attack,
  - attack → dodge,
  - attack → skill,
  - selected skills → aerial follow-up later.

Exit criteria:

- current 4-hit combo still works,
- timings come from data,
- future weapons can add different routes without rewriting `CombatService`.

### Phase 6 — Launcher + aerial prototype

Goal: first DMC feel.

Tasks:

- add one launcher action,
- add airborne/juggle state on enemy,
- add one aerial follow-up,
- tune gravity/float carefully,
- add landing/recovery rules.

Exit criteria:

- player can launch one enemy and follow with one air hit,
- server owns launch and damage,
- combo UI recognizes aerial hits.

### Phase 7 — Style meter

Goal: reward expressive play.

Tasks:

- style score state per player,
- rank thresholds,
- decay over time,
- repetition penalty,
- bonuses for:
  - varied combo hits,
  - perfect dodge/parry,
  - launcher,
  - aerial hit,
  - backstab,
  - skill weave,
  - no-damage streak.

Exit criteria:

- style rank changes during combat,
- score is server-authoritative,
- UI is client presentation only.

## First recommended vertical slice

Implement **Souls defense core first**, not DMC launcher first.

Reason: stylish combos only feel good if enemies are readable and player state is reliable. If dodge/i-frames/stamina/block are not correct, adding launcher/style will create bugs and spammy combat.

### Slice name

`combat-defense-core-v1`

### Contents

1. Export missing `Constants`, `Types`, `Util`, `RemoteManager`, `CombatHelpers`.
2. Add combat runtime state:
   - action lock,
   - i-frame window,
   - recovery window.
3. Refactor dash into dodge:
   - stamina cost,
   - i-frame duration,
   - recovery duration,
   - no damage during i-frames.
4. Make enemy damage call the same combat outcome path.
5. Add block angle check and stamina drain.
6. Add minimal HUD hooks for stamina.
7. Ask Windsurf Agent to test in Studio:
   - dodge avoids enemy hit,
   - dodge outside i-frame still takes damage,
   - block front reduces damage,
   - block from behind fails,
   - stamina prevents spam.

### Why this slice is safe

- It does not require a full animation/VFX redesign.
- It uses existing `CombatAction`, `dash`, `block_start`, and `block_end` paths.
- It keeps damage server-side.
- It creates the foundation needed for both Elden Ring and DMC layers.

## Implementation guardrails

- Do not trust client hit claims.
- Do not let client set damage, target validity, stamina, style score, or i-frame state.
- Keep client prediction cosmetic.
- Keep new modules `--!strict`.
- Avoid `Touched` hitboxes and RaycastHitboxV4.
- Before large raycast query changes, decide whether `Blockcast`/overlap queries are allowed or whether the project returns to pure `workspace:Raycast`.
- Do not combine export cleanup, combat refactor, lock-on, and style meter into one PR.

## Open decisions for user

1. Should melee hit detection be **strict raycast-only** as current docs say, or are Roblox shapecasts/overlap queries allowed if server-side?
2. Should the first weapon be a single katana/sword moveset, or should each current class keep its own moveset from the start?
3. Should stamina be a persistent stat shown in player profile, or a runtime-only combat resource derived from stats?
4. Should style meter affect rewards only, or also damage/loot multipliers later?
5. Should lock-on be mouse/keyboard only first, or also gamepad/mobile from the start?

## Recommendation

Start with Phase 0 and Phase 1 in the next PR/request:

1. ask Windsurf Agent to export missing support modules,
2. then implement `combat-defense-core-v1`.

This gives the project a reliable Souls-like defensive core before adding DMC-style launchers, aerial routes, and style scoring.
