context("TerminatorStagnation")

test_that("TerminatorStagnation works", {
  obj = OBJ_2D()
  term = TerminatorStagnation$new()
  term$param_set$values$iters = 10
  term$param_set$values$threshold = 100
  obj$terminator = term
  a = random_search(obj, batch_size = 1L)
  expect_equal(a$n_evals, 11)
})

# FIXME: disabled this as it might not nake sense
# test_that("TerminatorStagnation works for multi-objective", {
#   obj = OBJ_2D_2D
#   term = TerminatorStagnation$new()
#   term$param_set$values$iters = 4
#   term$param_set$values$threshold = 100
#   obj$terminator = term
#   a = random_search(obj, batch_size = 1L)
#   expect_equal(a$n_evals, 5)
# })
