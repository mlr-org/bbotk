skip_if_not_installed("moocore")

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

test_that("TerminatorStagnationHypervolume works with ArchiveAsync", {
  skip_if_not_installed("rush")
  skip_if_no_redis()
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  terminator = trm("stagnation_hypervolume", iters = 1L)
  instance = oi_async(objective = OBJ_2D_2D, search_space = PS_2D, terminator = terminator, rush = rush)
  archive = instance$archive

  archive$push_finished_points(xss = list(list(x1 = 0, x2 = 0)), yss = list(list(y1 = 2, y2 = 2)))
  archive$push_points(list(list(x1 = 1, x2 = 1), list(x1 = 1, x2 = 1)))
  expect_false(terminator$is_terminated(archive))

  archive$push_finished_points(xss = list(list(x1 = 0, x2 = 0)), yss = list(list(y1 = 3, y2 = 3)))
  expect_true(terminator$is_terminated(archive))
})
