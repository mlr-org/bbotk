test_that("Objective works", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    private = list(
      .eval = function(xs) list(y = sum(as.numeric(xs))^2)
    )
  )
  obj = ObjectiveTestEval$new(domain = PS_2D)
  expect_snapshot(obj)
  expect_equal(obj$xdim, 2L)
  expect_equal(obj$ydim, 1L)
  xs = list(x1 = 0, x2 = 1)
  xss = replicate(3, xs, simplify = FALSE)
  res1 = obj$eval(xs)
  expect_list(res1, len = 1L)
  expect_names(names(res1), identical.to = "y")
  res2 = obj$eval_many(xss)
  expect_data_table(res2, nrows = 3, ncols = 1)
  expect_names(names(res2), identical.to = "y")

  # checked interface
  expect_silent(obj$eval(xs))
  xsf = list(x1 = 0, x2 = 3)
  expect_error(obj$eval(xsf), "is not <= 1")
  expect_silent(obj$eval_many(xss))
  xssf = xss
  xssf[[2]]$x1 = 2
  expect_error(obj$eval_many(xssf), "is not <= 1")

  ObjectiveTestEvalMany = R6Class("ObjectiveTestEvalMany",
    inherit = Objective,
    private = list(
      .eval_many = function(xss) {
        data.table(y = map_dbl(xss, function(xs) sum(as.numeric(xs))^2))
      }
    )
  )
  obj = ObjectiveTestEvalMany$new(domain = PS_2D)
  expect_snapshot(obj)
  res1many = obj$eval(xs)
  expect_list(res1many)
  res2many = obj$eval_many(replicate(3, xs, simplify = FALSE))
  expect_data_table(res2many)

  expect_equal(res1, res1many)
  expect_equal(res2, res2many)
})

