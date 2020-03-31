context("TerminatorRunTime")

test_that("TerminatorRunTime works", {
  obj = OBJ_2D
  term = TerminatorRunTime$new()
  now = Sys.time()
  term$param_set$values$secs = 1
  a = random_search(obj, term, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_equal(time_needed, 1, tolerance = 0.15)
})
