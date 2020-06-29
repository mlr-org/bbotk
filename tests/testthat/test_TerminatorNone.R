context("TerminatorNone")

test_that("TerminatorNone works", {
  trms = c(TerminatorEvals$new(), TerminatorNone$new())
  trms[[1]]$param_set$values$n_evals = 10L
  expect_output(print(trms[[2]]), "TerminatorNone")
  terminator = TerminatorCombo$new(trms)
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 10L, info = mode)
})
