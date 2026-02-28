skip_if_not_installed("reticulate")

test_that("OptimizerBatchSmac3", {
  search_space = ps(
    x = p_dbl(lower = -1, upper = 1, default = 0)
  )

  fun = function(xs) {
    list(y = as.numeric(xs)^2)
  }

  objective = ObjectiveRFun$new(
    fun = fun,
    domain = search_space,
    properties = "single-crit"
  )

  terminator = trm("evals", n_evals = 5L)
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = terminator
  )

  optimizer = opt("smac")
  expect_class(optimizer, "OptimizerBatchSmac3")

  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 5L)
  expect_equal(instance$archive$n_evals, 5L)

  x_opt = instance$result_x_domain
  y_opt = instance$result_y
  expect_list(x_opt, len = 1)
  expect_named(x_opt, "x")
  expect_numeric(y_opt, len = 1)
  expect_named(y_opt, "y")
})

test_that("OptimizerBatchSmac3 with 2d search space", {
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1, default = 0),
    x2 = p_dbl(lower = -1, upper = 1, default = 0)
  )

  fun = function(xs) {
    list(y = sum(as.numeric(xs)^2))
  }

  objective = ObjectiveRFun$new(
    fun = fun,
    domain = search_space,
    properties = "single-crit"
  )

  terminator = trm("evals", n_evals = 10L)
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = terminator
  )

  optimizer = opt("smac", n_init = 5L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 10L)
  expect_equal(instance$archive$n_evals, 10L)
})

test_that("OptimizerBatchSmac3 with mixed parameter types", {
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1, default = 0),
    x2 = p_int(lower = 1L, upper = 10L, default = 5L),
    x3 = p_fct(levels = c("a", "b", "c"), default = "a"),
    x4 = p_lgl(default = TRUE)
  )

  fun = function(xs) {
    y = xs$x1^2 + xs$x2 / 10
    if (xs$x3 == "a") y = y + 1
    if (xs$x4) y = y + 0.5
    list(y = y)
  }

  objective = ObjectiveRFun$new(
    fun = fun,
    domain = search_space,
    properties = "single-crit"
  )

  terminator = trm("evals", n_evals = 10L)
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = terminator
  )

  optimizer = opt("smac", n_init = 5L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 10L)
  expect_equal(instance$archive$n_evals, 10L)
})

test_that("OptimizerBatchSmac3 with dependencies", {
  search_space = ps(
    x1 = p_fct(levels = c("a", "b"), default = "a"),
    x2 = p_dbl(lower = -1, upper = 1, default = 0, depends = x1 == "a")
  )

  fun = function(xs) {
    y = if (xs$x1 == "a") xs$x2^2 else 1
    list(y = y)
  }

  objective = ObjectiveRFun$new(
    fun = fun,
    domain = search_space,
    properties = "single-crit"
  )

  terminator = trm("evals", n_evals = 10L)
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = terminator
  )

  optimizer = opt("smac", n_init = 5L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, min.rows = 10L)
})
