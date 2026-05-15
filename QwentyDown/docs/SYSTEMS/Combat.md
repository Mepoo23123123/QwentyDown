# Combat System

Combat is server-authoritative. Client controllers handle input, local animation/VFX feedback and UI state, but server systems validate attacks and apply outcomes.

## Authoritative scripts

- `ServerScriptService.Systems.CombatService`
- `ReplicatedStorage.Modules.CombatQuery`
- `ReplicatedStorage.Modules.CombatData`
- `ReplicatedStorage.Shared.Constants`
- `ReplicatedStorage.Shared.Types`

## Client scripts

- `StarterPlayer.StarterPlayerScripts.Controllers.CombatController`

## Remotes

- `CombatAction`
- `DamageReceived`
- `StunApplied`
- `ComboUpdated`
- `DodgeState`

## Invariants

- Server validates attack cooldowns and player state.
- Server owns damage decisions.
- Server-side combat query logic should not trust client hit claims.
- Combo state should remain consistent between server and client presentation.

## Combat constants

From `Shared.Constants`:

| Constant | Value | Description |
|----------|-------|-------------|
| `COMBO_MAX` | 4 | Max hits in combo |
| `COMBO_TIMEOUT` | 1.5s | Seconds without hit to reset combo |
| `COMBO_COOLDOWN` | 0.6s | Min delay between hits |
| `DAMAGE_PER_HIT` | {25, 35, 50, 100} | % of base attack per combo hit |
| `BACKSTAB_MULT` | 1.5 | Backstab multiplier |
| `CRIT_CHANCE_BASE` | 5% | Base crit chance |
| `CRIT_MULT_BASE` | 150% | Base crit multiplier |
| `AIR_DAMAGE_MULT` | 1.3 | Air attack damage multiplier |
| `HIT_STUN` | 0.2s | Brief stun on hit |
| `CRITICAL_STUN` | 0.4s | Stun from critical hit |
| `KNOCKDOWN_STUN` | 0.6s | Stun from knockdown |
| `DASH_COOLDOWN` | 3.0s | Dash cooldown |
| `DASH_SPEED` | 80 | Dash speed |
| `DASH_IFRAME_DURATION` | 0.18s | Server-side dodge invulnerability window |
| `DASH_ACTION_LOCK` | 0.2s | Dash action lock window |
| `DASH_RECOVERY` | 0.25s | Dash recovery window |

## Damage formula

```
Damage = Attack × Multiplier × (100 / (100 + Defense)) × (CritMult or 1)
Attack = from Stats + Weapon
Defense = from Stats
```

## Key types

From `Shared.Types`:

- `HitType = "hit" | "crit" | "blocked" | "skill" | "knockdown" | "dodged"`
- `CombatActionType = "attack" | "dash" | "block_start" | "block_end"`
- `ComboState = { count: number, lastHitTime: number }`
- `CombatRuntimeState = { actionLockUntil: number, actionLockType: CombatLockType?, invulnerableUntil: number, recoveryUntil: number }`
- `DamageOutcome = { knockback: boolean, stun: boolean }`

## Outcomes table

| Outcome | Knockback | Stun |
|---------|-----------|------|
| hit | false | false |
| crit | true | true |
| blocked | false | false |
| knockdown | true | true |
| skill | false | false |
| dodged | false | false |

## Dodge / i-frame state

Dash now creates a separate combat runtime state instead of using stun as a fake i-frame flag:

- `invulnerableUntil` blocks player-vs-player and enemy-vs-player damage while active.
- `actionLockUntil` prevents starting another combat action during the dash action lock.
- `recoveryUntil` is tracked for later stamina/cancel tuning.
- Enemy attacks route player damage through `CombatService.ApplyEnemyDamageToPlayer`, so dodge i-frames and block checks apply to enemy hits too.

`DASH_STUN` remains as a compatibility alias for `DASH_ACTION_LOCK`; new code should use `DASH_IFRAME_DURATION`, `DASH_ACTION_LOCK`, and `DASH_RECOVERY`.

## Related systems

- VFX: `WeaponVFX`
- Skills: `SkillService`, `SkillController`
- Data/stats: stat formulas and damage calculations

## Testing checklist

- Basic attack executes.
- Combo order progresses correctly.
- Cooldown and input buffer behave as intended.
- Server rejects invalid/spam attacks.
- Combat queries do not duplicate damage.
- Front-box combo detection does not hit targets behind the player.
- Ranged ray queries stop on walls and only pierce through characters when configured.
- VFX/animation timing remains acceptable.

## Open questions

- Document exact `CombatAction` payload shape from current implementation.
- Tune current `CombatQuery` combo box configs (`range`, `width`, `height`) per hit.
