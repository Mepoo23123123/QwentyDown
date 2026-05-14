# Research Log

Use this file to record research-first work before important Roblox/Luau implementation tasks.

## Entry format

```md
## YYYY-MM-DD — Task title

**Task:** what is being changed

**Project context:** scripts/modules/systems involved

**Sources checked:** Roblox docs, Luau docs, DeepWiki, DevForum, source inspection

**Findings:** concise relevant facts

**Decision:** how findings affected implementation

**Follow-up docs:** docs updated after the task
```

## Source priority

1. Roblox Creator Docs / API Reference
2. Official Luau documentation
3. DeepWiki `luau-lang/luau`
4. Roblox DevForum as secondary evidence
5. Open-source/community examples only after cross-checking

## Current baseline

- DeepWiki `luau-lang/luau` should be used for Luau internals, type system, analyzer/linter, frontend/module-system and tooling questions.
- Roblox Creator Docs/API Reference should be used for engine APIs and instance behavior.
- Project source inspection remains required before editing existing systems.
