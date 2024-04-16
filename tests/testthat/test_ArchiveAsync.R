test_that("ArchiveAsync works with one point", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush = RushWorker$new(network_id = "remote_network", host = "local")

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  xss = list(list(x1 = 1, x2 = 2))
  keys = archive$push_points(xss)
  expect_string(keys)

  expect_data_table(archive$queued_data, nrows = 1)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 0)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$fetch_data_with_state()$state, "queued")

  expect_list(archive$pop_point(), len = 2)

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 1)
  expect_data_table(archive$finished_data, nrows = 0)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$fetch_data_with_state()$state, "running")

  archive$push_results(keys, yss = list(list(y1 = 1, y2 = 2)))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$fetch_data_with_state()$state, "finished")

  xss = list(list(x1 = 2, x2 = 2))
  keys = archive$push_running_points(xss)

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 1)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$fetch_data_with_state()$state, c("running", "finished"))

  archive$push_failed_points(keys, list(list(message = "error")))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 1)
  expect_equal(archive$fetch_data_with_state()$state, c("finished", "failed"))
})
