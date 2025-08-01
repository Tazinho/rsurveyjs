flight_schema <- function(language = "en") {
  list(
    title = if(language=="en") "✈️ Flight Booking" else "✈️ Flugbuchung",
    description = if(language=="en")
      "Book your next trip in a few simple steps." else
        "Buchen Sie Ihre nächste Reise in wenigen Schritten.",
    locale = language,
    showProgressBar = "top",
    pages = list(
      list(
        name = "route",
        elements = list(
          list(type="text", name="from", title=if(language=="en") "From" else "Von", isRequired=TRUE, placeHolder="City or Airport"),
          list(type="text", name="to", title=if(language=="en") "To" else "Nach", isRequired=TRUE, placeHolder="City or Airport"),
          list(type="text", name="depart", title=if(language=="en") "Departure Date" else "Abflugdatum", inputType="date", isRequired=TRUE),
          list(type="text", name="return", title=if(language=="en") "Return Date (optional)" else "Rückflugdatum (optional)", inputType="date")
        )
      ),
      list(
        name = "passengers",
        elements = list(
          list(type="dropdown", name="adults", title=if(language=="en") "Adults" else "Erwachsene", choices=as.character(1:6), defaultValue="1"),
          list(type="dropdown", name="children", title=if(language=="en") "Children" else "Kinder", choices=as.character(0:4), defaultValue="0"),
          list(type="dropdown", name="class", title=if(language=="en") "Class" else "Klasse",
               choices=if(language=="en") c("Economy", "Premium Economy", "Business", "First") else c("Economy", "Premium Economy", "Business", "First"), isRequired=TRUE)
        )
      ),
      list(
        name = "addons",
        elements = list(
          list(type="checkbox", name="addons", title=if(language=="en") "Add-ons" else "Zusatzleistungen",
               choices=if(language=="en")
                 c("Checked Bag (+$40)", "Seat Selection (+$10)", "Extra Legroom (+$20)", "Priority Boarding (+$15)")
               else
                 c("Aufgabegepäck (+40€)", "Sitzplatzwahl (+10€)", "Mehr Beinfreiheit (+20€)", "Priority Boarding (+15€)")
          ),
          list(type="text", name="requests", title=if(language=="en") "Special Requests" else "Besondere Wünsche", inputType="textarea", placeHolder=if(language=="en") "e.g. Vegetarian meal" else "z.B. vegetarisches Essen")
        )
      ),
      list(
        name = "contact",
        elements = list(
          list(type="text", name="name", title=if(language=="en") "Your Name" else "Ihr Name", isRequired=TRUE),
          list(type="text", name="email", title=if(language=="en") "Email Address" else "E-Mail-Adresse", inputType="email", isRequired=TRUE),
          list(type="text", name="phone", title=if(language=="en") "Phone Number" else "Telefonnummer", inputType="tel")
        )
      ),
      list(
        name = "summary",
        elements = list(
          list(
            type="expression", name="summary",
            title=if(language=="en") "<h4>Booking Summary</h4>" else "<h4>Buchungsübersicht</h4>",
            expression=paste0(
              "'<b>Route:</b> ' + from + ' → ' + to + '<br>' + ",
              "'<b>Departure:</b> ' + depart + (return ? ', <b>Return:</b> ' + return : '') + '<br>' + ",
              "'<b>Adults:</b> ' + adults + ', <b>Children:</b> ' + children + '<br>' + ",
              "'<b>Class:</b> ' + class + '<br>' + ",
              " (addons ? '<b>Add-ons:</b> ' + join(addons, ', ') + '<br>' : '') + ",
              " (requests ? '<b>Requests:</b> ' + requests + '<br>' : '') + ",
              "'<b>Name:</b> ' + name + '<br>' + ",
              "'<b>Email:</b> ' + email"
            )
          ),
          list(
            type = "html",
            html = if(language=="en")
              "<span style='color:#666'>Review your booking and click <b>Complete</b> to finish.</span>"
            else
              "<span style='color:#666'>Überprüfen Sie Ihre Buchung und klicken Sie auf <b>Abschließen</b>.</span>"
          )
        )
      )
    ),
    completedHtml = if(language=="en")
      "<h3>Thank you for booking your flight!<br>We wish you a pleasant journey. ✈️</h3>
       <div style='color:#555'>A confirmation will be sent to your email address.</div>"
    else
      "<h3>Vielen Dank für Ihre Flugbuchung!<br>Wir wünschen Ihnen eine gute Reise. ✈️</h3>
       <div style='color:#555'>Eine Bestätigung wird an Ihre E-Mail-Adresse gesendet.</div>"
  )
}


library(shiny)
library(rsurveyjs)

ui <- fluidPage(
  tags$head(
    # Sky CSS background, some clouds and fade
    tags$style(HTML("
      body {
        background: linear-gradient(to bottom,#93c9ff 0%,#cce6ff 80%,#fff 100%);
        min-height:100vh;
      }
      .sky-bg {
        position: fixed;
        top:0; left:0; width:100vw; height:100vh;
        z-index:-1;
        overflow:hidden;
      }
      .cloud {
        position: absolute;
        background: #fff;
        border-radius: 50%;
        opacity: 0.60;
      }
      .cloud1 { width: 110px; height: 60px; top: 70px; left: 14vw;}
      .cloud2 { width: 70px; height: 35px; top: 160px; left: 60vw;}
      .cloud3 { width: 150px; height: 60px; top: 240px; left: 38vw; opacity:0.45;}
      .cloud4 { width: 80px; height: 40px; top: 330px; left: 70vw; opacity:0.3;}
      .form-container {
        max-width: 600px;
        margin: 60px auto 24px auto;
        background: #fff;
        border-radius: 18px;
        box-shadow: 0 6px 32px #85b8ff33;
        padding: 36px 28px 18px 28px;
      }
      h2 { text-align: center; color: #2177d2; margin-bottom:0.4em;}
      .sv_p_root { background: #f7fcff !important;}
      .sv-question__title { color: #2177d2 !important;}
      .sv-body__footer { text-align:center;}
    "))
  ),
  # Animated clouds (simple, can be extended with JS if wanted)
  div(class="sky-bg",
      div(class="cloud cloud1"),
      div(class="cloud cloud2"),
      div(class="cloud cloud3"),
      div(class="cloud cloud4")
  ),
  div(class="form-container",
      h2("✈️ Flight Booking"),
      selectInput("lang", "🌐 Language / Sprache", choices = c("English" = "en", "Deutsch" = "de"), width = "220px"),
      surveyjsOutput("flight_form"),
      br(), h4("📝 Live Preview"), verbatimTextOutput("flight_data", placeholder = TRUE)
  )
)

server <- function(input, output, session) {
  output$flight_form <- renderSurveyjs({
    surveyjs(
      schema = flight_schema(input$lang),
      theme = "Modern",
      live = TRUE,
      theme_vars = list(
        "--sjs-primary-backcolor" = "#2177d2",
        "--sjs-questionpanel-backcolor" = "#f7fcff"
      )
    )
  })
  output$flight_data <- renderPrint({
    input$flight_form_data_live
  })
}

shinyApp(ui, server)
