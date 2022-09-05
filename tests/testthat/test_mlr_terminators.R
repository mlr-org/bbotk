test_that("mlr_terminators", {
  expect_dictionary(mlr_terminators, min_items = 1L)
  keys = mlr_terminators$keys()

  for (key in keys) {
    terminator = trm(key)
    expect_r6(terminator, "Terminator")
  }
})

test_that("mlr_terminators sugar", {
  expect_class(trm("evals"), "Terminator")
  expect_class(trms(c("evals", "evals")), "list")
})

test_that("as.data.table objects parameter", {
  tab = as.data.table(mlr_terminators, objects = TRUE)
  expect_data_table(tab)
  expect_list(tab$object, "Terminator", any.missing = FALSE)
})
