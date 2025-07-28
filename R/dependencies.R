#' Internal HTML dependency for SurveyJS runtime
#' @noRd
.dep_surveyjs_core <- function() {
  htmltools::htmlDependency(
    name = "surveyjs-core",
    version = "1.12.12",
    src = "htmlwidgets/lib/surveyjs/1.12.12",
    package = "rsurveyjs",
    script     = c("survey.core.min.js", "survey-js-ui.min.js"),
    stylesheet = c("defaultV2.min.css")
  )
}
