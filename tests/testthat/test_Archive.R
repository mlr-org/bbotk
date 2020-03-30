context("Archive")

test_that("Archive", {
  a = Archive$new(OBJ_2D)
  expect_output(print(a), "Archive")
  expect_equal(a$n_evals, 0)
  expect_equal(a$cols_x, c("x1", "x2"))
  expect_equal(a$cols_y, c("y1"))
})
