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
