test_that("OptimizerAsync starts local workers", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  rush_plan(n_workers = 2)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 50L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 2)
  expect_list(instance$rush$processes_processx, len = 2)

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
  mirai::daemons(0)
})

test_that("OptimizerAsync defaults to local worker", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  rush_plan(n_workers = 2)

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

  rush_plan(n_workers = 2)

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

  rush_plan(n_workers = 2)

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

  expect_error(optimizer$optimize(instance), "All workers have crashed.")

  expect_rush_reset(instance$rush)
})

test_that("restarting the optimization works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()
  library(rush)

  rush_plan(n_workers = 2)

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
})
