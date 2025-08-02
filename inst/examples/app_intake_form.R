library(shiny)
library(shinydashboard)
library(DBI)
library(RSQLite)
library(dplyr)
library(rsurveyjs)
library(shinyjs)
library(openxlsx)
library(DT)

db <- dbConnect(RSQLite::SQLite(), "ai_ideas.db")
existing_cols <- dbListFields(db, "ai_ideas")
if (!"priority" %in% existing_cols) dbExecute(db, "ALTER TABLE ai_ideas ADD COLUMN priority INTEGER")

survey_schema <- list(
  pages = list(
    list(
      name = "page1",
      elements = list(
        list(
          type = "text", name = "project_title", title = "Project Title",
          isRequired = TRUE,
          minLength = 3,
          validators = list(
            list(type = "regex", text = "Title must be at least 3 characters", regex = "^\\s*\\S.{1,}")
          )
        ),
        list(
          type = "comment", name = "project_description", title = "Describe your AI idea",
          isRequired = TRUE,
          minLength = 10,
          validators = list(
            list(type = "text", minLength = 10, text = "Description must be at least 10 characters")
          )
        ),
        list(
          type = "dropdown", name = "category", title = "Category",
          isRequired = TRUE, choices = c("NLP", "CV", "Recommendation", "Other")
        ),
        list(
          type = "rating", name = "priority", title = "Priority (1 = low, 10 = high)",
          rateMin = 1, rateMax = 10, isRequired = TRUE,
          validators = list(
            list(type = "numeric", text = "Priority must be between 1 and 10", minValue = 1, maxValue = 10)
          )
        ),
        list(
          type = "text", name = "contact", title = "Contact Email",
          isRequired = TRUE,
          inputType = "email",
          validators = list(
            list(type = "email", text = "Please enter a valid email address")
          )
        )
      )
    )
  )
)

