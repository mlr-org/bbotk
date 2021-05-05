test_that("bb_optimize works with function and bounds", {
  lower = c(-10, -5)
  upper = c(10, 5)

  fun = function(xs) {
    - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(method = "random_search", fun = fun, lower = lower, upper = upper, term_evals = 10)
  expect_list(res)
  expect_numeric(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "y")
  expect_r6(res$instance, "OptimInstanceSingleCrit")
})

test_that("bb_optimize works with function and named bounds", {
  lower = c(z1 = -10, z2 = -5)
  upper = c(z1 = 10, z2 = 5)

  fun = function(xs) {
    - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(method = "random_search", fun = fun, lower = lower, upper = upper, term_evals = 10)
  expect_list(res)
  expect_numeric(res$par)
  expect_named(res$par, c("z1", "z2"))
  expect_numeric(res$value)
  expect_named(res$value, "y")
  expect_r6(res$instance, "OptimInstanceSingleCrit")
})

test_that("bb_optimize works with function and search space", {
  search_space = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )

  fun = function(xs) {
    - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(method = "random_search", fun = fun, search_space = search_space, term_evals = 10)
  expect_list(res)
  expect_numeric(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "y")
  expect_r6(res$instance, "OptimInstanceSingleCrit")
})

test_that("bb_optimize works with function, bounds and codomain", {
  search_space = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )

  fun = function(xs) {
    c(z = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
  }

  codomain = ps(z = p_dbl(tags = "minimize"))

  objective = ObjectiveRFun$new(fun, search_space, codomain)

  res = bb_optimize(method = "random_search", objective = objective, term_evals = 10)
  expect_list(res)
  expect_numeric(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "z")
  expect_r6(res$instance, "OptimInstanceSingleCrit")
})

test_that("bb_optimize works with objective", {
  fun = function(xs) {
    c(z = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
  }
  search_space = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )
  codomain = ps(z = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun, search_space, codomain) 

  res = bb_optimize(method = "random_search", objective = objective, term_evals = 10)
  expect_list(res)
  expect_numeric(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "z")
  expect_r6(res$instance, "OptimInstanceSingleCrit")
})

test_that("bb_optimize checks work", {
  lower = c(-10, -5)

  fun = function(xs) {
    - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  expect_error(bb_optimize(method = "random_search", fun = fun, lower = lower, term_evals = 10),
    regexp = "`lower` and `upper` must be provided.", fixed = TRUE)

  search_space = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )
  codomain = ps(z = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun, search_space, codomain)

  expect_error(bb_optimize(method = "random_search", fun = fun,
    objective = objective, term_evals = 10),
    regexp = "Either `fun` or `objective` must be provided.", fixed = TRUE)

})
