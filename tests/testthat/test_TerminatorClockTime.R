context("TerminatorClockTime")

test_that("TerminatorClockTime works", {
  obj = OBJ_2D
  term = TerminatorClockTime$new()
  now = Sys.time()
  term$param_set$values$stop_time = now + 2L
  a = random_search(obj, term, batch_size = 1L)
  time_needed = difftime(Sys.time(), now, units = "secs")
  expect_equal(as.numeric(time_needed), 2, tolerance = 0.15)
})
