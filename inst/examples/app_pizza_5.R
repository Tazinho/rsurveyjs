library(shiny)
library(rsurveyjs)

feedback_schema <- function(language = "en") {
  list(
    title = if(language=="en") "🌟 Feedback Survey" else "🌟 Feedback Umfrage",
    description = if(language=="en") "Tell us how we did!" else "Wie fanden Sie unseren Service?",
    locale = language,
    pages = list(
      list(
        name = "feedback",
        elements = list(
          list(
            type = "rating", name = "satisfaction",
            title = if(language=="en") "How satisfied are you with our service?" else "Wie zufrieden sind Sie mit unserem Service?",
            minRateDescription = if(language=="en") "Very Dissatisfied" else "Sehr unzufrieden",
            maxRateDescription = if(language=="en") "Very Satisfied" else "Sehr zufrieden",
            rateMax = 5, isRequired = TRUE,
            rateType = "stars"
          ),
          list(
            type = "comment", name = "comment",
            title = if(language=="en") "Your comments:" else "Ihre Kommentare:"
          ),
          list(
            type = "boolean", name = "contact",
            title = if(language=="en") "Would you like to be contacted?" else "Möchten Sie kontaktiert werden?",
            labelTrue = if(language=="en") "Yes" else "Ja",
            labelFalse = if(language=="en") "No" else "Nein"
          ),
          list(
            type = "text", name = "email",
            title = if(language=="en") "Your email address:" else "Ihre E-Mail-Adresse:",
            inputType = "email", visibleIf = "{contact} = true"
          )
        )
      )
    ),
    completedHtml = if(language=="en")
      "<h3>Thank you for your feedback!<br>We appreciate your response.</h3>"
    else
      "<h3>Vielen Dank für Ihr Feedback!<br>Wir freuen uns über Ihre Rückmeldung.</h3>"
  )
}

ui <- fluidPage(
  tags$head(tags$style(HTML("body{background:#fafafa;} .survey-container{max-width:500px;margin:2em auto;background:#fff;border-radius:18px;box-shadow:0 6px 32px #aaa3;padding:36px 30px 16px 30px;}"))),
  div(class="survey-container",
      h2("🌟 Feedback Survey"),
      selectInput("lang", "🌐 Language:", choices=c("English"="en","Deutsch"="de"), width="220px"),
      surveyjsOutput("feedback"),
      br(), h4("📊 Preview"), verbatimTextOutput("data", placeholder=TRUE)
  )
)
server <- function(input, output, session) {
  output$feedback <- renderSurveyjs({
    surveyjs(schema = feedback_schema(input$lang), theme = "Modern", live = TRUE)
  })
  output$data <- renderPrint({ input$feedback_data_live })
}
shinyApp(ui, server)
