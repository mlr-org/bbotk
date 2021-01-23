test_that("TerminatorStagnationBatch works with single objective and n = 1", {
  terminator = TerminatorStagnationBatch$new()
  terminator$param_set$values$n = 1
  terminator$param_set$values$threshold = 0
  expect_output(print(terminator), "TerminatorStagnationBatch")
  inst = MAKE_INST_2D(terminator)
  inst$archive
  inst$eval_batch(xdt = data.table(x1 = 1, x2 = 1))
  inst$eval_batch(xdt = data.table(x1 = 0.8, x2 = 0.8))
  inst$eval_batch(xdt = data.table(x1 = 0.9, x2 = 0.9))
  # Arbitrary points since termination is checked before evalaluation
  expect_error(inst$eval_batch(xdt = data.table(x1 = 0, x2 = 0)))
})

test_that("TerminatorStagnationBatch works with single objective and n = 2", {
  terminator = TerminatorStagnationBatch$new()
  terminator$param_set$values$n = 2
  terminator$param_set$values$threshold = 0
  expect_output(print(terminator), "TerminatorStagnationBatch")
  inst = MAKE_INST_2D(terminator)
  inst$archive
  inst$eval_batch(xdt = data.table(x1 = 1, x2 = 1))
  inst$eval_batch(xdt = data.table(x1 = 0.8, x2 = 0.8))
  inst$eval_batch(xdt = data.table(x1 = 0.9, x2 = 0.9))
  # Expect no termination since n = 2
  inst$eval_batch(xdt = data.table(x1 = 0.7, x2 = 0.7))
  inst$eval_batch(xdt = data.table(x1 = 0.7, x2 = 0.7))
  inst$eval_batch(xdt = data.table(x1 = 0.7, x2 = 0.7))
  # Arbitrary points since termination is checked before evalaluation
  expect_error(inst$eval_batch(xdt = data.table(x1 = 0, x2 = 0)))
})

test_that("TerminatorStagnationBatch in OptimInstanceMultiCrit throws an error", {
  terminator = TerminatorStagnationBatch$new()
  expect_error(MAKE_INST_2D_2D(terminator))
})
