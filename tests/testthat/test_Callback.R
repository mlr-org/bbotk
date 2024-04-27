test_that("on_optimization_begin works", {
  callback = callback_batch(id = "test",
    on_optimization_begin = function(callback, context) {
      context$instance$terminator$param_set$values$n_evals = 20
    }
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$terminator$param_set$values$n_evals, 20)
})

test_that("on_optimization_end works", {
  callback = callback_batch(id = "test",
    on_optimization_end = function(callback, context) {
      context$instance$terminator$param_set$values$n_evals = 20
    }
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$terminator$param_set$values$n_evals, 10)
})

test_that("on_result in OptimInstanceBatchSingleCrit works", {
  callback = callback_batch(id = "test",
    on_result = function(callback, context) {
      context$result$y = 2
    }
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$result$y, 2)
})

test_that("on_result in OptimInstanceBatchMultiCrit works", {
  callback = callback_batch(id = "test",
    on_result = function(callback, context) {
      context$result$y1 = 2
      context$result$y2 = 2
    }
  )

  instance = OptimInstanceBatchMultiCrit$new(
    objective = OBJ_2D_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10),
    callbacks = list(callback)
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_equal(unique(instance$result$y1), 2)
  expect_equal(unique(instance$result$y2), 2)
})
