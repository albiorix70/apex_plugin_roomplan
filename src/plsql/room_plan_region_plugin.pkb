prompt -- RoomPlan APEX region plugin render implementation (APEX 19.2)

create or replace package body room_plan_region_plugin as

  function default_room_data return clob is
  begin
    return apex_string.join_clob(apex_t_varchar2(
      '{',
      '"locationId":1,',
      '"unit":"cm",',
      '"raumBreite":400,',
      '"raumLaenge":300,',
      '"wallPath":null,',
      '"features":[],',
      '"desks":[],',
      '"assets":[],',
      '"sockets":[]',
      '}'
    ));
  end default_room_data;

  function default_palette return clob is
  begin
    return apex_string.join_clob(apex_t_varchar2(
      '[',
      '{"label":"Tisch","template":{"kind":"DESK","deskTyp":"WORKSTATION","label":"Tisch","breite":140,"hoehe":70}},',
      '{"label":"Monitor","template":{"kind":"ASSET","label":"Monitor","hardwareId":4712,"breite":60,"hoehe":15}},',
      '{"label":"Dockingstation","template":{"kind":"ASSET","label":"Dockingstation","hardwareId":4713,"breite":20,"hoehe":10}},',
      '{"label":"PC (Beispiel-Asset)","template":{"kind":"ASSET","label":"PC","hardwareId":4711,"breite":30,"hoehe":20}},',
      '{"label":"Netzwerkdose","template":{"kind":"SOCKET","socketTyp":"NETZWERK","label":"Dose","breite":0,"hoehe":0}},',
      '{"label":"Stromdose","template":{"kind":"SOCKET","socketTyp":"STROM","label":"Dose","breite":0,"hoehe":0}},',
      '{"label":"Tur (nur auf Wand ziehbar, Standardbreite 100cm)","template":{"kind":"FEATURE","featureTyp":"TUER","label":"Tur","breite":100,"hoehe":0}},',
      '{"label":"Fenster (nur auf Wand ziehbar)","template":{"kind":"FEATURE","featureTyp":"FENSTER","label":"Fenster","breite":100,"hoehe":0}}',
      ']'
    ));
  end default_palette;

  procedure print_markup (
    p_container_id in varchar2,
    p_canvas_id    in varchar2,
    p_data_id      in varchar2,
    p_palette_id   in varchar2,
    p_data_json    in clob,
    p_palette_json in clob
  ) is
  begin
    sys.htp.p('<div id="' || apex_escape.html_attribute(p_container_id) || '" class="rp-wrapper">');
    sys.htp.p('  <div class="rp-palette" aria-label="RoomPlan Palette"></div>');
    sys.htp.p('  <div class="rp-editor">');
    sys.htp.p('    <div id="' || apex_escape.html_attribute(p_canvas_id) || '" class="room-plan"></div>');
    sys.htp.p('    <div class="rp-zoom-controls">');
    sys.htp.p('      <button type="button" data-action="zoom-out">-</button>');
    sys.htp.p('      <button type="button" data-action="zoom-reset">100%</button>');
    sys.htp.p('      <button type="button" data-action="zoom-in">+</button>');
    sys.htp.p('      <button type="button" data-action="view-reset">Ansicht zurucksetzen</button>');
    sys.htp.p('      <button type="button" data-action="fit">An Fenster anpassen</button>');
    sys.htp.p('      <button type="button" data-action="save">Speichern</button>');
    sys.htp.p('    </div>');
    sys.htp.p('    <pre class="rp-state-log"></pre>');
    sys.htp.p('  </div>');
    sys.htp.p('</div>');

    sys.htp.p('<script type="application/json" id="' || apex_escape.html_attribute(p_data_id) || '">');
    sys.htp.prn(apex_escape.html(p_data_json));
    sys.htp.p('</script>');

    sys.htp.p('<script type="application/json" id="' || apex_escape.html_attribute(p_palette_id) || '">');
    sys.htp.prn(apex_escape.html(p_palette_json));
    sys.htp.p('</script>');

    sys.htp.p('<style>');
    sys.htp.p('  #' || apex_escape.html_attribute(p_container_id) || ' { font-family: sans-serif; display: flex; gap: 16px; }');
    sys.htp.p('  #' || apex_escape.html_attribute(p_container_id) || ' .rp-palette { display: flex; flex-direction: column; gap: 8px; width: 200px; }');
    sys.htp.p('  #' || apex_escape.html_attribute(p_container_id) || ' .rp-palette-item { border: 1px solid #999; border-radius: 4px; padding: 8px; cursor: grab; background: #fafafa; text-align: center; font-size: 13px; }');
    sys.htp.p('  #' || apex_escape.html_attribute(p_container_id) || ' .room-plan { border: 1px solid #ccc; width: 900px; height: 650px; overflow: hidden; }');
    sys.htp.p('  #' || apex_escape.html_attribute(p_container_id) || ' .rp-zoom-controls { margin: 8px 0; display: flex; gap: 8px; flex-wrap: wrap; }');
    sys.htp.p('  #' || apex_escape.html_attribute(p_container_id) || ' .rp-state-log { max-width: 640px; white-space: pre-wrap; font-size: 12px; margin-top: 8px; }');
    sys.htp.p('</style>');
  end print_markup;

  function render_region (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean
  ) return apex_plugin.t_region_render_result is
    l_result       apex_plugin.t_region_render_result;
    l_static_id    varchar2(255);
    l_container_id varchar2(255);
    l_canvas_id    varchar2(255);
    l_data_id      varchar2(255);
    l_palette_id   varchar2(255);
    l_room_data    clob;
    l_palette      clob;
    l_onload_js    clob;
    l_file_prefix  varchar2(4000);
  begin
    if p_is_printer_friendly then
      return l_result;
    end if;

    l_static_id := nvl(p_region.static_id, 'RP_REGION_' || p_region.id);

    l_container_id := l_static_id || '_wrapper';
    l_canvas_id := l_static_id || '_room_plan';
    l_data_id := l_static_id || '_room_data';
    l_palette_id := l_static_id || '_palette_data';

    l_room_data := nvl(p_region.attribute_01, default_room_data);
    l_palette := nvl(p_region.attribute_02, default_palette);

    l_file_prefix := coalesce(p_region.attribute_03, p_plugin.file_prefix);

    apex_javascript.add_library(
      p_name      => 'room-plan-plugin.min',
      p_directory => l_file_prefix || 'js/'
    );

    print_markup(
      p_container_id => l_container_id,
      p_canvas_id    => l_canvas_id,
      p_data_id      => l_data_id,
      p_palette_id   => l_palette_id,
      p_data_json    => l_room_data,
      p_palette_json => l_palette
    );

    l_onload_js := apex_string.join_clob(apex_t_varchar2(
      '(function () {',
      '  var root = document.getElementById(', apex_escape.js_literal(l_container_id), ');',
      '  var canvas = document.getElementById(', apex_escape.js_literal(l_canvas_id), ');',
      '  var dataNode = document.getElementById(', apex_escape.js_literal(l_data_id), ');',
      '  var paletteNode = document.getElementById(', apex_escape.js_literal(l_palette_id), ');',
      '  if (!root || !canvas || !dataNode || !paletteNode) { return; }',
      '  if (!window.RoomPlan || !RoomPlan.RoomPlanRenderer) {',
      '    if (window.console) { console.error("RoomPlan bundle nicht geladen"); }',
      '    return;',
      '  }',
      '  var roomData = {};',
      '  var paletteData = [];',
      '  try { roomData = JSON.parse(dataNode.textContent || "{}"); } catch (e1) { if (window.console) { console.error(e1); } }',
      '  try { paletteData = JSON.parse(paletteNode.textContent || "[]"); } catch (e2) { if (window.console) { console.error(e2); } }',
      '  var renderer = new RoomPlan.RoomPlanRenderer(canvas, roomData, {',
      '    onValidationWarning: function (warn) {',
      '      if (window.console) { console.warn(warn.code, warn.message); }',
      '    }',
      '  });',
      '  window[''roomPlanRenderer_'' + ', to_char(p_region.id), '] = renderer;',
      '  var paletteContainer = root.querySelector(''.rp-palette'');',
      '  paletteData.forEach(function (item) {',
      '    var el = document.createElement("div");',
      '    el.className = "rp-palette-item";',
      '    el.setAttribute("draggable", "true");',
      '    el.textContent = item.label || "Element";',
      '    el.dataset.template = JSON.stringify(item.template || {});',
      '    el.addEventListener("dragstart", function (evt) {',
      '      evt.dataTransfer.setData("application/json", el.dataset.template);',
      '    });',
      '    paletteContainer.appendChild(el);',
      '  });',
      '  var bind = function (action, fn) {',
      '    var btn = root.querySelector("button[data-action=\"" + action + "\"]");',
      '    if (btn) { btn.addEventListener("click", fn); }',
      '  };',
      '  bind("zoom-in", function () { renderer.zoomIn(); });',
      '  bind("zoom-out", function () { renderer.zoomOut(); });',
      '  bind("zoom-reset", function () { renderer.resetZoom(); });',
      '  bind("view-reset", function () { renderer.resetView(); });',
      '  bind("fit", function () { renderer.fitToContainer(); });',
      '  bind("save", function () {',
      '    var payload = (typeof renderer.getData === "function") ? renderer.getData() : renderer;',
      '    var pre = root.querySelector(".rp-state-log");',
      '    if (pre) { pre.textContent = JSON.stringify(payload, null, 2); }',
      '    if (window.apex && apex.event && typeof apex.event.trigger === "function") {',
      '      apex.event.trigger(root, "roomplan-save", { data: payload });',
      '    }',
      '  });',
      '})();'
    ));

    apex_javascript.add_onload_code(p_code => l_onload_js);

    return l_result;
  exception
    when others then
      apex_debug.error(
        p_message => 'room_plan_region_plugin.render_region failed: %s',
        p0        => sqlerrm
      );
      raise;
  end render_region;

end room_plan_region_plugin;
/
