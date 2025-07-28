# rsurveyjs 0.1.0 (2025-07-28)

- Initial release.
- Htmlwidget to render SurveyJS forms (`surveyjs()`).
- Shiny bindings: final submission in `input$id_data`, optional live updates in `input$id_data_live`.
- Server update API: `updateSurveyjs()` to prefill data, toggle read-only, change theme/locale, or replace the schema.
- Works in Shiny apps and Quarto documents with `server: shiny`.
- Bundled SurveyJS runtime (MIT) pinned to v1.12.12.
