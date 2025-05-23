test_that("OptimizerBatchNLoptr", {
  skip_on_os("windows")
  skip_if_not_installed("nloptr")

  z = test_optimizer_1d("nloptr", algorithm = "NLOPT_LN_BOBYQA",
    xtol_rel = -1, xtol_abs = -1, ftol_rel = -1, ftol_abs = -1,
    term_evals = 5L)
  expect_class(z$optimizer, "OptimizerBatchNLoptr")
  expect_snapshot(z$optimizer)

  z = test_optimizer_1d("nloptr", algorithm = "NLOPT_LD_LBFGS", approximate_eval_grad_f = TRUE,
    xtol_rel = -1, xtol_abs = -1, ftol_rel = -1, ftol_abs = -1, term_evals = 5L)
  expect_class(z$optimizer, "OptimizerBatchNLoptr")
  expect_snapshot(z$optimizer)
})
