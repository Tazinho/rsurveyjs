library(shiny)
library(rsurveyjs)
library(tibble)
library(stringi)

# ----- Define Survey Catalog -----
survey_catalog <- tribble(
  ~key, ~title, ~schema_fn, ~n_questions, ~features, ~emoji,
  "pizza",      "Pizza Order",      "pizza_schema",        6,   c("Image Picker","Dynamic Price","Expression"), "1f355",
  "feedback",   "Feedback Survey",  "feedback_schema",     4,   c("Smileys","Rating","HTML"), "1f31f",
  "hotel",      "Hotel Booking",    "hotel_schema",        7,   c("Conditional Logic","Dynamic Price"), "1f3e8",
  "flight",     "Flight Booking",   "flight_schema",      11,   c("Multi-Language","Summary Page","Conditional Logic"), "2708",
  "tshirt",     "T-Shirt Shop",     "tshirt_schema",       8,   c("Image Picker","Dynamic Price"), "1f455",
  "conference", "Conference Registration", "conference_schema", 10, c("Checkbox","Multi-Day","Conditional Logic"), "1f3a4",
  "car",        "Car Reservation",  "car_schema",          8,   c("Conditional Logic","Fun Fact","Extras"), "1f697",
  "pet",        "Pet Adoption",     "pet_schema",          8,   c("Picture Choice","Conditional Logic","Match Score"), "1f436",
  "job",        "Job Application",  "job_schema",         12,   c("Conditional Logic","File Upload","Multi-Step"), "1f4c4",
  "icecream",   "Ice Cream Builder","icecream_schema",     7,   c("Image Picker","Dynamic Price","Random"), "1f366",
  "quiz",       "Language Quiz",    "quiz_schema",         6,   c("Quiz Mode","Score","Timer"), "1f4dd",
  "rsvp",       "Event RSVP",       "rsvp_schema",         7,   c("Conditional Logic","Guest List","Emoji"), "1f389"
)

survey_features <- sort(unique(unlist(survey_catalog$features)))

