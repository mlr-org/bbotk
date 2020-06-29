context("Optimizer")

test_that("Optimizer assertions work", {
  optimizer = MAKE_OPT()
  terminator = TerminatorEvals$new()
  instance = MAKE_INST_2D_2D(terminator = terminator)
  expect_error(optimizer$optimize(instance), "does not support multi-crit objectives")

  optimizer = MAKE_OPT(properties = "multi-crit")
  terminator = TerminatorEvals$new()
  instance = MAKE_INST_2D(terminator = terminator)
  expect_error(optimizer$optimize(instance), "does not support single-crit objectives")

  optimizer = MAKE_OPT(packages = "foo")
  terminator = TerminatorEvals$new()
  instance = MAKE_INST_2D(terminator = terminator)
  expect_error(optimizer$optimize(instance), class = "packageNotFoundError")

  optimizer = MAKE_OPT()
  terminator = TerminatorEvals$new()
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D_DEPS,
    terminator = terminator)
  expect_error(optimizer$optimize(instance), "does not support param sets with dependencies")

  optimizer = MAKE_OPT(param_classes = "ParamLgl")
  terminator = TerminatorEvals$new()
  instance = MAKE_INST_2D(terminator = terminator)
  expect_error(optimizer$optimize(instance), "does not support param types")
})
