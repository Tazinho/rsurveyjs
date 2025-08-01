library(shiny)
library(rsurveyjs)

pizza_schema <- list(
  title = "🍕 Pizza Order Service",
  description = "Build your pizza cart and pay online.",
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
      name = "cart",
      elements = list(
        list(
          type = "paneldynamic",
          name = "pizzas",
          title = "Your Pizza Cart",
          renderMode = "tab",
          templateTitle = "Pizza #{panelIndex}",
          minPanelCount = 1,
          panelAddText = "Add another pizza",
          panelRemoveText = "Remove",
          panelCount = 1,
          maxPanelCount = 5,
          templateElements = list(
            list(type = "dropdown", name = "size", title = "Pizza Size", isRequired = TRUE,
                 choices = c("Small", "Medium", "Large", "XL")),
            list(type = "radiogroup", name = "crust", title = "Crust Type", isRequired = TRUE,
                 choices = c("Thin", "Thick", "Stuffed")),
            list(
              type = "imagepicker",
              name = "pizza_type",
              title = "Type",
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
              visibleIf = "{panel.pizza_type} notempty",
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
        )
      )
    ),
    list(
      name = "cart_summary",
      elements = list(
        list(
          type = "expression",
          name = "cart_summary",
          title = "Your Order Summary",
          expression = "join(map({pizzas}, function(p, i) {
             'Pizza ' + (i+1) + ': ' + p.size + ' ' + p.pizza_type + (p.toppings ? ' with ' + join(p.toppings, ', ') : '') + ', ' + p.crust + ' crust' + (p.gluten_free ? ' (gluten free)' : '') + (p.notes ? '. Note: ' + p.notes : '')
          }), '\\n')"
        ),
        list(type = "html", html = "<span style='color: #666;'>Click <b>Next</b> to continue to payment.</span>")
      )
    ),
    list(
      name = "payment",
      elements = list(
        list(
          type = "radiogroup",
          name = "payment_method",
          title = "Payment Method",
          isRequired = TRUE,
          choices = list(
            list(value = "stripe", text = "<img src='https://upload.wikimedia.org/wikipedia/commons/3/3c/Stripe_Logo%2C_revised_2016.svg' height=20 style='vertical-align:middle'> Stripe"),
            list(value = "paypal", text = "<img src='https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg' height=20 style='vertical-align:middle'> PayPal")
          ),
          colCount = 2
        ),
        list(
          type = "text",
          name = "card_number",
          title = "Card Number",
          inputType = "number",
          isRequired = TRUE,
          visibleIf = "{payment_method} = 'stripe'",
          placeHolder = "4242 4242 4242 4242",
          validators = list(list(type = "regex", regex = "^\\d{12,19}$", text = "Enter 12 to 19 digits"))
        ),
        list(
          type = "text",
          name = "paypal_email",
          title = "PayPal Email",
          inputType = "email",
          isRequired = TRUE,
          visibleIf = "{payment_method} = 'paypal'",
          placeHolder = "me@example.com",
          validators = list(list(type = "email"))
        ),
        list(type = "boolean", name = "terms", title = "I accept the terms and conditions", isRequired = TRUE)
      )
    ),
    list(
      name = "confirmation",
      elements = list(
        list(
          type = "html",
          html = "<b>Review your details and click <span style='color:#fc5c2f'>Complete Order</span> below to finish.</b>"
        )
      )
    )
  ),
  completedHtml = "<h3>🎉 Thank you for your order! <br>We'll start making your pizzas now.</h3>
                   <div style='font-size:18px;margin:1em 0;'><b>Estimated time:</b> 30 minutes</div>
                   <div style='color:#666;font-size:15px'>A payment confirmation will be sent to your email.</div>"
)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background: #f8fafc; }
      .survey-container { max-width: 540px; margin: 2em auto; background: #fff; border-radius: 22px; box-shadow: 0 6px 32px #aaa3; padding: 36px 30px 16px 30px;}
      h2, h3 { text-align: center; }
      .sv_progress-buttons__page-title { font-weight: bold; }
      .sv_p_root { background: #fff8f0 !important; }
    "))
  ),
  div(class = "survey-container",
      h2("Pizza Order Service"),
      surveyjsOutput("pizza_order"),
      br(),
      h4("🛒 Live Cart Data Preview"),
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
        "--sjs-primary-backcolor" = "#fc5c2f",
        "--sjs-questionpanel-backcolor" = "#fff8f0",
        "--sjs-border-default" = "#efefef"
      ),
      pre_render_hook = "survey.setValue('name', 'Luigi');"
    )
  })

  output$live_data <- renderPrint({
    input$pizza_order_data_live
  })
}

shinyApp(ui, server)
