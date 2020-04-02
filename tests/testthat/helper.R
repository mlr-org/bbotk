# Simple 2D Function
PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(xs) {
  y = sum(as.numeric(xs)^2)
  list(y1 = y)
}
OBJ_2D = ObjectiveRFun$new(fun = FUN_2D, domain = PS_2D)

# Simple 2D Function with trafo
PS_2D_TRF = PS_2D$clone()
PS_2D_TRF$trafo = function(x, param_set) {
  x$x2 + 2
  return(x)
}
FUN_2D_TRF = function(xs) {
  list(y1 = xs[[1]]^2 + (xs[[2]]-2)^2)
}
OBJ_2D = ObjectiveRFun$new(fun = FUN_2D_TRF, domain = PS_2D_TRF)

# Multi-objecitve 2D->2D function
FUN_2D_2D = function(xs) {
  list(y1 = xs[[1]]^2, y2 = -xs[[2]]^2)
}
OBJ_2D_2D = ObjectiveRFun$new(fun = FUN_2D_2D, domain = PS_2D, codomain = make_ps_reals(2))

