context("Archive")

test_that("Archive", {
  ps2 = ParamSet$new(list(ParamDbl$new("y")))

  a = Archive$new(PS_2D, ps2)
  expect_output(print(a), "Archive")
  expect_equal(a$n_evals, 0)
  expect_equal(a$cols_x, c("x1", "x2"))
  expect_equal(a$cols_y, c("y"))
})
