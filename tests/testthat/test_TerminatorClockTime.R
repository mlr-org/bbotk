context("TerminatorClockTime")

test_that("TerminatorClockTime works", {
  obj = OBJ_2D()
  term = TerminatorClockTime$new()
  now = Sys.time()
  term$param_set$values$stop_time = now + 2L
  obj$terminator = term
  a = random_search(obj, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_true(time_needed > 2)
})
