skip_if_not(has_redis)
skip_if_not_installed("rush")

test_that("initializing OptimInstanceAsyncSingleCrit works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

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
})

test_that("rush controller can be passed to OptimInstanceAsyncSingleCrit", {
  rush = start_rush_worker()
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

  expect_class(instance$rush, "Rush")
})

test_that("context is initialized correctly", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_r6(instance$objective$context, "ContextAsync")
})

test_that("point evaluation works", {
  rush = start_rush_worker()
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

  expect_equal(get_private(instance)$.eval_point(list(x1 = 1, x2 = 0)), list(y = 1))
})

test_that("reconnect method works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

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
})

test_that("tiny logging works", {
  rush = start_rush_worker()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  old_opts = options(bbotk.tiny_logging = TRUE)
  on.exit(options(old_opts))

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L)
  )

  optimizer = opt("async_random_search")
  expect_data_table(optimizer$optimize(instance))
})
