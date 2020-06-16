context("TerminatorCombo")

test_that("TerminatorCombo works", {
  trms = terms(c("evals", "evals"))
  trms[[1]]$param_set$values$n_evals = 3L
  trms[[2]]$param_set$values$n_evals = 6L
  terminator = TerminatorCombo$new(trms)
  expect_output(print(terminator), "TerminatorEvals")
  for (mode in c("any", "all")) {
    terminator$param_set$values$any = (mode == "any")
    inst = MAKE_INST_2D(terminator)
    a = random_search(inst, batch_size = 1L)
    if (mode == "any") {
      expect_equal(a$n_evals, 3L, info = mode)
    } else {
      expect_equal(a$n_evals, 6L, info = mode)
    }
  }
})
