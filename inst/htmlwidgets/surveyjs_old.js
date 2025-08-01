HTMLWidgets.widget({
  name: "surveyjs",
  type: "output",

  factory: function (el, width, height) {

    return {
      renderValue: function (x) {
        // 🔑 Assign DOM id if not already set (needed for Shiny message targeting)
        if (!el.id) {
          el.id = x.element_id || ("surveyjs-" + Math.random().toString(36).slice(2));
        }

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

        // Event Listeners
        // Completion updates input$_y_survey_data
        if (HTMLWidgets.shinyMode) {
          surveyModel.onComplete.add(function(sender) {
            const inputId = el.id + "_data";
            Shiny.setInputValue(inputId, sender.data, { priority: "event" });
        });
        }

        // Typing in the form updates input$my_survey_data_live instantly
        if (x.live === true && HTMLWidgets.shinyMode) {
          surveyModel.onValueChanged.add(function(sender, options) {
            const inputId = el.id + "_data_live";
            Shiny.setInputValue(inputId, sender.data, { priority: "event" });
            });
        }

        // ✅ Add complete_hook
        if (x.complete_hook) {
          try {
            const hookFn = new Function("survey", x.complete_hook);
            surveyModel.onComplete.add(hookFn);
            } catch (err) {
              console.error("Error in complete_hook:", err);
            }
        }

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
        if (x.read_only === true) {
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
        // No manual resizing needed; SurveyJS layout is responsive by default
      }
    };

    // If running in Shiny, enable custom message handlers for server-to-client control
    if (HTMLWidgets.shinyMode) {

      // Update form data from R (e.g., for pre-filling answers)
      Shiny.addCustomMessageHandler("surveyjs-data", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.data) {
          // Clone model, set data, reassign and re-render
          const newModel = new Survey.Model(el.surveyModel.toJSON());
          newModel.data = message.data;
          el.surveyModel = newModel;
          ReactDOM.render(
            React.createElement(SurveyReact.Survey, { model: newModel }),
            el
          );
        }
      });

      // Set survey mode (edit/display)
      Shiny.addCustomMessageHandler("surveyjs-mode", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.mode) {
          // Clone model, preserve data add mode and re-render
          const newModel = new Survey.Model(el.surveyModel.toJSON());
          newModel.data = el.surveyModel.data; // preserve data
          newModel.mode = message.mode;
          el.surveyModel = newModel;
          ReactDOM.render(
            React.createElement(SurveyReact.Survey, { model: newModel }),
            el
          );
        }
      });

      // Update theme
      Shiny.addCustomMessageHandler("surveyjs-theme", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.theme && typeof SurveyTheme !== "undefined") {
          const themeKey = Object.keys(SurveyTheme).find(key =>
          key.toLowerCase() === message.theme.toLowerCase() ||
          key.toLowerCase().includes(message.theme.toLowerCase())
        );
        if (themeKey) {
          el.surveyModel.applyTheme(SurveyTheme[themeKey]);
        }
      }
      });

      // Update locale
      Shiny.addCustomMessageHandler("surveyjs-locale", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.locale) {
          el.surveyModel.locale = message.locale;
        }
      });

      // Replace schema
      Shiny.addCustomMessageHandler("surveyjs-schema", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel && message.schema) {
          el.surveyModel.fromJSON(message.schema);
        }
      });

      // REAKTIVE UPDATES HERE. We dont want to trigger them
      // ...from inside updateSurveyjs() automatically, as those are
      // imperative actions — not updates.
      // It's better to let the user explicitly call e.g.:
      //session$sendCustomMessage("surveyjs-complete", list(el = "mysurvey"))

      // Clear/reset survey
      Shiny.addCustomMessageHandler("surveyjs-clear", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel) {
          el.surveyModel.clear();
        }
      });

      // Complete the survey
      Shiny.addCustomMessageHandler("surveyjs-complete", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel) {
          el.surveyModel.completeLastPage();
        }
      });

      // Focus first question (for accessibility / UX polish)
      Shiny.addCustomMessageHandler("surveyjs-focus", function(message) {
        const el = document.getElementById(message.el);
        if (el && el.surveyModel) {
          el.surveyModel.focusFirstQuestion();
        }
      });
    }

  }
});


