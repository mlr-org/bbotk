context("Objective")

test_that("Objective works", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    private = list(
      .eval = function(xs) list(y = sum(as.numeric(xs))^2)
    )
  )
  obj = ObjectiveTestEval$new(domain = PS_2D)
  expect_output(print(obj), "<ObjectiveTestEval:f>")
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
  expect_output(print(obj), "<ObjectiveTestEvalMany:f>")
  res1many = obj$eval(xs)
  expect_list(res1many)
  res2many = obj$eval_many(replicate(3, xs, simplify = FALSE))
  expect_data_table(res2many)

  expect_equal(res1, res1many)
  expect_equal(res2, res2many)
})

test_that("Objective specialzations work", {

  FUN_1D_DT = function(xdt) data.table(y = xdt$x^2) # DT version oof FUN_1D in helper.R
  FUN_2D_DT = function(xdt) data.table(y = rowSums(xdt^2)) # same but FUN_2D

  # Different function pairs, where the R function uses a different signature but they should do the same
  funs = list(
    list( # 1d x, 1d y
      rfun = ObjectiveRFun$new(fun = FUN_1D, domain = PS_1D, codomain = FUN_1D_CODOMAIN),
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_1D_DT, domain = PS_1D, codomain = FUN_1D_CODOMAIN)),
    list( # 2d x, 1d y
      rfun = ObjectiveRFun$new(fun = FUN_2D, domain = PS_2D),
      rfun_dt = ObjectiveRFunDt$new(fun = FUN_2D_DT, domain = PS_2D)
    )
  )

  for (fun_pairs in funs) {
    fun1 = fun_pairs$rfun
    fun2 = fun_pairs$rfun_dt

    expect_function(fun1$fun) #check AB
    expect_function(fun2$fun)

    expect_output(print(fun1), "ObjectiveRFun:function")
    expect_output(print(fun2), "ObjectiveRFunDt:function")

    ps = fun1$domain
    sampler = SamplerUnif$new(param_set = ps)

    # one single x value
    xdt1 = sampler$sample(1)

    res1 = fun1$eval_dt(xdt1$data)
    expect_data_table(res1, nrows = 1, ncols = 1, any.missing = FALSE)
    expect_equal(colnames(res1), "y")
    expect_equal(res1, fun2$eval_dt(xdt1$data))

    res2 = fun1$eval(xdt1$transpose()[[1]])
    expect_list(res2)
    expect_equal(names(res2), "y")
    expect_equal(res2, fun2$eval(xdt1$transpose()[[1]]))

    res3 = fun1$eval_many(xdt1$transpose())
    expect_equal(res1, res3)
    expect_equal(res3, fun2$eval_many(xdt1$transpose()))

    # multiple x values in one call
    xdt3 = sampler$sample(3)
    res4 = fun1$eval_dt(xdt3$data)
    expect_data_table(res4, nrows = 3, ncols = 1, any.missing = FALSE)
    expect_equal(colnames(res4), "y")
    expect_equal(res4, fun2$eval_dt(xdt3$data))

    res5 = fun1$eval_many(xdt3$transpose())
    expect_equal(res4, res5)
    expect_equal(res5, fun2$eval_many(xdt3$transpose()))
  }
})

test_that("codomain assertions work", {
  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = "minimize")))
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain contains no 'minimize' or 'maximize' tag")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamLgl$new("y1")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain is not numeric")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = c("minimize", "maximize"))))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain contains a 'minimize' and 'maximize' tag")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = "minimize"), ParamDbl$new("y2", tags = "maximize")))
  expect_r6(Objective$new(domain = domain, codomain = codomain), "Objective")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1"), ParamDbl$new("y2")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain contains no 'minimize' or 'maximize' tag")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = "minimize"), ParamDbl$new("y2")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y2 in codomain contains no 'minimize' or 'maximize' tag")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = "minimize"), ParamLgl$new("y2", tags = "maximize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y2 in codomain is not numeric")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamLgl$new("y1", tags = "minimize"), ParamLgl$new("y2", tags = "maximize")))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain is not numeric")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = "minimize"), ParamDbl$new("y2", tags = c("minimize", "maximize"))))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y2 in codomain contains a 'minimize' and 'maximize' tag")

  domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
  codomain = ParamSet$new(list(ParamDbl$new("y1", tags = c("minimize", "maximize")), ParamDbl$new("y2", tags = c("minimize", "maximize"))))
  expect_error(Objective$new(domain = domain, codomain = codomain), "y1 in codomain contains a 'minimize' and 'maximize' tag")
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
              fixed = "Assertion on 'X[[i]]' failed: x1: Element 1 is not <= 1.")

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
    fixed = "Assertion on 'X[[i]]' failed: x1: Element 1 is not <= 1.")
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


