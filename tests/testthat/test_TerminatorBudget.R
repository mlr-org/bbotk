test_that("TerminatorBudget works", {
  PS_2D_BUDGET = ps(
    x = p_dbl(lower = -1, upper = 1),
    iterations = p_int(lower = 1, tags = "budget")
  )

  FUN_2D_BUDGET = function(xs) {
    y = sum(as.numeric(xs$x)^2)
      list(y = y)
    }

  objective = ObjectiveRFun$new(fun = FUN_2D_BUDGET, domain = PS_2D_BUDGET, properties = "single-crit")

  terminator = trm("budget", budget = 10)
  instance = OptimInstanceSingleCrit$new(objective, search_space = PS_2D_BUDGET, terminator = terminator)

  expect_false(terminator$is_terminated(instance$archive))
  expect_equal(instance$terminator$status(instance$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(instance$terminator$status(instance$archive)["current_steps"], c("current_steps" = 0))

  xdt = data.table(x = 1, iterations = 2)
  instance$eval_batch(xdt)
  expect_false(terminator$is_terminated(instance$archive))
  expect_equal(instance$terminator$status(instance$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(instance$terminator$status(instance$archive)["current_steps"], c("current_steps" = 20))

  xdt = data.table(x = 0.5, iterations = 3)
  instance$eval_batch(xdt)
  expect_false(terminator$is_terminated(instance$archive))
  expect_equal(instance$terminator$status(instance$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(instance$terminator$status(instance$archive)["current_steps"], c("current_steps" = 50))

  xdt = data.table(x = 0.5, iterations = 10)
  instance$archive$add_evals(xdt, status = "proposed")
  expect_false(terminator$is_terminated(instance$archive))
  expect_equal(instance$terminator$status(instance$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(instance$terminator$status(instance$archive)["current_steps"], c("current_steps" = 50))

  xdt = data.table(x = -0.5, iterations = 5)
  instance$eval_batch(xdt)
  expect_true(terminator$is_terminated(instance$archive))
  expect_equal(instance$terminator$status(instance$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(instance$terminator$status(instance$archive)["current_steps"], c("current_steps" = 100))
})
