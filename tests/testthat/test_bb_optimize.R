test_that("bb_optimize works with function and bounds", {
  lower = c(-10, -5)
  upper = c(10, 5)

  fun = function(xs) {
    -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(fun, lower = lower, upper = upper, max_evals = 10)
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "y1")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})

test_that("bb_optimize works with passed arguments to objective function", {
  lower = c(-10, -5)
  upper = c(10, 5)

  fun = function(xs, c) {
    -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + c
  }

  res = bb_optimize(fun, lower = lower, upper = upper, max_evals = 10, c = 1)
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "y1")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})

test_that("bb_optimize works with optimizer object", {
  lower = c(-10, -5)
  upper = c(10, 5)

  fun = function(xs) {
    -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(fun, method = opt("random_search"), lower = lower, upper = upper, max_evals = 10)
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "y1")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})

test_that("bb_optimize works with function and named bounds", {
  lower = c(z1 = -10, z2 = -5)
  upper = c(z1 = 10, z2 = 5)

  fun = function(xs) {
    -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(fun, method = "random_search", lower = lower, upper = upper, max_evals = 10)
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("z1", "z2"))
  expect_numeric(res$value)
  expect_named(res$value, "y1")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})

test_that("bb_optimize works with named codomain", {
  lower = c(-10, -5)
  upper = c(10, 5)

  fun = function(xs) {
    -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
  }

  res = bb_optimize(fun, method = "random_search", lower = lower, upper = upper, max_evals = 10, maximize = c(z = FALSE))
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "z")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})

test_that("bb_optimize works with objective", {
  fun = function(xs) {
    c(z = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
  }
  search_space = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )
  codomain = ps(z = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun, search_space, codomain)

  res = bb_optimize(objective, method = "random_search", max_evals = 10)
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "z")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})


test_that("bb_optimize works with function and bounds", {
  lower = c(-10, -5)
  upper = c(10, 5)

  fun = function(xs, c) {
    -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + c
  }

  res = bb_optimize(fun, lower = lower, upper = upper, max_evals = 1000, c = 10)

  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "y1")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})


test_that("bb_optimize works with objective", {
  fun = function(xs, c) {
    c(z = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10 + c)
  }
  search_space = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )
  codomain = ps(z = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun, search_space, codomain)
  objective$constants = ps(c = p_dbl())
  objective$constants$values$c = 1

  objective$eval(list(x1 = 1, x2 = 2))

  res = bb_optimize(objective, method = "random_search", max_evals = 10)
  expect_list(res)
  expect_data_table(res$par)
  expect_named(res$par, c("x1", "x2"))
  expect_numeric(res$value)
  expect_named(res$value, "z")
  expect_r6(res$instance, "OptimInstanceBatchSingleCrit")
})
