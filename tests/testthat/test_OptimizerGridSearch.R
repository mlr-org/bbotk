test_that("OptimizerGridSearch", {
  z = test_optimizer_1d("grid_search", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerGridSearch")
  expect_output(print(z$optimizer), "OptimizerGridSearch")

  z = test_optimizer_2d("grid_search", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerGridSearch")
  expect_output(print(z$optimizer), "OptimizerGridSearch")
})
