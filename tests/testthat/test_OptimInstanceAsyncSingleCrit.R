test_that("initializing OptimInstanceAsyncSingleCrit works", {
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

  expect_r6(instance$archive, "ArchiveAsync")
  expect_r6(instance$objective, "Objective")
  expect_r6(instance$search_space, "ParamSet")
  expect_r6(instance$terminator, "Terminator")
  expect_r6(instance$rush, "Rush")
  expect_null(instance$result)

  expect_rush_reset(instance$rush)
})

test_that("rush controller can be passed to OptimInstanceAsyncSingleCrit", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush = rush::rsh(network_id = "remote_network")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_class(instance$rush, "Rush")
  expect_equal(instance$rush$network_id, "remote_network")
  expect_rush_reset(instance$rush)
})

test_that("context is initialized correctly", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_r6(instance$objective$context, "ContextAsync")
  expect_rush_reset(instance$rush)
})

test_that("point evaluation works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  # evaluation takes place on the workers
  rush = rush::RushWorker$new("test", remote = FALSE)
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_equal(get_private(instance)$.eval_point(list(x1 = 1, x2 = 0)), list(y = 1))
})

test_that("reconnect method works", {
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

  file = tempfile(fileext = ".rds")
  suppressWarnings(saveRDS(instance, file = file))
  instance = readRDS(file)

  instance$reconnect()

  expect_r6(instance, "OptimInstanceAsyncSingleCrit")
  expect_rush_reset(instance$rush)
})

test_that("tiny logging works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  old_opts = options(bbotk.tiny_logging = TRUE)
  on.exit(options(old_opts))


  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L)
  )

  optimizer = opt("async_random_search")
  expect_snapshot(optimizer$optimize(instance))

  expect_rush_reset(instance$rush)
})
