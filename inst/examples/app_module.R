library(shiny)
library(rsurveyjs)

mod_survey_ui <- function(id) {
  ns <- NS(id)
  tagList(
    surveyjsOutput(ns("survey")),
    verbatimTextOutput(ns("data"))
  )
}

mod_survey_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$survey <- renderSurveyjs({
      surveyjs(
        schema = list(elements = list(
          list(type = "text", name = "color", title = "Favorite color?")
        )),
        element_id = session$ns("survey")
      )
    })

    output$data <- renderPrint({
      input[[paste0("survey_data")]]
    })
  })
}

ui <- fluidPage(
  surveyjsOutput("color_survey"),
  verbatimTextOutput("survey_data")
)

server <- function(input, output, session) {
  output$color_survey <- renderSurveyjs({
    surveyjs(schema = schema)
  })
  output$survey_data <- renderPrint({
    input$color_survey_data
  })
}

shinyApp(ui, server)
