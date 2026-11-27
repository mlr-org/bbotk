test_that("TerminatorPerfReached works", {
  terminator = TerminatorPerfReached$new()
  terminator$param_set$values$level = 0.2
  expect_snapshot(terminator)
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(sum(a$data$y < 0.2), 1)
  expect_true(tail(a$data$y, 1) < 0.2)
})

test_that("TerminatorPerfReached in OptimInstanceBatchMultiCrit throws an error", {
  terminator = TerminatorPerfReached$new()
  expect_error(MAKE_INST_2D_2D(terminator))
})

test_that("TerminatorPerfReached works with empty archive", {
  terminator = TerminatorPerfReached$new()
  archive = ArchiveBatch$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})

test_that("TerminatorPerfReached respects direction when codomain target has extra tags", {
  terminator = trm("perf_reached", level = 0.1)
  codomain = ps(y = p_dbl(tags = c("minimize", "extra")))

  archive = ArchiveBatch$new(ps(x = p_dbl(0, 1)), codomain)
  archive$add_evals(data.table(x = 0.5), ydt = data.table(y = 10))
  expect_false(terminator$is_terminated(archive))

  archive$add_evals(data.table(x = 0.1), ydt = data.table(y = 0.05))
  expect_true(terminator$is_terminated(archive))
})

test_that("TerminatorPerfReached errors with direction=0 (learn tag)", {
  terminator = trm("perf_reached", level = 0.1)
  codomain = ps(y = p_dbl(tags = "learn"))
  archive = ArchiveBatch$new(ps(x = p_dbl(0, 1)), codomain)
  archive$add_evals(data.table(x = 0.5), ydt = data.table(y = 0.5))

  expect_error(terminator$is_terminated(archive), "direction != 0")
})

test_that("man exists", {
  terminator = trm("perf_reached")
  expect_man_exists(terminator$man)
})
