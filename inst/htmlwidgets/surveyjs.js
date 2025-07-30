HTMLWidgets.widget({
  name: "surveyjs",

  type: "output",

  factory: function (el, width, height) {
    return {
      renderValue: function (x) {
        console.log("📦 SurveyJS renderValue() called");

        const container = el;
        const Survey = window.Survey;
        const SurveyReact = window.SurveyReact;

        if (!Survey || !SurveyReact || !React || !ReactDOM) {
          console.error("❌ Required libraries not loaded.");
          return;
        }

        console.log("SurveyJS schema:", x.schema);
        console.log("React:", React);
        console.log("ReactDOM:", ReactDOM);
        console.log("Survey:", Survey);
        console.log("SurveyReact:", SurveyReact);

        // Set SurveyJS locale before creating the model
        if (x.locale) {
          Survey.settings.defaultLocale = x.locale;
          console.log("🌐 Locale set to:", x.locale);
        }

        // ✅ Step 1: Create the survey model
        let surveyModel = new Survey.Model(x.schema);
        console.log("✅ SurveyJS model created:", surveyModel);
        console.log("All questions:", surveyModel.getAllQuestions());

        // ✅ Step 2: Apply theme if available
        if (x.theme && typeof SurveyTheme !== "undefined") {
          const themeName = x.theme.toLowerCase();
          const themeKey = Object.keys(SurveyTheme).find(key =>
            key.toLowerCase() === themeName || key.toLowerCase().includes(themeName)
          );
          if (themeKey) {
            console.log("🎨 Applying theme:", themeKey);
            surveyModel.applyTheme(SurveyTheme[themeKey]);
          } else {
            console.warn("⚠️ Theme not found:", x.theme);
          }
        }

        // ✅ Step 3: Defer rendering to ensure DOM is ready (important for Shiny)
        setTimeout(function () {
          ReactDOM.render(
            React.createElement(SurveyReact.Survey, {
              model: surveyModel
            }),
            container
          );

          console.log("✅ SurveyJS rendered into:", container);
          console.log("Inner HTML after render:", el.innerHTML);
        }, 0);
      },

      resize: function (width, height) {
        // Optional: implement resizing logic if needed
      }
    };
  }
});
