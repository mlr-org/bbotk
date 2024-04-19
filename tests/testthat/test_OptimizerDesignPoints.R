test_that("OptimizerBatchDesignPoints", {
  design = data.table(x = c(-1, 0, 1))
  z = test_optimizer_1d("design_points", design = design, term_evals = 10L, real_evals = 3)
  expect_class(z$optimizer, "OptimizerBatchDesignPoints")
  expect_output(print(z$optimizer), "OptimizerBatchDesignPoints")

  design = data.table(x1 = c(-1, 0, 1), x2 = c(-1, 0, 1))
  z = test_optimizer_2d("design_points", design = design, term_evals = 10L, real_evals = 3)
  expect_class(z$optimizer, "OptimizerBatchDesignPoints")
  expect_output(print(z$optimizer), "OptimizerBatchDesignPoints")

  expect_error(test_optimizer_1d("design_points", term_evals = 10L, real_evals = 3),
    "Please set design datatable")

  design = data.table(x1 = c(2), x2 = c(2))
  expect_error(test_optimizer_2d("design_points", design = design, term_evals = 10L, real_evals = 3),
    "<= 1", fixed = TRUE)
})
