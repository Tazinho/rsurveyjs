HTMLWidgets.widget({
  name: "surveyjs",
  type: "output",

  factory: function (el, width, height) {
    return {
      renderValue: function (x) {
        // DOM container to render into
        const container = el;

        // Grab needed libraries from global window
        const Survey = window.Survey;
        const SurveyReact = window.SurveyReact;

        // Ensure required libs are available
        if (!Survey || !SurveyReact || !React || !ReactDOM) {
          console.error("❌ Required libraries not loaded.");
          return;
        }

        // Set locale globally
        if (x.locale) {
          Survey.locale = x.locale;
        }

        // Create survey model from schema
        let surveyModel = new Survey.Model(x.schema);

        // Store model instance on DOM element for Shiny/custom access
        el.surveyModel = surveyModel;

        // Set locale on model too
        if (x.locale) {
          surveyModel.locale = x.locale;
        }

        // Populate with initial data if provided
        if (x.data) {
          surveyModel.data = x.data;
        }

        // Enable read-only display mode
        if (x.readOnly === true) {
          surveyModel.mode = "display";
        }

        // 🎨 Theme application block (with optional overrides from theme_vars)
        if (x.theme && typeof SurveyTheme !== "undefined") {
          const themeName = x.theme.toLowerCase();

          const themeKey = Object.keys(SurveyTheme).find(key =>
                                                           key.toLowerCase() === themeName ||
                                                           key.toLowerCase().includes(themeName)
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

        // Pre-render hook
        if (x.pre_render_hook) {
          try {
            // Create and execute a function that takes the survey model as input
            const hookFn = new Function("survey", x.pre_render_hook);
            hookFn(surveyModel);
          } catch (err) {
            console.error("Error in pre_render_hook:", err);
          }
        }

        // Render the survey into the container
        // We wait a tiny bit just to make sure everything the DOM is ready (especially helpful in Shiny)
        setTimeout(function () {
          ReactDOM.render(
            React.createElement(SurveyReact.Survey, { model: surveyModel }),
            container
          );

          // Post-render hook
          if (x.post_render_hook) {
            try {
              // Create and execute a function that takes el and x as inputs
              const hookFn = new Function("el", "x", x.post_render_hook);
              hookFn(el, x);
            } catch (err) {
              console.error("Error in post_render_hook:", err);
            }
          }
        }, 0);
      },

      resize: function (width, height) {
        // You can add resizing suppert here if needed later
      }
    };

    // If running in Shiny, enable custom message handlers for server-to-client control
    if (HTMLWidgets.shinyMode) {

      // 🟡 Update form data from R (e.g., for pre-filling answers)
      Shiny.addCustomMessageHandler("surveyjs-data", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.data) {
          el.surveyModel.data = message.data;
        }
      });

      // 🟡 Change the mode (edit/display/readonly)
      Shiny.addCustomMessageHandler("surveyjs-mode", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.mode) {
          el.surveyModel.mode = message.mode;
        }
      });

      // 🟡 Change the survey theme (must match known themes)
      Shiny.addCustomMessageHandler("surveyjs-theme", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.theme && typeof SurveyTheme !== "undefined") {
          const themeKey = Object.keys(SurveyTheme).find(key =>
            key.toLowerCase() === message.theme.toLowerCase()
          );
          if (themeKey) {
            el.surveyModel.applyTheme(SurveyTheme[themeKey]);
          }
        }
      });

      // ✅ Clear/reset the survey
      Shiny.addCustomMessageHandler("surveyjs-clear", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel) {
          el.surveyModel.clear();
        }
      });

      // ✅ Complete the survey programmatically
      Shiny.addCustomMessageHandler("surveyjs-complete", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel) {
          el.surveyModel.completeLastPage();
        }
      });

      // ✅ OPTIONAL: Focus the first question (for accessibility / UX polish)
      Shiny.addCustomMessageHandler("surveyjs-focus", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel) {
          el.surveyModel.focusFirstQuestion();
        }
      });

    }

  }
});





