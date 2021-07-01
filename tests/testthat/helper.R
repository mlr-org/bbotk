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
FUN_2D_DEPS = function(xs) {
  y = sum(as.numeric(xs)^2, na.rm = TRUE) # for PS with dependencies we ignore the not present param
  list(y = y)
}
PS_2D_DEPS = PS_2D$clone(deep = TRUE)
PS_2D_DEPS$add_dep("x2", "x1", CondEqual$new(1))
OBJ_2D_DEPS = ObjectiveRFun$new(fun = FUN_2D_DEPS, domain = PS_2D_DEPS, properties = "single-crit")

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

test_optimizer_1d = function(key, ..., term_evals = 2L, real_evals = term_evals) {
  terminator = trm("evals", n_evals = term_evals)
  instance = OptimInstanceSingleCrit$new(objective = OBJ_1D, search_space = PS_1D, terminator = terminator)
  res = test_optimizer(instance = instance, key = key, ..., real_evals = real_evals)

  x_opt = res$instance$result_x_domain
  y_opt = res$instance$result_y
  expect_list(x_opt, len = 1)
  expect_named(x_opt, "x")
  expect_numeric(y_opt, len = 1)
  expect_named(y_opt, "y")

  return(res)
}

test_optimizer_2d = function(key, ..., term_evals = 2L, real_evals = term_evals) {
  terminator = trm("evals", n_evals = term_evals)
  instance = OptimInstanceMultiCrit$new(objective = OBJ_2D_2D, search_space = PS_2D, terminator = terminator)
  res = test_optimizer(instance = instance, key = key, ..., real_evals = real_evals)

  x_opt = res$instance$result_x_domain
  y_opt = res$instance$result_y
  expect_list(x_opt[[1]], len = 2)
  expect_named(x_opt[[1]], c("x1", "x2"))
  expect_data_table(y_opt)
  expect_named(y_opt, c("y1", "y2"))

  return(res)
}

test_optimizer_dependencies = function(key, ..., term_evals = 2L, real_evals = term_evals) {
  terminator = trm("evals", n_evals = term_evals)
  instance = OptimInstanceSingleCrit$new(objective = OBJ_2D_DEPS, search_space = PS_2D_DEPS, terminator = terminator)
  res = test_optimizer(instance = instance, key = key, ..., real_evals = real_evals)
  x_opt = res$instance$result_x_domain
  y_opt = res$instance$result_y
  expect_list(x_opt)
  expect_names(names(x_opt),  subset.of = c("x1", "x2"))
  expect_numeric(y_opt, len = 1)
  expect_named(y_opt, "y")

  return(res)
}

test_optimizer = function(instance, key, ..., real_evals) {
  optimizer = opt(key, ...)
  expect_class(optimizer, "Optimizer")
  optimizer$optimize(instance)
  archive = instance$archive

  expect_data_table(archive$data, nrows = real_evals)
  expect_equal(instance$archive$n_evals, real_evals)

  list(optimizer = optimizer, instance = instance)
}

MAKE_OPT = function(param_set = ParamSet$new(), param_classes = c("ParamDbl", "ParamInt"),
  properties = "single-crit", packages = character(0)) {
  Optimizer$new(param_set = param_set,
    param_classes = param_classes,
    properties = properties,
    packages = packages)
}
