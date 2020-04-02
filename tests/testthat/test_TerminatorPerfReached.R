context("TerminatorPerfReached")

test_that("TerminatorPerfReached works", {
  term = TerminatorPerfReached$new()
  term$param_set$values$level = c(y = 0.2)
  inst = MAKE_INST_2D(term)
  a = random_search(inst, batch_size = 1L)
  expect_equal(sum(a$data$y < 0.2), 1)
})

# test_that("TerminatorPerfReached works for multi-objective", {
#   obj = OBJ_2D_2D
#   term = TerminatorPerfReached$new()
#   term$param_set$values$level = c(y1 = 0.2, y2 = -0.2)
#   obj$terminator = term
#   a = random_search(obj, batch_size = 1L)
#   a$data[, both := y1 <= 0.2 & y2 >= -0.2]
#   expect_equal(sum(a$data$both), 1)
# })
