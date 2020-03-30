context("random search")
test_that("random_search", {
  obj = Objective$new(fun = OBJ_2D, domain = PS_2D)
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 7L
  a = random_search(obj, term, batch_size = 1L)
  expect_equal(a$n_evals, 7L)
  expect_data_table(a$data,
    nrows = 7L,
    types = c("numeric", "numeric", "numeric", "list"),
    any.missing = FALSE
  )
  expect_names(colnames(a$data), permutation.of = c("batch_nr", "x1", "x2", "y1", "timestamp"))
})

