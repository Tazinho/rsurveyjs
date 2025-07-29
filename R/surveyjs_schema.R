#' SurveyJS JSON Schema Documentation
#'
#' SurveyJS surveys are defined as JSON. This function links to the official documentation
#' describing supported question types, structure, and logic options.
#'
#' @return Invisibly returns the URL to the SurveyJS schema docs.
#' @examples
#' if (interactive()) utils::browseURL(surveyjs_schema())
#' @export
surveyjs_schema <- function() {
  url <- "https://surveyjs.io/form-library/documentation/json-schema"
  return(invisible(url))
}
