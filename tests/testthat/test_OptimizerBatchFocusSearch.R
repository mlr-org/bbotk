test_that("OptimizerBatchFocusSearch", {
  z = test_optimizer_1d("focus_search", n_points = 1L, maxit = 10L, term_evals = 10L)
  expect_class(z$optimizer, "OptimizerBatchFocusSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_1d("focus_search", n_points = 10L, maxit = 10L, term_evals = 100L)
  expect_class(z$optimizer, "OptimizerBatchFocusSearch")
  expect_snapshot(z$optimizer)

  z = test_optimizer_dependencies("focus_search", n_points = 1L, maxit = 10L, term_evals = 10L)

  z = test_optimizer_dependencies("focus_search", n_points = 10L, maxit = 10L, term_evals = 100L)

  z = test_optimizer_1d("focus_search", n_points = 1L, maxit = 10L, term_evals = 100L) # 9 restarts, in total 10 runs
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
  # ParamLgls have the value to be shrunk around set as a default
  expect_true(psx$nlevels[["x4"]] == 2L && psx$default[["x4"]] == TRUE && psx$tags[["x4"]] == "shrunk")
})

test_that("shrink_ps trafo and deps", {
  param_set = ps(
    x1 = p_dbl(lower = log(1), upper = log(10), trafo = function(x) exp(x)),
    x2 = p_int(lower = -10, upper = 10, depends = x3 == "b"),
    x3 = p_fct(levels = c("a", "b", "c")),
    x4 = p_lgl()
  )

  # x contains the untransformed search space values
  x = data.table(x1 = log(5), x2 = 0, x3 = "b", x4 = FALSE)
  psx = shrink_ps(param_set, x = x)

  expect_equal(psx$lower, c(x1 = pmax(log(1), log(5) - (log(10) - log(1)) / 4), x2 = -5, x3 = NA, x4 = NA))
  expect_equal(psx$upper, c(x1 = pmin(log(10), log(5) + (log(10) - log(1)) / 4), x2 = 5, x3 = NA, x4 = NA))
  expect_true(psx$nlevels[["x3"]] == 2L && "b" %in% psx$levels$x3)
  # ParamLgls have the value to be shrunk around set as a default
  expect_true(psx$nlevels[["x4"]] == 2L && psx$default[["x4"]] == FALSE && psx$tags[["x4"]] == "shrunk")

  y = psx$trafo(x)
  expect_equal(param_set$trafo(x), y) # trafo works after shrinking
  expect_equal(param_set$deps, psx$deps) # dependencies are still there
})

test_that("shrink_ps shrinks around the untransformed value", {
  param_set = ps(x = p_dbl(-3, 3, trafo = function(x) 10^x))

  psx = shrink_ps(param_set, x = data.table(x = 2))
  expect_equal(psx$lower[["x"]], 0.5)
  expect_equal(psx$upper[["x"]], 3)
})

test_that("OptimizerBatchFocusSearch shrinks around the best point with a trafo", {
  objective = ObjectiveRFun$new(
    fun = function(xs) list(y = abs(log10(xs$x) - 2)),
    domain = ps(x = p_dbl(lower = 1e-3, upper = 1e3)),
    codomain = ps(y = p_dbl(tags = "minimize")),
    properties = "deterministic"
  )
  search_space = ps(x = p_dbl(-3, 3, trafo = function(x) 10^x))
  instance = oi(objective, search_space = search_space, terminator = trm("evals", n_evals = 200))

  optimizer = opt("focus_search", n_points = 10L, maxit = 19L)
  optimizer$optimize(instance)

  # the optimum is at x = 2 in the search space, focus search must get close
  expect_equal(instance$result_x_search_space$x, 2, tolerance = 0.1)
})
