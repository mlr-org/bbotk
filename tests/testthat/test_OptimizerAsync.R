test_that("OptimizerAsync starts local workers", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 50L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 2)
  expect_list(instance$rush$processes_mirai, len = 2)

  expect_rush_reset(instance$rush)
})

test_that("OptimizerAsync starts remote workers", {
  skip_on_cran()
  skip_if_not_installed(c("rush", "mirai"))
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 2)
  expect_list(instance$rush$processes_mirai, len = 2)

  expect_rush_reset(instance$rush)
})

test_that("OptimizerAsync defaults to local worker", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 50L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 2)

  expect_rush_reset(instance$rush)
})

test_that("OptimizerAsync assigns result", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )
  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$result, nrows = 1)

  expect_rush_reset(instance$rush)
})

test_that("OptimizerAsync throws an error when all workers are lost", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

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
  )
  optimizer = opt("async_random_search")

  expect_error(optimizer$optimize(instance), "Optimization terminated without any finished evaluations")

  expect_rush_reset(instance$rush)
})

test_that("restarting the optimization works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 5L)

  Sys.sleep(1)

  instance$terminator$param_set$values$n_evals = 30L

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 30L)
  expect_rush_reset(instance$rush)
})

test_that("Queued tasks are failed when optimization is terminated", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("run_time", secs = 1),
  )

  optimizer = opt("async_design_points", design = data.table(x1 = runif(5000L), x2 = runif(5000L)))
  optimizer$optimize(instance)

  expect_true(instance$rush$n_failed_tasks > 0L)
  expect_data_table(instance$archive$data[list("failed"), on = "state"], min.rows = 1L)
  expect_rush_reset(instance$rush)
})

test_that("Required packages are loaded", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  mirai::daemons(2)
  rush::rush_plan(n_workers = 2, worker_type = "remote")

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      if("irace" %in% loadedNamespaces()) {
        return(list(y = 1))
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
  )

  optimizer = opt("async_random_search")
  expect_error(optimizer$optimize(instance), "Optimization terminated without any finished evaluations")
  Sys.sleep(1)
  expect_match(instance$rush$fetch_failed_tasks()$message, "irace is not loaded")

  objective = ObjectiveRFun$new(
    fun = function(xs) {
      if("irace" %in% loadedNamespaces()) {
        return(list(y = 1))
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
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_set_equal(instance$archive$data$y, 1)
})
