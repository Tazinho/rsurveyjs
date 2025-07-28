#' @keywords internal
dep_surveyjs_core <- function(version = c("2", "1")) {
  version <- match.arg(version)

  if (identical(version, "2")) {
    htmltools::htmlDependency(
      name       = "surveyjs-core",
      version    = "2.2.6",
      src        = "htmlwidgets/lib/surveyjs/2.2.6",
      package    = "rsurveyjs",
      script     = c("survey.core.min.js", "survey-js-ui.min.js"),
      stylesheet = "survey-core.min.css"   # v2 CSS
    )
  } else {
    htmltools::htmlDependency(
      name       = "surveyjs-core",
      version    = "1.12.12",
      src        = "htmlwidgets/lib/surveyjs/1.12.12",
      package    = "rsurveyjs",
      script     = c("survey.core.min.js", "survey-js-ui.min.js"),
      stylesheet = "defaultV2.min.css"     # v1 CSS
    )
  }
}
