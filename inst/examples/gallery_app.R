library(shiny)
library(rsurveyjs)

# --------- Demo-App-Schemas ---------
pizza_schema <- function(language = "en") {
  # (Nur eine vereinfachte Version, für vollständiges Demo oben nachsehen)
  list(
    title = "🍕 Pizza Order",
    pages = list(
      list(elements = list(
        list(type="text",name="name",title="Your Name",isRequired=TRUE),
        list(type="dropdown",name="size",title="Size",choices=c("Small","Medium","Large"),isRequired=TRUE),
        list(type="checkbox",name="toppings",title="Toppings",choices=c("Cheese","Olives","Mushrooms")),
        list(type="expression",name="price",title="Total price",expression="({'Small':8,'Medium':11,'Large':14}[size] + (toppings ? count(toppings)*1 : 0))",displayStyle="currency",currency="USD")
      ))
    ),
    completedHtml = "<h3>Thank you for your Pizza order!<br>Enjoy!</h3>"
  )
}

feedback_schema <- function(language = "en") {
  list(
    title = "🌟 Feedback Survey",
    pages = list(
      list(elements = list(
        list(type="rating",name="stars",title="How did you like it?",rateMax=5,rateType="stars",isRequired=TRUE),
        list(type="comment",name="comment",title="Your comments")
      ))
    ),
    completedHtml = "<h3>Thanks for your feedback!</h3>"
  )
}

hotel_schema <- function(language = "en") {
  list(
    title = "🏨 Hotel Booking",
    pages = list(
      list(elements = list(
        list(type="dropdown",name="room",title="Room type",choices=c("Single","Double","Suite"),isRequired=TRUE),
        list(type="text",name="name",title="Your name",isRequired=TRUE),
        list(type="text",name="date",title="Arrival date",inputType="date")
      ))
    ),
    completedHtml = "<h3>Your booking was received!</h3>"
  )
}

# --------- Main UI -----------
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background: #f8fafc; }
    .gallery-header { text-align: center; margin: 2em 0 1.2em 0; }
    .gallery-row { display: flex; justify-content: center; flex-wrap: wrap; gap: 38px; }
    .gallery-card {
      background: #fff; border-radius: 18px; box-shadow: 0 6px 32px #aaa3; width: 320px; padding: 26px 24px 20px 24px;
      display: flex; flex-direction: column; align-items: center; transition: box-shadow .18s;
      border: 1.5px solid #eee; margin-bottom: 24px;
    }
    .gallery-card:hover { box-shadow: 0 8px 36px #ff90224a; border-color: #fc5c2f;}
    .gallery-img { width: 94px; height: 94px; object-fit: contain; margin-bottom: 10px; }
    .gallery-title { font-size: 1.36em; font-weight: 600; color: #fc5c2f; margin-bottom: 8px; }
    .gallery-desc { color: #666; font-size: 1.05em; min-height: 54px; margin-bottom: 1em; text-align: center;}
    .gallery-btn {
      font-size: 1.07em; padding: 9px 22px; border-radius: 8px;
      background: linear-gradient(90deg, #fc5c2f 75%, #fff1e1 100%);
      border: none; color: #fff; font-weight: 500; letter-spacing: .04em;
      box-shadow: 0 2px 12px #fc5c2f33; transition: background .16s;
      margin-top: 6px;
    }
    .gallery-btn:hover { background: linear-gradient(90deg, #ff8133 60%, #fff1e1 100%);}
    @media (max-width: 1100px) { .gallery-row { gap: 16px;} .gallery-card{width:98vw;max-width:400px;} }
    .back-btn {
      display:inline-block; margin: 1em 0 1em 0; font-size: 1.04em;
      background: #eee; color: #fc5c2f; border: none; padding: 6px 18px; border-radius: 7px;
      transition: background .16s;
    }
    .back-btn:hover { background: #fc5c2f; color: #fff;}
    .survey-wrap { max-width: 600px; margin: 2em auto; background: #fff; border-radius:18px; box-shadow: 0 6px 32px #aaa3; padding: 28px 26px 18px 26px;}
  "))),

  uiOutput("pageUI")
)

# ---------- Main SERVER -------------
server <- function(input, output, session) {
  page <- reactiveVal("landing")

  output$pageUI <- renderUI({
    switch(page(),
           "landing" = {
             div(
               class="gallery-header",
               tags$h1("🚀 Demo App Gallery"),
               tags$p(style="font-size:1.13em;color:#333;margin-bottom:0.9em","Klicke eine App, um sie auszuprobieren!")
             )
             div(
               class="gallery-row",
               div(class="gallery-card",
                   img(src="https://cdn-icons-png.flaticon.com/512/3132/3132693.png", class="gallery-img"),
                   div(class="gallery-title", "🍕 Pizza Order"),
                   div(class="gallery-desc", "Stelle dir eine Pizza zusammen, bestelle, und sehe den Preis."),
                   actionButton("to_pizza", "Jetzt ausprobieren", class="gallery-btn")
               ),
               div(class="gallery-card",
                   img(src="https://cdn-icons-png.flaticon.com/512/2583/2583313.png", class="gallery-img"),
                   div(class="gallery-title", "🌟 Feedback Survey"),
                   div(class="gallery-desc", "Bewerte den Service und hinterlasse Feedback."),
                   actionButton("to_feedback", "Jetzt ausprobieren", class="gallery-btn")
               ),
               div(class="gallery-card",
                   img(src="https://cdn-icons-png.flaticon.com/512/1865/1865269.png", class="gallery-img"),
                   div(class="gallery-title", "🏨 Hotel Booking"),
                   div(class="gallery-desc", "Buche ein Hotelzimmer mit Extras."),
                   actionButton("to_hotel", "Jetzt ausprobieren", class="gallery-btn")
               )
             )
           },
           "pizza" = {
             div(class="survey-wrap",
                 actionButton("back", "← Zurück zur Gallery", class="back-btn"),
                 surveyjsOutput("pizza_app"),
                 br(), h4("🛒 Data"), verbatimTextOutput("pizza_data", placeholder=TRUE)
             )
           },
           "feedback" = {
             div(class="survey-wrap",
                 actionButton("back", "← Zurück zur Gallery", class="back-btn"),
                 surveyjsOutput("feedback_app"),
                 br(), h4("📊 Data"), verbatimTextOutput("feedback_data", placeholder=TRUE)
             )
           },
           "hotel" = {
             div(class="survey-wrap",
                 actionButton("back", "← Zurück zur Gallery", class="back-btn"),
                 surveyjsOutput("hotel_app"),
                 br(), h4("🔍 Data"), verbatimTextOutput("hotel_data", placeholder=TRUE)
             )
           }
    )
  })

  observeEvent(input$to_pizza,   { page("pizza") })
  observeEvent(input$to_feedback,{ page("feedback") })
  observeEvent(input$to_hotel,   { page("hotel") })
  observeEvent(input$back,       { page("landing") })

  # Render Sub-Apps
  output$pizza_app <- renderSurveyjs({ surveyjs(schema = pizza_schema(), live = TRUE, theme = "Modern") })
  output$feedback_app <- renderSurveyjs({ surveyjs(schema = feedback_schema(), live = TRUE, theme = "Modern") })
  output$hotel_app <- renderSurveyjs({ surveyjs(schema = hotel_schema(), live = TRUE, theme = "Modern") })

  output$pizza_data    <- renderPrint({ input$pizza_app_data_live })
  output$feedback_data <- renderPrint({ input$feedback_app_data_live })
  output$hotel_data    <- renderPrint({ input$hotel_app_data_live })
}

shinyApp(ui, server)
