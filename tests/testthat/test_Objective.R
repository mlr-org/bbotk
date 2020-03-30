context("Objective")

test_that("Objective", {
  obj = Objective$new(fun = OBJ_2D, domain = PS_2D)
  expect_equal(obj$xdim, 2)
  expect_equal(obj$ydim, 1)
  expect_equal(obj$minimize, c(y1 = TRUE))
})
