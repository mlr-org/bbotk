context("TerminatorEvals")

test_that("TerminatorEvals works", {
  inst = MAKE_INST_2D(7L)
  expect_output(print(inst$terminator), "TerminatorEvals")
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 7L)
  expect_data_table(a$data(), nrows = 7L)
})

test_that("progressr works", {
  terminator = term("evals", n_evals = 10)
  inst = MAKE_INST_1D(terminator = terminator)
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(terminator$progressr_steps(), 10)
  expect_equal(terminator$progressr_update(inst$archive), list(amount = 1, sum = 1))

  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(terminator$progressr_update(inst$archive), list(amount = 1, sum = 2))
})


test_that("progressr package works", {
  skip_if_not_installed("progressr")
  requireNamespace("progressr")

  progressr::handlers("debug")
  terminator = term("evals", n_evals = 10)
  inst = MAKE_INST_1D(terminator = terminator)
  optimizer = opt("random_search")
  progressr::with_progress(optimizer$optimize(inst))

  expect_class(inst$progressor, "progressor")
  expect_equal(terminator$progressr_steps(), 10)
  expect_equal(terminator$progressr_update(inst$archive), list(amount = 1, sum = 10))
})
