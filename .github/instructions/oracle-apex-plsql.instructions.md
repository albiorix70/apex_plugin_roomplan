---
applyTo: "**/*.{sql,pls,pks,pkb,plb}"
description: "Use when editing Oracle SQL or PL/SQL files in this Oracle APEX plugin repository. Keep syntax Oracle-compatible, preserve APEX plugin semantics, and avoid assuming non-Oracle tooling."
---

# Oracle APEX PL/SQL Instructions

- Target Oracle SQL and PL/SQL syntax only. Do not use PostgreSQL, SQL Server, or MySQL-specific features.
- Assume code in these files is part of an Oracle APEX plugin integration unless the file itself clearly establishes a different boundary.
- Preserve package specs and bodies, object names, and public signatures unless the task explicitly requires an interface change.
- Prefer clear PL/SQL blocks with explicit exception handling when behavior can fail at runtime.
- When generating dynamic SQL, use bind variables and avoid string concatenation for user-provided values.
- Keep APEX-facing code defensive around session state, page item names, and plugin attribute usage.
- If a change depends on front-end behavior, check whether the corresponding asset must be synced through [scripts/sync-roomplan-js.ps1](../../scripts/sync-roomplan-js.ps1).
- Link to existing repository docs instead of duplicating them; start with [README.md](../../README.md).