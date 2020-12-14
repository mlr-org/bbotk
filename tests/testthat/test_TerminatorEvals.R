context("TerminatorEvals")

test_that("TerminatorEvals works", {
  inst = MAKE_INST_2D(7L)
  expect_output(print(inst$terminator), "TerminatorEvals")
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 7L)
  expect_data_table(a$data(), nrows = 7L)
})

test_that("status method works", {
  terminator = trm("evals", n_evals = 10)
  inst = MAKE_INST_1D(terminator = terminator)
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"],  c("max_steps" = 10))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps"= 1))
  expect_equal(inst$terminator$remaining_time(inst$archive), Inf)

  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"],  c("max_steps" = 10))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps"= 2))
  expect_equal(inst$terminator$remaining_time(inst$archive), Inf)
})
