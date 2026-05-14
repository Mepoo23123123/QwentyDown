---
description: Update project documentation after significant changes
---

# Docs Update Workflow

Use this workflow after significant QwentyDown changes to keep documentation in sync with implementation.

## 1. Identify what changed

- Which scripts/modules were modified?
- Which systems are affected?
- Did any remotes change (added/removed/payload changed)?
- Did any data schemas change?
- Did any architectural invariants change?

## 2. Update affected system docs

For each affected system, update `docs/SYSTEMS/*.md`:

- Add new types, constants or schemas.
- Update invariant list if behavior changed.
- Update testing checklist if new checks are needed.
- Remove outdated information.

## 3. Update REMOTE_CONTRACTS.md if remotes changed

- Add new remotes with direction, payload and validation rules.
- Update changed payload descriptions.
- Remove remotes that no longer exist.

## 4. Update ARCHITECTURE.md if structure changed

- Add new services/controllers/modules.
- Update responsibility descriptions.
- Update client/server split if changed.

## 5. Add decision to DECISIONS.md if applicable

If the change introduced a durable architectural decision:

```md
## YYYY-MM-DD — Decision title

**Status:** Accepted / Superseded / Rejected

**Context:** why this decision was needed

**Decision:** what we chose

**Consequences:** tradeoffs and follow-up work

**Related docs/scripts:** links or Studio paths
```

## 6. Add research entry if external sources were consulted

If Roblox Creator Docs, Luau docs, DeepWiki or DevForum were consulted:

- Add entry to `docs/RESEARCH_LOG.md`.
- Add API notes to `docs/RESEARCH/Roblox_API_Notes.md` if relevant.
- Add Luau findings to `docs/RESEARCH/Luau_DeepWiki_Notes.md` if relevant.

## 7. Verify index

- Check that `ROBLOX_LUAU_KNOWLEDGE_BASE.md` links to all updated docs.
- Check that `docs/README.md` is still accurate.
