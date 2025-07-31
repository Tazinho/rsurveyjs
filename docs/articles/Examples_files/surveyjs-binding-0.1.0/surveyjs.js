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

        // Set the survey language (if one is given)
        // This ensures the correct locale is used for text, buttons, etc.
        // Set the global default
        if (x.locale) {
          Survey.locale = x.locale;
        }

        // Create the survey model from the schema
        let surveyModel = new Survey.Model(x.schema);

        // Store the model instance on the DOM element for access from custom message handler
        el.surveyModel = surveyModel;

        // Set locale directly on the model (more reliable)
        if (x.locale) {
          surveyModel.locale = x.locale;
        }

        // Prefill data if provided
        if (x.data) {
          surveyModel.data = x.data;
        }

        // Apply read-only mode if requested
        if (x.readOnly === true) {
          surveyModel.mode = "display";
        }

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

    // If running in Shiny, add a custom message handler to update form data
    if (HTMLWidgets.shinyMode) {
      Shiny.addCustomMessageHandler("surveyjs-data", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.data) {
          el.surveyModel.data = message.data;
        }
    });

    Shiny.addCustomMessageHandler("surveyjs-mode", function(message) {
      const el = document.getElementById(message.el);
      if (el && el.surveyModel && message.mode) {
        el.surveyModel.mode = message.mode;
      }
    });

    Shiny.addCustomMessageHandler("surveyjs-theme", function(message) {
      const el = document.getElementById(message.el);
      if (el && el.surveyModel && message.theme && typeof SurveyTheme !== "undefined") {
        const themeKey = Object.keys(SurveyTheme).find(key =>
        key.toLowerCase() === message.theme.toLowerCase()
      );
      if (themeKey) {
        el.surveyModel.applyTheme(SurveyTheme[themeKey]);
      }
    }  });
    }

  }
});
