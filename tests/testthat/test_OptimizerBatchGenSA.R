test_that("OptimizerBatchGenSA", {
  skip_if_not_installed("GenSA")

  z = test_optimizer_1d("gensa", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchGenSA")
  expect_snapshot(z$optimizer)

  expect_error(test_optimizer_2d("gensa", term_evals = 10L), "multi-crit objectives")
})