# ---- App themes/backgrounds (as before) ----
app_bg <- function(app) {
  switch(app,
         "pizza" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(115deg,#ffdbb4 0%,#fff2dc 40%,#fff 100%), url('https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "feedback" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(90deg,#e1f6fc 0%,#fff 90%), url('https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80') right bottom/400px no-repeat;"
         ),
         "hotel" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(120deg,#d2f7ef 0%,#f5f6fa 60%,#fff 100%), url('https://images.unsplash.com/photo-1501117716987-c8e1ecb21019?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "flight" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(180deg,#a0d8fa 0%,#f2faff 100%), url('https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?auto=format&fit=crop&w=1200&q=80') center top/cover no-repeat;"
         ),
         "tshirt" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(105deg,#e9e4f0 0%,#d3cce3 80%), url('https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "conference" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(100deg,#ffd6e0 0%,#f3f9fb 80%), url('https://images.unsplash.com/photo-1515169273894-6a47b89d0b8b?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "car" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(115deg,#f5f7fa 0%,#c3cfe2 100%), url('https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "pet" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(120deg,#ffe4b2 0%,#fffbe7 80%), url('https://images.unsplash.com/photo-1518717758536-85ae29035b6d?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "job" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(130deg,#f1fff1 0%,#c6efd2 80%), url('https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "icecream" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(105deg,#ffe5fa 0%,#fff4e6 80%), url('https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "quiz" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(110deg,#e4e9fd 0%,#fff 80%), url('https://images.unsplash.com/photo-1513258496099-48168024aec0?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         ),
         "rsvp" = div(
           style="position:fixed;z-index:-1;top:0;left:0;width:100vw;height:100vh; background: linear-gradient(105deg,#fffbe7 0%,#ffe4b2 80%), url('https://images.unsplash.com/photo-1432888498266-38ffec3eaf0a?auto=format&fit=crop&w=1200&q=80') center/cover no-repeat;"
         )
  )
}
app_theme <- function(app) {
  switch(app,
         "pizza"      = list("--sjs-primary-backcolor"="#fc8c2a", "--sjs-questionpanel-backcolor"="#fffaf4"),
         "feedback"   = list("--sjs-primary-backcolor"="#2ad4ff", "--sjs-questionpanel-backcolor"="#f6feff"),
         "hotel"      = list("--sjs-primary-backcolor"="#26baaa", "--sjs-questionpanel-backcolor"="#f7fcfa"),
         "flight"     = list("--sjs-primary-backcolor"="#2177d2", "--sjs-questionpanel-backcolor"="#f7fcff"),
         "tshirt"     = list("--sjs-primary-backcolor"="#6a4bc2", "--sjs-questionpanel-backcolor"="#f4f1fa"),
         "conference" = list("--sjs-primary-backcolor"="#f44174", "--sjs-questionpanel-backcolor"="#fff2f7"),
         "car"        = list("--sjs-primary-backcolor"="#4954db", "--sjs-questionpanel-backcolor"="#f7f8ff"),
         "pet"        = list("--sjs-primary-backcolor"="#ffb84d", "--sjs-questionpanel-backcolor"="#fff8e1"),
         "job"        = list("--sjs-primary-backcolor"="#4eb883", "--sjs-questionpanel-backcolor"="#eaffee"),
         "icecream"   = list("--sjs-primary-backcolor"="#ff79c6", "--sjs-questionpanel-backcolor"="#fff2fa"),
         "quiz"       = list("--sjs-primary-backcolor"="#0066cc", "--sjs-questionpanel-backcolor"="#e4e9fd"),
         "rsvp"       = list("--sjs-primary-backcolor"="#ff9966", "--sjs-questionpanel-backcolor"="#fff5e6"),
         list()
  )
}

# ==== SCHEMA DEFINITIONS ====
# ... (put all 12 schema functions here from the previous message) ...

# For brevity:
# - Paste all the 12 schema functions here, as in the previous message.

# ==== UI ====
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background: #f8fafc; }
    .sidebar { position:fixed; left:0; top:0; bottom:0; width:250px; background:#fff; box-shadow:2px 0 12px #ddd; padding:28px 18px 0 18px; z-index:5; }
    .sidebar h3 { font-size:1.2em; margin-bottom:.7em; }
    .gallery-main { margin-left:270px; }
    .gallery-row { display:flex; flex-wrap:wrap; gap:38px; }
    .gallery-card { background: #fff; border-radius: 18px; box-shadow: 0 6px 32px #aaa3; width: 320px; padding: 26px 24px 20px 24px;
      display: flex; flex-direction: column; align-items: center; transition: box-shadow .18s; border: 1.5px solid #eee; margin-bottom: 24px;}
    .gallery-card:hover { box-shadow: 0 8px 36px #ff90224a; border-color: #2177d2;}
    .gallery-img { width: 94px; height: 94px; object-fit: contain; margin-bottom: 10px; }
    .gallery-title { font-size: 1.36em; font-weight: 600; color: #2177d2; margin-bottom: 8px;}
    .gallery-desc { color: #666; font-size: 1.05em; min-height: 54px; margin-bottom: 1em; text-align: center;}
    .gallery-btn { font-size: 1.07em; padding: 9px 22px; border-radius: 8px; background: linear-gradient(90deg, #2177d2 75%, #fff1e1 100%);
      border: none; color: #fff; font-weight: 500; letter-spacing: .04em; box-shadow: 0 2px 12px #2177d233; transition: background .16s; margin-top: 6px;}
    .gallery-btn:hover { background: linear-gradient(90deg, #2184d2 60%, #fff1e1 100%);}
    @media (max-width:1100px) {.gallery-row {gap:16px;} .gallery-card{width:98vw;max-width:400px;}}
    .back-btn { display:inline-block; margin: 1em 0 1em 0; font-size: 1.04em; background: #eee; color: #2177d2; border: none; padding: 6px 18px; border-radius: 7px; transition: background .16s;}
    .back-btn:hover { background: #2177d2; color: #fff;}
    .survey-wrap { max-width:700px; margin:2em auto; background:#fff; border-radius:18px; box-shadow:0 6px 32px #aaa3; padding:28px 26px 18px 26px; position:relative;}
    .list-table {width:100%; border-collapse:collapse;}
    .list-table th,.list-table td{padding:9px 10px;border-bottom:1px solid #eaeaea;}
    .list-table th{background:#f6f8fa; font-weight:600;}
    .list-table td{vertical-align:middle;}
    .list-table tr:hover{background:#f3f7ff;}
    .feature-badge{background:#f6f8fa; border-radius:8px; padding:2px 9px; font-size:0.98em; margin-right:5px;}
    .sidebar .form-group{margin-bottom:18px;}
    .gallery-header{margin-top:0.4em; margin-bottom:1.3em;}
  "))),
  div(class="sidebar",
      h3("🔎 Filter Gallery"),
      textInput("filter_name", "Name", "", placeholder="Type to search..."),
      sliderInput("filter_nq", "Number of Questions", 1, 15, c(1,15), step=1, width="100%"),
      checkboxGroupInput("filter_feat", "Features", choices=survey_features, selected=character(0), width="100%"),
      br(),
      div("Switch View:"),
      radioButtons("gallery_view", NULL, choices=c("Tiles"="tiles","List"="list"), selected="tiles", inline=TRUE)
  ),
  div(class="gallery-main",
      uiOutput("pageUI")
  )
)

server <- function(input, output, session) {
  page <- reactiveVal("landing")
  page_app <- reactiveVal(NULL)

  # Filtering logic INSIDE reactivity
  filtered_catalog <- reactive({
    cat <- survey_catalog
    # Name filter
    if(nzchar(input$filter_name)) {
      cat <- cat[grepl(input$filter_name, cat$title, ignore.case=TRUE),]
    }
    # Question count
    cat <- cat[cat$n_questions >= input$filter_nq[1] & cat$n_questions <= input$filter_nq[2],]
    # Features
    if(length(input$filter_feat)) {
      cat <- cat[sapply(cat$features, function(fs) all(input$filter_feat %in% fs)),]
    }
    cat
  })

  output$pageUI <- renderUI({
    if(page() == "landing") {
      cat <- filtered_catalog()
      if(input$gallery_view == "tiles") {
        tagList(
          div(class="gallery-header", h1("🚀 Survey Gallery"),
              tags$p(style="font-size:1.13em;color:#333;","Explore creative SurveyJS examples. Filter or click to try!")
          ),
          div(class="gallery-row",
              lapply(seq_len(nrow(cat)), function(i) {
                app <- cat$key[i]
                div(class="gallery-card",
                    app_bg(app),
                    img(src=sprintf("https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/%s.png", cat$emoji[i]), class="gallery-img"),
                    div(class="gallery-title", cat$title[i]),
                    div(class="gallery-desc", paste("This survey uses features like:", paste(cat$features[[i]], collapse=", "))),
                    div(style="margin-bottom:.4em;",
                        lapply(cat$features[[i]], function(feat)
                          span(class="feature-badge", feat)
                        )
                    ),
                    actionButton(paste0("to_",app), "Try now!", class="gallery-btn")
                )
              })
          )
        )
      } else {
        # List/table view
        tagList(
          div(class="gallery-header", h1("🚀 Survey Gallery"),
              tags$p(style="font-size:1.13em;color:#333;","Explore creative SurveyJS examples. Filter or click to try!")
          ),
          tableOutput("gallery_table")
        )
      }
    } else {
      app <- page_app()
      tagList(
        app_bg(app),
        div(class="survey-wrap",
            actionButton("back", "← Back to Gallery", class="back-btn"),
            surveyjsOutput(paste0(app,"_app")),
            br(), h4("📊 Data"), verbatimTextOutput(paste0(app,"_data"), placeholder=TRUE)
        )
      )
    }
  })

  # List view table
  output$gallery_table <- renderTable({
    cat <- filtered_catalog()
    tibble::tibble(
      Name = cat$title,
      Questions = cat$n_questions,
      Features = sapply(cat$features, function(fs) paste(fs, collapse=", ")),
      "Try it" = sapply(cat$key, function(app)
        as.character(actionButton(paste0("to_",app), "Try!", class="gallery-btn", style="padding:6px 18px;"))
      )
    )
  }, sanitize.text.function=identity)

  # Button Observers (reactive to filtered_catalog!)
  observe({
    lapply(filtered_catalog()$key, function(app) {
      observeEvent(input[[paste0("to_",app)]], { page("app"); page_app(app) }, ignoreInit=TRUE)
    })
  })
  observeEvent(input$back, { page("landing") })

  # Render Sub-Apps (all 12!)
  lapply(survey_catalog$key, function(app) {
    output[[paste0(app,"_app")]] <- renderSurveyjs({
      schema_fun <- get(survey_catalog$schema_fn[survey_catalog$key==app])
      surveyjs(schema = schema_fun(), live = TRUE, theme = "Modern", theme_vars = app_theme(app))
    })
    output[[paste0(app,"_data")]] <- renderPrint({ input[[paste0(app,"_app_data_live")]] })
  })
}

shinyApp(ui, server)
