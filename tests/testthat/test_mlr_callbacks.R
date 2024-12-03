test_that("backup batch callback works", {
  on.exit(unlink("./archive.rds"))

  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = clbk("bbotk.backup", path = "./archive.rds"),
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_file_exists("./archive.rds")
  expect_data_table(readRDS("./archive.rds"))
})

test_that("async callback works", {
  skip_if(TRUE) # Does not work in testthat environment
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush::rush_plan(n_workers = 2)

  callback = callback_async("bbotk.test",
    on_worker_begin = function(callback, context) {
      key = context$instance$archive$push_running_point(list(x = 1))
      context$instance$archive$push_result(key, list(y = 1), list(x = 1))
    },

    on_worker_end = function(callback, context) {
      key = context$instance$archive$push_running_point(list(x = 2))
      context$instance$archive$push_result(key, list(y = 2), list(x = 2))
    }
  )

  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback,
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  Sys.sleep(1)

  x = instance$archive$data$x
  expect_equal(head(x, 2), c(1, 1))
  expect_subset(2, tail(x, 2))
})

test_that("async freeze archive callback works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    callbacks = clbk("bbotk.async_freeze_archive"),
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_class(instance$archive, "ArchiveAsyncFrozen")

  frozen_archive = instance$archive
  expect_data_table(frozen_archive$data)
  expect_data_table(frozen_archive$queued_data)
  expect_data_table(frozen_archive$running_data)
  expect_data_table(frozen_archive$finished_data)
  expect_data_table(frozen_archive$failed_data)
  expect_equal(frozen_archive$n_queued, 0L)
  expect_equal(frozen_archive$n_running, 0L)
  expect_gte(frozen_archive$n_finished, 5L)
  expect_equal(frozen_archive$n_failed, 0L)
  expect_gte(frozen_archive$n_evals, 5L)

  expect_data_table(as.data.table(frozen_archive))
})
