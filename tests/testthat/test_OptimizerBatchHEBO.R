skip_if_not_installed("reticulate")

test_that("OptimizerBatchHEBO", {
  search_space = ps(x = p_dbl(lower = -1, upper = 1))
  fun = function(xs) list(y = as.numeric(xs)^2)
  objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 5L)
  )
  optimizer = opt("hebo")
  assert_class(optimizer, "OptimizerBatchHEBO")
  optimizer$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 5L)
  expect_equal(instance$archive$n_evals, 5L)
  x_opt = instance$result_x_domain
  y_opt = instance$result_y
  assert_list(x_opt, len = 1L)
  expect_identical(names(x_opt), "x")
  assert_numeric(y_opt, len = 1L)
  expect_identical(names(y_opt), "y")
})

test_that("OptimizerBatchHEBO with 2d search space", {
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
  opt("hebo")$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 8L)
  expect_equal(instance$archive$n_evals, 8L)
})

test_that("OptimizerBatchHEBO with mixed parameter types", {
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_int(lower = 1L, upper = 10L),
    x3 = p_fct(levels = c("a", "b", "c")),
    x4 = p_lgl()
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
  opt("hebo", n_init = 5L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 10L)
  expect_equal(instance$archive$n_evals, 10L)
})

test_that("OptimizerBatchHEBO with RF surrogate", {
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
  opt("hebo", surrogate = "rf", rf_n_estimators = 10L, n_init = 3L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 8L)
  expect_equal(instance$archive$n_evals, 8L)
})

test_that("OptimizerBatchHEBO with GP surrogate", {
  search_space = ps(x = p_dbl(lower = -1, upper = 1))
  fun = function(xs) list(y = as.numeric(xs)^2)
  objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 6L)
  )
  opt("hebo", surrogate = "gp", gp_lr = 0.05, gp_num_epochs = 50L, gp_noise_free = FALSE, n_init = 2L)$optimize(
    instance
  )
  assert_data_table(instance$archive$data, min.rows = 6L)
  expect_equal(instance$archive$n_evals, 6L)
})

test_that("OptimizerBatchHEBO with LCB acquisition function", {
  search_space = ps(x = p_dbl(lower = -1, upper = 1))
  fun = function(xs) list(y = as.numeric(xs)^2)
  objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 6L)
  )
  opt("hebo", acq_function = "lcb", n_suggestions = 1L, n_init = 2L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 6L)
  expect_equal(instance$archive$n_evals, 6L)
})

test_that("OptimizerBatchHEBO with batch suggestions", {
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_dbl(lower = -1, upper = 1)
  )
  fun = function(xs) list(y = sum(as.numeric(xs)^2))
  objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 9L)
  )
  opt("hebo", n_suggestions = 2L, n_init = 3L)$optimize(instance)
  # batches of 2 crossing the terminator boundary may yield 9 or 10 evals
  assert_data_table(instance$archive$data, min.rows = 9L)
})

test_that("OptimizerBatchHEBO with explicit seed", {
  search_space = ps(x = p_dbl(lower = -1, upper = 1))
  fun = function(xs) list(y = as.numeric(xs)^2)
  objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 5L)
  )
  opt("hebo", seed = 42L, n_init = 2L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 5L)
  expect_equal(instance$archive$n_evals, 5L)
})

test_that("OptimizerBatchHEBO with custom n_init", {
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_dbl(lower = -1, upper = 1)
  )
  fun = function(xs) list(y = sum(as.numeric(xs)^2))
  objective = ObjectiveRFun$new(fun = fun, domain = search_space, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 9L)
  )
  opt("hebo", n_init = 6L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 9L)
  expect_equal(instance$archive$n_evals, 9L)
})

test_that("OptimizerBatchHEBO with alternative evolutionary strategy", {
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
  opt("hebo", es = "ga", n_init = 3L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 8L)
  expect_equal(instance$archive$n_evals, 8L)
})

test_that("OptimizerBatchHEBO maximization", {
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
  opt("hebo", n_init = 3L)$optimize(instance)
  assert_data_table(instance$archive$data, min.rows = 8L)
  expect_equal(instance$archive$n_evals, 8L)
})
