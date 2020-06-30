context("OptimizerNLoptr")

test_that("OptimizerNLoptr", {
  param_set = list(x0 = 1)
  z = test_optimizer(OptimizerNLoptr$new(), param_set, n_dim = 1,
                     term_evals = 100L, real_evals = NA)
  expect_class(z$optimizer, "OptimizerNLoptr")
  expect_output(print(z$optimizer), "OptimizerNLoptr")
})
