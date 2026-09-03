skip_if_not_installed("rush")
skip_if_no_redis()

test_that("OptimizerAsync starts workers", {
  rush = start_rush(n_workers = 1)
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

  expect_data_table(instance$rush$worker_info, nrows = 1)
  expect_list(instance$rush$processes_mirai, len = 1)
})

test_that("OptimizerAsync assigns result", {
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

  expect_data_table(instance$result, nrows = 1)
})

test_that("OptimizerAsync throws an error when all workers are lost", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      stop("Error")
    },
    domain = PS_2D_domain,
    properties = "single-crit"
  )

  instance = oi_async(
    objective = objective,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )
  optimizer = opt("async_random_search")

  expect_error(optimizer$optimize(instance), "Optimization terminated without any finished evaluations")
})

test_that("restarting the optimization works", {
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

  expect_data_table(instance$archive$data, min.rows = 5L)

  Sys.sleep(1)

  instance$terminator$param_set$values$n_evals = 30L

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 30L)
})

test_that("Queued tasks are failed when optimization is terminated", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("run_time", secs = 1),
    rush = rush
  )

  optimizer = opt("async_design_points", design = data.table(x1 = runif(5000L), x2 = runif(5000L)))
  optimizer$optimize(instance)

  expect_true(instance$rush$n_failed_tasks > 0L)
  expect_data_table(instance$archive$data[list("failed"), on = "state"], min.rows = 1L)
})

test_that("Required packages are loaded", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      if ("irace" %in% loadedNamespaces()) {
        list(y = 1)
      } else {
        stop("irace is not loaded")
      }
    },
    domain = PS_2D_domain,
    properties = "single-crit"
  )

  instance = oi_async(
    objective = objective,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  expect_error(optimizer$optimize(instance), "Optimization terminated without any finished evaluations")
  Sys.sleep(1)
  if (packageVersion("rush") >= "1.1.0.9001") {
    expect_match(instance$rush$fetch_failed_tasks()$condition[[1]]$message, "irace is not loaded")
  } else {
    expect_match(instance$rush$fetch_failed_tasks()$message, "irace is not loaded")
  }

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      if ("irace" %in% loadedNamespaces()) {
        list(y = 1)
      } else {
        stop("irace is not loaded")
      }
    },
    domain = PS_2D_domain,
    properties = "single-crit",
    packages = "irace"
  )

  instance = oi_async(
    objective = objective,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_set_equal(instance$archive$data[list("finished"), on = "state"]$y, 1)
})

test_that("OptimizerAsync starts workers on compute profiles", {
  profiles = c(cpu = 2, gpu = 1)
  rush = start_rush_profiles(profiles)
  on.exit({
    rush$reset()
    stop_rush_profiles(profiles)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  worker_info = instance$rush$worker_info
  expect_data_table(worker_info, nrows = 3)
  expect_set_equal(worker_info$profile, c("cpu", "cpu", "gpu"))
  expect_data_table(instance$result, nrows = 1)
})

test_that("OptimizerAsync errors when n_workers and profiles are combined", {
  rush = start_rush(n_workers = 1)
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

  expect_error(
    optimize_async_default(instance, opt("async_random_search"), n_workers = 1, profiles = c(cpu = 1)),
    "cannot be used at the same time"
  )
})

test_that("OptimizerAsync errors on compute profiles with a non-mirai worker type", {
  profiles = c(cpu = 1)
  rush = start_rush_profiles(profiles)
  on.exit({
    rush$reset()
    stop_rush_profiles(profiles)
  })
  rush::rush_plan(profiles = profiles, worker_type = "script")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_error(
    optimize_async_default(instance, opt("async_random_search")),
    "only supported by the 'mirai' worker type"
  )
})

test_that("OptimizerAsync passes the compute profile to the optimizer", {
  profiles = c(cpu = 1, gpu = 1)
  rush = start_rush_profiles(profiles)
  on.exit({
    rush$reset()
    stop_rush_profiles(profiles)
  })

  # records the profile of the worker that evaluated the point
  OptimizerAsyncProfile = R6Class("OptimizerAsyncProfile",
    inherit = OptimizerAsyncRandomSearch,
    private = list(
      .optimize = function(inst) {
        search_space = inst$search_space
        while (!inst$is_terminated) {
          # the workers only load bbotk, so the functions of other packages must be qualified
          xs = mlr3misc::transpose_list(paradox::generate_design_random(search_space, 1L)$data)[[1L]]
          xs[[".profile"]] = inst$rush$profile
          mlr3misc::get_private(inst)$.eval_point(xs)
        }
      }
    )
  )

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush
  )

  OptimizerAsyncProfile$new()$optimize(instance)

  expect_subset(instance$archive$data$.profile, c("cpu", "gpu", NA))
  expect_true(all(c("cpu", "gpu") %in% instance$archive$data$.profile))
})

test_that("debug mode terminates when the design is exhausted", {
  rush = start_rush(n_workers = 1)
  on.exit({
    rush$reset()
    mirai::daemons(0)
    options(bbotk.debug = FALSE)
  })
  options(bbotk.debug = TRUE)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 20L),
    rush = rush
  )

  optimizer = opt("async_design_points", design = data.table(x1 = c(0, 0.5), x2 = c(0, 0.5)))
  optimizer$optimize(instance)

  expect_equal(instance$archive$n_finished, 2L)
  expect_data_table(instance$result, nrows = 1L)
})

test_that("OptimizerAsync checks the properties of the instance", {
  rush = start_rush(n_workers = 1)
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D_domain,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  expect_error(optimizer$optimize(instance), "does not support param types")
})

test_that("OptimizerAsync rejects a batch instance", {
  instance = MAKE_INST_1D(trm("evals", n_evals = 5L))

  optimizer = opt("async_random_search")
  expect_error(optimizer$optimize(instance), "OptimInstanceAsync")
})

test_that("workers are stopped when the optimization errors", {
  rush = start_rush(n_workers = 1)
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      Sys.sleep(10)
      list(y = xs$x1)
    },
    domain = PS_2D_domain,
    properties = "single-crit"
  )

  instance = oi_async(
    objective = objective,
    search_space = PS_2D,
    terminator = trm("run_time", secs = 2),
    rush = rush
  )

  optimizer = opt("async_random_search")
  expect_error(optimizer$optimize(instance), "without any finished evaluations")
  expect_equal(rush$n_running_workers, 0L)
})
