test_that("OptimizerGenSA", {
  skip_if_not_installed("GenSA")

  z = test_optimizer_1d("gensa", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerGenSA")
  expect_output(print(z$optimizer), "OptimizerGenSA")

  expect_error(test_optimizer_2d("gensa", term_evals = 10L), "multi-crit objectives")
})
