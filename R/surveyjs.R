#' SurveyJS widget for Shiny with support for JavaScript hooks
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
#' @param schema List or JSON string; must follow
#'   [SurveyJS JSON Schema](https://surveyjs.io/form-library/documentation/json-schema).
#' @param data Initial values.
#' @param read_only Render in read-only mode.
#' @param live Live update responses?
#' @param theme Theme name.
#' @param theme_vars Named list of CSS variables (e.g. `--sjs-primary-backcolor`).
#' @param locale Language code (e.g. `"en"`, `"de"`)
#' @param pre_render_hook JavaScript code (as a string) to run before rendering the survey.
#'   Supply only the body of a JavaScript function — do not wrap it in `function(...) {}`.
#' @param post_render_hook JavaScript code (as a string) to run after the survey is rendered.
#'   Also supply only the body of a JavaScript function — not a full `function(...) {}` wrapper.
#' @param complete_hook JavaScript function body to run on survey completion
#' @param width,height Optional CSS size or number.
#' @param element_id Optional element ID. Leave NULL in Shiny (it's auto-assigned).
#' @details
#' The SurveyJS widget is responsive by default. The `resize()` method is a placeholder
#' and does not implement manual resizing logic, as SurveyJS adapts to container size
#' via CSS flexbox rules.
#' @export
surveyjs <- function(schema, data = NULL, read_only = FALSE, live = FALSE,
                     theme = "DefaultLight", theme_vars = NULL, locale = NULL,
                     pre_render_hook = NULL, post_render_hook = NULL,
                     complete_hook = NULL, width = NULL, height = NULL,
                     element_id = NULL) {

  if (shiny::isRunning() && !is.null(element_id)) {
    warning("In Shiny, `element_id` is ignored. The widget ID is automatically set from the output ID in `surveyjsOutput(id)`.")
  }

  schema_json <- if (is.character(schema)) schema
  else jsonlite::toJSON(schema, auto_unbox = TRUE)

  x <- list(
    schema            = schema_json,
    data              = data,
    read_only         = read_only,
    live              = live,
    theme             = theme,
    theme_vars        = theme_vars,
    locale            = locale,
    pre_render_hook   = pre_render_hook,
    post_render_hook  = post_render_hook,
    complete_hook     = complete_hook,
    element_id        = element_id
  )

  htmlwidgets::createWidget(
    name = "surveyjs",
    x = x,
    width = width,
    height = height,
    elementId = element_id,
    package = "rsurveyjs",
    dependencies = list(
      dep_react(),
      dep_reactdom(),
      dep_surveyjs_core()
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
