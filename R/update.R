#' Dynamically update a `surveyjs()` widget from the server side
#'
#' This function sends a message to an existing SurveyJS widget rendered in the UI,
#' allowing you to update its data, read-only mode, theme, locale, or schema dynamically
#' from the server using Shiny.
#'
#' @param session Shiny session object.
#' @param id Output ID used in `surveyjsOutput()`.
#' @param data Optional named list of answers to set.
#' @param read_only Optional logical; toggle read-only mode.
#' @param schema Optional new schema (list or JSON string).
#' @param theme Optional theme name (e.g. `"modern"`).
#' @param locale Optional locale code (e.g. `"en"`, `"de"`).
#'
#' @examples
#' \dontrun{
#' # Inside a Shiny app server function:
#' updateSurveyjs(session, "mysurvey", data = list(q1 = "Yes"))
#' }
#'
#' @export
updateSurveyjs <- function(session, id,
                           data = NULL, read_only = NULL, schema = NULL,
                           theme = NULL, locale = NULL) {

  if (!is.null(data)) {
    session$sendCustomMessage("surveyjs-data", list(el = id, data = data))
  }
  if (!is.null(read_only)) {
    session$sendCustomMessage("surveyjs-mode", list(el = id, mode = if (read_only) "display" else "edit"))
  }
  if (!is.null(schema)) {
    session$sendCustomMessage("surveyjs-schema", list(el = id, schema = schema))
  }
  if (!is.null(theme)) {
    session$sendCustomMessage("surveyjs-theme", list(el = id, theme = theme))
  }
  if (!is.null(locale)) {
    session$sendCustomMessage("surveyjs-locale", list(el = id, locale = locale))
  }
}
