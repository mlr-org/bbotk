context("TerminatorRunTime")

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

  expect_equal(inst$terminator$max(inst$archive), 3)

  Sys.sleep(1)
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)
  expect_equal(inst$terminator$current(inst$archive), 1, tolerance = 1)
})
