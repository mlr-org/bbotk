context("Objective")

test_that("Objective Single-Objective", {
  obj = OBJ_2D(2L)
  expect_equal(obj$xdim, 2)
  expect_equal(obj$ydim, 1)
  expect_equal(obj$minimize, c(y1 = TRUE))
  obj$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  expect_equal(obj$archive$n_evals, 1L)
  a = obj$archive
  #FIXME: maybe this should be tested in the test_archive?
  expect_data_table(a$data,
    nrows = 1L,
    types = c("numeric", "numeric", "numeric", "list", "integer", "integer"),
    any.missing = FALSE
  )
  expect_names(colnames(a$data), permutation.of = c("batch_nr", "x1", "x2", "y1", "opt_x", "timestamp"))

  obj$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  expect_equal(obj$archive$n_evals, 3L)
  expect_error(obj$eval_batch(xdt = data.table(x1 = 1, x2 = 1)),
    class = "terminated_error")
})

test_that("Objective with Trafo", {
  obj = OBJ_2D_TRF(2L)
  # FIXME: Decide how to handle trafos
  # ev$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  # expect_equal(ev$archive$n_evals, 1L)
  # ev$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  # expect_equal(ev$archive$n_evals, 3L)
  # expect_error(ev$eval_batch(xdt = data.table(x1 = 1, x2 = 1)), class = "terminated_error")
})

test_that("Objective Multi-objective", {
  obj = OBJ_2D_2D(2L)
  obj$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  expect_equal(obj$archive$n_evals, 1L)
  obj$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  expect_equal(obj$archive$n_evals, 3L)
  #FIXME: add more tests regarding the y-output
  expect_error(obj$eval_batch(xdt = data.table(x1 = 1, x2 = 1)),
    class = "terminated_error")
})

