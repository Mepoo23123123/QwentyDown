# Coding Standards

Project code should be safe, typed where practical, server-authoritative and easy to maintain.

## Research-first rule

Before meaningful Roblox/Luau code changes, check relevant current references:

1. Roblox Creator Docs / API Reference
2. Official Luau documentation
3. DeepWiki `luau-lang/luau`
4. Roblox DevForum as secondary evidence only

## Luau style

- Prefer `--!strict` for new modules where practical.
- Use explicit types for public APIs, exported types and data shapes.
- Avoid broad `any` unless bridging dynamic Roblox APIs or legacy data.
- Keep imports/requires at the top of scripts.
- Keep modules focused on one responsibility.

## Roblox instance lifecycle

- Clean up temporary Instances, Tweens, connections and delayed tasks.
- Use `Debris` or explicit `Destroy()` for short-lived VFX/debug parts.
- Avoid creating unbounded instances during RenderStepped/Heartbeat loops.
- Avoid long-running loops without cancellation conditions.

## Server authority

Server validates:

- combat hits and damage
- cooldowns and combo state
- inventory ownership
- equip/use/delete/craft actions
- stat allocation
- loot collection
- skill casts

Client does not authoritatively decide gameplay state.

## Remote safety

- Validate payload type and value ranges server-side.
- Reject requests for missing/unowned items.
- Rate-limit spam-prone actions where needed.
- Do not expose privileged debug actions to normal clients.

## UI standards

- Prefer Builder + Controller split.
- Builder creates hierarchy, colors, sizes and base components.
- Controller owns state, selection, filtering, sorting, event connections and data updates.
- UI should be readable at common 16:9 sizes before adding extra polish.

## VFX standards

- VFX should have a clear lifetime.
- Effects should not permanently alter character/weapon hierarchy unless intended.
- Preview tools should clean previous preview roots.
- Gameplay VFX should follow server-authoritative outcomes when tied to hits.

## Documentation standard

When a durable pattern is learned, add it to the relevant docs page with:

- context
- final rule
- anti-pattern
- affected scripts/modules
- testing checklist
