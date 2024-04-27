test_that("OptimizerAsyncGridSearch works", {
  skip_if(TRUE)
  #skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  optimizer = opt("async_grid_search")
  expect_class(optimizer, "OptimizerAsync")

  rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("none"),
  )

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(instance$archive$data, nrows = 100)

  expect_rush_reset(instance$rush)
})