test_that("Objective specialzations work", {

  FUN_1D_MANY = function(xss) data.table(y = map_dbl(xss, function(xs) as.numeric(xs)^2)) # Many version of FUN_1D in helper.R
  FUN_2D_MANY = function(xss) data.table(y = map_dbl(xss, function(xs) sum(as.numeric(xs)^2))) # same but FUN_2D
  FUN_2D_2D_MANY = function(xss) map_dtr(xss, function(xs) data.table(y1 = xs[[1]]^2, y2 = -xs[[2]]^2)) # same as FUN_2D_2D
  FUN_2D_DEPS_MANY = function(xss) data.table(y = map_dbl(xss, function(xs) sum(as.numeric(xs)^2, na.rm = TRUE)))

  FUN_1D_DT = function(xdt) data.table(y = xdt$x^2) # DT version oof FUN_1D in helper.R
  FUN_2D_DT = function(xdt) data.table(y = rowSums(xdt^2)) # same but FUN_2D
  FUN_2D_2D_DT = function(xdt) data.table(y1 = xdt[[1]]^2, y2 = -xdt[[2]]^2) # same as FUN_2D_2D
  FUN_2D_DEPS_DT = function(xdt) data.table(y = rowSums(xdt^2, na.rm = TRUE))


  # Different function pairs, where the R function uses a different signature but they should do the same
  funs = list(
    list( # 1d x, 1d y
      rfun = ObjectiveRFun$new(fun = FUN_1D, domain = PS_1D, codomain = FUN_1D_CODOMAIN),
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_1D_DT, domain = PS_1D, codomain = FUN_1D_CODOMAIN),
      rfun_many = ObjectiveRFunMany$new(fun = FUN_1D_MANY, domain = PS_1D, codomain = FUN_1D_CODOMAIN)
    ),
    list( # 2d x, 1d y
      rfun = ObjectiveRFun$new(fun = FUN_2D, domain = PS_2D),
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_2D_DT, domain = PS_2D),
      rfun_many = ObjectiveRFunMany$new(fun = FUN_2D_MANY, domain = PS_2D)
    ),
    list( # 2d x, 1d y + extra
      rfun = ObjectiveRFun$new(fun = FUN_2D_2D, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN$clone(deep = TRUE)$subset("y1"), id = "function_extras"),
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_2D_2D_DT, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN$clone(deep = TRUE)$subset("y1"), , id = "function_extras"),
      rfun_many = ObjectiveRFunMany$new(fun = FUN_2D_2D_MANY, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN$clone(deep = TRUE)$subset("y1"), , id = "function_extras")
    ),
    list( # 2d x, 2d y
      rfun = ObjectiveRFun$new(fun = FUN_2D_2D, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN),
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_2D_2D_DT, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN),
      rfun_many = ObjectiveRFunMany$new(fun = FUN_2D_2D_MANY, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN)
    ),
    list( # 2d x with deps, 1d y
      rfun = ObjectiveRFun$new(fun = FUN_2D_DEPS, domain = PS_2D_DEPS, check_values = FALSE), # dont check bc. we get NAs
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_2D_DEPS_DT, domain = PS_2D_DEPS, check_values = TRUE), # here NAs can get checked by assert_dt correctly
      rfun_many = ObjectiveRFunMany$new(fun = FUN_2D_DEPS_MANY, domain = PS_2D_DEPS, check_values = FALSE)
    )
  )

   fun_pairs = funs[[1]]

  for (fun_pairs in funs) {
    fun1 = fun_pairs$rfun
    fun2 = fun_pairs$rfun_dt
    fun3 = fun_pairs$rfun_many

    expect_function(fun1$fun) # check AB
    expect_function(fun2$fun)
    expect_function(fun3$fun)

    ps = fun1$domain
    sampler = SamplerUnif$new(param_set = ps)

    # one single x value
    xdt1 = sampler$sample(1)

    expected_ncols = fun1$codomain$length
    if ("function_extras" == fun1$id) expected_ncols = expected_ncols + 1
    expected_colnames = fun1$codomain$ids()
    if ("function_extras" == fun1$id) expected_colnames = c(expected_colnames, "y2")

    # eval_dt
    res1 = fun1$eval_dt(xdt1$data)
    expect_data_table(res1, nrows = 1, ncols = expected_ncols, any.missing = FALSE)
    expect_equal(colnames(res1), expected_colnames)
    expect_equal(res1, fun2$eval_dt(xdt1$data))
    expect_equal(res1, fun3$eval_dt(xdt1$data))

    # eval
    res2 = fun1$eval(xdt1$transpose()[[1]])
    expect_list(res2)
    expect_equal(names(res2), expected_colnames)
    expect_equal(res2, fun2$eval(xdt1$transpose()[[1]]))
    expect_equal(res2, fun3$eval(xdt1$transpose()[[1]]))

    # eval_many
    res3 = fun1$eval_many(xdt1$transpose())
    expect_equal(res1, res3)
    expect_equal(res3, fun2$eval_many(xdt1$transpose()))
    expect_equal(res3, fun3$eval_many(xdt1$transpose()))

    # multiple x values in one call
    xdt2 = sampler$sample(10)

    res4 = fun1$eval_dt(xdt2$data)
    expect_data_table(res4, nrows = 10, ncols = expected_ncols, any.missing = FALSE)
    expect_equal(colnames(res4), expected_colnames)
    expect_equal(res4, fun2$eval_dt(xdt2$data))
    expect_equal(res4, fun3$eval_dt(xdt2$data))

    res5 = fun1$eval_many(xdt2$transpose())
    expect_equal(res4, res5)
    expect_equal(res5, fun2$eval_many(xdt2$transpose()))
    expect_equal(res5, fun3$eval_many(xdt2$transpose()))
  }
})

