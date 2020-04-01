context("random search")

test_that("random_search", {
  obj = OBJ_2D(7)
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 7L
  obj$terminator = term
  a = random_search(obj, batch_size = 1L)
  expect_equal(a$n_evals, 7L)
  expect_data_table(a$data, nrows = 7L)
})
