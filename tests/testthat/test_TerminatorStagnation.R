context("TerminatorStagnation")

test_that("TerminatorStagnation works", {
  terminator = TerminatorStagnation$new()
  terminator$param_set$values$iters = 10
  terminator$param_set$values$threshold = 100
  expect_output(print(terminator), "TerminatorStagnation")
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 11)
})

test_that("TerminatorStagnation in OptimInstanceMulticrit throws an error", {
  terminator = TerminatorStagnation$new()
  expect_error(MAKE_INST_2D_2D(terminator))
})
