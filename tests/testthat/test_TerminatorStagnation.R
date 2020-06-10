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

# FIXME: disabled this as it might not nake sense
# test_that("TerminatorStagnation works for multi-objective", {
#   obj = OBJ_2D_2D
#   terminator = TerminatorStagnation$new()
#   terminator$param_set$values$iters = 4
#   terminator$param_set$values$threshold = 100
#   obj$terminator = terminator
#   a = random_search(obj, batch_size = 1L)
#   expect_equal(a$n_evals, 5)
# })
