test_that("EvalInstance basic construction works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()
  terminator$param_set$values$n_evals = 10

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  expect_r6(instance, "EvalInstance")
  expect_r6(instance$objective, "Objective")
  expect_r6(instance$search_space, "ParamSet")
  expect_r6(instance$terminator, "Terminator")
  expect_r6(instance$archive, "Archive")
})

test_that("EvalInstance label and man work", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive,
    label = "test_label",
    man = "bbotk::EvalInstance"
  )

  expect_equal(instance$label, "test_label")
  expect_equal(instance$man, "bbotk::EvalInstance")

  # default values
  instance2 = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive$clone(deep = TRUE)
  )
  expect_true(is.na(instance2$label))
  expect_true(is.na(instance2$man))
})

test_that("EvalInstance is_terminated and n_evals work", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()
  terminator$param_set$values$n_evals = 2

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  expect_false(instance$is_terminated)
  expect_equal(instance$n_evals, 0L)

  # add some evaluations
  xdt = data.table(x = c(0.5))
  xss_trafoed = list(list(x = 0.5))
  ydt = data.table(y = 0.25)
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_false(instance$is_terminated)
  expect_equal(instance$n_evals, 1L)

  # add more evaluations to trigger termination
  xdt = data.table(x = c(0.3))
  xss_trafoed = list(list(x = 0.3))
  ydt = data.table(y = 0.09)
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_true(instance$is_terminated)
  expect_equal(instance$n_evals, 2L)
})

test_that("EvalInstance clear works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()
  terminator$param_set$values$n_evals = 10

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  # add some evaluations
  xdt = data.table(x = c(0.5, 0.3))
  xss_trafoed = list(list(x = 0.5), list(x = 0.3))
  ydt = data.table(y = c(0.25, 0.09))
  archive$add_evals(xdt, xss_trafoed, ydt)

  # set context
  objective$context = list(foo = "bar")

  expect_equal(instance$n_evals, 2L)
  expect_data_table(archive$data, nrows = 2)
  expect_list(objective$context)

  # clear
  instance$clear()

  expect_equal(instance$n_evals, 0L)
  expect_data_table(archive$data, nrows = 0)
  expect_null(objective$context)
})

test_that("EvalInstance format works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  expect_equal(instance$format(), "<EvalInstance>")
})

test_that("EvalInstance print works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()
  terminator$param_set$values$n_evals = 10

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  expect_output(print(instance), "EvalInstance")
  expect_output(print(instance), "Objective")
  expect_output(print(instance), "Search Space")
  expect_output(print(instance), "Terminator")
  expect_output(print(instance), "Evaluations")
})

test_that("EvalInstance deep clone works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  instance2 = instance$clone(deep = TRUE)

  expect_different_address(instance$objective, instance2$objective)
  expect_different_address(instance$search_space, instance2$search_space)
  expect_different_address(instance$archive, instance2$archive)
  expect_different_address(instance$terminator, instance2$terminator)
})

test_that("EvalInstance works with learn tag in codomain", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y = p_dbl(tags = "learn"))
  objective = ObjectiveRFun$new(fun = function(xs) list(y = xs$x^2), domain = domain, codomain = codomain)
  archive = ArchiveBatch$new(search_space = domain, codomain = codomain)
  terminator = TerminatorEvals$new()

  instance = EvalInstance$new(
    objective = objective,
    search_space = domain,
    terminator = terminator,
    archive = archive
  )

  expect_r6(instance, "EvalInstance")
  expect_equal(instance$archive$codomain$direction, c(y = 0L))
})
