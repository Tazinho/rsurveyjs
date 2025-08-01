library(shiny)
library(rsurveyjs)

hotel_schema <- function(language = "en") {
  list(
    title = if(language=="en") "🏨 Hotel Booking" else "🏨 Hotelbuchung",
    description = if(language=="en") "Book your stay with us!" else "Buchen Sie Ihren Aufenthalt bei uns!",
    locale = language,
    pages = list(
      list(
        name = "booking",
        elements = list(
          list(type = "dropdown", name = "room_type",
               title = if(language=="en") "Room type" else "Zimmerart",
               choices = if(language=="en") c("Single","Double","Suite") else c("Einzelzimmer","Doppelzimmer","Suite"),
               isRequired = TRUE),
          list(type = "text", name = "guest_name", title = if(language=="en") "Your name" else "Ihr Name", isRequired = TRUE),
          list(type = "text", name = "email", title = if(language=="en") "Email address" else "E-Mail-Adresse", inputType="email"),
          list(type = "text", name = "arrival", title = if(language=="en") "Arrival date" else "Anreisedatum", inputType = "date"),
          list(type = "text", name = "departure", title = if(language=="en") "Departure date" else "Abreisedatum", inputType = "date"),
          list(type = "checkbox", name = "services", title = if(language=="en") "Extras" else "Extras",
               choices = if(language=="en") c("Breakfast (+$10)", "Airport Shuttle (+$25)", "Late checkout (+$15)") else c("Frühstück (+10€)","Flughafenshuttle (+25€)","Später Checkout (+15€)"))
        )
      ),
      list(
        name = "summary",
        elements = list(
          list(
            type = "expression", name = "sum",
            title = if(language=="en") "<b>Order summary:</b>" else "<b>Buchungsübersicht:</b>",
            expression =
              "room_type + ', ' + join(services, ', ') + '<br>Name: ' + guest_name"
          )
        )
      )
    ),
    completedHtml = if(language=="en")
      "<h3>Your booking was received!<br>See you soon at our hotel.</h3>"
    else
      "<h3>Ihre Buchung wurde empfangen!<br>Wir freuen uns auf Ihren Besuch.</h3>"
  )
}

ui <- fluidPage(
  tags$head(tags$style(HTML("body{background:#fafafa;} .survey-container{max-width:500px;margin:2em auto;background:#fff;border-radius:18px;box-shadow:0 6px 32px #aaa3;padding:36px 30px 16px 30px;}"))),
  div(class="survey-container",
      h2("🏨 Hotel Booking"),
      selectInput("lang", "🌐 Language:", choices=c("English"="en","Deutsch"="de"), width="220px"),
      surveyjsOutput("hotel"),
      br(), h4("🔍 Preview"), verbatimTextOutput("data", placeholder=TRUE)
  )
)
server <- function(input, output, session) {
  output$hotel <- renderSurveyjs({
    surveyjs(schema = hotel_schema(input$lang), theme = "Modern", live = TRUE)
  })
  output$data <- renderPrint({ input$hotel_data_live })
}
shinyApp(ui, server)
