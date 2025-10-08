test_that("OptimizerBatchCmaes", {
  skip_if_not_installed("libcmaesr")

  z = test_optimizer_1d("cmaes", term_evals = 100L)
  expect_class(z$optimizer, "OptimizerBatchCmaes")
  expect_snapshot(z$optimizer)
})

