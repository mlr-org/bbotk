context("OptimizerGenSA")

test_that("OptimizerGenSA", {
  z = test_optimizer("gensa", n_dim = 1, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerGenSA")
  expect_output(print(z$optimizer), "OptimizerGenSA")

  expect_error(test_optimizer("gensa", n_dim = 2, term_evals = 10L), "multi-crit objectives")
})
