# apex-plugin-roomplan

APEX PL/SQL plugin project for Roomplan.

## Asset flow

The JavaScript bundle is copied into `assets/roomplan.js` from the sibling repository `apex_plugin_roomplan_js`.

Run the sync script after building the JS project:

```powershell
.\scripts\sync-roomplan-js.ps1
```

The script looks for the newest `*.js` file in `..\apex_plugin_roomplan_js\dist` and writes it into the plugin asset folder.
