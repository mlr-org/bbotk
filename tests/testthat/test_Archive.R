context("Archive")

test_that("Archive", {
  obj = Objective$new(fun = OBJ_2D, domain = PS_2D)
  a = Archive$new(obj)
  expect_output(print(a), "Archive")
  expect_equal(a$n_evals, 0)
  expect_equal(a$cols_x, c("x1", "x2"))
  expect_equal(a$cols_y, c("y1"))
})


