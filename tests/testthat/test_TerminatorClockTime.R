test_that("TerminatorClockTime works", {
  terminator = TerminatorClockTime$new()
  now = Sys.time()
  terminator$param_set$values$stop_time = now + 2L
  expect_snapshot(terminator)
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_true(time_needed > 2)
})

test_that("status method works", {
  terminator = trm("clock_time", stop_time = Sys.time() + 3)
  inst = MAKE_INST_1D(terminator = terminator)
  inst$archive$start_time = Sys.time()
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)
  Sys.sleep(1)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"], c("max_steps" = 3))
})

test_that("TerminatorClockTime works with empty archive", {
  terminator = TerminatorClockTime$new()
  terminator$param_set$values$stop_time = Sys.time() + 2L
  archive = ArchiveBatch$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})

test_that("man exists", {
  terminator = trm("clock_time")
  expect_man_exists(terminator$man)
})
