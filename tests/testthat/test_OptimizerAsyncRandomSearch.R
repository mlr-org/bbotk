test_that("OptimizerAsyncRandomSearch works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  options(bbotk.tiny_logging = TRUE)

  optimizer = opt("async_random_search")
  expect_class(optimizer, "OptimizerAsync")

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 1000L),
  )

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(instance$archive$data, min.rows = 5)

  expect_rush_reset(instance$rush)
})
