// Keep a small registry so we can update models from R
window.__rsurveyjs_models = window.__rsurveyjs_models || {};

HTMLWidgets.widget({
  name: 'surveyjs',
  type: 'output',

  factory: function(el, width, height) {
    let model = null;
    let liveTimer = null; // debounce timer for live updates

    function render(x) {
      // 1) Read schema from R
      const schema = (typeof x.schema === 'string') ? JSON.parse(x.schema || "{}") : (x.schema || {});

      // 2) Clear host and add a container
      while (el.firstChild) el.removeChild(el.firstChild);
      const host = document.createElement('div');
      host.className = 'rsurveyjs-host';
      el.appendChild(host);

      // 3) Ensure Survey core is present
      if (!(window.Survey && Survey.Model)) {
        const msg = 'SurveyJS core not loaded (check dependency paths).';
        if (window.console) console.error('[rsurveyjs]', msg);
        host.innerHTML = '<div style="color:#b00">' + msg + '</div>';
        return;
      }

      // 4) Build the model
      model = new Survey.Model(schema);
      if (x.data)     model.data = x.data;    // optional initial values
      if (x.readOnly) model.readOnly = true;  // optional read-only
      if (x.locale)   model.locale = x.locale;

      // Optional theme (applies if available in this version)
      try {
        if (x.theme && Survey.StylesManager && typeof Survey.StylesManager.applyTheme === 'function') {
          Survey.StylesManager.applyTheme(x.theme);
        }
      } catch(e) { /* ignore */ }

      // 5) Send final results to Shiny on "Complete"
      model.onComplete.add(function(sender) {
        if (HTMLWidgets.shinyMode && window.Shiny) {
          Shiny.setInputValue(el.id + '_data', sender.data, { priority: 'event' });
        }
      });

      // 6) Send debounced live data on every change (if enabled)
      if (x.live) {
        model.onValueChanged.add(function() {
          if (!(HTMLWidgets.shinyMode && window.Shiny)) return;
          if (liveTimer) clearTimeout(liveTimer);
          liveTimer = setTimeout(function() {
            try {
              Shiny.setInputValue(el.id + '_data_live', model.data, { priority: 'event' });
            } catch (e) {
              if (window.console) console.warn('[rsurveyjs] live update failed:', e);
            }
          }, 200); // debounce delay
        });
      }

      // 7) Render — v1.12.x supports rendering directly from the model
      if (typeof model.render === 'function') {
        model.render(host);
      } else if (Survey && typeof Survey.Survey === 'function') {
        // fallback for builds exposing a UI wrapper
        const ui = new Survey.Survey(model);
        ui.render(host);
      } else {
        const msg = 'SurveyJS UI not found. Ensure survey-js-ui.min.js is loaded for this version.';
        if (window.console) console.error('[rsurveyjs]', msg);
        host.innerHTML = '<div style="color:#b00">' + msg + '</div>';
      }

      // 8) Register model for update handler
      window.__rsurveyjs_models[el.id] = model;
    }

    return { renderValue: render, resize: function(w, h) { /* no-op */ } };
  }
});

// ---- Shiny update handler -------------------------------------------------
if (HTMLWidgets.shinyMode && window.Shiny) {
  Shiny.addCustomMessageHandler("rsurveyjs:update", function(msg) {
    const model = window.__rsurveyjs_models && window.__rsurveyjs_models[msg.id];
    if (!model) return;

    try {
      if (msg.schema) {
        const j = (typeof msg.schema === 'string') ? JSON.parse(msg.schema) : msg.schema;
        model.fromJSON(j); // replace questions safely
      }
      if (msg.data)           model.data = msg.data;
      if (msg.readOnly != null) model.readOnly = !!msg.readOnly;
      if (msg.locale)         model.locale = msg.locale;
      if (msg.theme && Survey.StylesManager && typeof Survey.StylesManager.applyTheme === 'function') {
        Survey.StylesManager.applyTheme(msg.theme);
      }
    } catch(e) {
      if (window.console) console.error('[rsurveyjs] update failed:', e);
    }
  });
}
