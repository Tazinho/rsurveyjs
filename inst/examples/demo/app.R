library(shiny)
library(rsurveyjs)

# Minimal survey schema (3 fields)
schema <- list(
  title = "SurveyJS demo",
  pages = list(
    list(elements = list(
      list(type="text",    name="title",   title="Idea title", isRequired=TRUE, maxLength=100),
      list(type="comment", name="problem", title="Problem statement", isRequired=TRUE, minLength=20),
      list(type="dropdown",name="bu",      title="Business unit", isRequired=TRUE,
           choices=c("Sales","Operations","HR","Finance","IT","Other"))
    ))
  )
)

ui <- fluidPage(
  titlePanel("rsurveyjs demo"),
  fluidRow(
    column(6,
           div(
             actionButton("lock", "Toggle read-only"),
             actionButton("prefill", "Prefill example"),
             style = "margin-bottom:10px"
           ),
           surveyjsOutput("survey", height = "380px")
    ),
    column(6,
           h4("Live (while typing)"),
           verbatimTextOutput("live"),
           h4("Final (after Complete)"),
           verbatimTextOutput("final"),
           textOutput("saved")
    )
  )
)

server <- function(input, output, session){

  # Render the survey (live=TRUE enables _data_live while typing)
  output$survey <- renderSurveyjs(
    surveyjs(schema, live = TRUE, theme = "defaultV2", locale = "en")
  )

  # Toggle read-only each click
  observeEvent(input$lock, {
    updateSurveyjs(session, "survey", readOnly = (input$lock %% 2) == 1)
  })

  # Prefill some answers
  observeEvent(input$prefill, {
    updateSurveyjs(session, "survey",
                   data = list(
                     title   = "Prefilled title",
                     problem = "Some starter problem statement...",
                     bu      = "IT"
                   ))
  })

  # Outputs
  output$live  <- renderPrint({ req(input$survey_data_live); input$survey_data_live })
  output$final <- renderPrint({ req(input$survey_data);      input$survey_data })

  # Tiny "saved" indicator when live data flows in
  saved <- reactiveVal("")
  observeEvent(input$survey_data_live, ignoreInit = TRUE, {
    saved(paste("Saved at", format(Sys.time(), "%H:%M:%S")))
  })
  output$saved <- renderText(saved())
}

shinyApp(ui, server)
