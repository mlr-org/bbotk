test_that("OptimizerBatchGridSearch", {
  z = test_optimizer_1d("grid_search", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchGridSearch")
  expect_output(print(z$optimizer), "OptimizerBatchGridSearch")

  z = test_optimizer_2d("grid_search", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchGridSearch")
  expect_output(print(z$optimizer), "OptimizerBatchGridSearch")
})
