context("OptimInstanceSingleCrit")

test_that("OptimInstanceSingleCrit", {
  inst = MAKE_INST_2D(20L)
  expect_r6(inst$archive, "Archive")
  expect_data_table(inst$archive$data(), nrows = 0L)
  expect_identical(inst$archive$n_evals, 0L)
  expect_identical(inst$archive$n_batch, 0L)
  expect_null(inst$result)
  expect_output(print(inst), "Not optimized")
  expect_output(print(inst), "ObjectiveRFun:function")
  expect_output(print(inst), "<ParamSet>")
  expect_output(print(inst), "^(?s)(?!.*Result).*$", perl = TRUE)
  expect_output(print(inst), "<TerminatorEvals>")
  expect_output(print(inst), "Terminated: FALSE")
  expect_output(print(inst), "<Archive>")

  xdt = data.table(x1 = -1:1, x2 = list(-1, 0, 1))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data(), nrows = 3L)
  expect_equal(inst$archive$data()$y, c(2, 0, 2))
  expect_identical(inst$archive$n_evals, 3L)
  expect_identical(inst$archive$n_batch, 1L)
  expect_null(inst$result)
  inst$assign_result(xdt = xdt[2,], y = c(y = -10))
  expect_equal(inst$result, cbind(xdt[2,], x_domain = list(list(x1 = 0, x2 = 0)), y = -10))

  inst = MAKE_INST_2D(20L)
  optimizer = opt("random_search")
  optimizer$optimize(inst)
  expect_output(print(inst), "Optimized")
  expect_output(print(inst), "ObjectiveRFun:function")
  expect_output(print(inst), "<ParamSet>")
  expect_output(print(inst), "<TerminatorEvals>")
  expect_output(print(inst), "Terminated: TRUE")
  expect_output(print(inst), "Result")
  expect_output(print(inst), "<Archive>")
})

test_that("OptimInstance works with trafos", {
  inst = MAKE_INST(objective = OBJ_2D, search_space = PS_2D_TRF, 20L)
  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data(), nrows = 3L)
  expect_equal(inst$archive$data()$y, c(2, 0, 2))
  expect_equal(inst$archive$data()$x_domain[[1]], list(x1 = -1, x2 = -1))
  expect_output(print(inst), "<OptimInstanceSingleCrit>")
})

test_that("OptimInstance works with extras input", {
  inst = MAKE_INST(objective = OBJ_2D, search_space = PS_2D_TRF, 20L)
  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3), extra1 = letters[1:3], extra2 = as.list(LETTERS[1:3]))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data(), nrows = 3L)
  expect_equal(inst$archive$data()$y, c(2, 0, 2))
  expect_equal(inst$archive$data()$x_domain[[1]], list(x1 = -1, x2 = -1))
  expect_subset(colnames(xdt), colnames(inst$archive$data()))
  expect_equal(xdt, inst$archive$data()[, colnames(xdt), with = FALSE])

  # just add extras sometimes
  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3), extra2 = as.list(letters[4:6]), extra3 = list(1:3, 2:4, 3:5))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data(), nrows = 6L)
  expect_equal(inst$archive$data()$y, c(2, 0, 2, 2, 0, 2))
  expect_equal(xdt, inst$archive$data()[4:6, colnames(xdt), with = FALSE])
  expect_equal(inst$archive$data()$extra3[1:3], list(NULL, NULL, NULL))
  expect_equal(inst$archive$data()$extra1[4:6], rep(NA_character_, 3))
})

test_that("OptimInstance works with extras output", {
  fun_extra = function(xs) {
    y = sum(as.numeric(xs)^2)
    res = list(y = y, extra1 = runif(1), extra2 = list(a = runif(1), b = Sys.time()))
    if (y > 0.5) { #sometimes add extras
      res$extra3 = -y
    }
    return(res)
  }
  obj_extra = ObjectiveRFun$new(fun = fun_extra, domain = PS_2D, codomain = FUN_2D_CODOMAIN)
  inst = MAKE_INST(objective = obj_extra, search_space = PS_2D, terminator = 20L)
  xdt = data.table(x1 = c(0.25, 0.5), x2 = c(0.25, 0.5))
  inst$eval_batch(xdt)
  expect_equal(xdt, inst$archive$data()[, obj_extra$domain$ids(), with = FALSE])
  expect_numeric(inst$archive$data()$extra1, any.missing = FALSE, len = nrow(xdt))
  expect_list(inst$archive$data()$extra2, len = nrow(xdt))

  xdt = data.table(x1 = c(0.75, 1), x2 = c(0.75, 1))
  inst$eval_batch(xdt)
  expect_equal(inst$archive$data()$extra3, c(NA, NA, -1.125, -2))
})

test_that("Terminator assertions work", {
  terminator = Terminator$new()
  terminator$properties = "multi-crit"
  expect_error(MAKE_INST(terminator = terminator))
})

test_that("objective_function works", {
  terminator = trm("evals", n_evals = 100)
  inst = MAKE_INST_1D(terminator = terminator)
  y = inst$objective_function(1)
  expect_equal(y, c(y = 1))

  obj = ObjectiveRFun$new(fun = FUN_1D, domain = PS_1D_domain, codomain = ParamSet$new(list(ParamDbl$new("y", tags = "maximize"))))
  inst = MAKE_INST(objective = obj, search_space = PS_1D, terminator = terminator)
  y = inst$objective_function(1)
  expect_equal(y, c(y = -1))

  z = optimize(inst$objective_function, lower = inst$search_space$lower,
    upper = inst$search_space$upper)
  expect_list(z, any.missing = FALSE, names = "named", len = 2L)

  search_space = ParamSet$new(list(
    ParamLgl$new("x1"),
    ParamDbl$new("x2", lower = -1, upper = 1)
  ))
  inst = MAKE_INST(objective = obj, search_space = search_space, terminator = terminator)
  expect_error(inst$objective_function(1), "objective_function can only")
})

test_that("search_space is optional", {
  inst = OptimInstanceSingleCrit$new(objective = OBJ_1D, terminator = TerminatorEvals$new())
  expect_identical(inst$search_space, OBJ_1D$domain)
})

test_that("OptimInstaceSingleCrit does not work with codomain > 1", {
  expect_error(OptimInstanceSingleCrit$new(objective = OBJ_2D_2D,
    terminator = trm("none")), "Codomain > 1")
})

