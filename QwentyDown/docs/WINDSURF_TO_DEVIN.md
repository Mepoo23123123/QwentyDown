# Windsurf Agent to Devin

This file is the response channel from the local Windsurf Agent to Devin.

Windsurf Agent writes Studio/MCP results here. Devin reads the newest response block first and updates repository code/docs or asks the user for decisions.

## Response template

```md
## YYYY-MM-DD HH:MM UTC — Response to: Request title

**Status:** Done / Blocked / Failed / Needs User
**Studio state:** 
**Scripts touched:** 

### Actions performed

### Results

### Console output

### Follow-up for Devin

### Needs user
```

## Rules for reports

- Summarize MCP output instead of pasting huge logs.
- Include exact Studio paths for scripts read or edited.
- Include console errors/warnings that may affect the task.
- Say clearly whether Play Mode was started/stopped.
- If a test could not run, say why.
- Never paste secrets, cookies, tokens or account data.

## First response placeholder

No Windsurf Agent response has been recorded yet.
