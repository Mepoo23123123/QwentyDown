# Studio Export Guide

This guide describes the expected repository layout for Studio source exported through the Devin ↔ Windsurf Agent bridge.

## Goal

Keep a readable repository snapshot of the real Roblox Studio scripts so Devin can review, plan and edit QwentyDown code without direct access to local Roblox Studio MCP.

## Preferred layout

```text
QwentyDown/
├── src/
│   ├── ReplicatedStorage/
│   ├── ServerScriptService/
│   ├── ServerStorage/
│   ├── StarterPlayer/
│   ├── StarterGui/
│   └── Workspace/
└── docs/
    ├── STUDIO_TREE.md
    └── STUDIO_EXPORT_REPORT.md
```

## Script extensions

| Roblox class | Extension |
| --- | --- |
| `ModuleScript` | `.lua` |
| `Script` | `.server.lua` |
| `LocalScript` | `.client.lua` |

## Export rules

- Preserve Studio hierarchy as folders.
- Export source-bearing `Script`, `LocalScript`, and `ModuleScript` instances.
- Do not export binary assets, meshes, textures, animations or plugin internals.
- Do not export secrets, cookies, tokens or account data.
- Record skipped and failed items in `docs/STUDIO_EXPORT_REPORT.md`.

## After export

Devin reads `src/`, `docs/STUDIO_TREE.md`, and `docs/STUDIO_EXPORT_REPORT.md` before planning major gameplay changes.

For code changes, Devin should update repository files first, then ask the Windsurf Agent to apply or verify the change in Roblox Studio through MCP.
