test_that("widget includes SurveyJS deps", {
  w <- rsurveyjs::surveyjs(list(title="t", pages=list(list(elements=list()))))
  deps <- htmltools::findDependencies(w)
  nms <- vapply(deps, `[[`, "", "name")
  expect_true("surveyjs-core" %in% nms)
  expect_true("surveyjs-binding" %in% nms)
})
