test_that("OptimizerBatchFocusSearch", {
  z = test_optimizer_1d("focus_search", n_points = 1L, maxit = 10L, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchFocusSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_1d("focus_search", n_points = 10L, maxit = 10L, term_evals = 100L)
  expect_class(z$optimizer, "OptimizerBatchFocusSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_dependencies("focus_search", n_points = 1L, maxit = 10L, term_evals = 10L)

  z = test_optimizer_dependencies("focus_search", n_points = 10L, maxit = 10L, term_evals = 100L)

  z = test_optimizer_1d("focus_search", n_points = 1L, maxit = 10L, term_evals = 100L)  # 9 restarts, in total 10 runs
})

test_that("shrink_ps", {
 param_set = ps(
  x1 = p_dbl(0, 10),
  x2 = p_int(-10, 10),
  x3 = p_fct(levels = c("a", "b", "c")),
  x4 = p_lgl()
 )

 x = data.table(x1 = 5, x2 = 0, x3 = "b", x4 = TRUE)
 psx = shrink_ps(param_set, x = x)
 expect_equal(psx$lower, c(x1 = 2.5, x2 = -5, x3 = NA, x4 = NA))
 expect_equal(psx$upper, c(x1 = 7.5, x2 = 5, x3 = NA, x4 = NA))
 expect_true(psx$nlevels[["x3"]] == 2L && "b" %in% psx$levels$x3)
 # ParamLgls have the value to be shrinked around set as a default
 expect_true(psx$nlevels[["x4"]] == 2L && psx$default[["x4"]] == TRUE && psx$tags[["x4"]] == "shrinked")
})

test_that("shrink_ps trafo and deps", {
 param_set = ps(
   x1 = p_dbl(lower = log(1), upper = log(10), trafo = function(x) exp(x)),
   x2 = p_int(lower = -10, upper = 10, depends = x3 == "b"),
   x3 = p_fct(levels = c("a", "b", "c")),
   x4 = p_lgl()
 )

 x = param_set$trafo(data.table(x1 = log(5), x2 = 0, x3 = "b", x4 = FALSE))
# expect_error(shrink_ps(param_set, x = as.data.table(x), check.feasible = TRUE))  ## TODO: ask sumny if this should actually be an error here
 psx = shrink_ps(param_set, x = as.data.table(x))

 expect_equal(psx$lower, c(x1 = pmax(log(1), log(5) - (log(10) - log(1)) / 4), x2 = -5, x3 = NA, x4 = NA))
 expect_equal(psx$upper, c(x1 = pmin(log(10), log(5) + (log(10) - log(1)) / 4), x2 = 5, x3 = NA, x4 = NA))
 expect_true(psx$nlevels[["x3"]] == 2L && "b" %in% psx$levels$x3)
 # ParamLgls have the value to be shrinked around set as a default
 expect_true(psx$nlevels[["x4"]] == 2L && psx$default[["x4"]] == FALSE && psx$tags[["x4"]] == "shrinked")
})

test_that("shrink_ps trafo and deps via sugar", {
 param_set = ps(
   x1 = p_dbl(lower = log(1), upper = log(10), trafo = function(x) exp(x)),
   x2 = p_int(lower = -10, upper = 10, depends = x3 == "b"),
   x3 = p_fct(levels = c("a", "b", "c")),
   x4 = p_lgl()
 )

 x = param_set$trafo(data.table(x1 = log(5), x2 = 0, x3 = "b", x4 = FALSE))
# expect_error(shrink_ps(param_set, x = as.data.table(x), check.feasible = TRUE))  ## TODO: ask sumny if this should actually be an error here
 psx = shrink_ps(param_set, x = as.data.table(x))

 expect_equal(psx$lower, c(x1 = pmax(log(1), log(5) - (log(10) - log(1)) / 4), x2 = -5, x3 = NA, x4 = NA))
 expect_equal(psx$upper, c(x1 = pmin(log(10), log(5) + (log(10) - log(1)) / 4), x2 = 5, x3 = NA, x4 = NA))
 expect_true(psx$nlevels[["x3"]] == 2L && "b" %in% psx$levels$x3)
 # ParamLgls have the value to be shrinked around set as a default
 expect_true(psx$nlevels[["x4"]] == 2L && psx$default[["x4"]] == FALSE && psx$tags[["x4"]] == "shrinked")

 y = psx$trafo(data.table(x1 = log(5), x2 = 0, x3 = "b", x4 = FALSE))
 expect_equal(x, y)  # trafo works after shrinking
 expect_equal(param_set$deps, psx$deps)  # dependencies are still there
})

