test_that("TerminatorEvals works", {

  # only n_evals
  inst = MAKE_INST_2D(trm("evals", n_evals = 7))
  expect_output(print(inst$terminator), "TerminatorEvals")
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 7L)
  expect_data_table(a$data, nrows = 7L)

  # n_evals and k
  inst = MAKE_INST_2D(trm("evals", n_evals = 7, k = 2))
  expect_output(print(inst$terminator), "TerminatorEvals")
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 11L)
  expect_data_table(a$data, nrows = 11L)

  # only k
  inst = MAKE_INST_2D(trm("evals", n_evals = 0, k = 2))
  expect_output(print(inst$terminator), "TerminatorEvals")
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 4L)
  expect_data_table(a$data, nrows = 4L)
})

test_that("status method works", {

  # only n_evals
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

  # n_evals k
  terminator = trm("evals", n_evals = 10, k = 5)
  inst = MAKE_INST_1D(terminator = terminator)
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"],  c("max_steps" = 15))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps"= 1))
  expect_equal(inst$terminator$remaining_time(inst$archive), Inf)

  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"],  c("max_steps" = 15))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps"= 2))
  expect_equal(inst$terminator$remaining_time(inst$archive), Inf)

  # only k
  terminator = trm("evals", n_evals = 0, k = 5)
  inst = MAKE_INST_1D(terminator = terminator)
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"],  c("max_steps" = 5))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps"= 1))
  expect_equal(inst$terminator$remaining_time(inst$archive), Inf)

  xdt = data.table(x = 1)
  inst$eval_batch(xdt)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"],  c("max_steps" = 5))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps"= 2))
  expect_equal(inst$terminator$remaining_time(inst$archive), Inf)
})

test_that("TerminatorEvals works with empty archive" ,{
  terminator = TerminatorEvals$new()
  archive = Archive$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})
