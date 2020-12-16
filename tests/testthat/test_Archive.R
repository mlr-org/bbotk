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
  expect_equal(a$data$x_domain, xss_trafoed)
  a$clear()
  expect_data_table(a$data, nrows = 0)
})

test_that("Archive best works", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  expect_error(a$best(), "No results stored in archive")
  xdt = data.table(x1 = c(0, 0.5), x2 = c(1, 1))
  xss_trafoed = list(list(x1 = c(0, 0.5), x2 = c(1, 1)))
  ydt = data.table(y = c(1, 0.25))
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$best()$y,0.25)

  xdt = data.table(x1 = 1, x2 = 1)
  xss_trafoed = list(list(x1 = 1, x2 = 1))
  ydt = data.table(y = 2)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$best(m = 2)$batch_nr, 2L)

  a = Archive$new(PS_2D, FUN_2D_2D_CODOMAIN)
  xdt = data.table(x1 = c(-1,-1,-1), x2 = c(1, 0, -1))
  xss_trafoed = list(list(x1 = -1, x2 = 1), list(x1 = -1, x2 = 0), list(x1 = -1, x2 = 1))
  ydt = data.table(y1 = c(1, 1, 1), y2 = c(-1, 0, -1))
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$best()$y2, 0)
})

test_that("Archive on 1D problem works", {
  a = Archive$new(PS_1D, FUN_1D_CODOMAIN)
  xdt = data.table(x = 1)
  xss_trafoed = list(list(x = 1))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$n_evals, 1)
  expect_equal(a$data$x_domain, xss_trafoed)
  expect_list(a$data$x_domain[[1]])

  xdt = data.table(x = 2)
  expect_error(a$add_evals(xdt, transpose_list(xdt), ydt), "Element 1 is not")
})

test_that("Unnest columns", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = 0, x2 = 1)
  xss_trafoed = list(list(x1 = 1, x2 = 2))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  a = as.data.table(a)
  expect_true("x_domain_x1" %in% colnames(a))
  expect_true("x_domain_x2" %in% colnames(a))
  expect_equal(a$x_domain_x1, 1)
  expect_equal(a$x_domain_x2, 2)

  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = 0.5, x2 = 2)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt), "Element 1 is not")
})

test_that("NAs in ydt throw an error", {
  a = Archive$new(PS_1D, FUN_1D_CODOMAIN)
  xdt = data.table(x = 1)
  xss_trafoed = list(list(x = 1))
  ydt = data.table(y = NA)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt), "Contains missing values")
})

test_that("start_time is set by Optimizer", {
  inst = MAKE_INST()
  expect_null(inst$archive$start_time)
  optimizer = OptimizerRandomSearch$new()
  time = Sys.time()
  optimizer$optimize(inst)
  expect_equal(inst$archive$start_time, time, tolerance = 0.5)
})

test_that("check_values flag works", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN, check_values = FALSE)
  xdt = data.table(x1 = c(0, 2), x2 = c(1, 1))
  xss_trafoed = list(list(x1 = c(0, 0.5), x2 = c(1, 1)))
  ydt = data.table(y = c(1, 0.25))
  a$add_evals(xdt, xss_trafoed, ydt)

  a = Archive$new(PS_2D, FUN_2D_CODOMAIN, check_values = TRUE)
  xdt = data.table(x1 = c(0, 2), x2 = c(1, 1))
  xss_trafoed = list(list(x1 = c(0, 0.5), x2 = c(1, 1)))
  ydt = data.table(y = c(1, 0.25))
  expect_error(a$add_evals(xdt, xss_trafoed, ydt),
    fixed = "x1: Element 1 is not <= 1.")
})

