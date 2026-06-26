skip_if_not_installed("rush")
skip_if_no_redis()

test_that("ArchiveAsync works with one point", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

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

  archive$finish_point(keys, ys = list(y1 = 1, y2 = 2), x_domain = list(x1 = 1, x2 = 2))

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

  archive$fail_point(keys, condition = list(message = "error"))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 1)
  expect_equal(archive$data_with_state()$state, c("finished", "failed"))
})

test_that("best method errors with direction=0 (learn tag)", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  codomain = ps(y = p_dbl(tags = "learn"))

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = codomain,
    rush = rush
  )

  xss = list(list(x1 = 0.5, x2 = 0.5))
  keys = archive$push_points(xss)
  archive$pop_point()
  archive$finish_point(keys, ys = list(y = 0.5), x_domain = list(x1 = 0.5, x2 = 0.5))

  expect_error(archive$best(), "direction = 0")
})

test_that("nds_selection errors with direction=0 (learn tag)", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  codomain = ps(y1 = p_dbl(tags = "learn"), y2 = p_dbl(tags = "minimize"))

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = codomain,
    rush = rush
  )

  xss = list(list(x1 = 0.5, x2 = 0.5), list(x1 = 0.3, x2 = 0.3))
  keys = archive$push_points(xss)
  archive$pop_point()
  archive$finish_point(keys[1], ys = list(y1 = 0.5, y2 = 0.3), x_domain = list(x1 = 0.5, x2 = 0.5))
  archive$pop_point()
  archive$finish_point(keys[2], ys = list(y1 = 0.3, y2 = 0.5), x_domain = list(x1 = 0.3, x2 = 0.3))

  expect_error(archive$nds_selection(n_select = 1), "direction = 0")
})

test_that("as.data.table.ArchiveAsync works", {
  rush = start_rush()
  on.exit({
    rush$reset()
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  data = as.data.table(instance$archive)
  expect_data_table(data, min.rows = 5)

  cns = c("state", "x1", "x2", "y", "timestamp_xs", "worker_id", "timestamp_ys", "keys", "x_domain_x1", "x_domain_x2")
  expect_names(colnames(data), identical.to = cns)

  data = as.data.table(instance$archive, unnest = NULL)
  expect_list(data$x_domain)
})

test_that("push_points works with extras argument", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  xss = list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))
  extras = list(list(extra_info = "point1", batch_id = 1), list(extra_info = "point2", batch_id = 1))
  keys = archive$push_points(xss, extras = extras)
  expect_character(keys, len = 2)

  queued = archive$queued_data
  expect_data_table(queued, nrows = 2)

  # check that extras are stored along with timestamp_xs
  expect_true("timestamp_xs" %in% names(queued))
  expect_true("extra_info" %in% names(queued))
  expect_true("batch_id" %in% names(queued))
  expect_equal(sort(queued$extra_info), c("point1", "point2"))
  expect_equal(queued$batch_id, c(1, 1))
})

test_that("push_finished_points works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  xss = list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))
  yss = list(list(y1 = 1, y2 = 2), list(y1 = 3, y2 = 4))
  xss_extra = list(list(extra_info = "point1", batch_id = 1), list(extra_info = "point2", batch_id = 1))
  yss_extra = list(list(extra_info = "point1", batch_id = 1), list(extra_info = "point2", batch_id = 1))
  archive$push_finished_points(xss, yss, xss_extra, yss_extra)

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 2)
  expect_data_table(archive$failed_data, nrows = 0)

  expect_character(archive$data$extra_info, len = 2)
})

test_that("push_finished_point works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  archive$push_finished_point(
    list(x1 = 1, x2 = 2),
    list(y1 = 1, y2 = 2),
    xs_extra = list(extra_info = "point1"),
    ys_extra = list(score = 0.5))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 1)
  expect_data_table(archive$failed_data, nrows = 0)

  finished = archive$finished_data
  expect_equal(finished$x1, 1)
  expect_equal(finished$y1, 1)
  expect_equal(finished$extra_info, "point1")
  expect_equal(finished$score, 0.5)
  expect_true("timestamp_xs" %in% names(finished))
  expect_true("timestamp_ys" %in% names(finished))
})

