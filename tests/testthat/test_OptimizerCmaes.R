test_that("OptimizerCmaes", {
  skip_if_not_installed("adagio")

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

  instance = OptimInstanceSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 10))

  z = test_optimizer(instance, "cmaes", real_evals = 10L)

  expect_class(z$optimizer, "OptimizerCmaes")
  expect_output(print(z$optimizer), "OptimizerCmaes")

  expect_error(test_optimizer_2d("cmaes", term_evals = 10L), "multi-crit objectives")
})
