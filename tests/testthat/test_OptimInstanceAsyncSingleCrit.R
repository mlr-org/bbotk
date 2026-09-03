skip_if_not_installed("rush")
skip_if_no_redis()

test_that("initializing OptimInstanceAsyncSingleCrit works", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_r6(instance$archive, "ArchiveAsync")
  expect_r6(instance$objective, "Objective")
  expect_r6(instance$search_space, "ParamSet")
  expect_r6(instance$terminator, "Terminator")
  expect_r6(instance$rush, "Rush")
  expect_null(instance$result)
})

test_that("context is initialized correctly", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_r6(instance$objective$context, "ContextAsync")
})

test_that("point evaluation works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_equal(get_private(instance)$.eval_point(list(x1 = 1, x2 = 0)), list(y = 1))
})

test_that("queue evaluation ignores points queued for another compute profile", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  instance$archive$push_point(list(x1 = 1, x2 = 0))
  instance$archive$push_point(list(x1 = 0, x2 = 1), profile = "gpu")

  # the worker runs on the default compute profile and must not wait for the point queued for the "gpu" profile
  get_private(instance)$.eval_queue()

  expect_equal(instance$archive$n_finished, 1L)
  expect_equal(instance$archive$n_queued, 1L)
  expect_equal(instance$archive$n_queued_available, 0L)
})

test_that("reconnect method works", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  file = tempfile(fileext = ".rds")
  suppressWarnings(saveRDS(instance, file = file))
  instance = readRDS(file)

  instance$reconnect()

  expect_r6(instance, "OptimInstanceAsyncSingleCrit")
})

test_that("tiny logging works", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  old_opts = options(bbotk.tiny_logging = TRUE)
  on.exit(options(old_opts))

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  expect_data_table(optimizer$optimize(instance))
})

test_that("an objective error fails the point instead of the worker", {
  rush = start_rush_worker()
  on.exit(rush$reset())

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      if (xs$x1 > 0.5) stop("objective failed")
      list(y = xs$x1 + xs$x2)
    },
    domain = PS_2D_domain,
    properties = "single-crit"
  )

  instance = oi_async(
    objective = objective,
    search_space = ps(x1 = p_dbl(0, 1), x2 = p_dbl(0, 1)),
    terminator = trm("evals", n_evals = 10L),
    rush = rush
  )

  expect_null(get_private(instance)$.eval_point(list(x1 = 0.9, x2 = 0.1)))
  expect_equal(instance$archive$n_failed, 1L)
  expect_equal(instance$archive$n_finished, 0L)

  expect_equal(get_private(instance)$.eval_point(list(x1 = 0.1, x2 = 0.2)), list(y = 0.3))
  expect_equal(instance$archive$n_failed, 1L)
  expect_equal(instance$archive$n_finished, 1L)
})

test_that("an objective error fails a queued point instead of the worker", {
  rush = start_rush_worker()
  on.exit(rush$reset())

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      if (xs$x1 > 0.5) stop("objective failed")
      list(y = xs$x1 + xs$x2)
    },
    domain = PS_2D_domain,
    properties = "single-crit"
  )

  instance = oi_async(
    objective = objective,
    search_space = ps(x1 = p_dbl(0, 1), x2 = p_dbl(0, 1)),
    terminator = trm("evals", n_evals = 10L),
    rush = rush
  )
  instance$archive$push_points(list(list(x1 = 0.9, x2 = 0.1), list(x1 = 0.1, x2 = 0.2)))

  get_private(instance)$.eval_queue()

  expect_equal(instance$archive$n_failed, 1L)
  expect_equal(instance$archive$n_finished, 1L)
})
