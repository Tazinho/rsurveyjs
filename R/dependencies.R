dep_surveyjs_core <- function() {
  htmltools::htmlDependency(
    name    = "surveyjs-v2",
    version = "2.2.6",
    src     = "htmlwidgets/lib/surveyjs/2.2.6",
    script  = c("survey.core.min.js", "survey-react-ui.min.js"),  # ← updated
    stylesheet = "survey-core.min.css",
    package = "rsurveyjs"
  )
}
