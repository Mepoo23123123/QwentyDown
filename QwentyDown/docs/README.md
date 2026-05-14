# QwentyDown Docs

Новая документация проекта QwentyDown. Этот раздел хранит только актуальные правила, архитектурные решения, contracts и research notes.

## Главный индекс

- `../ROBLOX_LUAU_KNOWLEDGE_BASE.md` — верхний вход в базу знаний и правило источников.

## Core docs

- `PROJECT_OVERVIEW.md` — краткая карта проекта и основных систем.
- `ARCHITECTURE.md` — client/server разделение и структура Roblox Studio.
- `CODING_STANDARDS.md` — правила Luau, Roblox, remotes, UI и cleanup.
- `REMOTE_CONTRACTS.md` — список RemoteEvent/RemoteFunction и правила безопасности.
- `TESTING_CHECKLIST.md` — чеклисты проверки перед завершением задач.
- `DECISIONS.md` — журнал архитектурных решений.
- `RESEARCH_LOG.md` — журнал research-first задач.
- `AGENT_BRIDGE_PROTOCOL.md` — file-based протокол Devin ↔ Windsurf Agent.
- `DEVIN_TO_WINDSURF.md` — команды Devin для локального Windsurf Agent с Roblox Studio MCP.
- `WINDSURF_TO_DEVIN.md` — ответы Windsurf Agent с результатами Studio/MCP.
- `DEVIN_CODE_DRAFTS.md` — черновики Luau-кода и patch plans от Devin.
- `STUDIO_EXPORT_GUIDE.md` — правила экспорта Studio scripts в `src/`.
- `COMBAT_AUDIT_ROADMAP.md` — аудит текущей боёвки и roadmap Elden Ring/DMC.

## System docs

- `SYSTEMS/Combat.md`
- `SYSTEMS/Inventory.md`
- `SYSTEMS/VFX.md`
- `SYSTEMS/UI.md`
- `SYSTEMS/Data.md`
- `SYSTEMS/Stats.md`
- `SYSTEMS/Skills.md`
- `SYSTEMS/Loot.md`
- `SYSTEMS/Enemies.md`

## Research docs

- `RESEARCH/Roblox_API_Notes.md`
- `RESEARCH/Luau_DeepWiki_Notes.md`
- `RESEARCH/DevForum_Findings.md`

## Правило обновления

После важных изменений добавлять durable knowledge:

- что изменилось
- почему так сделано
- какие источники проверены
- какие файлы/Studio scripts затронуты
- как тестировать
