context("TerminatorRunTime")

test_that("TerminatorRunTime works", {
  term = TerminatorRunTime$new()
  now = Sys.time()
  term$param_set$values$secs = 1
  inst = MAKE_INST_2D(term)
  a = random_search(inst, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_equal(time_needed, 1, tolerance = 0.15)
})
