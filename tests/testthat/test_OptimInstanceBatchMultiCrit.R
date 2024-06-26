test_that("OptimInstanceBatchMultiCrit", {
  inst = MAKE_INST_2D_2D(20L)
  expect_snapshot(inst)
  expect_r6(inst$archive, "Archive")
  expect_data_table(inst$archive$data, nrows = 0L)
  expect_identical(inst$archive$n_evals, 0L)
  expect_identical(inst$archive$n_batch, 0L)

  xdt = data.table(x1 = c(-1, -1, -1), x2 = c(1, 0, -1))
  expect_named(inst$eval_batch(xdt), c("y1", "y2"))
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_equal(inst$archive$data$y1, c(1, 1, 1))
  expect_equal(inst$archive$data$y2, c(-1, 0, -1))
  expect_identical(inst$archive$n_evals, 3L)
  expect_identical(inst$archive$n_batch, 1L)
  expect_equal(inst$archive$best()$y2, 0)
  expect_null(inst$result)

  xdt = data.table(x1 = c(0, 0), x2 = c(list(0), list(0)))
  ydt = data.table(y1 = c(-10, -10), y2 = c(10, 10))
  inst$assign_result(xdt = xdt, ydt = ydt)
  expect_equal(inst$result_x_search_space, xdt)
  expect_equal(inst$result_y, ydt)
  expect_equal(inst$result_x_domain, replicate(n = 2, list(x1 = 0, x2 = 0), simplify = FALSE))
})

test_that("OptimInstanceBatchMultiCrit with 1 Crit", {
  tt = trm("evals", n_evals = 5)
  inst = OptimInstanceBatchMultiCrit$new(objective = OBJ_2D, search_space = PS_2D, terminator = tt)
  optimizer = OptimizerBatchRandomSearch$new()
  optimizer$optimize(inst)
  expect_data_table(inst$result_y, ncols = 1)
  expect_data_table(inst$result_x_search_space)
})

test_that("Terminator assertions work", {
  terminator = trm("perf_reached")
  expect_error(MAKE_INST_2D_2D(terminator))
})

test_that("objective_function works", {
  terminator = terminator = trm("evals", n_evals = 100)
  inst = MAKE_INST_2D_2D(terminator = terminator)
  y = inst$objective_function(c(1, 1))
  expect_equal(y, c(y1 = 1, y2 = 1))
})

test_that("OptimInstanceBatchMultiCrit works with empty search space", {
  fun = function(xs) {
    c(y = 10 + sample(c(0, 1), 1), z = 20 + sample(c(0, 1), 1))
  }
  domain = ps()
  codomain = ps(y = p_dbl(tags = "minimize"), z = p_dbl(tags = "maximize"))

  # objective
  objective = ObjectiveRFun$new(fun, domain, codomain)
  expect_numeric(objective$eval(list()))

  # instance
  instance = OptimInstanceBatchMultiCrit$new(objective, terminator = trm("evals", n_evals = 20))
  instance$eval_batch(data.table())
  expect_data_table(instance$archive$data, nrows = 1)

  # optimizer lenght(y) > 1
  instance = OptimInstanceBatchMultiCrit$new(objective, terminator = trm("evals", n_evals = 20))
  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_data_table(instance$archive$data, nrows = 20)
  expect_equal(instance$result$x_domain[[1]], list())


  # optimizer lenght(y) == 1
  instance = OptimInstanceBatchMultiCrit$new(objective, terminator = trm("evals", n_evals = 1))
  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 1)
  expect_equal(instance$result$x_domain[[1]], list())
})
