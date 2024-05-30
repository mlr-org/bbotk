test_that("OptimInstanceSingleCrit deprecated works", {

  expect_message({instance = OptimInstanceSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )}, "OptimInstanceSingleCrit is deprecated")

  expect_class(instance, "OptimInstanceSingleCrit")
})

test_that("OptimInstanceMultiCrit deprecated works", {

  expect_message({instance = OptimInstanceMultiCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )}, "OptimInstanceMultiCrit is deprecated")

  expect_class(instance, "OptimInstanceMultiCrit")
})
