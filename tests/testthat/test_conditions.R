test_that("error_bbotk works", {
  cond = error_bbotk("test error %s", "msg", signal = FALSE)
  expect_class(cond, "Mlr3ErrorBbotk")
  expect_class(cond, "Mlr3Error")
  expect_class(cond, "error")
  expect_class(cond, "condition")
  expect_equal(cond$raw_message, "test error msg")

  expect_error(error_bbotk("test error"), class = "Mlr3ErrorBbotk")
  expect_error(error_bbotk("test error"), class = "Mlr3Error")
})

test_that("error_bbotk_terminated works", {
  cond = error_bbotk_terminated("terminated %s", "msg", signal = FALSE)
  expect_class(cond, "Mlr3ErrorBbotkTerminated")
  expect_class(cond, "Mlr3ErrorBbotk")
  expect_class(cond, "Mlr3Error")
  expect_class(cond, "error")
  expect_class(cond, "condition")
  expect_equal(cond$raw_message, "terminated msg")

  expect_error(error_bbotk_terminated("terminated"), class = "Mlr3ErrorBbotkTerminated")
  expect_error(error_bbotk_terminated("terminated"), class = "Mlr3ErrorBbotk")
})

test_that("error_bbotk with parent condition", {
  parent = simpleError("parent error")
  cond = error_bbotk("child error", signal = FALSE, parent = parent)
  expect_class(cond, "Mlr3ErrorBbotk")
  expect_identical(cond$parent, parent)
})

test_that("error_bbotk with additional classes", {
  cond = error_bbotk("test", class = "CustomClass", signal = FALSE)
  expect_class(cond, "CustomClass")
  expect_class(cond, "Mlr3ErrorBbotk")
  expect_class(cond, "Mlr3Error")
})

test_that("terminated_error uses Mlr3ErrorBbotkTerminated", {
  inst = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 1L)
  )
  expect_error(terminated_error(inst), class = "Mlr3ErrorBbotkTerminated")
  expect_error(terminated_error(inst), class = "Mlr3ErrorBbotk")
  expect_error(terminated_error(inst), class = "Mlr3Error")
})

test_that("terminated_error is caught by OptimizerBatch", {
  inst = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 2L)
  )
  optimizer = opt("random_search")
  # should not throw - terminated_error is caught internally
  result = optimizer$optimize(inst)
  expect_data_table(result)
})
