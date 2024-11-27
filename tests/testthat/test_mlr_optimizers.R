test_that("mlr_optimizers", {
  expect_dictionary(mlr_optimizers, min_items = 1L)
  keys = mlr_optimizers$keys()

  for (key in keys) {
    if (key == "chain") {
      optimizer = opt(key, optimizers = list(opt("random_search")))
    } else {
      optimizer = opt(key)
    }
    expect_multi_class(optimizer, c("Optimizer", "OptimizerAsync"))
  }
})

test_that("mlr_optimizers sugar", {
  expect_class(opt("random_search"), "Optimizer")
  expect_class(opts(c("random_search", "random_search")), "list")
})

test_that("as.data.table objects parameter", {
  tab = as.data.table(mlr_optimizers, objects = TRUE)
  expect_data_table(tab)
  expect_list(tab$object, any.missing = FALSE)
})
