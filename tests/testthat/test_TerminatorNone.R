test_that("TerminatorNone works", {
  terminators = trms(c("evals", "none"))

  terminators[[1]]$param_set$values$n_evals = 10L
  expect_output(print(terminators[[2]]), "TerminatorNone")
  terminator = TerminatorCombo$new(terminators)
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(a$n_evals, 10L, info = mode)
})

test_that("TerminatorNone works with empty archive", {
  terminator = TerminatorNone$new()
  archive = Archive$new(ps(x = p_dbl()), ps(y = p_dbl(tags = "minimize")))
  expect_false(terminator$is_terminated(archive))
})

test_that("man exists", {
  terminator = trm("none")
  expect_man_exists(terminator$man)
})
