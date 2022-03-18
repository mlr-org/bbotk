test_that("mlr_optimizers", {
  expect_dictionary(mlr_optimizers, min_items = 1L)
  keys = mlr_optimizers$keys()

  for (key in keys) {
    optimizer = opt(key)
    expect_r6(optimizer, "Optimizer")
  }
})

test_that("mlr_optimizers sugar", {
  expect_class(opt("random_search"), "Optimizer")
  expect_class(opts(c("random_search", "random_search")), "list")
})

test_that("as.data.table objects parameter", {
  tab = as.data.table(mlr_optimizers, objects = TRUE)
  expect_data_table(tab)
  expect_list(tab$object, "Optimizer", any.missing = FALSE)
})
