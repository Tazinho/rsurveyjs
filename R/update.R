#' Dynamically update a `surveyjs()` widget from the server side
#'
#' This function sends a message to an existing SurveyJS widget rendered in the UI,
#' allowing you to update its data, read-only mode, theme, locale, or schema dynamically
#' from the server using Shiny.
#'
#' @param session Shiny session object.
#' @param id Output ID used in `surveyjsOutput()`.
#' @param data Optional named list of answers to set.
#' @param readOnly Optional logical; toggle read-only mode.
#' @param schema Optional new schema (list or JSON string).
#' @param theme Optional theme name (e.g. `"modern"`).
#' @param locale Optional locale code (e.g. `"en"`, `"de"`).
#'
#' @examples
#' # Inside a Shiny server function:
#' updateSurveyjs(session, "mysurvey", data = list(q1 = "Yes"))
#'
#' @export
updateSurveyjs <- function(session, id,
                           data     = NULL,
                           readOnly = NULL,
                           schema   = NULL,
                           theme    = NULL,
                           locale   = NULL) {

  payload <- list(
    id = id,
    data = data,
    readOnly = readOnly,
    schema = if (!is.null(schema)) if (is.character(schema)) schema else jsonlite::toJSON(schema, auto_unbox = TRUE),
    theme  = theme,
    locale = locale
  )
  session$sendCustomMessage("rsurveyjs:update", payload)
}
