# AGENTS.md

This repository is an Oracle APEX plugin project for Roomplan.

## Project Facts

- Start with [README.md](README.md) for the current project summary.
- The repository currently contains documentation and helper scripts; the main implementation files are not yet present under `src/`.
- JavaScript distribution files are expected to come from the sibling repository `../apex_plugin_roomplan_js` and are synced into `src/js`.

## Working Rules

- Prefer minimal changes and keep Oracle APEX compatibility in mind.
- When a task touches JavaScript assets, account for the sync flow in [scripts/sync-roomplan-js.ps1](scripts/sync-roomplan-js.ps1).
- Do not invent npm, Node, SQLcl, or test commands unless the repository adds them.
- In files committed to this repository (e.g. APEX exports under `src/plugin/`), always use `TEST` as the schema name. Replace any other schema or owner name (e.g. from the connected database) with `TEST`.
- If SQL or PL/SQL files are introduced or edited, also follow [.github/instructions/oracle-apex-plsql.instructions.md](.github/instructions/oracle-apex-plsql.instructions.md).

## Validation

- The only verified project command today is:

```powershell
.\scripts\sync-roomplan-js.ps1
```

- No automated test, lint, or build command is documented in this repository yet.