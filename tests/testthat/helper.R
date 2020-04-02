# Simple 2D Function
PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(xs) {
  y = sum(as.numeric(xs)^2)
  list(y = y)
}
FUN_2D_CODOMAIN = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
OBJ_2D = ObjectiveRFun$new(fun = FUN_2D, domain = PS_2D)


# Simple 2D Function with trafo
PS_2D_TRF = PS_2D$clone()
PS_2D_TRF$trafo = function(x, param_set) {
  x$x2 + 2
  return(x)
}
FUN_2D_TRF = function(xs) {
  list(y = xs[[1]]^2 + (xs[[2]]-2)^2)
}
OBJ_2D_TRF = ObjectiveRFun$new(fun = FUN_2D_TRF, domain = PS_2D_TRF)

# Multi-objecitve 2D->2D function
FUN_2D_2D = function(xs) {
  list(y1 = xs[[1]]^2, y2 = -xs[[2]]^2)
}
FUN_2D_2D_CODOMAIN = ParamSet$new(list(
  ParamDbl$new("y1", tags = "minimize"),
  ParamDbl$new("y2", tags = "maximize")
))

OBJ_2D_2D = ObjectiveRFun$new(fun = FUN_2D_2D, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN)

# General Helper
MAKE_INST = function(objective = OBJ_2D, param_set = PS_2D, terminator = 5L) {
  if (is.integer(terminator)) {
    tt = TerminatorEvals$new()
    tt$param_set$values$n_evals = terminator
    terminator = tt
  }
  OptimInstance$new(objective = objective, param_set = param_set, terminator = terminator)
}

MAKE_INST_2D = function(terminator) {
  MAKE_INST(objective = OBJ_2D, param_set = PS_2D, terminator = terminator)
}

MAKE_INST_2D_2D = function(terminator) {
 MAKE_INST(objective = OBJ_2D_2D, param_set = PS_2D, terminator = terminator)
}

