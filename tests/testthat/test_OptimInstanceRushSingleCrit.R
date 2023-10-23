test_that("initializing OptimInstanceRushSingleCrit works", {
  skip_on_cran()

  rush = rsh()

  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_r6(instance$archive, "ArchiveRush")
  expect_r6(instance$objective, "Objective")
  expect_r6(instance$search_space, "ParamSet")
  expect_r6(instance$terminator, "Terminator")
  expect_r6(instance$rush, "Rush")
  expect_null(instance$result)

  rush$reset()
})

test_that("starting workers with OptimInstanceRushSingleCrit works", {
  skip_on_cran()

  rush = rsh()
  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  future::plan("cluster", workers = 1L)
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  expect_equal(rush$n_workers, 1L)

  rush$reset()
})

test_that("evaluating points works with OptimInstanceRushSingleCrit", {
  skip_on_cran()

  rush = rsh()
  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  future::plan("cluster", workers = 1L)
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  xdt = data.table(x1 = -1:1, x2 = list(-1, 0, 1))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)

  expect_data_table(instance$archive$data, nrows = 3L)

  rush$reset()
})

test_that("assigning a result works with OptimInstanceRushSingleCrit", {
  skip_on_cran()

  rush = rsh()
  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  future::plan("cluster", workers = 1L)
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  xdt = data.table(x1 = -1:1, x2 = list(-1, 0, 1))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)

  expect_null(instance$result)
  get_private(instance)$.assign_result(xdt = xdt[2, ], y = c(y = -10))
  expect_equal(instance$result, cbind(xdt[2, ], x_domain = list(list(x1 = 0, x2 = 0)), y = -10))

  rush$reset()
})

test_that("OptimInstanceRushSingleCrit works with trafos", {
  skip_on_cran()

  rush = rsh()
  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D_TRF,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  future::plan("cluster", workers = 1L)
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)

  expect_data_table(instance$archive$data, nrows = 3L)
  expect_equal(instance$archive$data$y, c(2, 0, 2))
  expect_equal(instance$archive$data$x_domain[[1]], list(x1 = -1, x2 = -1))

  rush$reset()
})

test_that("OptimInstanceRushSingleCrit works with extra input", {
  skip_on_cran()

  rush = rsh()
  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D_TRF,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  future::plan("cluster", workers = 1L)
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3), extra1 = letters[1:3], extra2 = as.list(LETTERS[1:3]))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)

  expect_data_table(instance$archive$data, nrows = 3L)
  expect_equal(instance$archive$data$y, c(2, 0, 2))
  expect_equal(instance$archive$data$x_domain[[1]], list(x1 = -1, x2 = -1))
  expect_subset(colnames(xdt), colnames(instance$archive$data))

  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3), extra2 = as.list(letters[4:6]), extra3 = list(list(1:3), list(2:4), list(3:5)))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)

  expect_data_table(instance$archive$data, nrows = 6L)
  expect_equal(instance$archive$data$y, c(2, 0, 2, 2, 0, 2))
  expect_equal(instance$archive$data$extra3[1:3], list(NULL, NULL, NULL))
  expect_equal(instance$archive$data$extra1[4:6], rep(NA_character_, 3))

  rush$reset()
})

test_that("OptimInstanceRushSingleCrit works with extra outputs", {
  skip_on_cran()

  fun_extra = function(xs) {
    y = sum(as.numeric(xs)^2)
    res = list(y = y, extra1 = runif(1), extra2 = list(list(a = runif(1), b = Sys.time())))
    if (y > 0.5) { # sometimes add extras
      res$extra3 = -y
    }
    return(res)
  }
  obj_extra = ObjectiveRFun$new(fun = fun_extra, domain = PS_2D, codomain = FUN_2D_CODOMAIN)

  rush = rsh()
  instance = OptimInstanceRushSingleCrit$new(
    objective = obj_extra,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  future::plan("cluster", workers = 1L)
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  xdt = data.table(x1 = c(0.25, 0.5), x2 = c(0.25, 0.5))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)

  expect_equal(xdt[, list(x1, x2)], instance$archive$data[, obj_extra$domain$ids(), with = FALSE])
  expect_numeric(instance$archive$data$extra1, any.missing = FALSE, len = nrow(xdt))
  expect_list(instance$archive$data$extra2, len = nrow(xdt))

  xdt = data.table(x1 = c(0.75, 1), x2 = c(0.75, 1))
  keys = instance$eval_async(xdt)
  rush$await_tasks(keys)
  expect_equal(instance$archive$data$extra3, c(NA, NA, -1.125, -2))

  rush$reset()
})

