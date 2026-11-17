# apex-plugin-roomplan

APEX PL/SQL plugin project for Roomplan.

## Asset flow

The distribution files are synced into `src/js` from the sibling repository `apex_plugin_roomplan_js`.

Run the sync script after building the JS project:

```powershell
.\scripts\sync-roomplan-js.ps1
```

The script mirrors the contents of `..\apex_plugin_roomplan_js\dist` into `src\js`, wiping `src\js` first — do not hand-edit files there.

`src/js-init/room-plan-init.js` is a hand-maintained glue script (not synced) that wires up a region on page load; upload it as plugin file `room-plan-init.js` (without a `js-init/` subdirectory); the plugin references it as `#PLUGIN_FILES#room-plan-init.js`.
