# Luau DeepWiki Notes

Use DeepWiki repo `luau-lang/luau` as a Luau implementation and tooling reference when QwentyDown tasks involve typing, analysis, linting, parser/compiler behavior, VM/runtime or tooling.

## DeepWiki pages available

- Luau Overview
- Type System
- Parser and AST
- Compiler
- Virtual Machine
- Developer Tools
- Testing Infrastructure
- Build System and CI
- Glossary

## Practical use in QwentyDown

Use DeepWiki before tasks involving:

- `--!strict` typing strategy
- exported types and module API design
- narrowing/refinements/unions/generics
- luau-analyze or linter warnings
- require/module resolution concepts
- performance-sensitive Luau behavior
- memory/GC questions at language/runtime level

## Current summarized findings

- Luau supports gradual typing with modes such as `--!strict`, `--!nonstrict` and `--!nocheck`.
- `--!strict` should be preferred for new focused modules where practical.
- `luau-analyze` is the static analysis entry point for type checking and linting.
- The Luau frontend handles parsing, module resolution and type checking across dependency graphs.
- Luau runtime/VM is optimized, but Roblox gameplay memory practices still require project-level cleanup of Instances, connections and tasks.
- DeepWiki is strongest for language internals/tooling, not for Roblox engine API behavior.

## How to record future findings

```md
## YYYY-MM-DD — Topic

**DeepWiki page/question:**

**Finding:**

**Project rule:**

**Applies to:**
```
