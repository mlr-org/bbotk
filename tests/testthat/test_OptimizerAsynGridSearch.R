skip_if_not_installed("rush")
skip_if_no_redis()

test_that("OptimizerAsyncGridSearch works", {
  rush = start_rush(n_workers = 2)
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  optimizer = opt("async_grid_search")
  expect_class(optimizer, "OptimizerAsync")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("none"),
    rush = rush
  )

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(instance$archive$data, nrows = 100)

  expect_rush_reset(instance$rush)
})
