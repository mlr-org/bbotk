skip_if_not_installed("rush")
skip_if_no_redis()

test_that("OptimizerAsync starts local workers", {
  rush = start_rush(n_workers = 1, worker_type = "local") # FIXME: change to "processx" after rush 1.0.0 is released
  on.exit({
    rush$reset()
    walk(rush$processes_processx, function(p) p$kill())
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 50L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 1)
  expect_list(instance$rush$processes_processx, len = 1)

})

test_that("OptimizerAsync starts remote workers", {
  rush = start_rush(n_worker = 1, worker_type = "remote") # FIXME: change to "mirai" after rush 1.0.0 is released
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
    rush = rush
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
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_set_equal(instance$archive$data[list("finished"), on = "state"]$y, 1)
})
