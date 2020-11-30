context("TerminatorClockTime")

test_that("TerminatorClockTime works", {
  terminator = TerminatorClockTime$new()
  now = Sys.time()
  terminator$param_set$values$stop_time = now + 2L
  expect_output(print(terminator), "TerminatorClockTime")
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_true(time_needed > 2)
})

test_that("progressr works", {
  skip_if_not_installed("progressr")
  requireNamespace("progressr")

  progressr::handlers("debug")
  terminator = trm("clock_time", stop_time = Sys.time() + 3)
  inst = MAKE_INST_1D(terminator = terminator)
  inst$archive$start_time = Sys.time()
  xdt = data.table(x = 1)
  progressr::with_progress(inst$eval_batch(xdt))

  expect_class(inst$progressor$progressor, "progressor")
  expect_equal(inst$terminator$max(inst$archive), 3)
  expect_equal(inst$terminator$current(inst$archive), 1, tolerance = 1)
})
