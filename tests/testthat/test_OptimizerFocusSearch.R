test_that("OptimizerFocusSearch", {
  z = test_optimizer_1d("focus_search", n_points = 1L, maxit = 10L, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerFocusSearch")
  expect_output(print(z$optimizer), "OptimizerFocusSearch")

  z = test_optimizer_1d("focus_search", n_points = 10L, maxit = 10L, term_evals = 100L)
  expect_class(z$optimizer, "OptimizerFocusSearch")
  expect_output(print(z$optimizer), "OptimizerFocusSearch")

  z = test_optimizer_dependencies("focus_search", n_points = 1L, maxit = 10L, term_evals = 10L)

  z = test_optimizer_dependencies("focus_search", n_points = 10L, maxit = 10L, term_evals = 100L)

  z = test_optimizer_1d("focus_search", n_points = 1L, maxit = 10L, term_evals = 100L)  # 9 restarts, in total 10 runs
})

test_that("shrink_ps", {
 param_set = ParamSet$new(list(
   ParamDbl$new("x1", lower = 0, upper = 10),
   ParamInt$new("x2", lower = -10, upper = 10),
   ParamFct$new("x3", levels = c("a", "b", "c")),
   ParamLgl$new("x4"))
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
 param_set = ParamSet$new(list(
   ParamDbl$new("x1", lower = log(1), upper = log(10)),
   ParamInt$new("x2", lower = -10, upper = 10),
   ParamFct$new("x3", levels = c("a", "b", "c")),
   ParamLgl$new("x4"))
 )
 param_set$trafo = function(x, param_set) {
   x[["x1"]] = exp(x[["x1"]])
   x
 }
 param_set$add_dep("x2", on = "x3", cond = CondEqual$new("b"))

 x = param_set$trafo(data.table(x1 = log(5), x2 = 0, x3 = "b", x4 = FALSE))
 expect_error(shrink_ps(param_set, x = x, check.feasible = TRUE))
 psx = shrink_ps(param_set, x = x)

 expect_equal(psx$lower, c(x1 = pmax(log(1), log(5) - (log(10) - log(1)) / 4), x2 = -5, x3 = NA, x4 = NA))
 expect_equal(psx$upper, c(x1 = pmin(log(10), log(5) + (log(10) - log(1)) / 4), x2 = 5, x3 = NA, x4 = NA))
 expect_true(psx$nlevels[["x3"]] == 2L && "b" %in% psx$levels$x3)
 # ParamLgls have the value to be shrinked around set as a default
 expect_true(psx$nlevels[["x4"]] == 2L && psx$default[["x4"]] == FALSE && psx$tags[["x4"]] == "shrinked")
})
