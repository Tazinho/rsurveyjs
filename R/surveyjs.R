#' SurveyJS widget for Shiny
#'
#' Render a SurveyJS form from a JSON/list schema. Final answers are delivered to
#' `input[[paste0(id, "_data")]]` after the user clicks **Complete**. If `live = TRUE`,
#' live updates while typing are delivered to `input[[paste0(id, "_data_live")]]`.
#'
#' @param schema   List or JSON string; SurveyJS survey JSON.
#' @param data     Optional named list of initial answers.
#' @param readOnly Logical; render in read-only mode.
#' @param live     Logical; send live updates while typing? Default `TRUE`.
#' @param theme    SurveyJS theme name (e.g., `"defaultV2"` for v1.x).
#' @param locale   Locale code (e.g., `"en"`, `"de"`).
#' @param width,height CSS size or number for the widget container.
#' @param elementId Optional element id.
#' @return An htmlwidget to be used in Shiny UIs.
#' @export
surveyjs <- function(schema,
                     data = NULL,
                     readOnly = FALSE,
                     live = FALSE,
                     locale = NULL,
                     theme = NULL,          # <— NEU
                     theme_vars = NULL,
                     version = c("2", "1"),
                     width = NULL, height = NULL, elementId = NULL) {

  version <- match.arg(version)

  schema_json <- if (is.character(schema)) schema else jsonlite::toJSON(schema, auto_unbox = TRUE)
  x <- list(
    schema     = schema_json,
    data       = data,
    readOnly   = readOnly,
    live       = live,
    locale     = locale,
    theme      = theme,       # <— NEU
    theme_vars = theme_vars,
    version    = version
  )

  htmlwidgets::createWidget(
    name = "surveyjs",
    x = x,
    width = width, height = height,
    package = "rsurveyjs", elementId = elementId,
    dependencies = list(dep_surveyjs_core(version))
  )
}

#' Shiny bindings for the SurveyJS widget
#'
#' @param outputId Output variable to read from.
#' @param width,height Size of the output container (CSS unit or number).
#' @name surveyjs-shiny
#' @export
surveyjsOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "surveyjs", width, height, package = "rsurveyjs")
}

#' @rdname surveyjs-shiny
#' @param expr An expression that generates a surveyjs widget.
#' @param env The environment in which to evaluate `expr`.
#' @param quoted Is `expr` a quoted expression? (With `quote()`.)
#' @export
renderSurveyjs <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) expr <- substitute(expr)
  htmlwidgets::shinyRenderWidget(expr, surveyjsOutput, env, quoted = TRUE)
}

