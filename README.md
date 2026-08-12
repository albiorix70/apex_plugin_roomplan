# apex-plugin-roomplan

APEX PL/SQL plugin project for Roomplan.

## Asset flow

The distribution files are synced into `src/js` from the sibling repository `apex_plugin_roomplan_js`.

Run the sync script after building the JS project:

```powershell
.\scripts\sync-roomplan-js.ps1
```

The script mirrors the contents of `..\apex_plugin_roomplan_js\dist` into `src\js`.
