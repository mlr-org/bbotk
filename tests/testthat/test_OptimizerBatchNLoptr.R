test_that("OptimizerBatchNLoptr", {
  skip_on_os("windows")
  skip_if_not_installed("nloptr")

  z = test_optimizer_1d(
    "nloptr",
    algorithm = "NLOPT_LN_BOBYQA",
    xtol_rel = -1,
    xtol_abs = -1,
    ftol_rel = -1,
    ftol_abs = -1,
    term_evals = 5L
  )
  expect_class(z$optimizer, "OptimizerBatchNLoptr")
  expect_snapshot(z$optimizer)

  z = test_optimizer_1d(
    "nloptr",
    algorithm = "NLOPT_LD_LBFGS",
    approximate_eval_grad_f = TRUE,
    xtol_rel = -1,
    xtol_abs = -1,
    ftol_rel = -1,
    ftol_abs = -1,
    term_evals = 5L
  )
  expect_class(z$optimizer, "OptimizerBatchNLoptr")
  expect_snapshot(z$optimizer)
})

test_that("OptimizerBatchNLoptr custom start values work", {
  skip_on_os("windows")
  skip_if_not_installed("nloptr")

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
    codomain = codomain
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 10L)
  )

  optimizer = opt("nloptr", algorithm = "NLOPT_LN_BOBYQA", x0 = c(-9.1, 1.3))
  optimizer$optimize(instance)
  expect_equal(unlist(instance$archive$data[1L, c("x1", "x2")]), c(x1 = -9.1, x2 = 1.3))
})

test_that("OptimizerBatchNLoptr internal termination criteria are honored", {
  skip_on_os("windows")
  skip_if_not_installed("nloptr")

  instance = oi(OBJ_1D, search_space = PS_1D, terminator = trm("evals", n_evals = 50L))
  optimizer = opt("nloptr", algorithm = "NLOPT_LN_BOBYQA", x0 = 0.9, maxeval = 5L)
  optimizer$optimize(instance)
  # nloptr stops on its own budget, the terminator would allow 50 evaluations
  expect_lte(instance$archive$n_evals, 10L)

  instance = oi(OBJ_1D, search_space = PS_1D, terminator = trm("evals", n_evals = 50L))
  optimizer = opt("nloptr", algorithm = "NLOPT_LN_BOBYQA", x0 = 0.9)
  optimizer$optimize(instance)
  expect_gt(instance$archive$n_evals, 10L)
})
