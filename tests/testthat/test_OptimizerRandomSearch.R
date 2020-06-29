context("OptimizerRandomSearch")

test_that("OptimizerRandomSearch", {
  z = test_optimizer(OptimizerRandomSearch$new(), n_dim = 1, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerRandomSearch")
  expect_output(print(z$optimizer), "OptimizerRandomSearch")

  z = test_optimizer(OptimizerRandomSearch$new(), n_dim = 2, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerRandomSearch")
  expect_output(print(z$optimizer), "OptimizerRandomSearch")
})