ui <- dashboardPage(
  dashboardHeader(title = span(icon("robot"), "AI Idea Dashboard")),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("New Idea", tabName = "new", icon = icon("plus"))
    ),
    hr(),
    downloadButton("download_ideas", "Download ideas (.xlsx)", class = "btn btn-info", icon = icon("download")),
    radioButtons("view_mode", "View Mode", choices = c("Tiles" = "tile", "List" = "list"), inline = TRUE, selected = "tile"),
    textInput("filter_title", "Filter Title"),
    textInput("filter_category", "Filter Category"),
    textInput("filter_contact", "Filter by Contact"),
    sliderInput("filter_priority", "Priority Range", min = 1, max = 10, value = c(1,10)),
    br(),
    div(
      style = "font-size:12px; color:#ccc; padding:6px 2px;",
      "Note: If multiple people edit the same project idea, the last save will overwrite previous edits."
    )
  ),
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$script(src = "https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"),
      tags$style(HTML("
        #particles-js { position: fixed; z-index: 0; top: 0; left: 0; width: 100vw; height: 100vh; pointer-events: none; }
        .content-wrapper { background: transparent !important; }
        .tile-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 22px; align-items: stretch; }
        .main-header, .main-sidebar { background: #222b38; }
        #download-panel { margin: 14px 0 20px 0; }
        #toggle-panel { margin: 0 0 16px 0; }
        .dt-wrapper, .dataTables_wrapper { background: #fff !important; }
        table.dataTable { background: #fff !important; }
        .dataTables_wrapper .dataTables_paginate .paginate_button {background: #eee;}
        .ai-form-box { background: #fff; border-radius: 16px; box-shadow: 0 2px 14px rgba(50,50,93,0.09); padding:28px 30px 18px 30px; margin-top:28px;}
        .idea-action-btn { margin-right:8px; }
        .btn-soft-red { background-color: #ffe0e6 !important; color: #c72a2a !important; border: none; }
        .btn-soft-red:hover { background-color: #ffc2cb !important; color: #a51c1c !important; }
      "))
    ),
    tags$div(id = "particles-js"),
    tags$script(HTML('
      $(document).ready(function(){
        if(window.pJSDom && window.pJSDom.length > 0) window.pJSDom[0].pJS.fn.vendors.destroypJS();
        particlesJS("particles-js", {
          "particles": {
            "number": {
              "value": 48,
              "density": { "enable": true, "value_area": 900 }
            },
            "color": { "value": ["#36e2ec", "#5e60ce", "#ffd166", "#ff6f61", "#ffffff"] },
            "shape": { "type": "circle" },
            "opacity": { "value": 0.4, "random": true },
            "size": { "value": 4, "random": true },
            "line_linked": {
              "enable": true,
              "distance": 130,
              "color": "#36e2ec",
              "opacity": 0.19,
              "width": 1
            },
            "move": {
              "enable": true,
              "speed": 1.9,
              "direction": "none",
              "random": true,
              "straight": false,
              "out_mode": "out"
            }
          },
          "interactivity": {
            "detect_on": "canvas",
            "events": {
              "onhover": { "enable": true, "mode": "repulse" },
              "onclick": { "enable": false }
            },
            "modes": {
              "repulse": { "distance": 95, "duration": 0.6 }
            }
          },
          "retina_detect": true
        });
      });
    ')),
    tabItems(
      tabItem(
        tabName = "dashboard",
        fluidRow(
          column(
            width = 12,
            uiOutput("main_dashboard"),
            uiOutput("actions_ui")
          )
        )
      ),
      tabItem(
        tabName = "new",
        box(
          title = "Submit or Edit Your AI Idea",
          width = 7,
          solidHeader = TRUE,
          status = "primary",
          class = "ai-form-box",
          surveyjsOutput("survey", height = "510px"),
          br(),
          actionButton("cancel_edit", "Cancel", class = "btn btn-default"),
          textOutput("save_message")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  edit_id <- reactiveVal(NULL)
  selected_id <- reactiveVal(NULL)
  save_message <- reactiveVal("")
  data_trigger <- reactiveVal(0)
  trigger_update <- function() data_trigger(data_trigger() + 1)

  debounced_title    <- debounce(reactive(input$filter_title),    300)
  debounced_category <- debounce(reactive(input$filter_category), 300)
  debounced_contact  <- debounce(reactive(input$filter_contact),  300)
  debounced_priority <- debounce(reactive(input$filter_priority), 300)

  filter_ideas <- reactive({
    data_trigger()
    ideas <- dbGetQuery(db, "SELECT * FROM ai_ideas")
    if (nrow(ideas) > 0) {
      idx <- rep(TRUE, nrow(ideas))
      if (nzchar(debounced_title())) {
        idx <- idx & grepl(debounced_title(), ideas$project_title, ignore.case = TRUE)
      }
      if (nzchar(debounced_category())) {
        idx <- idx & grepl(debounced_category(), ideas$category, ignore.case = TRUE)
      }
      if (nzchar(debounced_contact())) {
        idx <- idx & grepl(debounced_contact(), ideas$contact, ignore.case = TRUE)
      }
      prange <- debounced_priority()
      idx <- idx & ideas$priority >= prange[1] & ideas$priority <= prange[2]
      ideas <- ideas[idx, , drop = FALSE]
    }
    ideas
  })

  output$download_ideas <- downloadHandler(
    filename = function() paste0("AI_Ideas_", Sys.Date(), ".xlsx"),
    content = function(file) openxlsx::write.xlsx(filter_ideas(), file)
  )

  # TILE UI: show Edit/Delete directly on each tile (no more Select)
  output$main_dashboard <- renderUI({
    ideas <- filter_ideas()
    if (input$view_mode == "tile") {
      if (nrow(ideas) == 0) return(h4("No project ideas found.", style="color: #ffb347; margin:25px;"))
      div(class = "tile-grid",
          lapply(seq_len(nrow(ideas)), function(i) {
            idea <- ideas[i, ]
            box(
              title = span(idea$project_title, style = "font-size: 1.1em;"),
              status = "primary",
              solidHeader = TRUE,
              width = NULL,
              p(idea$project_description),
              p(strong("Category:"), idea$category),
              p(strong("Priority:"), tags$span(style="color:#36e2ec;font-weight:bold;", idea$priority)),
              p(strong("Contact:"), idea$contact),
              div(
                actionButton(
                  inputId = paste0("edit_tile_", idea$id),
                  label = "Edit",
                  class = "idea-action-btn btn btn-info btn-sm"
                ),
                actionButton(
                  inputId = paste0("delete_tile_", idea$id),
                  label = "Delete",
                  class = "idea-action-btn btn btn-soft-red btn-sm"
                )
              )
            )
          })
      )
    } else {
      ideas <- filter_ideas()
      box(
        title = "AI Project Ideas (List View)",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        style = "background: #fff; padding:18px 18px 6px 18px; min-width:350px; overflow-x:auto;",
        if (nrow(ideas) == 0) {
          h4("No project ideas found.", style="color: #ffb347; margin:25px;")
        } else {
          DT::dataTableOutput("ideas_table", width = "100%")
        }
      )
    }
  })

  output$ideas_table <- DT::renderDataTable({
    ideas <- filter_ideas()
    datatable(
      ideas,
      selection = "single",
      rownames = FALSE,
      class = "stripe hover",
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        autoWidth = FALSE,
        columnDefs = list(list(width = '120px', targets = c(0,2,4)))
      )
    )
  })

  # Per-tile edit/delete: only these two observers for all tiles (no dynamic observer loops)
  observe({
    ideas <- filter_ideas()
    lapply(ideas$id, function(id) {
      observeEvent(input[[paste0("edit_tile_", id)]], {
        edit_id(id)
        updateTabItems(session, "tabs", selected = "new")
        shinyjs::show("cancel_edit")
        save_message("")
      }, ignoreInit = TRUE)
      observeEvent(input[[paste0("delete_tile_", id)]], {
        ideas_now <- filter_ideas()
        proj_name <- ideas_now$project_title[ideas_now$id == id]
        showModal(modalDialog(
          title = "Confirm Deletion",
          sprintf("Are you sure you want to delete the project idea '%s'?", proj_name),
          footer = tagList(
            modalButton("Cancel"),
            actionButton("confirm_delete_selected", "Yes, Delete", class = "btn-soft-red btn")
          )
        ))
        selected_id(id)
      }, ignoreInit = TRUE)
    })
  })

  # List view: Actions below table, per selection
  output$actions_ui <- renderUI({
    if (input$view_mode == "list") {
      dt_rows <- input$ideas_table_rows_selected
      ideas <- filter_ideas()
      sel_id <- if (!is.null(dt_rows) && length(dt_rows) > 0) ideas$id[dt_rows[1]] else NULL
      if (is.null(sel_id)) return(NULL)
      tagList(
        actionButton("edit_selected", "Edit", class = "btn btn-info"),
        actionButton("delete_selected", "Delete", class = "btn-soft-red btn", style = "margin-left:8px;"),
        div(style = "margin-left:12px; display:inline; color:#888; font-size:13px;",
            paste0("Selected project ID: ", sel_id))
      )
    } else NULL
  })

  # Unified edit/delete (list view)
  observeEvent(input$edit_selected, {
    dt_rows <- input$ideas_table_rows_selected
    ideas <- filter_ideas()
    id <- if (!is.null(dt_rows) && length(dt_rows) > 0) ideas$id[dt_rows[1]] else NULL
    if (!is.null(id)) {
      edit_id(id)
      updateTabItems(session, "tabs", selected = "new")
      shinyjs::show("cancel_edit")
      save_message("")
    }
  })

  observeEvent(input$delete_selected, {
    dt_rows <- input$ideas_table_rows_selected
    ideas <- filter_ideas()
    id <- if (!is.null(dt_rows) && length(dt_rows) > 0) ideas$id[dt_rows[1]] else NULL
    proj_name <- if (!is.null(id)) ideas$project_title[ideas$id == id] else ""
    if (!is.null(id)) {
      showModal(modalDialog(
        title = "Confirm Deletion",
        sprintf("Are you sure you want to delete the project idea '%s'?", proj_name),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("confirm_delete_selected", "Yes, Delete", class = "btn-soft-red btn")
        )
      ))
      selected_id(id)
    }
  })

  observeEvent(input$confirm_delete_selected, {
    id <- selected_id()
    if (!is.null(id)) {
      dbExecute(db, "DELETE FROM ai_ideas WHERE id=?", params = list(id))
      removeModal()
      trigger_update()
      if (!is.null(edit_id()) && edit_id() == id) {
        edit_id(NULL)
        updateTabItems(session, "tabs", selected = "dashboard")
        shinyjs::hide("cancel_edit")
      }
      selected_id(NULL)
    }
  })

  output$survey <- renderSurveyjs({
    if (!is.null(edit_id())) {
      row <- dbGetQuery(db, sprintf("SELECT * FROM ai_ideas WHERE id=%d", edit_id()))
      vals <- as.list(row[1, -1])
      vals$priority <- as.integer(vals$priority)
      surveyjs(
        schema = survey_schema,
        data = vals
      )
    } else {
      surveyjs(schema = survey_schema)
    }
  })

  observeEvent(input$tabs, {
    if (input$tabs == "new" && is.null(edit_id())) {
      updateSurveyjs(session, "survey", data = NULL, read_only = FALSE)
      session$sendCustomMessage("surveyjs-clear", list(el = "survey"))
      shinyjs::show("cancel_edit")
    }
  })

  observeEvent(input$cancel_edit, {
    edit_id(NULL)
    updateTabItems(session, "tabs", selected = "dashboard")
    shinyjs::hide("cancel_edit")
    save_message("")
    updateSurveyjs(session, "survey", data = NULL, read_only = FALSE)
    session$sendCustomMessage("surveyjs-clear", list(el = "survey"))
    selected_id(NULL)
  })

  output$save_message <- renderText({ save_message() })

  observeEvent(input$survey_data, {
    vals <- input$survey_data
    if (is.null(vals)) return()
    if (is.null(edit_id())) {
      dbExecute(db, "INSERT INTO ai_ideas (project_title, project_description, category, priority, contact) VALUES (?, ?, ?, ?, ?)",
                params = list(
                  vals$project_title,
                  vals$project_description,
                  vals$category,
                  as.integer(vals$priority),
                  vals$contact
                ))
    } else {
      dbExecute(db, "UPDATE ai_ideas SET project_title=?, project_description=?, category=?, priority=?, contact=? WHERE id=?",
                params = list(
                  vals$project_title,
                  vals$project_description,
                  vals$category,
                  as.integer(vals$priority),
                  vals$contact,
                  edit_id()
                ))
      edit_id(NULL)
      shinyjs::hide("cancel_edit")
    }
    trigger_update()
    updateTabItems(session, "tabs", selected = "dashboard")
    updateSurveyjs(session, "survey", data = NULL, read_only = FALSE)
    session$sendCustomMessage("surveyjs-clear", list(el = "survey"))
    selected_id(NULL)
  })
}

shinyApp(ui, server)
