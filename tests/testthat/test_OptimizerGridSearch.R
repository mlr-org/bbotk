context("OptimizerGridSearch")

test_that("OptimizerGridSearch", {
  z = test_optimizer("grid_search", n_dim = 1, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerGridSearch")
  expect_output(print(z$optimizer), "OptimizerGridSearch")

  z = test_optimizer("grid_search", n_dim = 2, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerGridSearch")
  expect_output(print(z$optimizer), "OptimizerGridSearch")
})
