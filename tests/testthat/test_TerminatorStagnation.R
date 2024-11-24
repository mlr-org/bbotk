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
