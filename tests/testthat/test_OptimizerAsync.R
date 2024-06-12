test_that("OptimizerAsync starts local workers", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush::rush_plan(n_workers = 2)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 2)

  expect_rush_reset(instance$rush)
})

test_that("OptimizerAsync starts remote workers", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush = rsh(network_id = "test_rush")
  expect_snapshot(rush$create_worker_script())

  px = processx::process$new("Rscript",
    args = c("-e", 'rush::start_worker(network_id = "test_rush", remote = TRUE, url = "redis://127.0.0.1:6379", scheme = "redis", host = "127.0.0.1", port = "6379")'),
    supervise = TRUE,
    stderr = "|", stdout = "|")

  on.exit({
    px$kill()
  }, add = TRUE)

  Sys.sleep(5)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$rush$worker_info, nrows = 1)
  expect_true(instance$rush$worker_info$remote)

  expect_rush_reset(instance$rush)
})

test_that("OptimizerAsync assigns result", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush::rush_plan(n_workers = 2)

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

  rush::rush_plan(n_workers = 2)

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
