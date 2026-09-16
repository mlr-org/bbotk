test_that("OptimizerBatchCmaes", {
  skip_if_not_installed("libcmaesr")

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
    codomain = codomain
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 10L)
  )

  z = test_optimizer(instance, "cmaes", lambda = 5L, real_evals = 10L)

  expect_class(z$optimizer, "OptimizerBatchCmaes")
  # one batch per generation
  expect_equal(instance$archive$n_batch, 2L)
  expect_snapshot(z$optimizer)

  expect_error(test_optimizer_2d("cmaes", term_evals = 10L), "multi-crit objectives")

  instance$archive$clear()
  optimizer = opt("cmaes", start_values = "custom", start = c(-9.1, 1.3))
  optimizer$optimize(instance)
  # start values are used for the initial mean vector so a deterministic test is not applicable
  expect_data_table(instance$archive$data, min.rows = 10L)
})

test_that("OptimizerBatchCmaes finds the optimum", {
  skip_if_not_installed("libcmaesr")

  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 200L)
  )

  set.seed(1)
  opt("cmaes")$optimize(instance)
  expect_equal(unname(instance$result_y), 0, tolerance = 1e-4)
})

test_that("OptimizerBatchCmaes propagates errors of the objective function", {
  skip_if_not_installed("libcmaesr")

  objective = ObjectiveRFun$new(
    fun = function(xs) stop("objective failed"),
    domain = PS_2D,
    properties = "single-crit"
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L)
  )

  expect_error(opt("cmaes")$optimize(instance), "objective failed")
})