test_that("codomain assertions work", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y1 = p_dbl(tags = "minimize"))
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")

  codomain = ps(y1 = p_dbl())
  expect_error(Objective$new(domain = domain, codomain = codomain), "Codomain contains no parameter tagged with 'minimize', 'maximize', or 'learn'")

  codomain = ps(y1 = p_lgl(tags = "minimize"))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain is not numeric")

  codomain = ps(y1 = p_dbl(tags = c("minimize", "maximize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain contains multiple target tags")

  codomain = ps(y1 = p_dbl(tags = "minimize"), y2 = p_dbl(tags = "maximize"))
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")

  codomain = ps(y1 = p_dbl(), y2 = p_dbl())
  expect_error(Objective$new(domain = domain, codomain = codomain), "Codomain contains no parameter tagged with 'minimize', 'maximize', or 'learn'")

  codomain = ps(y1 = p_dbl(tags = "minimize"), time = p_dbl())
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")

  codomain = ps(y1 = p_dbl(tags = "minimize"), y2 = p_lgl(tags = "maximize"))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y2 in codomain is not numeric")

  codomain = ps(y1 = p_lgl(tags = "minimize"), y2 = p_lgl(tags = "maximize"))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain is not numeric")

  codomain = ps(y1 = p_dbl(tags = "minimize"), y2 = p_dbl(tags = c("minimize", "maximize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y2 in codomain contains multiple target tags")

  codomain = ps(y1 = p_dbl(tags = c("minimize", "maximize")), y2 = p_dbl(tags = c("minimize", "maximize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain contains multiple target tags")
})

test_that("check_values flag works", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    private = list(
      .eval = function(xs) list(y = sum(as.numeric(xs))^2, extra = 2)
    )
  )

  obj = ObjectiveTestEval$new(domain = PS_2D, codomain = FUN_2D_CODOMAIN,
    check_values = FALSE)
  expect_list(obj$eval(list(x1 = 2, x2 = 1)), len = 2)

  obj = ObjectiveTestEval$new(domain = PS_2D, codomain = FUN_2D_CODOMAIN,
    check_values = TRUE)
  expect_error(obj$eval(list(x1 = 2, x2 = 1)),
    "<= 1.", fixed = TRUE)

  ObjectiveTestEvalMany = R6Class("ObjectiveTestEvalMany",
    inherit = Objective,
    private = list(
      .eval_many = function(xss) {
        data.table(y = map_dbl(xss, function(xs) sum(as.numeric(xs))^2))
      }
    )
  )

  obj = ObjectiveTestEvalMany$new(domain = PS_2D, check_values = FALSE)
  xs = list(x1 = 2, x2 = 1)
  expect_data_table(obj$eval_many(replicate(3, xs, simplify = FALSE)))

  obj = ObjectiveTestEvalMany$new(domain = PS_2D, check_values = TRUE)
  xs = list(x1 = 2, x2 = 1)
  expect_error(obj$eval(list(x1 = 2, x2 = 1)),
    "<= 1.", fixed = TRUE)
})

test_that("check_values = TRUE with extra output works", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    private = list(
      .eval = function(xs) list(y = sum(as.numeric(xs))^2, extra = 2)
    )
  )
  obj = ObjectiveTestEval$new(domain = PS_2D, codomain = FUN_2D_CODOMAIN)
  expect_list(obj$eval(list(x1 = 0, x2 = 1)), len = 2)

  ObjectiveTestEvalMany = R6Class("ObjectiveTestEvalCheck",
    inherit = Objective,
    private = list(
      .eval_many = function(xss) {
        res = data.table(y = map_dbl(xss, function(xs) sum(as.numeric(xs))^2))
        extra = list(extra = 2)
        res[, extra := extra]
      }
    )
  )
  obj = ObjectiveTestEvalMany$new(domain = PS_2D, codomain = FUN_2D_CODOMAIN)
  expect_data_table(obj$eval_many(
    list(list(x1 = 0, x2 = 1), list(x1 = 1, x2 = 0))), nrows = 2, ncols = 2)
})

