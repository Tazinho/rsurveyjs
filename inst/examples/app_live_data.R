library(shiny)
library(rsurveyjs)

schema <- list(
  elements = list(
    list(type = "text", name = "feedback", title = "Leave your feedback")
  )
)


ui <- fluidPage(
  surveyjsOutput("mysurvey"),
  verbatimTextOutput("live")
)

server <- function(input, output, session) {
  output$mysurvey <- renderSurveyjs({
    surveyjs(schema = schema, live = TRUE, element_id = "mysurvey")
  })

  output$live <- renderPrint({
    input$mysurvey_data_live
  })
}

shinyApp(ui, server)
