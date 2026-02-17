skip_if_not_installed("rush")
skip_if_no_redis()

test_that("OptimizerAsyncRandomSearch works", {
  rush = start_rush(n_workers = 2)
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  optimizer = opt("async_random_search")
  expect_class(optimizer, "OptimizerAsync")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(instance$archive$data, min.rows = 5)
})
