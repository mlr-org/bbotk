context("TerminatorCombo")

test_that("TerminatorCombo works", {
  obj = OBJ_2D
  term1 = TerminatorEvals$new()
  term2 = TerminatorEvals$new()
  term1$param_set$values$n_evals = 3L
  term2$param_set$values$n_evals = 6L
  term = TerminatorCombo$new(list(term1, term2))
  for (mode in c("any", "all")) {
    term$param_set$values$any = (mode == "any")
    a = random_search(obj, term, batch_size = 1L)
    if (mode == "any") {
      expect_equal(a$n_evals, 3L)
    } else {
      expect_equal(a$n_evals, 6L)
    }
  }
})
