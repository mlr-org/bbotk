context("OptimizerNLoptr")

test_that("OptimizerNLoptr", {
  skip_on_os("windows")
  z = test_optimizer("nloptr", algorithm = "NLOPT_LN_BOBYQA",
    xtol_rel = -1, xtol_abs = -1, ftol_rel = -1, ftol_abs = -1, n_dim = 1,
    term_evals = 5L)
  expect_class(z$optimizer, "OptimizerNLoptr")
  expect_output(print(z$optimizer), "OptimizerNLoptr")
})
