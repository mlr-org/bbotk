test_that("call method works", {
  callback = Callback$new(id = "test")
  callback$on_result = function(context) {
    context$result$x = 2
  }
  z = test_optimizer_1d("random_search", term_evals = 10L)
  context = ContextInstance$new(z$instance)

  callback$call("on_result", context)
  expect_equal(z$instance$result$x, 2)
})

test_that("Callback works with OptimInstanceSingleCrit", {
  callback_result = as_callback("test", on_result = function(context) context$result$x = 2)
  instance = OptimInstanceSingleCrit$new(objective = OBJ_1D, search_space = PS_1D, terminator = trm("evals", n_evals = 10), callback = list(callback_result))
  expect_list(instance$callbacks)
  expect_class(instance$callbacks[[1]], "Callback")
  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_equal(instance$result$x, 2)
})

test_that("Callback works with OptimInstanceMultiCrit", {
  callback_result = as_callback("test", on_result = function(context) context$result$x1 = 2)
  instance = OptimInstanceMultiCrit$new(objective = OBJ_2D_2D, search_space = PS_2D, terminator = trm("evals", n_evals = 10), callback = list(callback_result))
  expect_list(instance$callbacks)
  expect_class(instance$callbacks[[1]], "Callback")
  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_equal(instance$result$x1[1], 2)
})

test_that("as_callback function works", {
  expect_class(as_callback("test", on_result = function(context) context), "Callback")
  callback = as_callback("test", on_result = function(context) context)
  expect_function(callback$on_result)
})

test_that("as_callback  function checks for context argument", {
  expect_error(as_callback("test", on_result = function(env) context), "identical")
})

test_that("as_callback  function checks step name", {
  expect_error(as_callback("test", on_eval = function(context) context), "subset")
})
