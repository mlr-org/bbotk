skip_if_not_installed("reticulate")
skip_if_not_installed("callr")

test_that("OptimizerBatchSmac3", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    optimizer = opt("smac")
    assert_class(optimizer, "OptimizerBatchSmac3")
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

test_that("OptimizerBatchSmac3 with 2d search space", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1, default = 0),
      x2 = p_dbl(lower = -1, upper = 1, default = 0)
    )
    fun = function(xs) list(y = sum(as.numeric(xs)^2))
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", n_init = 5L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with mixed parameter types", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1, default = 0),
      x2 = p_int(lower = 1L, upper = 10L, default = 5L),
      x3 = p_fct(levels = c("a", "b", "c"), default = "a"),
      x4 = p_lgl(default = TRUE)
    )
    fun = function(xs) {
      y = xs$x1^2 + xs$x2 / 10
      if (xs$x3 == "a") {
        y = y + 1
      }
      if (xs$x4) {
        y = y + 0.5
      }
      list(y = y)
    }
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", n_init = 5L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with dependencies", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(
      x1 = p_fct(levels = c("a", "b"), default = "a"),
      x2 = p_dbl(lower = -1, upper = 1, default = 0, depends = x1 == "a")
    )
    fun = function(xs) {
      y = if (xs$x1 == "a") xs$x2^2 else 1
      list(y = y)
    }
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", n_init = 5L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with HyperparameterOptimizationFacade", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", facade = "smac4hb", n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with AlgorithmConfigurationFacade", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", facade = "smac4ac", n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with RandomFacade", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", facade = "smac4rs", n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with custom surrogate model", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1, default = 0),
      x2 = p_dbl(lower = -1, upper = 1, default = 0)
    )
    fun = function(xs) list(y = sum(as.numeric(xs)^2))
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", facade = "smac4hb", surrogate = "rf", rf.n_trees = 5L, n_init = 5L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with GP surrogate", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", surrogate = "gp", gp.n_restarts = 5L, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with custom acquisition function", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", acq_function = "ei", acq_function.xi = 0.01, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with LCB acquisition function", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", acq_function = "lcb", acq_function.beta = 2.0, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with custom initial design", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(
      x1 = p_dbl(lower = -1, upper = 1, default = 0),
      x2 = p_dbl(lower = -1, upper = 1, default = 0)
    )
    fun = function(xs) list(y = sum(as.numeric(xs)^2))
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    for (design in c("sobol", "random", "lhc", "default")) {
      instance = OptimInstanceBatchSingleCrit$new(
        objective = objective,
        search_space = search_space,
        terminator = trm("evals", n_evals = 10L)
      )
      opt("smac", initial_design = design, n_init = 5L)$optimize(instance)
      assert_data_table(instance$archive$data, min.rows = 10L)
      stopifnot(instance$archive$n_evals == 10L)
    }
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with explicit seed", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 5L)
    )
    opt("smac", seed = 42L, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 5L)
    stopifnot(instance$archive$n_evals == 5L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with deterministic FALSE and max_config_calls", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", deterministic = FALSE, max_config_calls = 2L, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with random design probability", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", random_design = "probability", random_design.probability = 0.2, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})

test_that("OptimizerBatchSmac3 with MultiFidelityFacade", {
  expect_true(callr::r(function() {
    Sys.setenv(RETICULATE_PYTHON = "managed")
    library(bbotk)
    library(paradox)
    library(checkmate)
    search_space = ps(x = p_dbl(lower = -1, upper = 1, default = 0))
    fun = function(xs) list(y = as.numeric(xs)^2)
    objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
    instance = OptimInstanceBatchSingleCrit$new(
      objective = objective,
      search_space = search_space,
      terminator = trm("evals", n_evals = 10L)
    )
    opt("smac", facade = "smac4mf", eta = 3L, min_budget = 1, max_budget = 10, n_init = 3L)$optimize(instance)
    assert_data_table(instance$archive$data, min.rows = 10L)
    stopifnot(instance$archive$n_evals == 10L)
    TRUE
  }))
})
