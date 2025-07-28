#' Update a SurveyJS widget on the client
#'
#' @param session Shiny session.
#' @param id      Output id used in `surveyjsOutput()`.
#' @param data     Optional named list of answers to set.
#' @param readOnly Optional logical; toggle read-only mode.
#' @param schema   Optional new schema (list or JSON string).
#' @param theme    Optional theme name.
#' @param locale   Optional locale code.
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
