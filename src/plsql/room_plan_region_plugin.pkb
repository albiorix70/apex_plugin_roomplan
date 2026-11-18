pro    -- RoomPlan APEX region plugin render implementation (APEX 19.2)

create or replace package body room_plan_region_plugin as

   function default_room_data return clob is
   begin
      return apex_string.join_clob(apex_t_varchar2(
         q'[{]',
         q'["locationId":1,]',
         q'["unit":"cm",]',
         q'["raumBreite":400,]',
         q'["raumLaenge":300,]',
         q'["wallPath":null,]',
         q'["features":[],]',
         q'["desks":[],]',
         q'["assets":[],]',
         q'["sockets":[]]',
         q'[}]'
      ));
   end default_room_data;

   function default_palette return clob is
   begin
      return apex_string.join_clob(apex_t_varchar2(
         q'[[]',
         q'[{"label":"Tisch","template":{"kind":"DESK","deskTyp":"WORKSTATION","label":"Tisch","breite":140,"hoehe":70}},]',
         q'[{"label":"Monitor","template":{"kind":"ASSET","label":"Monitor","hardwareId":4712,"breite":60,"hoehe":15}},]',
         q'[{"label":"Dockingstation","template":{"kind":"ASSET","label":"Dockingstation","hardwareId":4713,"breite":20,"hoehe":10}},]',
         q'[{"label":"PC (Beispiel-Asset)","template":{"kind":"ASSET","label":"PC","hardwareId":4711,"breite":30,"hoehe":20}},]',
         q'[{"label":"Netzwerkdose","template":{"kind":"SOCKET","socketTyp":"NETZWERK","label":"Dose","breite":0,"hoehe":0}},]',
         q'[{"label":"Stromdose","template":{"kind":"SOCKET","socketTyp":"STROM","label":"Dose","breite":0,"hoehe":0}},]',
         q'[{"label":"Tur (nur auf Wand ziehbar, Standardbreite 100cm)","template":{"kind":"FEATURE","featureTyp":"TUER","label":"Tur","breite":100,"hoehe":0}},]',
         q'[{"label": "Fenster (nur auf Wand ziehbar)","template": {"kind": "FEATURE","featureTyp": "FENSTER","label":"Fenster", "breite": 100,"hoehe": 0 } }]',
         q'[]]'
      ));
   end default_palette;

   function ajax_callback (
      p_region in apex_plugin.t_region,
      p_plugin in apex_plugin.t_plugin
   ) return apex_plugin.t_region_ajax_result is
      l_result    apex_plugin.t_region_ajax_result;
      l_room_data clob;
      l_palette   clob;
   begin
      if apex_application.g_debug then
         apex_plugin_util.debug_region(
            p_plugin              => p_plugin,
            p_region              => p_region,
            p_is_printer_friendly => false
         );
      end if;
      l_room_data := nvl(
         p_region.attribute_01,
         default_room_data
      );
      l_palette := nvl(
         p_region.attribute_02,
         default_palette
      );
      sys.htp.prn(apex_string.join_clob(apex_t_varchar2(
         q'[{"data":]',
         l_room_data,
         q'[,"palette":]',
         l_palette,
         q'[}]'
      )));

      return l_result;
   exception
      when others then
         apex_debug.error(
            p_message => 'room_plan_region_plugin.ajax_callback failed: %s',
            p0        => sqlerrm
         );
         raise;
   end ajax_callback;

   procedure print_markup (
      p_container_id in varchar2,
      p_canvas_id    in varchar2
   ) is
   begin
      sys.htp.p('<div id="'
                || apex_escape.html_attribute(p_container_id) || '" class="rp-wrapper">');
      sys.htp.p('  <div class="rp-palette" aria-label="RoomPlan Palette"></div>');
      sys.htp.p('  <div class="rp-editor">');
      sys.htp.p('    <div id="'
                || apex_escape.html_attribute(p_canvas_id) || '" class="room-plan"></div>');
      sys.htp.p('    <div class="a-Toolbar rp-zoom-controls">');
      sys.htp.p('      <div class="a-Toolbar-body">');
      sys.htp.p('        <div class="a-Toolbar-group">');
      sys.htp.p('          <button type="button" class="t-Button t-Button--small" data-action="zoom-out" aria-label="Verkleinern" title="Verkleinern">-</button>');
      sys.htp.p('          <button type="button" class="t-Button t-Button--small" data-action="zoom-reset" aria-label="Zoom zuruecksetzen" title="Zoom zuruecksetzen">100%</button>');
      sys.htp.p('          <button type="button" class="t-Button t-Button--small" data-action="zoom-in" aria-label="Vergroessern" title="Vergroessern">+</button>');
      sys.htp.p('          <button type="button" class="t-Button t-Button--small" data-action="view-reset" aria-label="Ansicht zuruecksetzen" title="Ansicht zuruecksetzen">Ansicht zuruecksetzen</button>');
      sys.htp.p('          <button type="button" class="t-Button t-Button--small" data-action="fit">An Fenster anpassen</button>');
      sys.htp.p('          <button type="button" class="t-Button t-Button--small t-Button--hot" data-action="save">Speichern</button>');
      sys.htp.p('        </div>');
      sys.htp.p('      </div>');
      sys.htp.p('    </div>');
      sys.htp.p('    <pre class="rp-state-log"></pre>');
      sys.htp.p('  </div>');
      sys.htp.p('</div>');
      sys.htp.p('<style>');
      sys.htp.p('  #'
                || apex_escape.html_attribute(p_container_id) || ' { display: flex; gap: 16px; }');
      sys.htp.p('  #'
                || apex_escape.html_attribute(p_container_id) || ' .rp-palette { display: flex; flex-direction: column; gap: 8px; width: 200px; }'
                );
      sys.htp.p('  #'
                || apex_escape.html_attribute(p_container_id) || ' .rp-palette-item { cursor: grab; width: 100%; text-align: left; }'
                );
      sys.htp.p('  #'
                || apex_escape.html_attribute(p_container_id) || ' .room-plan { border: 1px solid; width: 900px; height: 650px; overflow: hidden; }'
                );
      sys.htp.p('  #'
                || apex_escape.html_attribute(p_container_id) || ' .rp-zoom-controls { margin: 8px 0; }'
                );
      sys.htp.p('  #'
                || apex_escape.html_attribute(p_container_id) || ' .rp-state-log { max-width: 640px; white-space: pre-wrap; font-size: 12px; margin-top: 8px; }'
                );
      sys.htp.p('</style>');
   end print_markup;

   function render_region (
      p_region              in apex_plugin.t_region,
      p_plugin              in apex_plugin.t_plugin,
      p_is_printer_friendly in boolean
   ) return apex_plugin.t_region_render_result is
      l_result          apex_plugin.t_region_render_result;
      l_static_id       varchar2(255);
      l_container_id    varchar2(255);
      l_canvas_id       varchar2(255);
      l_ajax_identifier varchar2(4000);
      l_config_json     clob;
      l_onload_js       clob;
   begin
      if apex_application.g_debug then
         apex_plugin_util.debug_region(
            p_plugin              => p_plugin,
            p_region              => p_region,
            p_is_printer_friendly => p_is_printer_friendly
         );
      end if;

      if p_is_printer_friendly then
         return l_result;
      end if;
      l_static_id := nvl(
         p_region.static_id,
         'RP_REGION_' || p_region.id
      );
      l_container_id := l_static_id || '_wrapper';
      l_canvas_id := l_static_id || '_room_plan';
      print_markup(
         p_container_id => l_container_id,
         p_canvas_id    => l_canvas_id
      );
      l_ajax_identifier := apex_plugin.get_ajax_identifier;
      apex_json.initialize_clob_output;
      apex_json.open_object;
      apex_json.write(
         'containerId',
         l_container_id
      );
      apex_json.write(
         'canvasId',
         l_canvas_id
      );
      apex_json.write(
         'regionId',
         p_region.id
      );
      apex_json.write(
         'ajaxIdentifier',
         l_ajax_identifier
      );
      apex_json.close_object;
      l_config_json := apex_json.get_clob_output;
      apex_json.free_output;
      l_onload_js := apex_string.join_clob(apex_t_varchar2(
         q'[RoomPlanInitRegion(]',
         l_config_json,
         q'[);]'
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