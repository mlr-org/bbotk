test_that("OptimizerBatchLocalSearch works with numeric parameter", {
  domain = ps(
    x = p_dbl(lower = -1, upper = 1)
  )
  fun = function(xs) {
    list(y = as.numeric(xs)^2)
  }

  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x, lower = -1, upper = 1)
})

test_that("OptimizerBatchLocalSearch works with numeric parameters", {
  domain = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_dbl(lower = -1, upper = 1)
  )
  fun = function(xs) {
    list(y = sum(as.numeric(xs)^2))
  }
  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x1, lower = -1, upper = 1)
  expect_numeric(instance$archive$data$x2, lower = -1, upper = 1)
})

test_that("OptimizerBatchLocalSearch works with categorical parameters", {
  domain = ps(
    x = p_fct(c("a", "b"))
  )
  fun = function(xs) {
    list(y = if (xs$x == "a") 1 else 2)
  }
  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_character(instance$archive$data$x, any.missing = FALSE)
  expect_set_equal(instance$archive$data$x, c("a", "b"))
})

test_that("OptimizerBatchLocalSearch works with mixed spaces", {
  domain = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_fct(c("a", "b"))
  )

  fun = function(xs) {
    y = if (xs$x2 == "a") {
      xs$x1^2 + 1
    } else {
      xs$x1^2
    }
    list(y = y)
  }

  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x1, lower = -1, upper = 1)
  expect_character(instance$archive$data$x2, any.missing = FALSE)
  expect_set_equal(instance$archive$data$x2, c("a", "b"))
})

test_that("OptimizerBatchLocalSearch works with dependencies on logical parameter", {
  domain = ps(
    x1 = p_dbl(-5, 5, depends = x2 == TRUE),
    x2 = p_lgl()
  )

  fun = function(xs) {
    y = if (is.null(xs$x1)) {
      3
    } else {
      xs$x1^2
    }
    list(y = y)
  }

  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x1, lower = -5, upper = 5)
  expect_logical(instance$archive$data$x2, any.missing = FALSE)
  if (nrow(instance$archive$data[x2 == FALSE])) expect_set_equal(instance$archive$data[x2 == FALSE]$x1, NA)
  if (nrow(instance$archive$data[x2 == FALSE])) expect_set_equal(instance$archive$data[x2 == FALSE]$y, 3)
})

test_that("OptimizerBatchLocalSearch works with dependencies on factor parameter", {
  domain = ps(
    x1 = p_dbl(-5, 5, depends = x2 == "a"),
    x2 = p_fct(c("a", "b"))
  )

  fun = function(xs) {
    y = if (is.null(xs$x1)) {
      3
    } else {
      xs$x1^2
    }
    list(y = y)
  }
  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x1, lower = -5, upper = 5)
  expect_character(instance$archive$data$x2, any.missing = FALSE)
  if (nrow(instance$archive$data[x2 == "b"])) expect_set_equal(instance$archive$data[x2 == "b"]$x1, NA)
  if (nrow(instance$archive$data[x2 == "b"])) expect_set_equal(instance$archive$data[x2 == "b"]$y, 3)
})

test_that("OptimizerBatchLocalSearch works with dependencies on factor parameters with multiple values", {
  domain = ps(
    x1 = p_dbl(-5, 5, depends = x2 %in% c("a", "b")),
    x2 = p_fct(c("a", "b", "c"))
  )

  fun = function(xs) {
    y = if (is.null(xs$x1)) {
      3
    } else {
      xs$x1^2
    }
    list(y = y)
  }
  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")

  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x1, lower = -5, upper = 5)
  expect_character(instance$archive$data$x2, any.missing = FALSE)
  if (nrow(instance$archive$data[x2 == "c"])) expect_set_equal(instance$archive$data[x2 == "c"]$y, 3)
  if (nrow(instance$archive$data[x2 == "c"])) expect_set_equal(instance$archive$data[x2 == "c"]$x1, NA)
})

test_that("OptimizerBatchLocalSearch works with dependencies on numeric parameters", {
  domain = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_dbl(lower = -1, upper = 1)
    )
  domain$add_dep("x2", on = "x1", cond = CondEqual$new(1))

  fun = function(xs) {
    y = sum(as.numeric(xs)^2)
    list(y = y)
  }
  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")

  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  expect_numeric(instance$archive$data$x1, lower = -1, upper = 1)
  expect_numeric(instance$archive$data$x2, lower = -1, upper = 1)
  if (nrow(instance$archive$data[x1 != 1])) expect_set_equal(instance$archive$data[x1 != 1]$x2, NA)
})

