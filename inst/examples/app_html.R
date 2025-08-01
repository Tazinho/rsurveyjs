library(shiny)
library(rsurveyjs)

schema <- list(
  completedHtml = "<h2>Thank you for your response!</h2>",
  elements = list(
    list(type = "text", name = "name", title = "Your name?")
  )
)

ui <- fluidPage(
  surveyjsOutput("mysurvey"),
  verbatimTextOutput("completed")
)

server <- function(input, output, session) {
  output$mysurvey <- renderSurveyjs({
    surveyjs(schema = schema)
  })

  observeEvent(input$mysurvey_data, {
    showNotification("Survey completed!", type = "message")
  })

  output$completed <- renderPrint({
    input$mysurvey_data
  })
}


shinyApp(ui, server)