test_that("clear method of OptimInstanceRushSingleCrit works", {
  skip_on_cran()

  rush = rsh()
  future::plan("cluster", workers = 1L)
  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)
  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 5L)
  instance$clear()
  expect_data_table(instance$archive$data, nrows = 0L)
})

test_that("OptimInstanceRushSingleCrit and the cluster backend works", {
  skip_on_cran()
  skip_on_ci()

  rush = rsh()
  future::plan("cluster", workers = 1L)

  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)
  expect_equal(rush$n_workers, 1L)
  optimizer = opt("random_search")

  expect_data_table(optimizer$optimize(instance), nrows = 1L)
  expect_data_table(as.data.table(instance$archive), nrows = 5L)

  rush$reset()
})

test_that("OptimInstanceRushSingleCrit and the multisession backend works", {
  skip_on_cran()

  rush = rsh()
  future::plan("multisession", workers = 2L)

  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush
  )
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)
  expect_equal(rush$n_workers, 2L)
  optimizer = opt("random_search")

  expect_data_table(optimizer$optimize(instance), nrows = 1L)
  archive = as.data.table(instance$archive)
  expect_data_table(archive, nrows = 10L)
  expect_length(unique(archive$pid), 2L)

  rush$reset()
})

test_that("freezing ArchiveRush after the optimization works", {
  skip_on_cran()

  rush = rsh()
  future::plan("cluster", workers = 1L)

  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush
  )
  instance$start_workers(freeze_archive = TRUE, await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_null(instance$archive$rush)
  expect_data_table(instance$archive$data, min.rows = 10L)

  rush$reset()
})

test_that("timestamps are written to ArchiveRush", {
  skip_on_cran()

  rush = rsh()
  future::plan("cluster", workers = 1L)

  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush
  )
  instance$start_workers(await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  assert_names(names(instance$archive$data), must.include = c("timestamp_xs", "timestamp_ys"))
  expect_true(all(instance$archive$data$timestamp_xs < instance$archive$data$timestamp_ys))

  rush$reset()
})

test_that("saving log messages from the workers works", {
  skip_on_cran()

  rush = rsh()
  future::plan("cluster", workers = 1L)

  instance = OptimInstanceRushSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 3L),
    rush = rush
  )

  instance$start_workers(lgr_thresholds = c(rush = "debug"), await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)
  optimizer = opt("random_search")
  optimizer$optimize(instance)

  log = rush$read_log()
  expect_data_table(log, nrows = 13)
  expect_names(names(log), must.include = c("worker_id", "timestamp", "logger", "msg"))

  rush$reset()
})

test_that("optimizer throws and error when no worker is running", {
  skip_on_cran()

  rush = rsh()
  future::plan("cluster", workers = 1L)

  fun = function(xs) {
    get("attach")(structure(list(), class = "UserDefinedDatabase"))
  }

  obj = ObjectiveRFun$new(fun = fun, domain = PS_2D_domain, properties = "single-crit")

  instance = OptimInstanceRushSingleCrit$new(
    objective = obj,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 1L),
    rush = rush
  )

  optimizer = opt("random_search")
  expect_error(optimizer$optimize(instance), "Cannot start optimization because no workers are running.")

  rush$reset()
})

test_that("detect lost tasks works", {
  skip_on_cran()

  rush = rsh()
  future::plan("cluster", workers = 1L)

  fun = function(xs) {
    get("attach")(structure(list(), class = "UserDefinedDatabase"))
  }
  obj = ObjectiveRFun$new(fun = fun, domain = PS_2D_domain, properties = "single-crit")
  instance = OptimInstanceRushSingleCrit$new(
    objective = obj,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 1L),
    rush = rush,
  )

  instance$start_workers(detect_lost_tasks = TRUE, await_workers = TRUE)
  pids = rush$worker_info$pid
  on.exit({clean_on_exit(pids)}, add = TRUE)
  rush$await_workers(1)

  optimizer = opt("random_search")
  expect_error(optimizer$optimize(instance), "Can't assign result to")

  rush$reset()
})
