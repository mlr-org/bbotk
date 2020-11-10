# Simple 1D Function
PS_1D_domain = ParamSet$new(list(
  ParamDbl$new("x", lower = -1, upper = 1),
  ParamUty$new("foo") # the domain of the function should not matter.
))
PS_1D = ParamSet$new(list(
  ParamDbl$new("x", lower = -1, upper = 1)
))
FUN_1D = function(xs) {
  list(y = as.numeric(xs)^2)
}
FUN_1D_CODOMAIN = ParamSet$new(list(ParamDbl$new("y", tags = c("minimize", "random_tag"))))
OBJ_1D = ObjectiveRFun$new(fun = FUN_1D, domain = PS_1D_domain, properties = "single-crit")

# Simple 2D Function
PS_2D_domain = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1),
  ParamUty$new("foo") # the domain of the function should not matter.
))
PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(xs) {
  y = sum(as.numeric(xs)^2)
  list(y = y)
}
FUN_2D_CODOMAIN = ParamSet$new(list(ParamDbl$new("y", tags = c("minimize", "random_tag"))))
OBJ_2D = ObjectiveRFun$new(fun = FUN_2D, domain = PS_2D_domain, properties = "single-crit")


# Simple 2D Function with trafo
PS_2D_TRF = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = 1, upper = 3)
))
PS_2D_TRF$trafo = function(x, param_set) {
  x$x2 = x$x2 - 2
  return(x)
}

# Simple 2D Function with deps
PS_2D_DEPS = ParamSet$new(list(
  ParamInt$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = 1, upper = 3)
))
PS_2D_DEPS$add_dep("x2", "x1", CondEqual$new(1))

# Multi-objecitve 2D->2D function
FUN_2D_2D = function(xs) {
  list(y1 = xs[[1]]^2, y2 = -xs[[2]]^2)
}
FUN_2D_2D_CODOMAIN = ParamSet$new(list(
  ParamDbl$new("y1", tags = "minimize"),
  ParamDbl$new("y2", tags = "maximize")
))

OBJ_2D_2D = ObjectiveRFun$new(fun = FUN_2D_2D, domain = PS_2D,
  codomain = FUN_2D_2D_CODOMAIN, properties = "multi-crit")

# General Helper
MAKE_INST = function(objective = OBJ_2D, search_space = PS_2D,
  terminator = 5L) {
  if (is.integer(terminator)) {
    tt = TerminatorEvals$new()
    tt$param_set$values$n_evals = terminator
    terminator = tt
  }
  if (objective$codomain$length == 1) {
    OptimInstanceSingleCrit$new(objective = objective, search_space = search_space, terminator = terminator)
  } else {
    OptimInstanceMultiCrit$new(objective = objective, search_space = search_space, terminator = terminator)
  }

}

MAKE_INST_1D = function(terminator) {
  MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = terminator)
}

MAKE_INST_2D = function(terminator) {
  MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = terminator)
}

MAKE_INST_2D_2D = function(terminator) {
  MAKE_INST(objective = OBJ_2D_2D, search_space = PS_2D,
    terminator = terminator)
}

test_optimizer = function(key, ..., n_dim, term_evals = 2L, real_evals = term_evals) {
  terminator = trm("evals", n_evals = term_evals)

  if (n_dim == 1) {
    search_space =  ParamSet$new(list(
      ParamDbl$new("x", lower = -1, upper = 1)
    ))
    domain = search_space
    codomain = ParamSet$new(list(
      ParamDbl$new("y", tags = "minimize")
    ))
    objective_function = function(xs) {
      y = sum(as.numeric(xs)^2)
      list(y = y)
    }
    objective = ObjectiveRFun$new(fun = objective_function, domain = domain,
      codomain = codomain, properties = "single-crit")
    instance = OptimInstanceSingleCrit$new(objective = objective,
      search_space = search_space, terminator = terminator)
  } else if (n_dim == 2) {
    search_space = ParamSet$new(list(
      ParamDbl$new("x1", lower = -1, upper = 1),
      ParamDbl$new("x2", lower = -1, upper = 1)
    ))
    codomain = ParamSet$new(list(
      ParamDbl$new("y1", tags = c("minimize", "random_tag")),
      ParamDbl$new("y2", tags = "maximize")
    ))
    domain = search_space
    objective_function = function(xs) {
      list(y1 = xs[[1]]^2, y2 = -xs[[2]]^2)
    }
    objective = ObjectiveRFun$new(fun = objective_function, domain = domain,
      codomain = codomain, properties = "multi-crit")
    instance = OptimInstanceMultiCrit$new(objective = objective,
      search_space = search_space, terminator = terminator)
  }

  optimizer = opt(key, ...)
  expect_class(optimizer, "Optimizer")
  optimizer$optimize(instance)
  archive = instance$archive

  expect_data_table(archive$data(), nrows = real_evals)
  expect_equal(instance$archive$n_evals, real_evals)

  x_opt = instance$result_x_domain
  y_opt = instance$result_y

  if (n_dim == 1) {
    expect_list(x_opt, len = n_dim)
    expect_named(x_opt, "x")
    expect_numeric(y_opt, len = n_dim)
    expect_named(y_opt, "y")
  } else {
    expect_list(x_opt[[1]], len = n_dim)
    expect_named(x_opt[[1]], c("x1", "x2"))
    expect_data_table(y_opt)
    expect_named(y_opt, c("y1", "y2"))
  }

  list(optimizer = optimizer, instance = instance)
}

MAKE_OPT = function(param_set = ParamSet$new(), param_classes = c("ParamDbl", "ParamInt"),
  properties = "single-crit", packages = character(0)) {
  Optimizer$new(param_set = param_set,
    param_classes = param_classes,
    properties = properties,
    packages = packages)
}
