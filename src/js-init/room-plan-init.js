"use strict";

window.RoomPlanInitRegion = function (config) {
  var root = document.getElementById(config.containerId);
  var canvas = document.getElementById(config.canvasId);
  if (!root || !canvas) { return; }
  if (!window.RoomPlan || !RoomPlan.RoomPlanRenderer) {
    if (window.console) { console.error("RoomPlan bundle nicht geladen"); }
    return;
  }
  if (!window.apex || !apex.server || typeof apex.server.plugin !== "function") {
    if (window.console) { console.error("apex.server.plugin nicht verfuegbar"); }
    return;
  }

  canvas.textContent = "Wird geladen...";

  apex.server.plugin(config.ajaxIdentifier, {}, {
    dataType: "json",
    success: function (response) {
      var roomData = (response && response.data) || {};
      var paletteData = (response && response.palette) || [];
      canvas.textContent = "";

      var renderer = new RoomPlan.RoomPlanRenderer(canvas, roomData, {
        onValidationWarning: function (warn) {
          if (window.console) { console.warn(warn.code, warn.message); }
        }
      });
      window["roomPlanRenderer_" + config.regionId] = renderer;

      var paletteContainer = root.querySelector(".rp-palette");
      paletteData.forEach(function (item) {
        var el = document.createElement("div");
        el.className = "t-Button t-Button--small rp-palette-item";
        el.setAttribute("draggable", "true");
        el.textContent = item.label || "Element";
        el.dataset.template = JSON.stringify(item.template || {});
        el.addEventListener("dragstart", function (evt) {
          evt.dataTransfer.setData("application/json", el.dataset.template);
        });
        paletteContainer.appendChild(el);
      });

      var bind = function (action, fn) {
        var btn = root.querySelector('button[data-action="' + action + '"]');
        if (btn) { btn.addEventListener("click", fn); }
      };
      bind("zoom-in", function () { renderer.zoomIn(); });
      bind("zoom-out", function () { renderer.zoomOut(); });
      bind("zoom-reset", function () { renderer.resetZoom(); });
      bind("view-reset", function () { renderer.resetView(); });
      bind("fit", function () { renderer.fitToContainer(); });
      bind("save", function () {
        var payload = (typeof renderer.getData === "function") ? renderer.getData() : renderer;
        var pre = root.querySelector(".rp-state-log");
        if (pre) { pre.textContent = JSON.stringify(payload, null, 2); }
        if (window.apex && apex.event && typeof apex.event.trigger === "function") {
          apex.event.trigger(root, "roomplan-save", { data: payload });
        }
      });
    },
    error: function (jqXHR) {
      canvas.textContent = "RoomPlan-Daten konnten nicht geladen werden.";
      if (window.console) { console.error("RoomPlan AJAX-Ladefehler", jqXHR); }
    }
  });
};
