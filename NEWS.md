# rsurveyjs 0.1.0

## Initial release

- **First release of `rsurveyjs`: Minimal, powerful R bindings for [SurveyJS v2.x](https://surveyjs.io/)**

### Features

- Render [SurveyJS](https://surveyjs.io/) surveys, forms, and quizzes from R using simple JSON-compatible lists
- Full **Shiny integration**:  
  - Get completed responses via `input$<id>_data`
  - Track live responses while typing via `input$<id>_data_live`
  - Dynamically update schema, data, theme, or language from the server
- **Easy theming and localization**:  
  - Choose from built-in SurveyJS themes  
  - Customize styles via CSS variables (`theme_vars`)  
  - Instantly localize the UI with the `locale` argument, or provide multi-locale schemas
- **Advanced extensibility**:  
  - Inject custom JavaScript (for validation, events, or logic) via `pre_render_hook`, `post_render_hook`, and `complete_hook`
  - Listen to any SurveyJS event or add custom behaviors
- **Real-world vignettes and recipes**:  
  - [Survey Schema Recipes](articles/survey-schema-recipes.html): Copy-paste building blocks for all question types, logic, and validation
  - [Themes, Styling and Localization](articles/themes-styling-and-localization.html)
  - [Advanced JS Hooks & Events](articles/advanced-js-hooks--events.html)
  - [Shiny and Database Integration](articles/shiny-and-database-integration.html): Persistent survey storage with database examples

### Philosophy & Limitations

- Keeps all validation and rendering on the JS (SurveyJS) side—no R-side schema validation
- No bundled visual designer or SurveyJS Creator (see [SurveyJS licensing](https://surveyjs.io/licensing) for those features)
- Custom widgets/plugins are not officially supported, but power users can inject JavaScript for advanced cases

---

Thank you to early testers and the SurveyJS team for making world-class survey tooling available under MIT!

