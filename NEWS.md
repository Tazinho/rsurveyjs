## Version 0.1.0

- Initial release of `rsurveyjs`, supporting:
  - SurveyJS v2 (React-based)
  - Dynamic theming via CSS variables (`theme_vars`)
  - Shiny integration (`surveyjsOutput()`, `renderSurveyjs()`)
  - Server-side updates (`updateSurveyjs()`)
  - Dependency-managed via `htmlwidgets` and pkgdown-ready
- Dropped legacy SurveyJS v1 fallback to simplify maintenance
- Added introductory vignette: "Getting Started"
