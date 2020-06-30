context("OptimizerNLoptr")

test_that("OptimizerNLoptr", {
  param_set = list(x0 = 1, algorithm = "NLOPT_LN_BOBYQA", xtol_rel = -1,
    xtol_abs = -1, ftol_rel = -1, ftol_abs = -1)
  z = test_optimizer(OptimizerNLoptr$new(), param_set, n_dim = 1,
    term_evals = 5L)
  expect_class(z$optimizer, "OptimizerNLoptr")
  expect_output(print(z$optimizer), "OptimizerNLoptr")
})
