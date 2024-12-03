test_that("ArchiveAsyncFrozen works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  archive = instance$archive
  frozen_archive = ArchiveAsyncFrozen$new(archive)

  expect_data_table(frozen_archive$data)
  expect_data_table(frozen_archive$queued_data)
  expect_data_table(frozen_archive$running_data)
  expect_data_table(frozen_archive$finished_data)
  expect_data_table(frozen_archive$failed_data)
  expect_equal(frozen_archive$n_queued, 0L)
  expect_equal(frozen_archive$n_running, 0L)
  expect_gte(frozen_archive$n_finished, 5L)
  expect_equal(frozen_archive$n_failed, 0L)
  expect_gte(frozen_archive$n_evals, 5L)

  expect_data_table(as.data.table(frozen_archive))
})
