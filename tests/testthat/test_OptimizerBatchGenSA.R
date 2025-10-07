test_that("OptimizerBatchGenSA", {
  skip_if_not_installed("GenSA")

  z = test_optimizer_1d("gensa", term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchGenSA")
  expect_snapshot(z$optimizer)
})

test_that("OptimizerBatchGenSA custom start values work", {
  skip_if_not_installed("GenSA")

  search_space = domain = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )

  codomain = ps(y = p_dbl(tags = "maximize"))

  objective_function = function(xs) {
    c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
  }

  objective = ObjectiveRFun$new(
    fun = objective_function,
    domain = domain,
    codomain = codomain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 10L))

  optimizer = opt("gensa", par = c(-9.1, 1.3))
  optimizer$optimize(instance)
  expect_equal(unlist(instance$archive$data[1L, c("x1", "x2")]), c(x1 = -9.1, x2 = 1.3))
})