test_that("push_point works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  key = archive$push_point(list(x1 = 1, x2 = 2), extra = list(extra_info = "point1"))
  expect_character(key, len = 1)

  queued = archive$queued_data
  expect_data_table(queued, nrows = 1)
  expect_equal(queued$x1, 1)
  expect_equal(queued$extra_info, "point1")
  expect_true("timestamp_xs" %in% names(queued))
})

test_that("push_running_points works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  xss = list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))
  archive$push_running_points(xss, extras = list(list(extra_info = "point1"), list(extra_info = "point2")))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 2)
  expect_equal(sort(archive$running_data$extra_info), c("point1", "point2"))
})

test_that("push_failed_point creates a failed point", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  archive$push_failed_point(list(x1 = 1, x2 = 2), condition = list(message = "error"))

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 0)
  expect_data_table(archive$failed_data, nrows = 1)

  failed = archive$failed_data
  expect_equal(failed$x1, 1)
  if (packageVersion("rush") >= "1.1.0.9001") {
    expect_equal(failed$condition[[1]]$message, "error")
  } else {
    expect_equal(failed$message, "error")
  }
})

test_that("push_failed_points creates failed points", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  xss = list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))
  conditions = list(list(message = "error1"), list(message = "error2"))
  archive$push_failed_points(xss, conditions = conditions)

  expect_data_table(archive$queued_data, nrows = 0)
  expect_data_table(archive$running_data, nrows = 0)
  expect_data_table(archive$finished_data, nrows = 0)
  expect_data_table(archive$failed_data, nrows = 2)
  if (packageVersion("rush") >= "1.1.0.9001") {
    expect_equal(sort(map_chr(archive$failed_data$condition, "message")), c("error1", "error2"))
  } else {
    expect_equal(sort(archive$failed_data$message), c("error1", "error2"))
  }
})

test_that("finish_point stores extra information", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  keys = archive$push_points(list(list(x1 = 1, x2 = 2)))
  archive$pop_point()
  archive$finish_point(
    keys,
    ys = list(y1 = 1, y2 = 2),
    x_domain = list(x1 = 1, x2 = 2),
    extra = list(extra_info = "point1"))

  expect_data_table(archive$finished_data, nrows = 1)
  expect_equal(archive$finished_data$extra_info, "point1")
})

test_that("finish_points works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  keys = archive$push_points(list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4)))
  archive$pop_point()
  archive$pop_point()
  archive$finish_points(
    keys,
    yss = list(list(y1 = 1, y2 = 2), list(y1 = 3, y2 = 4)),
    x_domains = list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4)),
    extras = list(list(extra_info = "point1"), list(extra_info = "point2")))

  expect_data_table(archive$finished_data, nrows = 2)
  expect_equal(sort(archive$finished_data$extra_info), c("point1", "point2"))
})

test_that("fail_points works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  keys = archive$push_points(list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4)))
  archive$pop_point()
  archive$pop_point()
  archive$fail_points(keys, conditions = list(list(message = "error1"), list(message = "error2")))

  expect_data_table(archive$failed_data, nrows = 2)
  if (packageVersion("rush") >= "1.1.0.9001") {
    expect_equal(sort(map_chr(archive$failed_data$condition, "message")), c("error1", "error2"))
  } else {
    expect_equal(sort(archive$failed_data$message), c("error1", "error2"))
  }
})

test_that("push_result is deprecated and forwards to finish_point", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  archive = ArchiveAsync$new(
    search_space = PS_2D,
    codomain = FUN_2D_CODOMAIN,
    rush = rush
  )

  keys = archive$push_points(list(list(x1 = 1, x2 = 2)))
  archive$pop_point()
  expect_warning(
    archive$push_result(keys, ys = list(y1 = 1, y2 = 2), x_domain = list(x1 = 1, x2 = 2)),
    "deprecated"
  )

  expect_data_table(archive$finished_data, nrows = 1)
})