test_that("OptimizerBatchLocalSearch works with trafo", {
  domain = ps(
    x1 = p_dbl(lower = 0, upper = 1),
    x2 = p_dbl(lower = 1, upper = 10)
  )
  search_space = ps(
    x1 = p_dbl(lower = -1, upper = 1, trafo = function(x) x^2),
    x2 = p_dbl(lower = 1, upper = 10, logscale = TRUE)
  )
  fun = function(xs) {
    list(y = - sum(as.numeric(xs)^2))
  }
  codomain = ps(
    y = p_dbl(lower = -101, upper = 0, tags = "maximize")
  )
  objective = ObjectiveRFun$new(fun = fun, domain = domain, codomain = codomain, properties = "single-crit")
  instance = oi(objective = objective, search_space = search_space, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 510L)
  archive = as.data.table(instance$archive, unnest = "x_domain")
  expect_true(all(archive$x_domain_x1 >= 0))
  expect_true(all(archive$x_domain_x1 <= 1))
  expect_true(all(archive$x_domain_x2 >= 1))
  expect_true(all(archive$x_domain_x2 <= 10.1))
})

test_that("OptimizerBatchLocalSearch works with errors", {
  domain = ps(
    x1 = p_dbl(-5, 5)
  )

  fun = function(xs) {
    stopf("test error")
  }

  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")

  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  expect_error(optimizer$optimize(instance))
})

test_that("OptimizerBatchLocalSearch works with minimization", {
  domain = ps(
    x1 = p_dbl(-5, 5),
    x2 = p_dbl(-5, 5)
  )

  fun = function(xs) {
    list(y =  xs$x1 * xs$x2)
  }
  codomain = ps(
    y = p_dbl(lower = -25, upper = 25, tags = "minimize")
  )
  objective = ObjectiveRFun$new(fun = fun, domain = domain, codomain = codomain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_true(all(instance$archive$data$x1 * instance$archive$data$x2 == instance$archive$data$y))
  expect_equal(instance$archive$best()$y, min(instance$archive$data$y))
})

test_that("OptimizerBatchLocalSearch works with minimization", {
  domain = ps(
    x1 = p_dbl(-5, 5),
    x2 = p_dbl(-5, 5)
  )

  fun = function(xs) {
    list(y =  xs$x1 * xs$x2)
  }
  codomain = ps(
    y = p_dbl(lower = -25, upper = 25, tags = "maximize")
  )
  objective = ObjectiveRFun$new(fun = fun, domain = domain, codomain = codomain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_true(all(instance$archive$data$x1 * instance$archive$data$x2 == instance$archive$data$y))
  expect_equal(instance$archive$best()$y, max(instance$archive$data$y))
})

test_that("OptimizerBatchLocalSearch evaluates the right number of points", {
  domain = ps(
    x = p_dbl(lower = -1, upper = 1)
  )
  fun = function(xs) {
    list(y = as.numeric(xs)^2)
  }

  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 1L, n_steps = 1L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 11L)
  expect_data_table(instance$archive$data[batch_nr == 1], nrows = 1L)
  expect_data_table(instance$archive$data[batch_nr == 2], nrows = 10L)

  instance$clear()
  optimizer = opt("local_search", n_searches = 1L, n_steps = 2L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 21L)
  expect_data_table(instance$archive$data[batch_nr == 1], nrows = 1L)
  expect_data_table(instance$archive$data[batch_nr == 2], nrows = 10L)
  expect_data_table(instance$archive$data[batch_nr == 3], nrows = 10L)

  objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")
  instance = oi(objective = objective, search_space = domain, terminator = trm("evals", n_evals = 500L))
  optimizer = opt("local_search", n_searches = 2L, n_steps = 1L, n_neighbors = 10L)
  optimizer$optimize(instance)

  expect_data_table(instance$archive$data, nrows = 22L)
  expect_data_table(instance$archive$data[batch_nr == 1], nrows = 2L)
  expect_data_table(instance$archive$data[batch_nr == 2], nrows = 20L)
})
