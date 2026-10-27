test_that("TerminatorStagnation works", {
  terminator = TerminatorStagnation$new()
  terminator$param_set$values$iters = 10
  terminator$param_set$values$threshold = 100
  expect_snapshot(terminator)
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 11)
})

test_that("TerminatorStagnation in OptimInstanceBatchMultiCrit throws an error", {
  terminator = TerminatorStagnation$new()
  expect_error(MAKE_INST_2D_2D(terminator))
})

test_that("TerminatorStagnation works with empty archive", {
  terminator = TerminatorStagnation$new()
  archive = ArchiveBatch$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})

test_that("man exists", {
  terminator = trm("stagnation")
  expect_man_exists(terminator$man)
})

test_that("TerminatorStagnation errors with direction=0 (learn tag)", {
  terminator = TerminatorStagnation$new()
  codomain = ps(y = p_dbl(tags = "learn"))
  archive = ArchiveBatch$new(ps(x = p_dbl()), codomain)

  # add some evaluations
  xdt = data.table(x = c(0.5, 0.3))
  xss_trafoed = list(list(x = 0.5), list(x = 0.3))
  ydt = data.table(y = c(0.25, 0.09))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_error(terminator$is_terminated(archive), "direction != 0")
})

test_that("TerminatorStagnation works with ArchiveAsync", {
  skip_if_not_installed("rush")
  skip_if_no_redis()
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  terminator = trm("stagnation", iters = 2L)
  instance = oi_async(objective = OBJ_2D, search_space = PS_2D, terminator = terminator, rush = rush)
  archive = instance$archive

  archive$push_finished_points(
    xss = list(list(x1 = 0, x2 = 0), list(x1 = 0, x2 = 0)),
    yss = list(list(y = 3), list(y = 2))
  )
  archive$push_points(list(list(x1 = 1, x2 = 1), list(x1 = 1, x2 = 1)))
  expect_false(terminator$is_terminated(archive))

  archive$push_finished_points(xss = list(list(x1 = 0, x2 = 0)), yss = list(list(y = 5)))
  expect_false(terminator$is_terminated(archive))

  archive$push_finished_points(xss = list(list(x1 = 0, x2 = 0)), yss = list(list(y = 6)))
  expect_true(terminator$is_terminated(archive))
})
