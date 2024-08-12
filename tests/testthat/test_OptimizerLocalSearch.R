test_that("OptimizerBatchLocalSearch", {
  z = test_optimizer_1d("local_search", mu = 3L, n_points = 10L, term_evals = 33L)
  expect_class(z$optimizer, "OptimizerBatchLocalSearch")
  expect_snapshot(z$optimizer)
})
