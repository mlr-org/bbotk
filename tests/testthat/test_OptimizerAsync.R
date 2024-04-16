test_that("OptimizerAsync starts local workers", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush_plan(n_workers = 2)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")

  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 2)
})

test_that("OptimizerAsync assigns result", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush_plan(n_workers = 2)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")

  optimizer$optimize(instance)

  expect_data_table(instance$result, nrows = 1)
})
