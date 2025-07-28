HTMLWidgets.widget({
  name: 'surveyjs',
  type: 'output',

  factory: function(el, width, height) {

    // NEU: CSS-Variablen auf dem Host setzen (scoped)
    function applyThemeVars(host, vars) {
      if (!vars || typeof vars !== 'object') return;
      // CSS-Regel nur für diesen Host (scoped via Klasse)
      let css = '.rsurveyjs-host{';
      Object.entries(vars).forEach(([k, v]) => {
        const key = k.startsWith('--') ? k : `--${k}`;
        css += `${key}:${v};`;
      });
      css += '}';
      const style = document.createElement('style');
      style.setAttribute('data-rsurveyjs-theme', '');
      style.textContent = css;
      host.appendChild(style);
    }

    function render(x) {
      const schema = (typeof x.schema === 'string') ? JSON.parse(x.schema) : x.schema;

      el.innerHTML = '';
      const host = document.createElement('div');
      host.className = 'rsurveyjs-host';
      el.appendChild(host);

      if (typeof window.Survey === 'undefined' || !Survey.Model) {
        console.error('[rsurveyjs] SurveyJS runtime not loaded.');
        return;
      }

      // NEU: Theme-Variablen (vor dem Rendern setzen)
      applyThemeVars(host, x.themeVars);

      const model = new Survey.Model(schema);

      if (x && x.data)     { model.data = x.data; }
      if (x && x.readOnly) { model.readOnly = true; }
      if (x && x.locale)   { try { model.locale = x.locale; } catch(e){} }

      if (x && x.live && HTMLWidgets.shinyMode && window.Shiny) {
        let debounce;
        model.onValueChanged.add(function() {
          if (debounce) clearTimeout(debounce);
          debounce = setTimeout(function() {
            try {
              Shiny.setInputValue(el.id + '_data_live', model.data, { priority: 'event' });
            } catch(e){}
          }, 200);
        });
      }

      model.onComplete.add(function(sender) {
        if (HTMLWidgets.shinyMode && window.Shiny) {
          try {
            Shiny.setInputValue(el.id + '_data', sender.data, { priority: 'event' });
          } catch(e){}
        }
      });

      const survey = new Survey.Survey(model);
      survey.render(host);
    }

    return { renderValue: render, resize: function(w, h){} };
  }
});
