# Roblox/Luau Knowledge Base для QwentyDown

Этот файл — локальная база проверенных Roblox/Luau практик для проекта QwentyDown.

## Главный индекс документации

- `docs/README.md` — карта новой документации.
- `docs/PROJECT_OVERVIEW.md` — обзор проекта и систем.
- `docs/ARCHITECTURE.md` — client/server архитектура.
- `docs/CODING_STANDARDS.md` — стандарты Roblox/Luau кода.
- `docs/REMOTE_CONTRACTS.md` — RemoteEvent/RemoteFunction contracts.
- `docs/TESTING_CHECKLIST.md` — чеклисты проверки.
- `docs/DECISIONS.md` — журнал архитектурных решений.
- `docs/RESEARCH_LOG.md` — журнал research-first задач.

## Системная документация

- `docs/SYSTEMS/Combat.md`
- `docs/SYSTEMS/Inventory.md`
- `docs/SYSTEMS/VFX.md`
- `docs/SYSTEMS/UI.md`
- `docs/SYSTEMS/Data.md`
- `docs/SYSTEMS/Stats.md`
- `docs/SYSTEMS/Skills.md`
- `docs/SYSTEMS/Loot.md`
- `docs/SYSTEMS/Enemies.md`

## Research docs

- `docs/RESEARCH/Roblox_API_Notes.md`
- `docs/RESEARCH/Luau_DeepWiki_Notes.md`
- `docs/RESEARCH/DevForum_Findings.md`

## Правило источников

Перед важными Roblox/Luau изменениями использовать источники в таком приоритете:

1. Roblox Creator Docs / API Reference
2. Official Luau documentation
3. DeepWiki `luau-lang/luau`
4. Roblox DevForum как дополнительный источник с проверкой даты и контекста
5. Open-source проекты/статьи/видео только как идеи, не как источник истины

## Постоянный workflow

Для новых изменений использовать workflow:

- `.windsurf/workflows/roblox-research-before-code.md`

## Формат записи практик

```md
## YYYY-MM-DD — Название практики

**Источник:** ссылка/DeepWiki/Creator Docs/проектная практика

**Контекст:** где применимо в QwentyDown

**Правило:** что делать

**Антипаттерн:** чего избегать

**Связанные файлы/скрипты:** пути или Studio paths
```

## 2026-05-03 — Research-first перед Roblox/Luau кодом

**Источник:** пользовательское правило проекта + DeepWiki `luau-lang/luau` как обязательный Luau reference

**Контекст:** любые изменения Roblox/Luau кода, особенно API, типы, UI, remotes, DataStore, physics/raycasting, animation, performance, security.

**Правило:** перед кодом проверять актуальные источники, если задача не является простой локальной правкой. После важных находок обновлять эту базу знаний.

**Антипаттерн:** писать код по памяти для спорных/изменчивых Roblox API без проверки документации.

**Связанные файлы/скрипты:** весь проект QwentyDown.

## 2026-05-03 — Reset root documentation

**Источник:** решение пользователя.

**Контекст:** старые root markdown-документы проекта были удалены, чтобы пересобрать документацию заново и правильно.

**Правило:** основной root-документ для новой базы знаний — `ROBLOX_LUAU_KNOWLEDGE_BASE.md`. Workflow перед Roblox/Luau кодом находится в `.windsurf/workflows/roblox-research-before-code.md`.

**Антипаттерн:** опираться на удалённые старые docs как источник истины.

**Связанные файлы/скрипты:** root markdown docs, `.windsurf/workflows`.
