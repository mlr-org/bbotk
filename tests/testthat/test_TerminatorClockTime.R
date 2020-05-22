context("TerminatorClockTime")

test_that("TerminatorClockTime works", {
  term = TerminatorClockTime$new()
  now = Sys.time()
  term$param_set$values$stop_time = now + 2L
  expect_output(print(term), "TerminatorClockTime")
  inst = MAKE_INST_2D(term)
  a = random_search(inst, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_true(time_needed > 2)
})
