context("Archive")

test_that("Archive", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  expect_output(print(a), "Archive")
  expect_equal(a$n_evals, 0)
  expect_equal(a$cols_x, c("x1", "x2"))
  expect_equal(a$cols_y, c("y"))
  xdt = data.table(x1 = 0, x2 = 1)
  xss_trafoed = list(list(x1 = 0, x2 = 1))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$n_evals, 1)
  expect_equal(a$data()$opt_x, xss_trafoed)
  # FIXME: a$get_best(), a$clear()
})

test_that("Archive on 1D problem works", {
  a = Archive$new(PS_1D, FUN_1D_CODOMAIN)
  xdt = data.table(x = 1)
  xss_trafoed = list(list(x = 1))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$n_evals, 1)
  expect_equal(a$data()$opt_x, xss_trafoed)
  expect_list(a$data()$opt_x[[1]])

  xdt = data.table(x = 2)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt))
})

test_that("Unnest columns", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = 0, x2 = 1)
  xss_trafoed = list(list(x1 = 1, x2 = 2))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  a = a$data(unnest = "opt_x")
  expect_true("opt_x_x1" %in% colnames(a))
  expect_true("opt_x_x2" %in% colnames(a))
  expect_equal(a$opt_x_x1, 1)
  expect_equal(a$opt_x_x2, 2)

  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = 0.5, x2 = 2)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt))
})

test_that("NAs in ydt throw an error", {
  a = Archive$new(PS_1D, FUN_1D_CODOMAIN)
  xdt = data.table(x = 1)
  xss_trafoed = list(list(x = 1))
  ydt = data.table(y = NA)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt))
})