test_that("assertion on overlapping and reserved names works", {
  expect_error(Objective$new(domain = ps(x = p_lgl()), codomain = ps(x = p_dbl(tags = "maximize"))),
    regexp = "disjunct from",
    fixed = TRUE)

  expect_error(Objective$new(domain = ps(batch_nr = p_lgl()), codomain = ps(x = p_dbl(tags = "maximize"))),
    regexp = "disjunct from",
    fixed = TRUE)

  expect_error(Objective$new(domain = ps(x = p_lgl()), codomain = ps(timestamp = p_dbl(tags = "maximize"))),
    regexp = "disjunct from",
    fixed = TRUE)
})

test_that("ObjectiveRFunDt works with a list containing elements with different order", {
  FUN = function(xdt) data.table(y = xdt$x)

  rfun_dt = ObjectiveRFunDt$new(fun = FUN, domain = ps(x = p_int(), z = p_int()), codomain = ps(y = p_int(tags = "minimize")))

  res = rfun_dt$eval_many(list(list(x = 1, z = 2), list(x = 1, z = 2)))
  expect_equal(res, data.table(y = c(1, 1)))
})

test_that("ObjectiveRFunDt works with deps #141", {
  FUN = function(xdt) {
    pmap_dtr(xdt, function(x1, x2) {
      data.table(y = if (is.na(x2)) x1 else x2)
    })
  }
  domain = ps(x1 = p_int(), x2 = p_int())
  domain$add_dep("x2", "x1", CondEqual$new(-1))
  codomain = ps(y = p_dbl(tags = "minimize"))
  rfun_dt = ObjectiveRFunDt$new(fun = FUN, domain = domain, codomain = codomain)

  design = Design$new(
    domain,
    data.table(x1 = c(-1, 1), x2 = c(2, 2)),
    remove_dupl = FALSE
  )
  xss = design$transpose(trafo = TRUE, filter_na = TRUE)
  res = rfun_dt$eval_many(xss)
  expect_equal(res, data.table(y = c(2, 1)))

  # all configuration miss the same parameter #189
  design = Design$new(
    domain,
    data.table(x1 = 1, x2 = 2),
    remove_dupl = FALSE
  )
  xss = design$transpose(trafo = TRUE, filter_na = TRUE)
  res = rfun_dt$eval_many(xss)
  expect_equal(res, data.table(y = 1))
})

test_that("Objective works with constants", {

  # .eval implemented
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    private = list(
      .eval = function(xs, c) list(y = xs[["x"]]^2 + c)
    )
  )

  objective = ObjectiveTestEval$new(domain = PS_1D, constants = ps(c = p_dbl()))
  objective$constants$values$c = 1

  expect_equal(objective$eval(list(x = 1)), list(y = 2))
  expect_equal(objective$eval(list(x = 0)), list(y = 1))
  expect_equal(objective$eval_many(list(list(x = 1), list(x = 0))), data.table(y = c(2, 1)))
  expect_equal(objective$eval_dt(data.table(x = c(1, 0))), data.table(y = c(2, 1)))

  # .eval_many implemented
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    private = list(
      .eval_many = function(xss, c) data.table(y = map_dbl(xss, function(xs) xs[["x"]]^2 + c))
    )
  )

  objective = ObjectiveTestEval$new(domain = PS_1D, constants = ps(c = p_dbl()))
  objective$constants$values$c = 1

  expect_equal(objective$eval(list(x = 1)), list(y = 2))
  expect_equal(objective$eval(list(x = 0)), list(y = 1))
  expect_equal(objective$eval_many(list(list(x = 1), list(x = 0))), data.table(y = c(2, 1)))
  expect_equal(objective$eval_dt(data.table(x = c(1, 0))), data.table(y = c(2, 1)))

  # ObjectiveRFun
  fun = function(xs, c) list(y = xs[["x"]]^2 + c)
  objective = ObjectiveRFun$new(fun = fun, domain = PS_1D, constants = ps(c = p_dbl()))
  objective$constants$values$c = 1

  expect_equal(objective$eval(list(x = 1)), list(y = 2))
  expect_equal(objective$eval(list(x = 0)), list(y = 1))
  expect_equal(objective$eval_many(list(list(x = 1), list(x = 0))), data.table(y = c(2, 1)))
  expect_equal(objective$eval_dt(data.table(x = c(1, 0))), data.table(y = c(2, 1)))

  # ObjectiveRFunDt
  fun = function(xdt, c) data.table(y = xdt[["x"]]^2 + c)
  objective = ObjectiveRFunDt$new(fun = fun, domain = PS_1D, constants = ps(c = p_dbl()))
  objective$constants$values$c = 1

  expect_equal(objective$eval(list(x = 1)), list(y = 2))
  expect_equal(objective$eval(list(x = 0)), list(y = 1))
  expect_equal(objective$eval_many(list(list(x = 1), list(x = 0))), data.table(y = c(2, 1)))
  expect_equal(objective$eval_dt(data.table(x = c(1, 0))), data.table(y = c(2, 1)))
})

