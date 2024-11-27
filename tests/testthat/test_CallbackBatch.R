# stages in $optimize() --------------------------------------------------------

test_that("on_optimization_begin works", {
  callback = callback_batch(id = "test",
    on_optimization_begin = function(callback, context) {
      context$instance$terminator$param_set$values$n_evals = 20
    }
  )

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
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

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$terminator$param_set$values$n_evals, 20)
})

# stages in $eval_batch() ------------------------------------------------------

test_that("on_optimizer_before_eval works", {
  callback = callback_batch(id = "test",
    on_optimizer_before_eval = function(callback, context) {
      set(context$xdt, j = "x", value = 1)
    }
  )

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(unique(instance$archive$data$x), 1)
})

test_that("on_optimizer_after_eval works", {
  callback = callback_batch(id = "test",
    on_optimizer_after_eval = function(callback, context) {
      set(context$instance$archive$data, j = "y", value = 0.5)
    }
  )

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(unique(instance$archive$data$y), 0.5)
})

# stages in $assign_result() in OptimInstanceBatchSingleCrit -------------------

test_that("on_result_begin in OptimInstanceBatchSingleCrit works", {
  callback = callback_batch(id = "test",
    on_result_begin = function(callback, context) {
      context$result_xdt = data.table(x = 1)
      context$result_y = c(y = 2)
    }
  )

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$result$x, 1)
  expect_equal(instance$result$y, 2)
})

test_that("on_result_end in OptimInstanceBatchSingleCrit works", {
  callback = callback_batch(id = "test",
    on_result_end = function(callback, context) {
      context$result$y = 2
    }
  )

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$result$y, 2)
})

test_that("on_result in OptimInstanceBatchSingleCrit works", {
  expect_warning({callback = callback_batch(id = "test",
    on_result = function(callback, context) {
      context$result$y = 2
    }
  )}, "deprecated")

  instance = oi(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$result$y, 2)
})

# stages in $assign_result() in OptimInstanceBatchMultiCrit --------------------

test_that("on_result_begin in OptimInstanceBatchMultiCrit works", {
  callback = callback_batch(id = "test",
    on_result_begin = function(callback, context) {
      context$result_xdt = data.table(x1 = 1, x2 = 1)
      context$result_ydt = data.table(y1 = 2, y2 = 2)
    }
  )

  instance = oi(
    objective = OBJ_2D_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(instance$result$x1, 1)
  expect_equal(instance$result$x2, 1)
  expect_equal(unique(instance$result$y1), 2)
  expect_equal(unique(instance$result$y2), 2)
})

test_that("on_result_end in OptimInstanceBatchMultiCrit works", {
  callback = callback_batch(id = "test",
    on_result_end = function(callback, context) {
      set(context$result, j = "y1", value = 2)
      set(context$result, j = "y2", value = 3)
    }
  )

  instance = oi(
    objective = OBJ_2D_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(unique(instance$result$y1), 2)
  expect_equal(unique(instance$result$y2), 3)
})

test_that("on_result in OptimInstanceBatchMultiCrit works", {
  expect_warning({callback = callback_batch(id = "test",
    on_result = function(callback, context) {
      set(context$result, j = "y1", value = 2)
      set(context$result, j = "y2", value = 3)
    }
  )}, "deprecated")

  instance = oi(
    objective = OBJ_2D_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10),
    callbacks = callback
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_class(instance$objective$context, "ContextBatch")
  expect_equal(unique(instance$result$y1), 2)
  expect_equal(unique(instance$result$y2), 3)
})

