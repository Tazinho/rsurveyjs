#' SurveyJS core HTML dependency
#'
#' Internal helper that injects the SurveyJS core library as an
#' `htmltools::htmlDependency` for your widget.
#'
#' @return An [htmltools::htmlDependency] for SurveyJS v2.2.6
#' @importFrom htmltools htmlDependency
#' @keywords internal
dep_surveyjs_core <- function() {
  htmltools::htmlDependency(
    name       = "surveyjs-v2",
    version    = "2.2.6",
    src        = "htmlwidgets/lib/surveyjs/2.2.6",
    script     = c("survey.core.min.js", "survey-react-ui.min.js"),
    stylesheet = "survey-core.min.css",
    package    = "rsurveyjs"
  )
}
