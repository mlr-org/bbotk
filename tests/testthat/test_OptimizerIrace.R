test_that("OptimizerBatchIrace minimize works", {
  skip_if_not_installed("irace")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15)
  )

  fun = function(xdt, instances) {
    data.table(y = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances)))
  }

  objective = ObjectiveRFunDt$new(fun = fun, domain = domain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 1000))


  optimizer = opt("irace", instances = rnorm(10, mean = 0, sd = 0.1))

  x = capture.output(optimizer$optimize(instance))

  # check archive columns
  archive = instance$archive$data
  expect_subset(c("race", "step", "configuration", "instance"), names(archive))

  # check optimization direction
  # first elite of the first race should have the lowest average performance
  load(optimizer$param_set$values$logFile)
  elites = iraceResults$allElites
  aggr = instance$archive$data[race == 1, .(y = mean(y)), by = configuration]
  expect_equal(aggr[which.min(y), configuration], elites[[1]][1])

  # the performance of the best configuration should be the mean performance across all evaluated instances
  configuration_id = instance$result$configuration
  expect_equal(unname(instance$result_y), mean(archive[configuration == configuration_id, y]))
})

test_that("OptimizerBatchIrace maximize works", {
  skip_if_not_installed("irace")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15)
  )

  fun = function(xdt, instances) {
    data.table(y = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances)))
  }

  codomain = ps(y = p_dbl(tags = "maximize"))
  objective = ObjectiveRFunDt$new(fun = fun, domain = domain, codomain = codomain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 96))

  optimizer = opt("irace", instances = rnorm(10, mean = 0, sd = 0.1))

  x = capture.output(optimizer$optimize(instance))

  # check archive columns
  archive = instance$archive$data
  expect_subset(c("race", "step", "configuration", "instance"), names(archive))

  # check optimization direction
  # first elite of the first race should have the highest average performance
  load(optimizer$param_set$values$logFile)
  elites = iraceResults$allElites
  aggr = instance$archive$data[race == 1, .(y = mean(y)), by = configuration]
  expect_equal(aggr[which.max(y), configuration], elites[[1]][1])

  # the performance of the best configuration should be the mean performance across all evaluated instances
  configuration_id = instance$result$configuration
  expect_equal(unname(instance$result_y), mean(archive[configuration == configuration_id, y]))
})

test_that("OptimizerBatchIrace assertions works",  {
  skip_if_not_installed("irace")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15)
  )

  fun = function(xdt, instances) {
    data.table(y = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances)))
  }

  objective = ObjectiveRFunDt$new(fun = fun, domain = domain)

  # unsupported terminators
  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("perf_reached", level = 0.1))

  optimizer = opt("irace", instances = rnorm(10, mean = 0, sd = 0.1))

  expect_error(optimizer$optimize(instance),
    regexp = "<TerminatorPerfReached> is not supported. Use <TerminatorEvals> instead",
    fixed = TRUE)
})

test_that("OptimizerBatchIrace works with passed constants set",  {
  skip_if_not_installed("irace")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15)
  )

  fun = function(xdt, instances) {
    data.table(y = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances)))
  }

  objective = ObjectiveRFunDt$new(fun = fun, domain = domain, constants = ps(instances = p_uty()))

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 96))

  optimizer = opt("irace", instances = rnorm(10, mean = 0, sd = 0.1))

  x = capture.output(optimizer$optimize(instance))
  expect_data_table(instance$result, nrows = 1)
})

test_that("OptimizerBatchIrace works without passed constants set",  {
  skip_if_not_installed("irace")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15)
  )

  fun = function(xdt, instances) {
    data.table(y = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances)))
  }

  objective = ObjectiveRFunDt$new(fun = fun, domain = domain)

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 96))

  optimizer = opt("irace", instances = rnorm(10, mean = 0, sd = 0.1))

  x = capture.output(optimizer$optimize(instance))
  expect_data_table(instance$result, nrows = 1)
})


test_that("paradox_to_irace without dependencies", {
  skip_if_not_installed("irace")

  # only ParamLgl
  pps = ps(lgl = p_lgl())
  expect_irace_parameters(parameters = paradox_to_irace(pps, 4), names = "lgl", types = "c",
    domain = list(lgl = c("TRUE", "FALSE")), conditions = list(lgl = TRUE))

  # only ParamUty
  pps = ps(uty = p_uty())
  expect_error(paradox_to_irace(pps, 4), regexp = "<ParamUty> not supported by <OptimizerBatchIrace>", fixed = TRUE)

  # mixed set
  pps = ps(
    dbl = p_dbl(lower = 0.1, upper = 0.3),
    int = p_int(lower = 1, upper = 9),
    fct = p_fct(levels = c("a", "b", "c")),
    lgl = p_lgl()
  )
  expect_irace_parameters(
    parameters = paradox_to_irace(pps, 4),
    names = c("dbl", "int", "fct", "lgl"),
    types = c("r", "i", "c", "c"),
    domain = list(dbl = c(0.1, 0.3), int = c(1, 9), fct = c("a", "b", "c"), lgl = c("TRUE", "FALSE")))

  # double checking previous bug in merge sort
  pps = ps(
    fct = p_fct(levels = c("a", "b", "c")),
    int1 = p_int(lower = 1, upper = 9),
    dbl = p_dbl(lower = 0.1, upper = 0.3),
    int2 = p_int(lower = 10, upper = 90),
    lgl = p_lgl()
  )
  expect_irace_parameters(
    parameters = paradox_to_irace(pps, 4),
    names = c("fct", "int1", "dbl", "int2", "lgl"),
    types = c("c", "i", "r", "i", "c"),
    domain = list(fct = c("a", "b", "c"), int1 = c(1, 9), dbl = c(0.1, 0.3), int2 = c(10, 90),
      lgl = c("TRUE", "FALSE")))
})

