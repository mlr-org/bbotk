test_that("OptimizerBatchLocalSearch works", {
  optimizer = opt("local_search")
  expect_r6(optimizer, classes = "OptimizerBatchLocalSearch")

  instance = MAKE_INST_1D(terminator = trm("evals", n_evals = 3000L))

  optimizer$optimize(instance)
})

test_that("OptimizerBatchLocalSearch works with 2D", {
  optimizer = opt("local_search")
  expect_r6(optimizer, classes = "OptimizerBatchLocalSearch")

  instance = MAKE_INST_2D(terminator = trm("evals", n_evals = 3000L))

  optimizer$optimize(instance)
})

test_that("OptimizerBatchLocalSearch works with 2D", {
  optimizer = opt("local_search")
  expect_r6(optimizer, classes = "OptimizerBatchLocalSearch")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15),
    x3 = p_fct(c("a", "b")),
  )

  fun = function(xs) {
    if (xs$x3 == "a") {
      c(y = xs$x1 + xs$x2)
    } else if (xs$x3 == "b") {
      c(y = xs$x1 - xs$x2)
    }
  }

  objective = ObjectiveRFunDt$new(fun = fun, domain = domain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 1000))

  instance = MAKE_INST_2D(terminator = trm("evals", n_evals = 3000L))

  optimizer$optimize(instance)
})
