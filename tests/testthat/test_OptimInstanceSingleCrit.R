test_that("OptimInstanceSingleCrit", {
  inst = MAKE_INST_2D(20L)
  expect_r6(inst$archive, "Archive")
  expect_data_table(inst$archive$data, nrows = 0L)
  expect_identical(inst$archive$n_evals, 0L)
  expect_identical(inst$archive$n_batch, 0L)
  expect_null(inst$result)
  expect_output(print(inst), "Not optimized")
  expect_output(print(inst), "ObjectiveRFun:function")
  expect_output(print(inst), "^(?s)(?!.*Result).*$", perl = TRUE)
  expect_output(print(inst), "<TerminatorEvals>")

  xdt = data.table(x1 = -1:1, x2 = list(-1, 0, 1))
  expect_named(inst$eval_batch(xdt), "y")
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_equal(inst$archive$data$y, c(2, 0, 2))
  expect_identical(inst$archive$n_evals, 3L)
  expect_identical(inst$archive$n_batch, 1L)
  expect_null(inst$result)
  inst$assign_result(xdt = xdt[2, ], y = c(y = -10))
  expect_equal(inst$result, cbind(xdt[2, ], x_domain = list(list(x1 = 0, x2 = 0)), y = -10))

  inst = MAKE_INST_2D(20L)
  optimizer = opt("random_search")
  optimizer$optimize(inst)
  expect_output(print(inst), "Optimized")
  expect_output(print(inst), "ObjectiveRFun:function")
  expect_output(print(inst), "<TerminatorEvals>")
  expect_output(print(inst), "Result")
})

test_that("OptimInstance works with trafos", {
  inst = MAKE_INST(objective = OBJ_2D, search_space = PS_2D_TRF, 20L)
  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_equal(inst$archive$data$y, c(2, 0, 2))
  expect_equal(inst$archive$data$x_domain[[1]], list(x1 = -1, x2 = -1))
  expect_output(print(inst), "<OptimInstanceSingleCrit>")
})

test_that("OptimInstance works with extras input", {
  inst = MAKE_INST(objective = OBJ_2D, search_space = PS_2D_TRF, 20L)
  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3), extra1 = letters[1:3], extra2 = as.list(LETTERS[1:3]))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data, nrows = 3L)
  expect_equal(inst$archive$data$y, c(2, 0, 2))
  expect_equal(inst$archive$data$x_domain[[1]], list(x1 = -1, x2 = -1))
  expect_subset(colnames(xdt), colnames(inst$archive$data))
  expect_equal(xdt, inst$archive$data[, colnames(xdt), with = FALSE])

  # just add extras sometimes
  xdt = data.table(x1 = -1:1, x2 = list(1, 2, 3), extra2 = as.list(letters[4:6]), extra3 = list(1:3, 2:4, 3:5))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data, nrows = 6L)
  expect_equal(inst$archive$data$y, c(2, 0, 2, 2, 0, 2))
  expect_equal(xdt, inst$archive$data[4:6, colnames(xdt), with = FALSE])
  expect_equal(inst$archive$data$extra3[1:3], list(NULL, NULL, NULL))
  expect_equal(inst$archive$data$extra1[4:6], rep(NA_character_, 3))
})

test_that("OptimInstance works with extras output", {
  fun_extra = function(xs) {
    y = sum(as.numeric(xs)^2)
    res = list(y = y, extra1 = runif(1), extra2 = list(a = runif(1), b = Sys.time()))
    if (y > 0.5) { # sometimes add extras
      res$extra3 = -y
    }
    return(res)
  }
  obj_extra = ObjectiveRFun$new(fun = fun_extra, domain = PS_2D, codomain = FUN_2D_CODOMAIN)
  inst = MAKE_INST(objective = obj_extra, search_space = PS_2D, terminator = 20L)
  xdt = data.table(x1 = c(0.25, 0.5), x2 = c(0.25, 0.5))
  inst$eval_batch(xdt)
  expect_equal(xdt, inst$archive$data[, obj_extra$domain$ids(), with = FALSE])
  expect_numeric(inst$archive$data$extra1, any.missing = FALSE, len = nrow(xdt))
  expect_list(inst$archive$data$extra2, len = nrow(xdt))

  xdt = data.table(x1 = c(0.75, 1), x2 = c(0.75, 1))
  inst$eval_batch(xdt)
  expect_equal(inst$archive$data$extra3, c(NA, NA, -1.125, -2))
})

test_that("Terminator assertions work", {
  terminator = trm("perf_reached")
  expect_error(MAKE_INST_2D_2D(terminator = terminator), "does not support multi-crit optimization")
})

