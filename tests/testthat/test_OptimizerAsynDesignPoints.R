skip_if_not_installed("rush")
skip_if_no_redis()

test_that("OptimizerAsyncRandomSearch works", {
  rush = start_rush(n_workers = 2)
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  design = data.table(x1 = c(0.1, 0.2), x2 = c(0.3, 0.4))
  optimizer = opt("async_design_points", design = design)
  expect_class(optimizer, "OptimizerAsync")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("none"),
    rush = rush
  )

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(instance$archive$data, nrows = 2)
})

