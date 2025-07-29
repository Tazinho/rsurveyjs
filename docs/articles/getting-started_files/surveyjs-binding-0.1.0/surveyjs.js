HTMLWidgets.widget({
  name: 'surveyjs',
  type: 'output',
  factory: function(el, width, height) {
    return {
      renderValue: function(x) {
        el.innerHTML = "";

        if (x.locale && Survey.localization) {
          Survey.localization.currentLocale = x.locale;
        }

        if (x.theme && Survey.StylesManager) {
          try {
            Survey.StylesManager.applyTheme(x.theme);
          } catch (e) {
            console.warn("Theme konnte nicht angewendet werden:", x.theme);
          }
        }

        if (x.theme_vars) {
          const style = document.createElement("style");
          let css = ":root {";
          for (const [k, v] of Object.entries(x.theme_vars)) {
            css += `${k}: ${v};`;
          }
          css += "}";
          style.innerHTML = css;
          document.head.appendChild(style);
        }

        const model = new Survey.Model(x.schema);

        if (x.data) model.data = x.data;
        if (x.readOnly) model.mode = "display";

        if (x.live && HTMLWidgets.shinyMode) {
          model.onValueChanged.add(function(_, options) {
            Shiny.setInputValue(el.id + "_data_live", model.data);
          });
        }

        if (HTMLWidgets.shinyMode) {
          model.onComplete.add(function(_, options) {
            Shiny.setInputValue(el.id + "_data", model.data);
          });
        }

        model.render(el);
      }
    };
  }
});
