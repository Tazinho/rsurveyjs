HTMLWidgets.widget({
  name: "surveyjs",
  type: "output",

  factory: function (el, width, height) {
    return {
      renderValue: function (x) {
        // Set up container and needed libraries
        const container = el;
        const Survey = window.Survey;
        const SurveyReact = window.SurveyReact;

        // Make sure everything we need is loaded
        if (!Survey || !SurveyReact || !React || !ReactDOM) {
          console.error("❌ Required libraries not loaded.");
          return;
        }

        console.log("Available locales:", Survey.localization.getLocales());
        console.log("Current locale:", Survey.settings.defaultLocale);


        // Set the survey language (if one is given)
        if (x.locale) {
          Survey.settings.defaultLocale = x.locale;
        }

        // Create the survey model from the scheema (the form structure)
        let surveyModel = new Survey.Model(x.schema);

        // 🎨 Apply a theme (with optional overrides from theme_vars)
        if (x.theme && typeof SurveyTheme !== "undefined") {
          const themeName = x.theme.toLowerCase();

          const themeKey = Object.keys(SurveyTheme).find(key =>
                                                           key.toLowerCase() === themeName || key.toLowerCase().includes(themeName)
          );

          if (themeKey) {
            // Clone the theme object so we don't modify the original
            const themeObject = { ...SurveyTheme[themeKey] };

            // If custom theme_vars are provided, inject them into cssVariables
            // 🎯 Check for unknown theme_vars before merging
            if (x.theme_vars && typeof x.theme_vars === "object") {
              const knownVars = Object.keys(themeObject.cssVariables || {});
              const suppliedVars = Object.keys(x.theme_vars);
              const unknownVars = suppliedVars.filter(k => !knownVars.includes(k));

            if (unknownVars.length > 0) {
              console.warn(`⚠️ Some theme_vars are not recognized in theme "${themeKey}":`, unknownVars);
            }

            // 🎨 Merge valid (and possibly unknown) theme_vars anyway
            themeObject.cssVariables = {
              ...(themeObject.cssVariables || {}),
              ...x.theme_vars
            };
            }

            // Apply the modified theme to this survey model
            surveyModel.applyTheme(themeObject);
          } else {
            console.warn(`⚠️ Theme "${x.theme}" not found. Skipping theme and theme_vars.`);
          }
        }

        // Render the survey into the container
        // We wait a tiny bit just to make sure everything is ready (especially helpful in Shiny)
        setTimeout(function () {
          ReactDOM.render(
            React.createElement(SurveyReact.Survey, {
              model: surveyModel
            }),
            container
          );
        }, 0);
      },

      resize: function (width, height) {
        // You can add resizing suppert here if needed later
      }
    };
  }
});
