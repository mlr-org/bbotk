test_that("OptimizerAsyncRandomSearch works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush_plan(n_workers = 2)

  instance = OptimInstanceAsyncSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")

  expect_data_table(optimizer$optimize(instance), nrows = 1)
})
