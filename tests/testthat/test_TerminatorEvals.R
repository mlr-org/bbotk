context("TerminatorEvals")

test_that("TerminatorEvals works", {
  inst = MAKE_INST_2D(7L)
  expect_output(print(inst$terminator), "TerminatorEvals")
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 7L)
  expect_data_table(a$data, nrows = 7L)
})
