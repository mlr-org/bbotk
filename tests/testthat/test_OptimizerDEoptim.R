test_that("OptimizerBatchDEoptim", {
  skip_if_not_installed("DEoptim")

  z = test_optimizer_1d("deoptim", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchDEoptim")
  expect_snapshot(z$optimizer)
})
