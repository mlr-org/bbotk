context("TerminatorNone")

test_that("TerminatorNone works", {
  terminators = trms(c("evals", "none"))
  terminators[[1]]$param_set$values$n_evals = 10L
  expect_output(print(terminators[[2]]), "TerminatorNone")
  terminator = TerminatorCombo$new(terminators)
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 10L, info = mode)
})
