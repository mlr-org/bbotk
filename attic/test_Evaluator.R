context("Evaluator")

test_that("Evaluator", {
  a = Archive$new(OBJ_2D)
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2
  ev = Evaluator$new(OBJ_2D, a, term)
  ev$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  expect_equal(ev$archive$n_evals, 1L)
  ev$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  expect_equal(ev$archive$n_evals, 3L)
  expect_error(ev$eval_batch(xdt = data.table(x1 = 1, x2 = 1)),
    class = "terminated_error")
})

test_that("Evaluator Multi-criteria", {
  a = Archive$new(OBJ_2D_2D)
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2
  ev = Evaluator$new(OBJ_2D_2D, a, term)
  ev$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  expect_equal(ev$archive$n_evals, 1L)
  ev$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  expect_equal(ev$archive$n_evals, 3L)
  expect_error(ev$eval_batch(xdt = data.table(x1 = 1, x2 = 1)),
    class = "terminated_error")
})

test_that("Evaluator with Trafo", {
  a = Archive$new(OBJ_2D_TRF)
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2
  ev = Evaluator$new(OBJ_2D_TRF, a, term)
  # FIXME: Decide how to handle trafos
  # ev$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  # expect_equal(ev$archive$n_evals, 1L)
  # ev$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  # expect_equal(ev$archive$n_evals, 3L)
  # expect_error(ev$eval_batch(xdt = data.table(x1 = 1, x2 = 1)), class = "terminated_error")
})


