test_that("OptimizerBatchCmaes", {
  skip_if_not_installed("cmaes")

  search_space = domain = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )

  codomain = ps(y = p_dbl(tags = "maximize"))

  objective_function = function(xs) {
    c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
  }

  objective = ObjectiveRFun$new(
    fun = objective_function,
    domain = domain,
    codomain = codomain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 100L))

  z = test_optimizer(instance, "cmaes", max_fevals = 100L)

  expect_class(z$optimizer, "OptimizerBatchCmaes")
  expect_snapshot(z$optimizer)

  expect_error(test_optimizer_2d("cmaes",  mu = 5, lambda = 5, term_evals = 10L), "multi-crit objectives")

  instance$archive$clear()
  optimizer = opt("cmaes",  mu = 5, lambda = 5, start_values = "custom", start = c(-9.1, 1.3))
  optimizer$optimize(instance)
  # start values are used for the initial mean vector so a deterministic test is not applicable
})

test_that("OptimizerBatchCmaes", {
  skip_if_not_installed("cmaes")

  search_space = domain = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )

  codomain = ps(y = p_dbl(tags = "maximize"))

  objective_function = function(xs) {
    c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
  }

  objective = ObjectiveRFun$new(
    fun = objective_function,
    domain = domain,
    codomain = codomain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 100L))

  z = test_optimizer(instance, "cmaes", max_fevals = 100L, max_restarts = 2L)

  expect_class(z$optimizer, "OptimizerBatchCmaes")
  expect_snapshot(z$optimizer)

  expect_error(test_optimizer_2d("cmaes",  mu = 5, lambda = 5, term_evals = 10L), "multi-crit objectives")

  instance$archive$clear()
  optimizer = opt("cmaes",  mu = 5, lambda = 5, start_values = "custom", start = c(-9.1, 1.3))
  optimizer$optimize(instance)
  # start values are used for the initial mean vector so a deterministic test is not applicable
})
