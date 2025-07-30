#' SurveyJS widget for Shiny
#'
#' Render a [SurveyJS](https://surveyjs.io/) form from a JSON schema.
#'
#' This widget renders a fully customizable survey using SurveyJS v2 inside a Shiny app.
#' It supports themes, read-only mode, initial values, localization, and real-time updates.
#'
#' Final answers are delivered to `input[[paste0(id, "_data")]]` after the user
#' clicks **Complete**. If `live = TRUE`, updates are delivered to
#' `input[[paste0(id, "_data_live")]]` during input.
#'
#' @param schema List or JSON string; must follow the
#'   [SurveyJS JSON Schema](https://surveyjs.io/form-library/documentation/json-schema).
#' @param data Optional named list of initial values.
#' @param readOnly Logical; render in read-only mode.
#' @param live Logical; send live updates while typing? Default `FALSE`.
#' @param theme Theme, default "DefaultLight".
#' @param theme_vars Optional named list of CSS variables (e.g. `--sjs-primary-backcolor`).
#' @param locale Optional language code (e.g. `"en"`, `"de"`). See [SurveyJS localization docs](https://surveyjs.io/form-library/documentation/localization).
#' @param width,height Optional CSS size or number.
#' @param elementId Optional element id for the container.
#'
#' @seealso [surveyjs_themes()], [surveyjs_schema()]
#' @return A Shiny widget (htmlwidget).
#' @export
surveyjs <- function(schema, data = NULL, readOnly = FALSE, live = FALSE,
                     theme = "DefaultLight", theme_vars = NULL, locale = NULL,
                     width = NULL, height = NULL, elementId = NULL) {

  schema_json <- if (is.character(schema)) schema
  else jsonlite::toJSON(schema, auto_unbox = TRUE)

  x <- list(
    schema     = schema_json,
    data       = data,
    readOnly   = readOnly,
    live       = live,
    theme      = theme,
    theme_vars = theme_vars,
    locale     = locale
  )

  htmlwidgets::createWidget(
    name = "surveyjs",
    x = x,
    width = width,
    height = height,
    package = "rsurveyjs",
    elementId = elementId,
    dependencies = list(
      dep_react(),         # MUST BE FIRST
      dep_reactdom(),      # THEN ReactDOM
      dep_surveyjs_core()  # THEN SurveyJS
    )
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
