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
FUN_1D_CODOMAIN = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
OBJ_1D = ObjectiveRFun$new(fun = FUN_1D, domain = PS_1D_domain)

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
FUN_2D_CODOMAIN = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
OBJ_2D = ObjectiveRFun$new(fun = FUN_2D, domain = PS_2D_domain)


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
  codomain = FUN_2D_2D_CODOMAIN)

# General Helper
MAKE_INST = function(objective = OBJ_2D, search_space = PS_2D,
  terminator = 5L) {
  if (is.integer(terminator)) {
    tt = TerminatorEvals$new()
    tt$param_set$values$n_evals = terminator
    terminator = tt
  }
  if (objective$codomain$length == 1) {
    OptimInstance$new(objective = objective, search_space = search_space, terminator = terminator)
  } else {
    OptimInstanceMulticrit$new(objective = objective, search_space = search_space, terminator = terminator)
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

MAKE_OPT = function(param_set = ParamSet$new(), param_classes = c("ParamDbl", "ParamInt"),
  properties = "single-crit", packages = character(0)) {
  Optimizer$new(param_set = param_set,
    param_classes = param_classes,
    properties = properties,
    packages = packages)
}
