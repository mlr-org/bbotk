test_that("TerminatorRunTime works", {
    skip_on_cran()

  terminator = trm("run_time", secs = 1)
  expect_output(print(terminator), "TerminatorRunTime")
  now = Sys.time()
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_equal(time_needed, 1, tolerance = 0.15)
})

test_that("max and current works", {
  terminator = trm("run_time", secs = 3)
  inst = MAKE_INST_1D(terminator = terminator)
  inst$archive$start_time = Sys.time()
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)
  Sys.sleep(1)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"], c("max_steps" = 3))
})

test_that("TerminatorRunTime works with empty archive", {
  terminator = TerminatorRunTime$new()
  archive = ArchiveBatch$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})

test_that("man exists", {
  terminator = trm("run_time")
  expect_man_exists(terminator$man)
})
