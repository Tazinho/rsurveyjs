#' SurveyJS core HTML dependency
#'
#' Internal helper that injects the SurveyJS core library as an
#' `htmltools::htmlDependency` for your widget.
#'
#' @return An [htmltools::htmlDependency] for SurveyJS v2.2.6
#' @importFrom htmltools htmlDependency
#' @keywords internal
#’ @noRd
dep_react <- function() {
  htmltools::htmlDependency(
    name = "react",
    version = "18.2.0",
    src = c(file = system.file("htmlwidgets/lib/react", package = "rsurveyjs")),
    script = "react.production.min.js"
  )
}

#' Internal helper to load the React DOM Model as an
#' `htmltools::htmlDependency` for your widget.
#'
#' @return An [htmltools::htmlDependency] for SurveyJS v2.2.6
#' @importFrom htmltools htmlDependency
#' @keywords internal
#’ @noRd
dep_reactdom <- function() {
  htmltools::htmlDependency(
    name = "react-dom",
    version = "18.2.0",
    src = c(file = system.file("htmlwidgets/lib/react_dom", package = "rsurveyjs")),
    script = "react-dom.production.min.js"
  )
}

#' Internal helper that loads react as an
#' `htmltools::htmlDependency` for your widget.
#'
#' @return An [htmltools::htmlDependency] for SurveyJS v2.2.6
#' @importFrom htmltools htmlDependency
#' @keywords internal
#’ @noRd
dep_surveyjs_core <- function() {
  htmltools::htmlDependency(
    name = "surveyjs", version = "2.2.6",
    src = c(file = system.file("htmlwidgets/lib/surveyjs", package = "rsurveyjs")),
    script = c(
      "survey.core.min.js",
      "survey-react-ui.min.js",
      "survey.themes.min.js",
      "survey.i18n.min.js"
    ),
    stylesheet = "survey-core.min.css",
    all_files = TRUE
  )
}
