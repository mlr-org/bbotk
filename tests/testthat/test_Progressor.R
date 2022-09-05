test_that("progressr works", {
  skip_if_not_installed("progressr")
  requireNamespace("progressr")

  progressr::handlers("debug")
  terminator = trm("evals", n_evals = 10)
  inst = MAKE_INST_1D(terminator = terminator)
  optimizer = opt("random_search")
  progressr::with_progress(optimizer$optimize(inst))

  expect_class(inst$progressor$progressor, "progressor")
  expect_equal(inst$progressor$unit, "evaluations")
  expect_equal(inst$progressor$max_steps, c("max_steps" = 10))
  expect_equal(inst$progressor$current_steps, c("current_steps" = 10))
})

test_that("$clear() method of instance resets progressr", {
  progressr::handlers("debug")
  terminator = trm("evals", n_evals = 10)
  inst = MAKE_INST_1D(terminator = terminator)
  optimizer = opt("random_search")
  progressr::with_progress(optimizer$optimize(inst))
  expect_class(inst$progressor$progressor, "progressor")
  expect_equal(inst$progressor$current_steps, c("current_steps" = 10))

  inst$clear()
  expect_null(inst$progressor)

  progressr::with_progress(optimizer$optimize(inst))
  expect_class(inst$progressor$progressor, "progressor")
  expect_equal(inst$progressor$current_steps, c("current_steps" = 10))
})
