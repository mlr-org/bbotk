test_that("TerminatorStagnationHypervolume works", {
  skip_if_not_installed("emoa")

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

test_that("TerminatorStagnationHypervolume errors with direction=0 (learn tag)", {

  terminator = trm("stagnation_hypervolume")
  terminator$param_set$values$iters = 1
  codomain = ps(y1 = p_dbl(tags = "learn"), y2 = p_dbl(tags = "minimize"))
  archive = ArchiveBatch$new(PS_2D, codomain)

  # add some evaluations
  xdt = data.table(x1 = c(0.5, 0.3), x2 = c(0.5, 0.3))
  xss_trafoed = list(list(x1 = 0.5, x2 = 0.5), list(x1 = 0.3, x2 = 0.3))
  ydt = data.table(y1 = c(0.25, 0.09), y2 = c(0.5, 0.3))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_error(terminator$is_terminated(archive), "direction != 0")
})
