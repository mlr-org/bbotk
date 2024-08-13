test_that("TerminatorStagnationHypervolume works", {
  terminator = trm("stagnation_hypervolume")
  terminator$param_set$values$iters = 5
  terminator$param_set$values$threshold = 0

  inst = MAKE_INST_2D_2D(terminator)

  xdt = data.table(x1 = seq(0.1, 0.5, by = 0.1), x2 = seq(0.1, 0.5, by = 0.1))
  inst$eval_batch(xdt = xdt)
  expect_false(inst$terminator$is_terminated(inst$archive))

  xdt = data.table(x1 = 0.6, x2 = 0.6)
  inst$eval_batch(xdt = xdt)
  expect_false(inst$terminator$is_terminated(inst$archive))

  xdt = data.table(x1 = rep(0.7, 6), x2 = rep(0.7, 6))
  inst$eval_batch(xdt = xdt)
  expect_true(inst$terminator$is_terminated(inst$archive))
})


