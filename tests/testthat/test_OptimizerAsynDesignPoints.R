test_that("OptimizerAsyncRandomSearch works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  design = data.table(x1 = c(0.1, 0.2), x2 = c(0.3, 0.4))
  optimizer = opt("async_design_points", design = design)
  expect_class(optimizer, "OptimizerAsync")

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("none")
  )

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(instance$archive$data, nrows = 2)

  expect_rush_reset(instance$rush)
})
