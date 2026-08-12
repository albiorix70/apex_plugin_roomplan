prompt -- RoomPlan APEX region plugin render implementation (APEX 19.2)

create or replace package room_plan_region_plugin authid definer as
  function render_region (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean
  ) return apex_plugin.t_region_render_result;
end room_plan_region_plugin;
/
