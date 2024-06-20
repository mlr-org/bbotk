test_that("OptimizerBatchRandomSearch", {
  z = test_optimizer_1d("random_search", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchRandomSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_2d("random_search", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchRandomSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_2d("random_search", term_evals = 10L, batch_size = 10)
  expect_class(z$optimizer, "OptimizerBatchRandomSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_dependencies("random_search", term_evals = 10L, batch_size = 1)

  z = test_optimizer_dependencies("random_search", term_evals = 10L, batch_size = 10L)
})
