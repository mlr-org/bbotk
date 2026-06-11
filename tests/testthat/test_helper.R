test_that("is_dominated identifies dominated points", {
  # columns are points: (1, 1) dominates (2, 2)
  ymat = matrix(c(1, 1, 2, 2), nrow = 2)
  expect_equal(is_dominated(ymat), c(FALSE, TRUE))
})

test_that("is_dominated keeps tied (weakly dominated) points as non-dominated", {
  # two identical non-dominated points must both be reported as non-dominated
  ymat = matrix(c(1, 1, 1, 1, 2, 2), nrow = 2)
  expect_equal(is_dominated(ymat), c(FALSE, FALSE, TRUE))
})