test_that("objective can be initialized with empty codomain", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps()
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_r6(obj, "Objective")
})

test_that("deep cloning works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))
  codomain = ps(y1 = p_dbl(tags = "minimize"))
  objective = Objective$new(domain = domain, codomain = codomain)

  objective_2 = objective$clone(deep = TRUE)
  expect_different_address(objective$domain, objective_2$domain)
  expect_different_address(objective$codomain, objective_2$codomain)
  expect_different_address(objective$constants, objective_2$constants)
})

test_that("unnamed objective value works", {
  fun = function(xs) {
    xs$x^2
  }

  objective = ObjectiveRFun$new(fun = fun, domain = PS_1D_domain)

  expect_named(objective$eval(list(x = 1)), "y")
  expect_named(objective$eval_many(list(list(x = 1), list(x = 0))), "y")
})

test_that("named objective value works", {
  fun = function(xs) {
    c(y = xs$x^2)
  }

  objective = ObjectiveRFun$new(fun = fun, domain = PS_1D_domain)

  expect_named(objective$eval(list(x = 1)), "y")
  expect_named(objective$eval_many(list(list(x = 1), list(x = 0))), "y")
})

test_that("codomain with learn tag works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))

  # learn tag alone
  codomain = ps(y = p_dbl(tags = "learn"))
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")
  expect_equal(Objective$new(domain = domain, codomain = codomain)$codomain$direction, c(y = 0L))

  # learn tag with other tags
  codomain = ps(y = p_dbl(tags = c("learn", "random_tag")))
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")

  # multiple target tags error
  codomain = ps(y = p_dbl(tags = c("learn", "minimize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "multiple target tags")

  codomain = ps(y = p_dbl(tags = c("learn", "maximize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "multiple target tags")

  # mixed codomain with learn and optimize targets
  codomain = ps(y1 = p_dbl(tags = "learn"), y2 = p_dbl(tags = "minimize"))
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_r6(obj, "Objective")
  expect_equal(obj$codomain$direction, c(y1 = 0L, y2 = 1L))

  codomain = ps(y1 = p_dbl(tags = "maximize"), y2 = p_dbl(tags = "learn"))
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_equal(obj$codomain$direction, c(y1 = -1L, y2 = 0L))
})

test_that("codomain direction property works", {
  domain = ps(x = p_dbl(lower = -1, upper = 1))

  # minimize
  codomain = ps(y = p_dbl(tags = "minimize"))
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_equal(obj$codomain$direction, c(y = 1L))

  # maximize
  codomain = ps(y = p_dbl(tags = "maximize"))
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_equal(obj$codomain$direction, c(y = -1L))

  # learn
  codomain = ps(y = p_dbl(tags = "learn"))
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_equal(obj$codomain$direction, c(y = 0L))

  # multi-objective
  codomain = ps(
    y1 = p_dbl(tags = "minimize"),
    y2 = p_dbl(tags = "maximize"),
    y3 = p_dbl(tags = "learn")
  )
  obj = Objective$new(domain = domain, codomain = codomain)
  expect_equal(obj$codomain$direction, c(y1 = 1L, y2 = -1L, y3 = 0L))
})
