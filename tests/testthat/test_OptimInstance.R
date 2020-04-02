context("OptimInstance")

test_that("OptimInstance", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    public = list(
      eval = function(xs) list(y = sum(as.numeric(xs))^2)
    )
  )
  obj = ObjectiveTestEval$new(domain = PS_2D)
  terminator = term("evals", n_evals = 20)
  
  inst = OptimInstance$new(objective = obj, param_set = PS_2D, terminator = terminator)
  expect_r6(inst$archive, "Archive")
  expect_data_table(inst$archive$data, nrows = 0L)
  expect_identical(inst$archive$n_evals, 0L)
  expect_identical(inst$archive$n_batch, 0L)
  expect_list(inst$result)

  xdt = data.table(x1=list(1,2,3), x2=list(1,2,3))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_identical(inst$archive$n_evals, 3L)
  expect_identical(inst$archive$n_batch, 1L)
  expect_list(inst$result)
})