test_that("paradox_to_irace with dependencies", {
  skip_if_not_installed("irace")

  # one dependency
  pps = ps(
    a = p_lgl(),
    b = p_int(lower = 1, upper = 9, depends = a == TRUE)
  )
  expect_irace_parameters(
    parameters = paradox_to_irace(pps, 4), names = c("a", "b"), types = c("c", "i"),
    domain = list(a = c("TRUE", "FALSE"), b = c(1, 9)),
    conditions = list(a = TRUE, b = expression(a == TRUE)),
    depends = list(a = character(0), b = "a"),
    hierarchy = c(1, 2))

  # two dependencies
  pps = ps(
    a = p_lgl(),
    c = p_fct(levels = c("lvl1", "lvl2"), depends = b %in% c(2, 5, 7)),
    b = p_int(lower = 1, upper = 9, depends = a == TRUE)
  )
  expect_irace_parameters(
    parameters = paradox_to_irace(pps, 4), names = c("a", "c", "b"),
    types = c("c", "c", "i"),
    domain = list(a = c("TRUE", "FALSE"), c = c("lvl1", "lvl2"), b = c(1, 9)),
    conditions = list(
      a = TRUE, b = expression(a == TRUE),
      c = expression(b %in% c(2, 5, 7))),
    depends = list(a = character(0), c = "b", b = "a"),
    hierarchy = c(1, 3, 2))

  # three dependencies
  pps = ps(
    a = p_lgl(depends = c == "lvl1"),
    b = p_int(lower = 1, upper = 9, depends = a == TRUE),
    c = p_fct(levels = c("lvl1", "lvl2")),
    d = p_dbl(lower = 0, upper = 1, depends = c %in% c("lvl1", "lvl2"))
  )
  expect_irace_parameters(
    parameters = paradox_to_irace(pps, 4), names = c("a", "b", "c", "d"),
    types = c("c", "i", "c", "r"),
    domain = list(
      a = c("TRUE", "FALSE"), b = c(1, 9), c = c("lvl1", "lvl2"),
      d = c(0, 1)),
    conditions = list(
      c = TRUE, a = expression(c == "lvl1"),
      d = expression(c %in% c("lvl1", "lvl2")),
      b = expression(a == TRUE)),
    depends = list(a = "c", b = "a", c = character(0), d = "c"),
    hierarchy = c(2, 3, 1, 2))
})

test_that("paradox_to_irace works with parameters with multiple dependencies", {
  skip_if_not_installed("irace")

  pps = ps(
    a = p_lgl(),
    b = p_lgl(),
    c = p_fct(levels = c("lvl1", "lvl2", "lvl3")),
    d = p_fct(levels = c("lvl1", "lvl2", "lvl3", "lvl4")),
    e = p_int(lower = 1, upper = 9, depends = a == TRUE),
    f = p_int(lower = 1, upper = 9, depends = a == TRUE && b == TRUE),
    g = p_int(lower = 2, upper = 3, depends = c %in% c("lvl2", "lvl3")),
    h = p_int(lower = 2, upper = 3, depends = c %in% c("lvl2", "lvl3") && d %in% c("lvl3", "lvl4"))
  )
  expect_irace_parameters(
    parameters = paradox_to_irace(pps, 4), names = c("a", "b", "c", "d", "e", "f", "g", "h"), types = c("c", "c", "c", "c", "i", "i", "i", "i"),
    domain = list(a = c("TRUE", "FALSE"), b = c("TRUE", "FALSE"), c = c("lvl1", "lvl2", "lvl3"), d = c("lvl1", "lvl2", "lvl3", "lvl4"), e = c(1, 9), f = c(1, 9), g = c(2, 3), h = c(2, 3)),
    conditions = list(a = TRUE, b = TRUE, c = TRUE, d = TRUE, e = expression(a == TRUE), f = expression(a == TRUE & b == TRUE), g = expression(c %in% c("lvl2", "lvl3")), h = expression(c %in% c("lvl2", "lvl3") & d %in% c("lvl3", "lvl4"))),
    depends = list(a = character(0), b = character(0), c = character(0), d = character(0), e = "a", f = c("a", "b"), g = "c", h = c("c", "d")),
    hierarchy = c(1, 1, 1, 1, 2, 2, 2, 2))
})
