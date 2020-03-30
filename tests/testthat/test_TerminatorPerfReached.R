context("TerminatorPerfReached")

test_that("TerminatorPerfReached works", {
  obj = OBJ_2D
  term = TerminatorPerfReached$new()
  term$param_set$values$level = c(y1 = 0.2)
  a = random_search(obj, term, batch_size = 1L)
  expect_equal(sum(a$data$y1 < 0.2), 1)
})
