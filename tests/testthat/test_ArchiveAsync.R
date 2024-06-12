test_that("ArchiveAsync works with one point", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush = RushWorker$new(network_id = "remote_network", remote = FALSE)

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
  expect_equal(archive$data_with_state()$state, "queued")

  expect_list(archive$pop_point(), len = 2)

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 1)
  expect_data_table(archive$finished_data, nrows = 0)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$data_with_state()$state, "running")

  archive$push_result(keys, ys = list(y1 = 1, y2 = 2), x_domain = list(x1 = 1, x2 = 2))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$data_with_state()$state, "finished")

  xs = list(x1 = 2, x2 = 2)
  keys = archive$push_running_point(xs)

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 1)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 0)
  expect_equal(archive$data_with_state()$state, c("running", "finished"))

  archive$push_failed_point(keys, message = "error")

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 1)
  expect_equal(archive$data_with_state()$state, c("finished", "failed"))

  expect_rush_reset(rush, type = "terminate")
})

test_that("as.data.table.ArchiveAsync works", {
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

  data = as.data.table(instance$archive)
  expect_data_table(data, min.rows = 5)
  expect_names(colnames(data), identical.to = c("state","x1","x2","y","timestamp_xs","pid","worker_id","timestamp_ys","keys","x_domain_x1","x_domain_x2"))

  data = as.data.table(instance$archive, unnest = NULL)
  expect_list(data$x_domain)

  expect_rush_reset(instance$rush)
})
