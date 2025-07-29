HTMLWidgets.widget({
  name: "surveyjs",

  type: "output",

  factory: function(el, width, height) {
    return {
      renderValue: function(x) {
        console.log("📦 SurveyJS renderValue() called");

        // Reset container
        el.innerHTML = '<div id="surveyjs-inner"></div>';
        const container = el.querySelector("#surveyjs-inner");

        // Apply modern theme class
        el.classList.add("sv-root", "sv-root-modern");

        // Debug info
        console.log("SurveyJS schema:", x.schema);
        console.log("React:", typeof React);
        console.log("ReactDOM:", typeof ReactDOM);
        console.log("Survey:", typeof Survey);
        console.log("SurveyReact:", typeof SurveyReact);

        // Check dependencies are loaded
        if (
          typeof React === "undefined" ||
          typeof ReactDOM === "undefined" ||
          typeof SurveyReact === "undefined" ||
          typeof Survey === "undefined"
        ) {
          console.error("❌ One or more SurveyJS dependencies are missing.");
          return;
        }

        // Build model
        let surveyModel = new Survey.Model(x.schema);
        console.log("SurveyJS model created:", surveyModel);
        console.log("All questions:", surveyModel.getAllQuestions());

        // Defer rendering to ensure DOM is ready (important for Shiny)
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

      resize: function(width, height) {
        // No-op: layout handled by SurveyJS
      }
    };
  }
});
