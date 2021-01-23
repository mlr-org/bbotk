test_that("OptimizerDesignPoints", {
  design = data.table(x = c(-1, 0, 1))
  z = test_optimizer("design_points", design = design, n_dim = 1, term_evals = 10L, real_evals = 3)
  expect_class(z$optimizer, "OptimizerDesignPoints")
  expect_output(print(z$optimizer), "OptimizerDesignPoints")

  design = data.table(x1 = c(-1, 0, 1), x2 = c(-1, 0, 1))
  z = test_optimizer("design_points", design = design, n_dim = 2, term_evals = 10L, real_evals = 3)
  expect_class(z$optimizer, "OptimizerDesignPoints")
  expect_output(print(z$optimizer), "OptimizerDesignPoints")

  expect_error(test_optimizer("design_points", n_dim = 1, term_evals = 10L, real_evals = 3),
    "Please set design datatable")

  design = data.table(x1 = c(2), x2 = c(2))
  expect_error(test_optimizer("design_points", design = design, n_dim = 2, term_evals = 10L, real_evals = 3),
    fixed = "Assertion on 'pv$design' failed: x1: Element 1 is not <= 1")
})
