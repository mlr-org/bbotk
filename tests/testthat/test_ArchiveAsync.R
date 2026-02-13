test_that("ArchiveAsync works with one point", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  # FIXME: Remove after rush 1.0.0 is released
  if (packageVersion("rush") <= "0.4.1") {
    rush = rush::RushWorker$new(network_id = "remote_network", remote = FALSE)
  } else {
    rush = rush::rsh(network_id = "remote_network")
  }

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

  expect_rush_reset(rush)
})

test_that("as.data.table.ArchiveAsync works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  data = as.data.table(instance$archive)
  expect_data_table(data, min.rows = 5)

  if (packageVersion("rush") <= "0.4.1") {
    cns = c("state", "x1", "x2", "y", "timestamp_xs", "pid", "worker_id", "timestamp_ys", "keys", "x_domain_x1", "x_domain_x2")
  } else {
    cns = c("state", "x1", "x2", "y", "timestamp_xs", "worker_id", "timestamp_ys", "keys", "x_domain_x1", "x_domain_x2")
  }

  expect_names(colnames(data), identical.to = cns)

  data = as.data.table(instance$archive, unnest = NULL)
  expect_list(data$x_domain)

  expect_rush_reset(instance$rush)
})

test_that("best method errors with direction=0 (learn tag)", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  # FIXME: Remove after rush 1.0.0 is released
  if (packageVersion("rush") <= "0.4.1") {
    rush = rush::RushWorker$new(network_id = "remote_network", remote = FALSE)
  } else {
    rush = rush::rsh(network_id = "remote_network")
  }

  codomain = ps(y = p_dbl(tags = "learn"))

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = codomain,
    rush = rush
  )

  xss = list(list(x1 = 0.5, x2 = 0.5))
  keys = archive$push_points(xss)
  archive$pop_point()
  archive$push_result(keys, ys = list(y = 0.5), x_domain = list(x1 = 0.5, x2 = 0.5))

  expect_error(archive$best(), "direction = 0")

  expect_rush_reset(rush)
})

test_that("nds_selection errors with direction=0 (learn tag)", {
  skip_on_cran()
  skip_if_not_installed("rush")
  skip_if_not_installed("emoa")
  flush_redis()

  # FIXME: Remove after rush 1.0.0 is released
  if (packageVersion("rush") <= "0.4.1") {
    rush = rush::RushWorker$new(network_id = "remote_network", remote = FALSE)
  } else {
    rush = rush::rsh(network_id = "remote_network")
  }
  codomain = ps(y1 = p_dbl(tags = "learn"), y2 = p_dbl(tags = "minimize"))

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = codomain,
    rush = rush
  )

  xss = list(list(x1 = 0.5, x2 = 0.5), list(x1 = 0.3, x2 = 0.3))
  keys = archive$push_points(xss)
  archive$pop_point()
  archive$push_result(keys[1], ys = list(y1 = 0.5, y2 = 0.3), x_domain = list(x1 = 0.5, x2 = 0.5))
  archive$pop_point()
  archive$push_result(keys[2], ys = list(y1 = 0.3, y2 = 0.5), x_domain = list(x1 = 0.3, x2 = 0.3))

  expect_error(archive$nds_selection(n_select = 1), "direction = 0")

  expect_rush_reset(rush)
})
