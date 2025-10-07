test_that("OptimizerBatchLocalSearch", {
  z = test_optimizer_1d("local_search", n_initial_points = 3L, initial_random_sample_size = 100L, neighbors_per_point = 10L, term_evals = 130L)
  expect_class(z$optimizer, "OptimizerBatchLocalSearch")
  expect_snapshot(z$optimizer)
})

test_that("OptimizerBatchLocalSearch mixed hierarchical search space", {
  domain = ps(
    x1 = p_dbl(-5, 5),
    x2 = p_fct(c("a", "b", "c")),
    x3 = p_int(1L, 2L),
    x4 = p_lgl()
  )
  domain$add_dep("x2", on = "x4", cond = CondEqual$new(TRUE))
  fun = function(xs) {
    if (is.null(xs$x2)) {
      xs$x2 = "a"
    }
    list(y = (xs$x1 - switch(xs$x2, "a" = 0, "b" = 1, "c" = 2)) %% xs$x3 + (if (xs$x4) xs$x1 else pi))
  }
  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 130L))
  optimizer = opt("local_search", n_initial_points = 3L, initial_random_sample_size = 100L, neighbors_per_point = 10L)
  optimizer$optimize(instance)
  expect_class(optimizer, "OptimizerBatchLocalSearch")
  expect_snapshot(optimizer)
})

test_that("OptimizerBatchLocalSearch trafo", {
  domain = ps(
    x1 = p_dbl(lower = 0, upper = 1),  # searching from -1 to 1 on ^2 results in a domain of [0, 1]
    x2 = p_dbl(lower = 1, upper = 10)  # searching from log(1) to log(10) on exp() results in a domain of [1, 10]
  )
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1, trafo = function(x) x^2),
    x2 = p_dbl(lower = 1, upper = 10, logscale = TRUE)
  )
  fun = function(xs) {
    list(y = - sum(as.numeric(xs)^2))
  }
  codomain = ps(
    y = p_dbl(lower = -101, upper = 0, tags = "maximize")
  )
  objective = ObjectiveRFun$new(fun = fun, domain = domain, codomain = codomain, properties = "single-crit")
  instance = OptimInstanceBatchSingleCrit$new(objective = objective, search_space = search_space, terminator = trm("evals", n_evals = 130L))
  optimizer = opt("local_search", n_initial_points = 3L, initial_random_sample_size = 100L, neighbors_per_point = 10L)
  optimizer$optimize(instance)
  expect_class(optimizer, "OptimizerBatchLocalSearch")
  expect_snapshot(optimizer)
})
