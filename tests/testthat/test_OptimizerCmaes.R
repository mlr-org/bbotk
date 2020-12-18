context("OptimizerCmaes")

test_that("OptimizerCmaes", {
  z = test_optimizer("cmaes", n_dim = 1, term_evals = 2L)
  expect_class(z$optimizer, "OptimizerCmaes")
  expect_output(print(z$optimizer), "OptimizerCmaes")

  expect_error(test_optimizer("cmaes", n_dim = 2, term_evals = 10L), "multi-crit objectives")
})
