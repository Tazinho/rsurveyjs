library(shiny)
library(rsurveyjs)

languages <- list(
  en = list(
    title = "🍕 Pizza Order Service",
    description = "Build your pizza cart, add drinks/dessert, and pay online."
  ),
  de = list(
    title = "🍕 Pizza Bestellservice",
    description = "Stellen Sie Ihren Warenkorb zusammen, fügen Sie Getränke/Dessert hinzu und bezahlen Sie online."
  )
)

pizza_schema <- function(language = "en") {
  lang_txt <- languages[[language]]
  list(
    title = lang_txt$title,
    description = lang_txt$description,
    showProgressBar = "top",
    progressBarType = "buttons",
    firstPageIsStarted = TRUE,
    startSurveyText = if(language=="en") "Start Order" else "Bestellung starten",
    locale = language,
    calculatedValues = list(
      list(name = "size_price", expression = "({'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[size])"),
      list(name = "topping_price", expression = "0.9"),
      list(name = "gf_price", expression = "gluten_free ? 2 : 0")
    ),
    pages = list(
      # Customer info
      list(
        name = "info",
        elements = list(
          list(type = "text", name = "name", title = if(language=="en") "Your Name" else "Ihr Name", isRequired = TRUE),
          list(type = "text", name = "phone", title = if(language=="en") "Phone Number" else "Telefonnummer", inputType = "tel",
               placeHolder = if(language=="en") "e.g. 555-1234" else "z.B. 0176-12345678", isRequired = TRUE,
               validators = list(list(type = "regex", regex = "^[0-9\\-\\+\\s]+$", text = if(language=="en") "Only numbers, spaces and dashes allowed" else "Nur Zahlen, Leerzeichen und Bindestriche erlaubt"))
          ),
          list(type = "dropdown", name = "delivery_type", title = if(language=="en") "Delivery or Pickup?" else "Lieferung oder Abholung?", isRequired = TRUE,
               choices = if(language=="en") c("Delivery", "Pickup") else c("Lieferung", "Abholung")),
          list(type = "dropdown", name = "zone", title = if(language=="en") "Delivery Zone" else "Lieferzone",
               visibleIf = "{delivery_type} = 'Delivery' or {delivery_type} = 'Lieferung'", isRequired = TRUE,
               choices = if(language=="en") c("Downtown", "Suburbs", "Other") else c("Innenstadt", "Vororte", "Andere")),
          list(type = "text", name = "address", title = if(language=="en") "Delivery Address" else "Lieferadresse",
               visibleIf = "{delivery_type} = 'Delivery' or {delivery_type} = 'Lieferung'", isRequired = TRUE,
               placeHolder = if(language=="en") "123 Pizza St." else "Musterstraße 1")
        )
      ),
      # Coupon code
      list(
        name = "coupon",
        elements = list(
          list(type = "text", name = "coupon_code", title = if(language=="en") "Have a coupon code? Enter it here:" else "Haben Sie einen Gutscheincode? Hier eingeben:"),
          list(
            type = "expression",
            name = "coupon_message",
            title = "",
            visibleIf = "{coupon_code} = 'PIZZA10' or {coupon_code} = 'DEAL10'",
            expression = if(language=="en") "'🎁 Coupon applied! 10% off!'" else "'🎁 Gutschein angewendet! 10% Rabatt!'"
          )
        )
      ),
      # Pizza cart (dynamic panels)
      list(
        name = "cart",
        elements = list(
          list(
            type = "paneldynamic",
            name = "pizzas",
            title = if(language=="en") "Your Pizza Cart" else "Ihr Pizza-Warenkorb",
            renderMode = "tab",
            templateTitle = if(language=="en") "Pizza #{panelIndex}" else "Pizza #{panelIndex}",
            minPanelCount = 1,
            panelAddText = if(language=="en") "Add another pizza" else "Weitere Pizza hinzufügen",
            panelRemoveText = if(language=="en") "Remove" else "Entfernen",
            panelCount = 1,
            maxPanelCount = 5,
            templateElements = list(
              list(type = "dropdown", name = "size", title = if(language=="en") "Pizza Size" else "Pizzagröße", isRequired = TRUE,
                   choices = if(language=="en") c("Small", "Medium", "Large", "XL") else c("Klein", "Mittel", "Groß", "XL")),
              list(type = "radiogroup", name = "crust", title = if(language=="en") "Crust Type" else "Teigart", isRequired = TRUE,
                   choices = if(language=="en") c("Thin", "Thick", "Stuffed") else c("Dünn", "Dick", "Gefüllt")),
              list(
                type = "imagepicker",
                name = "pizza_type",
                title = if(language=="en") "Type" else "Art",
                isRequired = TRUE,
                choices = list(
                  list(value = "margherita", imageLink = "https://cdn-icons-png.flaticon.com/512/3132/3132693.png", text = if(language=="en") "Margherita" else "Margherita"),
                  list(value = "pepperoni", imageLink = "https://cdn-icons-png.flaticon.com/512/1046/1046784.png", text = if(language=="en") "Pepperoni" else "Pepperoni"),
                  list(value = "veggie", imageLink = "https://cdn-icons-png.flaticon.com/512/1046/1046846.png", text = if(language=="en") "Veggie" else "Vegetarisch"),
                  list(value = "hawaiian", imageLink = "https://cdn-icons-png.flaticon.com/512/2647/2647246.png", text = if(language=="en") "Hawaiian" else "Hawaii")
                ),
                imageWidth = 80, imageHeight = 80, colCount = 4
              ),
              list(
                type = "checkbox",
                name = "toppings",
                title = if(language=="en") "Extra Toppings (up to 4, $0.90 each)" else "Extra Beläge (bis zu 4, je 0,90€)",
                visibleIf = "{panel.pizza_type} notempty",
                choices = if(language=="en")
                  c("Mushrooms", "Olives", "Onions", "Bacon", "Peppers", "Extra Cheese", "Spinach", "Pineapple")
                else
                  c("Champignons", "Oliven", "Zwiebeln", "Speck", "Paprika", "Extra Käse", "Spinat", "Ananas"),
                maxSelectedChoices = 4
              ),
              list(
                type = "boolean",
                name = "gluten_free",
                title = if(language=="en") "Gluten Free? (+$2)" else "Glutenfrei? (+2€)",
                labelTrue = if(language=="en") "Yes" else "Ja",
                labelFalse = if(language=="en") "No" else "Nein"
              ),
              list(
                type = "text",
                name = "notes",
                title = if(language=="en") "Special Instructions" else "Besondere Hinweise",
                placeHolder = if(language=="en") "No onions, cut in squares, etc." else "Keine Zwiebeln, geschnitten etc.",
                inputType = "textarea"
              ),
              list(
                type = "expression",
                name = "pizza_price",
                title = if(language=="en") "<b>Price for this pizza:</b>" else "<b>Preis für diese Pizza:</b>",
                displayStyle = "currency",
                currency = if(language=="en") "USD" else "EUR",
                expression =
                  "({'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[size])
                  + (toppings ? count(toppings) * 0.9 : 0)
                  + (gluten_free ? 2 : 0)"
              )
            )
          ),
          # Drinks and desserts
          list(
            type = "matrixdropdown",
            name = "extras",
            title = if(language=="en") "Drinks & Desserts" else "Getränke & Desserts",
            columns = list(
              list(name = "qty", title = if(language=="en") "Qty" else "Menge", cellType = "dropdown",
                   choices = as.list(0:6), defaultValue = 0)
            ),
            rows = if(language=="en")
              list(
                list(value = "coke", text = "Coke ($2)"),
                list(value = "sprite", text = "Sprite ($2)"),
                list(value = "water", text = "Mineral Water ($1.5)"),
                list(value = "tiramisu", text = "Tiramisu ($4)"),
                list(value = "icecream", text = "Ice Cream ($3)")
              )
            else
              list(
                list(value = "coke", text = "Cola (2€)"),
                list(value = "sprite", text = "Sprite (2€)"),
                list(value = "water", text = "Mineralwasser (1,50€)"),
                list(value = "tiramisu", text = "Tiramisu (4€)"),
                list(value = "icecream", text = "Eis (3€)")
              ),
            cellType = "dropdown",
            horizontalScroll = FALSE
          )
        )
      ),
      # Cart Summary with Total
      list(
        name = "cart_summary",
        elements = list(
          list(
            type = "expression",
            name = "cart_summary",
            title = if(language=="en") "<h4>Your Order:</h4>" else "<h4>Ihre Bestellung:</h4>",
            expression =
              "join(map({pizzas}, function(p, i) {
                 '🍕 <b>Pizza ' + (i+1) + ':</b> ' + p.size + ' ' + p.pizza_type +
                 (p.toppings ? ' with ' + join(p.toppings, ', ') : '') +
                 ', ' + p.crust + ' crust' +
                 (p.gluten_free ? ' (gluten free)' : '') +
                 (p.notes ? '. Note: ' + p.notes : '') +
                 '<br><b>Pizza Price: $' + (({'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[p.size])
                     + (p.toppings ? count(p.toppings) * 0.9 : 0)
                     + (p.gluten_free ? 2 : 0)).toFixed(2) + '</b>'
              }), '<hr style=\"margin:5px 0\">')"
          ),
          list(
            type = "expression",
            name = "extras_summary",
            title = if(language=="en") "Drinks & Desserts" else "Getränke & Desserts",
            expression = "join(filter(map(['coke','sprite','water','tiramisu','icecream'], function(key) {
              var n = extras[key] && extras[key].qty ? extras[key].qty : 0;
              var label = ({coke:'Coke',sprite:'Sprite',water:'Mineral Water',tiramisu:'Tiramisu',icecream:'Ice Cream'})[key];
              var price = ({coke:2,sprite:2,water:1.5,tiramisu:4,icecream:3})[key];
              return n > 0 ? n + ' x ' + label + ' ($' + price + ' each)' : '';
            }), function(x) { return x.length > 0; }), ', ')",
            visibleIf = "{extras} notempty"
          ),
          list(
            type = "expression",
            name = "cart_total",
            title = if(language=="en") "<span style='font-size:18px;'><b>Total Pizza(s):</b></span>" else "<span style='font-size:18px;'><b>Pizza-Gesamtbetrag:</b></span>",
            displayStyle = "currency",
            currency = if(language=="en") "USD" else "EUR",
            expression =
              "sum(map({pizzas}, function(p) {
                 ( {'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[p.size] || 0 )
                 + (p.toppings ? count(p.toppings) * 0.9 : 0)
                 + (p.gluten_free ? 2 : 0)
               }))"
          ),
          list(
            type = "expression",
            name = "extras_total",
            title = if(language=="en") "<span style='font-size:18px;'><b>Drinks & Desserts:</b></span>" else "<span style='font-size:18px;'><b>Getränke & Desserts:</b></span>",
            displayStyle = "currency",
            currency = if(language=="en") "USD" else "EUR",
            expression =
              "sum(map(['coke','sprite','water','tiramisu','icecream'], function(key) {
                var n = extras[key] && extras[key].qty ? extras[key].qty : 0;
                var price = ({coke:2,sprite:2,water:1.5,tiramisu:4,icecream:3})[key];
                return n * price;
              }))"
          ),
          list(
            type = "expression",
            name = "delivery_fee",
            title = if(language=="en") "Delivery Fee" else "Liefergebühr",
            displayStyle = "currency",
            currency = if(language=="en") "USD" else "EUR",
            visibleIf = "{delivery_type} = 'Delivery' or {delivery_type} = 'Lieferung'",
            expression =
              "({Downtown:4,Suburbs:7,Other:10,Innenstadt:4,Vororte:7,Andere:10}[zone])"
          ),
          list(
            type = "expression",
            name = "coupon_discount",
            title = if(language=="en") "Coupon Discount" else "Gutscheinrabatt",
            displayStyle = "currency",
            currency = if(language=="en") "USD" else "EUR",
            visibleIf = "{coupon_code} = 'PIZZA10' or {coupon_code} = 'DEAL10'",
            expression = "(
              sum(map({pizzas}, function(p) {
                ( {'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[p.size] || 0 )
                + (p.toppings ? count(p.toppings) * 0.9 : 0)
                + (p.gluten_free ? 2 : 0)
              })) +
              sum(map(['coke','sprite','water','tiramisu','icecream'], function(key) {
                var n = extras[key] && extras[key].qty ? extras[key].qty : 0;
                var price = ({coke:2,sprite:2,water:1.5,tiramisu:4,icecream:3})[key];
                return n * price;
              })) +
              ({Downtown:4,Suburbs:7,Other:10,Innenstadt:4,Vororte:7,Andere:10}[zone] || 0)
            ) * 0.10"
          ),
          list(
            type = "expression",
            name = "grand_total",
            title = if(language=="en") "<span style='font-size:20px;color:#fc5c2f'><b>Order Total:</b></span>" else "<span style='font-size:20px;color:#fc5c2f'><b>Gesamtsumme:</b></span>",
            displayStyle = "currency",
            currency = if(language=="en") "USD" else "EUR",
            expression =
              "(
                sum(map({pizzas}, function(p) {
                   ( {'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[p.size] || 0 )
                   + (p.toppings ? count(p.toppings) * 0.9 : 0)
                   + (p.gluten_free ? 2 : 0)
                 }))
                + sum(map(['coke','sprite','water','tiramisu','icecream'], function(key) {
                  var n = extras[key] && extras[key].qty ? extras[key].qty : 0;
                  var price = ({coke:2,sprite:2,water:1.5,tiramisu:4,icecream:3})[key];
                  return n * price;
                }))
                + (({Downtown:4,Suburbs:7,Other:10,Innenstadt:4,Vororte:7,Andere:10}[zone]) || 0)
              )
              - ( ( {coupon_code} = 'PIZZA10' or {coupon_code} = 'DEAL10' ) ?
                   (
                    sum(map({pizzas}, function(p) {
                      ( {'Small':8,'Medium':11,'Large':14,'XL':17,'Klein':8,'Mittel':11,'Groß':14,'XL':17}[p.size] || 0 )
                      + (p.toppings ? count(p.toppings) * 0.9 : 0)
                      + (p.gluten_free ? 2 : 0)
                    }))
                    + sum(map(['coke','sprite','water','tiramisu','icecream'], function(key) {
                      var n = extras[key] && extras[key].qty ? extras[key].qty : 0;
                      var price = ({coke:2,sprite:2,water:1.5,tiramisu:4,icecream:3})[key];
                      return n * price;
                    }))
                    + (({Downtown:4,Suburbs:7,Other:10,Innenstadt:4,Vororte:7,Andere:10}[zone]) || 0)
                   ) * 0.10 : 0 )"
          ),
          list(
            type = "expression",
            name = "delivery_time",
            title = if(language=="en") "<b>Estimated Delivery Time</b>" else "<b>Voraussichtliche Lieferzeit</b>",
            expression =
              "({Downtown:'30 min',Suburbs:'40 min',Other:'55 min',Innenstadt:'30 min',Vororte:'40 min',Andere:'55 min'}[zone])",
            visibleIf = "{delivery_type} = 'Delivery' or {delivery_type} = 'Lieferung'"
          ),
          list(
            type = "html",
            html = "<button id='download-pdf' style='margin-top:15px;font-size:1.1em;padding:6px 22px;border-radius:8px;background:#fc5c2f;color:#fff;border:none;cursor:pointer;'>📄 Download Order as PDF</button>
                    <span id='pdf-note' style='margin-left:12px;color:#888'></span>
                    <script>
                      document.addEventListener('DOMContentLoaded', function() {
                        var btn = document.getElementById('download-pdf');
                        if(btn) btn.onclick = function() {
                          document.getElementById('pdf-note').innerText = ' (PDF download simulated)';
                        }
                      });
                    </script>"
          ),
          list(type = "html", html = if(language=="en") "<span style='color: #666;'>Click <b>Next</b> to continue to payment.</span>" else "<span style='color: #666;'>Klicken Sie auf <b>Weiter</b>, um zur Zahlung zu gelangen.</span>")
        )
      ),
      # Payment mockup
      list(
        name = "payment",
        elements = list(
          list(
            type = "radiogroup",
            name = "payment_method",
            title = if(language=="en") "Payment Method" else "Zahlungsmethode",
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
            title = if(language=="en") "Card Number" else "Kartennummer",
            inputType = "number",
            isRequired = TRUE,
            visibleIf = "{payment_method} = 'stripe'",
            placeHolder = "4242 4242 4242 4242",
            validators = list(list(type = "regex", regex = "^\\d{12,19}$", text = if(language=="en") "Enter 12 to 19 digits" else "12 bis 19 Ziffern eingeben"))
          ),
          list(
            type = "text",
            name = "paypal_email",
            title = if(language=="en") "PayPal Email" else "PayPal-E-Mail",
            inputType = "email",
            isRequired = TRUE,
            visibleIf = "{payment_method} = 'paypal'",
            placeHolder = "me@example.com",
            validators = list(list(type = "email"))
          ),
          list(type = "boolean", name = "terms", title = if(language=="en") "I accept the terms and conditions" else "Ich akzeptiere die AGB", isRequired = TRUE)
        )
      ),
      # Final confirm
      list(
        name = "confirmation",
        elements = list(
          list(
            type = "html",
            html = if(language=="en")
              "<b>Review your details and click <span style='color:#fc5c2f'>Complete Order</span> below to finish.</b>
               <div style='color:#888'>If this were real, your card or PayPal would be charged <span style='color:#fc5c2f;font-weight:bold;'>the order total above</span>.</div>"
            else
              "<b>Überprüfen Sie Ihre Angaben und klicken Sie unten auf <span style='color:#fc5c2f'>Bestellung abschließen</span>.</b>
               <div style='color:#888'>Wenn dies echt wäre, würde Ihre Karte oder Ihr PayPal mit dem obigen Gesamtbetrag belastet.</div>"
          )
        )
      )
    ),
    completedHtml = if(language=="en")
      "<h3>🎉 Thank you for your order! <br>We'll start making your pizzas now.</h3>
      <div style='font-size:18px;margin:1em 0;'><b>Estimated time:</b> See your delivery time above.</div>
      <div style='color:#666;font-size:15px'>A payment confirmation will be sent to your email.</div>"
    else
      "<h3>🎉 Vielen Dank für Ihre Bestellung! <br>Wir machen uns sofort an die Arbeit.</h3>
      <div style='font-size:18px;margin:1em 0;'><b>Lieferzeit:</b> Siehe oben.</div>
      <div style='color:#666;font-size:15px'>Eine Zahlungsbestätigung wird an Ihre E-Mail gesendet.</div>"
  )
}

# (pizza_schema wie oben...)
ui <- fluidPage(
  tags$head(tags$style(HTML("body{background:#fafafa;} .survey-container{max-width:600px;margin:2em auto;background:#fff;border-radius:18px;box-shadow:0 6px 32px #aaa3;padding:36px 30px 16px 30px;}"))),
  div(class="survey-container",
      h2("🍕 Pizza Order Demo"),
      selectInput("lang", "🌐 Language:", choices=c("English"="en","Deutsch"="de"), width="220px"),
      surveyjsOutput("pizza_order"),
      br(), h4("🛒 Preview"), verbatimTextOutput("live_data", placeholder=TRUE)
  )
)
server <- function(input, output, session) {
  output$pizza_order <- renderSurveyjs({
    surveyjs(
      schema = pizza_schema(input$lang),
      theme = "Modern",
      live = TRUE,
      theme_vars = list("--sjs-primary-backcolor" = "#fc5c2f", "--sjs-questionpanel-backcolor" = "#fff8f0")
    )
  })
  output$live_data <- renderPrint({ input$pizza_order_data_live })
}
shinyApp(ui, server)
