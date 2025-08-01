library(shiny)
library(rsurveyjs)

# -- Survey schema for Pizza Order --
pizza_schema <- list(
  title = "🍕 Pizza Order Service",
  description = "Tell us how you want your pizza!",
  showProgressBar = "top",
  progressBarType = "buttons",
  firstPageIsStarted = TRUE,
  startSurveyText = "Start Order",
  pages = list(
    list(
      name = "info",
      elements = list(
        list(type = "text", name = "name", title = "Your Name", isRequired = TRUE),
        list(type = "text", name = "phone", title = "Phone Number", inputType = "tel",
             placeHolder = "e.g. 555-1234", isRequired = TRUE,
             validators = list(list(type = "regex", regex = "^[0-9\\-\\+\\s]+$", text = "Only numbers, spaces and dashes allowed"))
        ),
        list(type = "dropdown", name = "delivery_type", title = "Delivery or Pickup?", isRequired = TRUE,
             choices = c("Delivery", "Pickup")),
        list(type = "text", name = "address", title = "Delivery Address",
             visibleIf = "{delivery_type} = 'Delivery'", isRequired = TRUE,
             placeHolder = "123 Pizza St.")
      )
    ),
    list(
      name = "pizza",
      elements = list(
        list(type = "dropdown", name = "size", title = "Pizza Size", isRequired = TRUE,
             choices = c("Small", "Medium", "Large", "XL")),
        list(type = "radiogroup", name = "crust", title = "Crust Type", isRequired = TRUE,
             choices = c("Thin", "Thick", "Stuffed")),
        list(
          type = "imagepicker",
          name = "pizza_type",
          title = "Choose your pizza",
          isRequired = TRUE,
          choices = list(
            list(value = "margherita", imageLink = "https://cdn-icons-png.flaticon.com/512/3132/3132693.png", text = "Margherita"),
            list(value = "pepperoni", imageLink = "https://cdn-icons-png.flaticon.com/512/1046/1046784.png", text = "Pepperoni"),
            list(value = "veggie", imageLink = "https://cdn-icons-png.flaticon.com/512/1046/1046846.png", text = "Veggie"),
            list(value = "hawaiian", imageLink = "https://cdn-icons-png.flaticon.com/512/2647/2647246.png", text = "Hawaiian")
          ),
          imageWidth = 80, imageHeight = 80, colCount = 4
        ),
        list(
          type = "checkbox",
          name = "toppings",
          title = "Extra Toppings (choose up to 4)",
          visibleIf = "{pizza_type} notempty",
          choices = c("Mushrooms", "Olives", "Onions", "Bacon", "Peppers", "Extra Cheese", "Spinach", "Pineapple"),
          maxSelectedChoices = 4
        ),
        list(
          type = "boolean",
          name = "gluten_free",
          title = "Gluten Free?",
          labelTrue = "Yes", labelFalse = "No"
        ),
        list(
          type = "text",
          name = "notes",
          title = "Special Instructions",
          placeHolder = "Allergic to garlic, cut into squares, etc.",
          inputType = "textarea"
        )
      )
    ),
    list(
      name = "confirmation",
      elements = list(
        list(
          type = "expression",
          name = "summary",
          title = "Your Order Summary",
          expression = "
            'Pizza: ' + {size} + ' ' + {pizza_type} + ' with ' + (if({toppings} notempty, join({toppings}, ', '), 'no extra toppings')) +
            '. Crust: ' + {crust} + '. ' +
            (if({gluten_free}, 'Gluten free. ', '')) +
            (if({notes} notempty, 'Note: ' + {notes}, '')) +
            '.'
          "
        ),
        list(type = "html", html = "<span style='color: #666;'>Click <b>Complete Order</b> to finish.</span>")
      )
    )
  ),
  completedHtml = "<h3>🎉 Thank you for your order! <br>We'll start making your pizza now.</h3>
                   <div style='font-size:18px;margin:1em 0;'><b>Estimated time:</b> 30 minutes</div>"
)

# -- Shiny UI/Server --

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background: #f8fafc; }
      .survey-container { max-width: 520px; margin: 2em auto; background: #fff; border-radius: 22px; box-shadow: 0 6px 32px #aaa3; padding: 36px 30px 16px 30px;}
      h2, h3 { text-align: center; }
    "))
  ),
  div(class = "survey-container",
      h2("Pizza Order Service"),
      surveyjsOutput("pizza_order"),
      br(),
      h4("🔎 Live Order Preview"),
      verbatimTextOutput("live_data", placeholder = TRUE)
  )
)

server <- function(input, output, session) {
  output$pizza_order <- renderSurveyjs({
    surveyjs(
      schema = pizza_schema,
      theme = "Modern",
      live = TRUE,
      theme_vars = list(
        "--sjs-primary-backcolor" = "#fc5c2f", # nice pizza orange
        "--sjs-questionpanel-backcolor" = "#fff8f0",
        "--sjs-border-default" = "#efefef"
      ),
      pre_render_hook = "survey.setValue('name', 'Luigi');"
    )
  })

  # Live order preview
  output$live_data <- renderPrint({
    input$pizza_order_data_live
  })
}

shinyApp(ui, server)
