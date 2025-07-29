HTMLWidgets.widget({
  name: 'surveyjs',
  type: 'output',
  factory: function(el, width, height) {
    return {
      renderValue: function(x) {
        el.innerHTML = "";

        // Locale setzen (wenn unterstützt)
        if (x.locale && Survey.localization) {
          Survey.localization.currentLocale = x.locale;
        }

        // SurveyJS v2 oder v1?
        const isV2 = x.version === "2";

        // Theme anwenden (nur v2)
        if (isV2 && x.theme && Survey.StylesManager) {
          try {
            Survey.StylesManager.applyTheme(x.theme);
          } catch (e) {
            console.warn("Konnte Theme nicht laden:", x.theme);
          }
        }

        // Theme-Variablen anwenden (nur v2)
        if (isV2 && x.theme_vars) {
          const style = document.createElement("style");
          let css = ":root {";
          for (const [k, v] of Object.entries(x.theme_vars)) {
            css += `${k}: ${v};`;
          }
          css += "}";
          style.innerHTML = css;
          document.head.appendChild(style);
        }

        // Survey-Objekt erstellen (v2 oder v1)
        const model = isV2
          ? new Survey.Model(x.schema)
          : new Survey.SurveyModel(x.schema);

        // Daten setzen
        if (x.data) model.data = x.data;

        // Readonly-Modus
        if (x.readOnly) model.mode = "display";

        // Live-Daten an Shiny senden
        if (x.live && HTMLWidgets.shinyMode) {
          model.onValueChanged.add(function(_, options) {
            Shiny.setInputValue(el.id + "_data_live", model.data);
          });
        }

        // Finaldaten an Shiny senden
        if (HTMLWidgets.shinyMode) {
          model.onComplete.add(function(_, options) {
            Shiny.setInputValue(el.id + "_data", model.data);
          });
        }

        // Render auf DOM-Element
        model.render(el);
      }
    };
  }
});
