library(shiny)
library(rsurveyjs)

mod_survey_ui <- function(id) {
  ns <- NS(id)
  tagList(
    surveyjsOutput(ns("survey")),
    verbatimTextOutput(ns("data"))
  )
}

mod_survey_server <- function(id, schema) {
  moduleServer(id, function(input, output, session) {
    output$survey <- renderSurveyjs({
      surveyjs(
        schema = schema,
        # element_id not strictly necessary in shiny, so can omit
        live = TRUE  # Optionally: show live updates!
      )
    })
    output$data <- renderPrint({
      input[[paste0("survey_data")]]
    })
  })
}

# Example: Two totally different surveys using same module
color_schema <- list(
  elements = list(
    list(type = "text", name = "color", title = "Favorite color?")
  )
)

pet_schema <- list(
  elements = list(
    list(type = "radiogroup", name = "pet", title = "Best pet?", choices = c("Dog", "Cat", "Fish"))
  )
)

ui <- fluidPage(
  h3("Survey 1: Color"),
  mod_survey_ui("color_mod"),
  h3("Survey 2: Pets"),
  mod_survey_ui("pet_mod")
)

server <- function(input, output, session) {
  mod_survey_server("color_mod", color_schema)
  mod_survey_server("pet_mod", pet_schema)
}

shinyApp(ui, server)


library(shiny)
library(rsurveyjs)

mod_survey_ui <- function(id) {
  ns <- NS(id)
  tagList(
    surveyjsOutput(ns("survey")),
    verbatimTextOutput(ns("data"))
  )
}

mod_survey_server <- function(id, schema, theme = "Modern", pre_render_hook = NULL) {
  moduleServer(id, function(input, output, session) {
    output$survey <- renderSurveyjs({
      surveyjs(
        schema = schema,
        theme = theme,
        pre_render_hook = pre_render_hook
      )
    })
    output$data <- renderPrint({
      input[[paste0("survey_data")]]
    })
  })
}

fancy_schema <- list(
  elements = list(
    list(type = "text", name = "icecream", title = "Favorite ice cream flavor?")
  )
)

ui <- fluidPage(
  h3("Themed Survey with Pre-render JS Hook"),
  mod_survey_ui("fancy_mod")
)

server <- function(input, output, session) {
  mod_survey_server(
    "fancy_mod",
    schema = fancy_schema,
    theme = "Modern",
    pre_render_hook = "survey.setValue('icecream', 'Chocolate');"
  )
}

shinyApp(ui, server)


mod_survey_server <- function(id, schema) {
  moduleServer(id, function(input, output, session) {
    output$survey <- renderSurveyjs({
      surveyjs(
        schema = schema,
        live = TRUE
      )
    })
    output$data <- renderPrint({
      input[[paste0("survey_data_live")]]
    })
  })
}
