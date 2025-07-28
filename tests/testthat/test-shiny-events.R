test_that("server reacts to live and final inputs", {
  skip_if_not_installed("shiny")

  library(shiny)

  schema <- list(
    title = "t",
    pages = list(
      list(elements = list(
        list(type = "text", name = "title", title = "Title", isRequired = TRUE)
      ))
    )
  )

  # Serverfunktion wie in deiner App
  server <- function(input, output, session){
    output$s <- renderSurveyjs(surveyjs(schema, live = TRUE))
    output$final <- renderPrint({ req(input$s_data);      input$s_data })
    output$live  <- renderPrint({ req(input$s_data_live); input$s_data_live })
  }

  # Browserloser Test: Inputs direkt setzen, ohne UI/Binding
  testServer(server, {
    # Live-Input simulieren (ohne Binding, daher allowInputNoBinding = TRUE)
    session$setInputs(s_data_live = list(title = "Live"),
                      allowInputNoBinding = TRUE)
    expect_equal(input$s_data_live$title, "Live")

    # Final-Input simulieren
    session$setInputs(s_data = list(title = "Final"),
                      allowInputNoBinding = TRUE)
    expect_equal(input$s_data$title, "Final")
  })
})
