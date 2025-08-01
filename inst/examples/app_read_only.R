library(shiny)
library(rsurveyjs)

schema <- list(
  elements = list(
    list(type = "text", name = "name", title = "What's your name?")
  )
)

ui <- fluidPage(
  actionButton("prefill", "Prefill Name"),
  actionButton("readonly", "Make Read-only"),
  surveyjsOutput("mysurvey")
)

server <- function(input, output, session) {
  output$mysurvey <- renderSurveyjs({
    surveyjs(schema = schema)
  })

  observeEvent(input$prefill, {
    updateSurveyjs(session, "mysurvey", data = list(name = "Alice"))
  })

  observeEvent(input$readonly, {
    updateSurveyjs(session, "mysurvey", read_only = TRUE)
  })
}

shinyApp(ui, server)
