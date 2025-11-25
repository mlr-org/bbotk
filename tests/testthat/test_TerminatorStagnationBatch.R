test_that("TerminatorStagnationBatch works with single objective and n = 1", {
  terminator = TerminatorStagnationBatch$new()
  terminator$param_set$values$n = 1
  terminator$param_set$values$threshold = 0
  expect_snapshot(terminator)
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
  expect_snapshot(terminator)
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

test_that("TerminatorStagnationBatch in OptimInstanceBatchMultiCrit throws an error", {
  terminator = TerminatorStagnationBatch$new()
  expect_error(MAKE_INST_2D_2D(terminator))
})

test_that("TerminatorStagnationBatch works with empty archive", {
  terminator = TerminatorStagnationBatch$new()
  archive = ArchiveBatch$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})

test_that("man exists", {
  terminator = trm("stagnation_batch")
  expect_man_exists(terminator$man)
})

test_that("TerminatorStagnationBatch errors with direction=0 (learn tag)", {
  terminator = TerminatorStagnationBatch$new()
  codomain = ps(y = p_dbl(tags = "learn"))
  archive = ArchiveBatch$new(ps(x = p_dbl()), codomain)

  # add some evaluations across multiple batches
  xdt = data.table(x = 0.5)
  xss_trafoed = list(list(x = 0.5))
  ydt = data.table(y = 0.25)
  archive$add_evals(xdt, xss_trafoed, ydt)

  xdt = data.table(x = 0.3)
  xss_trafoed = list(list(x = 0.3))
  ydt = data.table(y = 0.09)
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_error(terminator$is_terminated(archive), "direction != 0")
})
