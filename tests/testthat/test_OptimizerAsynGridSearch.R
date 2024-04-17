test_that("OptimizerAsyncRandomSearch works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  # options(bbotk_local = TRUE)

  rush_plan(n_workers = 2)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("none"),
  )

  optimizer = opt("async_grid_search")

  expect_data_table(optimizer$optimize(instance), nrows = 1)

  expect_rush_reset(instance$rush)
})
