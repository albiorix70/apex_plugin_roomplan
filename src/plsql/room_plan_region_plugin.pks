prompt -- RoomPlan APEX region plugin render implementation (APEX 19.2)

create or replace package room_plan_region_plugin authid definer as
  function render_region (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean
  ) return apex_plugin.t_region_render_result;

  function ajax_callback (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin
  ) return apex_plugin.t_region_ajax_result;
end room_plan_region_plugin;
/
