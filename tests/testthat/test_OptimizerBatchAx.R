skip_if_not_installed("reticulate")
skip_if_not_installed("callr")

test_that("OptimizerBatchAx", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(x = p_dbl(lower = -1, upper = 1))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    optimizer = opt("ax")
    assert_class(optimizer, "OptimizerBatchAx")
    optimizer$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    x_opt = instance$result_x_domain
    y_opt = instance$result_y
    assert_list(x_opt, len = 1L)
    stopifnot(identical(names(x_opt), "x"))
    assert_numeric(y_opt, len = 1L)
    stopifnot(identical(names(y_opt), "y"))
    TRUE
  }))
})

test_that("OptimizerBatchAx with 2d search space", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1),
      x2 = p_dbl(lower = -1, upper = 1)
    )
    fun = function(xs) list(y = sum(as.numeric(xs)^2))
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 8L)
    )
    opt("ax")$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 8L)
    stopifnot(instance$archive$n_evals == 8L)
    TRUE
  }))
})

test_that("OptimizerBatchAx with mixed parameter types", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1),
      x2 = p_int(lower = 1L, upper = 10L),
      x3 = p_fct(levels = c("a", "b", "c")),
      x4 = p_lgl()
    )
    fun = function(xs) {
      y = xs$x1^2 + xs$x2 / 10
      if (xs$x3 == "a") y = y + 1
      if (xs$x4) y = y + 0.5
      list(y = y)
    }
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("ax", n_sobol = 8L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchAx multi-crit", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1),
      x2 = p_dbl(lower = -1, upper = 1)
    )
    fun = function(xs) list(y1 = xs$x1^2, y2 = xs$x2^2)
    codomain = ps(y1 = p_dbl(tags = "minimize"), y2 = p_dbl(tags = "minimize"))
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, codomain = codomain, properties = "multi-crit")
    instance = OptimInstanceBatchMultiCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("ax", n_sobol = 8L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchAx with explicit seed", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(x = p_dbl(lower = -1, upper = 1))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("ax", seed = 42L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchAx with n_sobol", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1),
      x2 = p_dbl(lower = -1, upper = 1)
    )
    fun = function(xs) list(y = sum(as.numeric(xs)^2))
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("ax", n_sobol = 5L, seed = 1L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchAx maximization", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = reticulate::virtualenv_python("r-ax"))
    library(checkmate)
    library(bbotk)
    library(paradox)
    search_space = ps(
      x1 = p_dbl(lower = -5, upper = 5),
      x2 = p_dbl(lower = -5, upper = 5)
    )
    fun = function(xs) list(y = -(xs$x1^2 + xs$x2^2))
    codomain = ps(y = p_dbl(tags = "maximize"))
    objective = ObjectiveRFun$new(
      fun = fun,
      domain = search_space,
      codomain = codomain,
      properties = "single-crit"
    )
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 8L)
    )
    opt("ax")$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 8L)
    stopifnot(instance$archive$n_evals == 8L)
    TRUE
  }))
})
