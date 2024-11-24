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

test_that("man exists", {
  terminator = trm("perf_reached")
  expect_man_exists(terminator$man)
})
