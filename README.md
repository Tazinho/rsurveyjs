
# rsurveyjs

[![R-CMD-check](https://github.com/Tazinho/rsurveyjs/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Tazinho/rsurveyjs/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Tazinho/rsurveyjs/actions/workflows/pkgdown.yaml/badge.svg)](https://Tazinho.github.io/rsurveyjs/)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/rsurveyjs)](https://CRAN.R-project.org/package=rsurveyjs)
![Last
Commit](https://img.shields.io/github/last-commit/Tazinho/rsurveyjs.svg)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Minimal bindings for [SurveyJS v2.x](https://surveyjs.io/) in R/Shiny.
([See also](https://app.unpkg.com/survey-core@2.2.6/files/i18n).)

**rsurveyjs** lets you render and interact with fully customizable
surveys, forms and quizzes in Shiny apps using
[SurveyJS](https://surveyjs.io/) v2.

------------------------------------------------------------------------

## 🚀 Installation

``` r
# Install from GitHub
remotes::install_github("Tazinho/rsurveyjs")
```

------------------------------------------------------------------------

## ✨ Features

- Integrates **SurveyJS v2** in R
- Supports **Shiny input/output** for complete + live responses
- Customize via **CSS variables** using (`theme_vars`)
- Dynamically update widgets via `updateSurveyjs()`
- Supports **readonly**, **initial values**, and **multilingual forms**

------------------------------------------------------------------------

## 🔧 Usage Example

``` r
library(rsurveyjs)

surveyjs(
  schema = list(
    title = "Feedback",
    questions = list(
      list(type = "rating", name = "s", title = "How satisfied are you?"),
      list(type = "text", name = "c", title = "Any comments?")
    )
  ),
  theme_vars = list("--sjs-primary-backcolor" = "#39f"),
  locale = "en",
  live = TRUE
)
```

------------------------------------------------------------------------

## 📚 SurveyJS Documentation

- [SurveyJS Homepage](https://surveyjs.io/)
- [Theme Customization
  Docs](https://surveyjs.io/survey-creator/documentation/theme-editor)
- [Release Notes](https://surveyjs.io/stay-updated/release-notes)

------------------------------------------------------------------------

## 🧪 Shiny Integration

| Feature                   | Shiny Input ID         |
|---------------------------|------------------------|
| Completed form data       | `input$<id>_data`      |
| Live updates while typing | `input$<id>_data_live` |

------------------------------------------------------------------------

## Design Decisions

### No Validation on the R Side

`rsurveyjs` does not perform schema validation in R. This decision is
based on the fact that SurveyJS already performs runtime validation in
the browser. It catches basic issues like malformed JSON or unknown
question types and typically fails gracefully — for example, by skipping
invalid questions or logging a console warning. However, also SurveyJS
does not enforce strict pre-validation:

- Invalid types like `type = "foo"` fail silently

- `name` is required — it acts as the key in the survey result; without
  it, the answer is not saved.

- Invalid logic or expressions may only throw errors at runtime

While an unofficial JSON Schema exists, it’s not actively maintained.
Adding deep validation in R would introduce unnecessary complexity,
dependencies, and risk drift from the actual rendering engine.

The philosophy of `rsurveyjs` is to keep things lightweight and trust
the developer. If something breaks, it will break at render time — just
as it would in a native SurveyJS project.

### Only apply theme variables if the theme is valid

We intentionally apply custom `theme_vars` only when a valid `theme` is
provided.

This means:

- If the specified theme is invalid or misspelled, the survey falls back
  to the default visual style.

- In this case, any `theme_vars` are not applied, since they’re assumed
  to be designed for the intended `theme`.

This avoids applying potentially mismatched styles and helps keep
behavior predictable.

------------------------------------------------------------------------

## Comparison of surveyjs and rsurveyjs

## 📊 Feature Coverage: SurveyJS vs. rsurveyjs

| Feature | SurveyJS (core lib) | `rsurveyjs` Support | Notes / Status |
|----|----|----|----|
| JSON-based survey schema | ✅ | ✅ | Fully supported via `schema =` |
| Multi-page surveys | ✅ | ✅ | Handled via schema structure |
| Question types (text, rating, dropdown, etc.) | ✅ | ✅ | Full core support |
| Validation rules | ✅ | ✅ | Add via schema |
| Conditional logic / visibility rules | ✅ | 🟡 (basic) | Logic works, no helper yet |
| Themes (built-in) | ✅ | ✅ | Use `theme = "..."` |
| Theme variables (CSS vars) | ✅ | ✅ | Via `theme_vars = list(...)` |
| Custom CSS styling | ✅ | 🟡 | Add via Shiny or HTML templates |
| Localization / i18n | ✅ | 🟡 (manual) | Manual script setup required |
| Read-only mode | ✅ | ✅ | Via `readOnly = TRUE` |
| Default values | ✅ | ✅ | Use `data = list(...)` |
| Live response tracking | ✅ | ✅ | `input$<id>_data_live` in Shiny |
| Completed result capture | ✅ | ✅ | `input$<id>_data` in Shiny |
| Dynamic update (R to JS) | ✅ | ✅ | Use `updateSurveyjs()` |
| Survey events / hooks | ✅ | ❌ | Not exposed (yet) |
| File uploads | ✅ | ❌ | Not integrated |
| Custom widgets / question renderers | ✅ | ❌ | JS-level customization only |
| Survey Creator (visual editor) | ⚠️ Separate product | ❌ | Not included due to license |
| PDF export | ✅ (via add-on) | ❌ | Not included |
| Mobile responsiveness | ✅ | ✅ | Inherited from SurveyJS |

### Legend

- ✅ = Fully supported
- 🟡 = Partially supported / works manually
- ❌ = Not yet supported in `rsurveyjs`
- ⚠️ = Separate licensing or package

------------------------------------------------------------------------

## Known limitations so far

- Custom widgets / question renderers ✅ ❌ JS-level customization only
- Mobile responsiveness ✅ ✅ Inherited from SurveyJS
- Debug the question types link in vignette examples
- find out why the rendering in vignettes is so strange
- It must be possible to embed surveys cleaner into web/vignettes
- does the high level structure for vignettes make sense?
- In surveyjs.js den Comment noch auflösen. You can add resizing suppert
  here if needed later
- what are multi-locale surveys?
- switch language on runtime (e.g. via dropown; supproted by surveyjs)
- consistent argument naming e.g. theme_vars vs readOnly…
- provide a shiny database example including testing with db-connection
- Live results tracking example doesnt work yet
- Completion example does not work or is not meaningful
- Dynamic Update example does not work or is not meaningful
- Handling: 📥 Input validation / error handling 📦 Embedding in other
  widgets or layouts \*� Unit testing examples 🧩 Extending with custom
  question types
- What about
- Survey events / hooks ✅ ❌ Not exposed (yet)
- Provide file upload example - e.g. what to do then with that file?
- PDF/Excel/CSV/JSON Export
- tests for all examples are needed

------------------------------------------------------------------------

## 🪪 License

- SurveyJS Form Library is licensed under MIT.
- rsurveyjs is MIT licensed.

Note: **Survey Creator is not included** due to licensing restrictions.
