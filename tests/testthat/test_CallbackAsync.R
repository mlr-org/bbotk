test_that("on_optimization_begin works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  callback = callback_async(id = "test",
    on_optimization_begin = function(callback, context) {
      context$instance$terminator$param_set$values$n_evals = 20
    }
  )

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextAsync")
  expect_equal(instance$terminator$param_set$values$n_evals, 20)
})

test_that("on_worker_begin works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  callback = callback_async(id = "test",
    on_worker_begin = function(callback, context) {
      instance = context$instance
      mlr3misc::get_private(instance)$.eval_point(list(x = 1))
    }
  )

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_subset(1, instance$archive$data$x)
})

test_that("on_worker_end works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  callback = callback_async(id = "test",
    on_worker_end = function(callback, context) {
      instance = context$instance
      mlr3misc::get_private(instance)$.eval_point(list(x = 1))
    }
  )

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_subset(1, instance$archive$data$x)
})

test_that("on_optimizer_before_eval and on_optimizer_after_eval works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  callback = callback_async(id = "test",
    on_optimizer_before_eval = function(callback, context) {
      context$xs = list(x = 1)
      context$xs_trafoed = list(x = 0)
    },

    on_optimizer_after_eval = function(callback, context) {
      context$ys = list(y = 0)
    }
  )

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_equal(unique(instance$archive$data$x), 1)
  expect_equal(unique(instance$archive$data$y), 0)
  expect_equal(unique(unlist(instance$archive$data$x_domain)), 0)
})

test_that("on_result works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  callback = callback_async(id = "test",
    on_result = function(callback, context) {
      context$result = 2
    }
  )

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  expect_equal(instance$result, 2)
})

test_that("on_optimization_end works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  callback = callback_async(id = "test",
    on_optimization_end = function(callback, context) {
      context$instance$terminator$param_set$values$n_evals = 200
    }
  )

  rush::rush_plan(n_workers = 2)
  instance = oi_async(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)
  expect_equal(instance$terminator$param_set$values$n_evals, 200)
})