test_that("objective_function works", {
  terminator = trm("evals", n_evals = 100)
  inst = MAKE_INST_1D(terminator = terminator)
  y = inst$objective_function(1)
  expect_equal(y, c(y = 1))

  obj = ObjectiveRFun$new(fun = FUN_1D, domain = PS_1D_domain, codomain = ps(y = p_dbl(tags = "maximize")))
  inst = MAKE_INST(objective = obj, search_space = PS_1D, terminator = terminator)
  y = inst$objective_function(1)
  expect_equal(y, c(y = -1))

  z = optimize(inst$objective_function, lower = inst$search_space$lower,
    upper = inst$search_space$upper)
  expect_list(z, any.missing = FALSE, names = "named", len = 2L)

  search_space = ps(
    x1 = p_lgl(),
    x2 = p_dbl(lower = -1, upper = 1)
  )
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

test_that("OptimInstanceSingleCrit$eval_batch() throws and error if columns are missing", {
  inst = MAKE_INST_2D(20L)
  expect_error(inst$eval_batch(data.table(x1 = 0)),
    regexp = "include the elements",
    fixed = TRUE)
})

test_that("domain, search_space and TuneToken work", {

  domain = ps(
    x1 = p_dbl(-10, 10),
    x2 = p_dbl(-5, 5)
  )

  codomain = ps(
    y = p_dbl(tags = "maximize")
  )

  objective = Objective$new(
    domain = domain,
    codomain = codomain
  )

  # only domain
  instance = OptimInstanceSingleCrit$new(
    objective = objective,
    terminator = trm("none")
  )

  expect_equal(domain, instance$search_space)

  # search_space and domain
  search_space = ps(
    x1 = p_dbl(-10, 10)
  )

  instance = OptimInstanceSingleCrit$new(
    objective = objective,
    terminator = trm("none"),
    search_space = search_space
  )

  expect_equal(search_space, instance$search_space)

  # TuneToken
  domain$values$x1 = to_tune()

  objective = Objective$new(
    domain = domain,
    codomain = codomain
  )

  instance = OptimInstanceSingleCrit$new(
    objective = objective,
    terminator = trm("none"),
  )

  expect_equal(domain$search_space(), instance$search_space)

  # TuneToken and search_space
  expect_error(OptimInstanceSingleCrit$new(objective = objective, terminator = trm("none"), search_space = search_space),
    regexp = "If the domain contains TuneTokens, you cannot supply a search_space")
})

test_that("OptimInstanceSingleCrit works with empty search space", {
  fun = function(xs) {
    c(y = 10 + rnorm(1))
  }
  domain = ps()
  codomain = ps(y = p_dbl(tags = "minimize"))

  # objective
  objective = ObjectiveRFun$new(fun, domain, codomain)
  expect_numeric(objective$eval(list()))

  # instance
  instance = OptimInstanceSingleCrit$new(objective, terminator = trm("evals", n_evals = 20))
  instance$eval_batch(data.table())
  expect_data_table(instance$archive$data, nrows = 1)

  # optimizer
  instance = OptimInstanceSingleCrit$new(objective, terminator = trm("evals", n_evals = 20))
  optimizer = opt("random_search")
  optimizer$optimize(instance)
  expect_data_table(instance$archive$data, nrows = 20)
  expect_equal(instance$result$x_domain[[1]], list())
})

test_that("deep clone works", {
  inst = MAKE_INST_2D(20L)
  inst_2 = inst$clone(deep = TRUE)

  expect_different_address(inst$objective, inst_2$objective)
  expect_different_address(inst$search_space, inst_2$search_space)
  expect_different_address(inst$archive, inst_2$archive)
  expect_different_address(inst$terminator, inst_2$terminator)
})

test_that("$clear() method works", {
  inst = MAKE_INST_2D(1L)
  inst_copy = inst$clone(deep = TRUE)
  optimizer = opt("random_search")

  optimizer$optimize(inst)
  inst$clear()
  expect_equal(inst, inst_copy)
})

# rush -------------------------------------------------------------------------

test_that("OptimInstanceSingleCrit works with rush", {
  skip_on_cran()
  skip_on_ci()

  config = start_flush_redis()
  future::plan("multisession", workers = 2L)
  rush = Rush$new("test", config)

  instance = OptimInstanceSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 3L),
    rush = rush,
    start_workers = TRUE
  )

  expect_equal(rush$n_workers, 2)
  optimizer = opt("random_search")

  expect_data_table(optimizer$optimize(instance), nrows = 1)
  expect_data_table(as.data.table(instance$archive), nrows = 3)
})

test_that("archive is froozen", {
  skip_on_cran()
  skip_on_ci()

  config = start_flush_redis()
  future::plan("multisession", workers = 2L)
  rush = Rush$new("test", config)

  instance = OptimInstanceSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush,
    start_workers = TRUE,
    freeze_archive = TRUE
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_null(instance$archive$rush)
  expect_data_table(instance$archive$data, min.rows = 10L)
})

test_that("timestamps are written to the archive", {
  skip_on_cran()
  skip_on_ci()

  config = start_flush_redis()
  future::plan("multisession", workers = 2L)
  rush = Rush$new("test", config)

  instance = OptimInstanceSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush,
    start_worker = TRUE,
    freeze_archive = TRUE
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  assert_names(names(instance$archive$data), must.include = c("timestamp_xs", "timestamp_ys"))
  expect_true(all(instance$archive$data$timestamp_xs < instance$archive$data$timestamp_ys))
})

test_that("saving lgr logs works", {
  skip_on_cran()
  skip_on_ci()

  config = start_flush_redis()
  future::plan("multisession", workers = 2L)
  rush = Rush$new("test", config)

  instance = OptimInstanceSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 3L),
    rush = rush,
    start_workers = TRUE,
    lgr_thresholds = c(rush = "debug")
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  log = rush$read_log()
  expect_data_table(log, nrows = 12)
  expect_names(names(log), must.include = c("worker_id", "timestamp", "logger", "msg"))
})
