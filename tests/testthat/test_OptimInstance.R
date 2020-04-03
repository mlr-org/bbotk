context("OptimInstance")

ObjectiveTestEval = R6Class("ObjectiveTestEval",
  inherit = Objective,
  public = list(
    eval = FUN_2D
  )
)
obj_test_eval = ObjectiveTestEval$new(domain = PS_2D)

test_that("OptimInstance", {
  terminator = term("evals", n_evals = 20)
  inst = OptimInstance$new(objective = obj_test_eval, param_set = PS_2D, terminator = terminator)
  expect_r6(inst$archive, "Archive")
  expect_data_table(inst$archive$data, nrows = 0L)
  expect_identical(inst$archive$n_evals, 0L)
  expect_identical(inst$archive$n_batch, 0L)
  expect_list(inst$result)

  xdt = data.table(x1=-1:1, x2=list(-1,0,1))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_equal(inst$archive$data$y, c(2,0,2))
  expect_identical(inst$archive$n_evals, 3L)
  expect_identical(inst$archive$n_batch, 1L)
  expect_list(inst$result)
})

test_that("OptimInstance works with trafos", {
  terminator = term("evals", n_evals = 20)
  inst = OptimInstance$new(objective = obj_test_eval, param_set = PS_2D_TRF, terminator = terminator)
  expect_r6(inst$archive, "Archive")
  xdt = data.table(x1=-1:1, x2=list(1,2,3))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_equal(inst$archive$data$y, c(2,0,2))
  expect_equal(inst$archive$data$opt_x[[1]], list(x1 = -1, x2 = -1))
})
