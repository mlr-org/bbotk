context("Evaluator")

test_that("Evaluator", {
  obj = Objective$new(fun = OBJ_2D, domain = PS_2D, minimize = TRUE)
  a = Archive$new(obj$domain, obj$codomain)
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2
  ev = Evaluator$new(obj, a, term)
  ev$eval_batch(xdt = data.table(x1 = 0, x2 = 0))
  expect_equal(ev$archive$n_evals, 1L)
  ev$eval_batch(xdt = data.table(x1 = c(1,2), x2 = c(1,2)))
  expect_equal(ev$archive$n_evals, 3L)
  expect_error(ev$eval_batch(xdt = data.table(x1 = 1, x2 = 1)),
    class = "terminated_error")
})



