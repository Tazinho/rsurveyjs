HTMLWidgets.widget({
  name: "surveyjs",
  type: "output",

  factory: function (el, width, height) {

    function renderSurvey(el, model, config) {
      if (HTMLWidgets.shinyMode) {
        model.onComplete.add(sender => {
          if (sender.isCompleted && !sender.isCurrentPageHasErrors) {
            Shiny.setInputValue(el.id + "_data", sender.data, { priority: "event" });
          }
        });

        if (config.live)
          model.onValueChanged.add(sender => Shiny.setInputValue(el.id + "_data_live", sender.data, { priority: "event" }));
      }

      if (config.complete_hook) {
        try {
          model.onComplete.add(sender => {
            new Function("survey", config.complete_hook)(sender);
          });
          } catch (err) {
          console.error("Complete hook error:", err);
        }
      }


      ReactDOM.render(
        React.createElement(SurveyReact.Survey, { model, key: Math.random() }),
        el
      );
    }

    if (HTMLWidgets.shinyMode) {
      const handlers = {
        "surveyjs-data": (el, msg) => {
          if (msg.data && el.surveyModel.mode !== "display") {
            el.surveyModel.mergeData(msg.data);
          } else if (el.surveyModel.mode === "display") {
            console.warn("Attempted to update survey data while in read-only mode.");
          }
        },
        "surveyjs-mode": (el, msg) => { el.surveyModel.mode = msg.mode; },
        "surveyjs-theme": (el, msg) => { el.surveyModel.applyTheme(SurveyTheme[msg.theme]); },
        "surveyjs-locale": (el, msg) => { el.surveyModel.locale = msg.locale; },
        "surveyjs-schema": (el, msg) => { el.surveyModel.fromJSON(msg.schema); },
        "surveyjs-clear": (el) => { el.surveyModel.clear(); },
        "surveyjs-complete": (el) => { el.surveyModel.completeLastPage(); },
        "surveyjs-focus": (el) => { el.surveyModel.focusFirstQuestion(); }
      };

      Object.entries(handlers).forEach(([name, fn]) => {
        Shiny.addCustomMessageHandler(name, msg => {
          const target = document.getElementById(msg.el);
          if (target && target.surveyModel) {
            fn(target, msg);
            renderSurvey(target, target.surveyModel, target._config);
          }
        });
      });
    }

    return {
      renderValue: function (config) {
        el.id = config.element_id || el.id || `surveyjs-${Math.random().toString(36).slice(2)}`;

        const { schema, locale, data, read_only, theme, theme_vars, pre_render_hook, post_render_hook } = config;
        const model = new Survey.Model(schema);

        if (locale) model.locale = locale;
        if (data) model.data = data;
        if (read_only) model.mode = "display";
        if (theme && SurveyTheme[theme]) {
          const themeObject = { ...SurveyTheme[theme], cssVariables: { ...theme_vars } };
          model.applyTheme(themeObject);
        }
        if (pre_render_hook) new Function("survey", pre_render_hook)(model);

        el.surveyModel = model;
        el._config = config;

        setTimeout(() => {
          renderSurvey(el, model, config);
          if (post_render_hook) new Function("el", "config", post_render_hook)(el, config);
        }, 0);
      },

      resize: function () {}
    };
  }
});
