context("TerminatorRunTime")

test_that("TerminatorRunTime works", {
  skip_on_cran()

  terminator = term("run_time", secs = 1)
  expect_output(print(terminator), "TerminatorRunTime")
  now = Sys.time()
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
  expect_equal(time_needed, 1, tolerance = 0.15)
})
