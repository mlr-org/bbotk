# Simple 2D Function
PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(xdt) {
  xdt$y1 = apply(xdt, 1, function(x) sum(x)^2)
  return(xdt)
}
OBJ_2D = Objective$new(fun = FUN_2D, domain = PS_2D)

# Simple 2D Function with trafo
PS_2D_TRF = PS_2D$clone()
PS_2D_TRF$trafo = function(x, param_set) {
  assert_numeric(x$x2, lower = -1, upper = 1)
  x$x2 + 2
  return(x)
}
FUN_2D_TRF = function(xdt) {
  assert_numeric(xdt$x2, lower = 1, upper = 3)
  x$x2 - 2
  xdt$y1 = apply(xdt, 1, function(x) sum(x)^2)
  return(xdt)
}
OBJ_2D_TRF = Objective$new(fun = FUN_2D_TRF, domain = PS_2D_TRF)

# Multi-objecitve 2D->2D function
FUN_2D_2D = function(xdt) {
  xdt$y1 = xdt$x1^2
  xdt$y2 = -xdt$x2^2
  return(xdt)
}
OBJ_2D_2D = Objective$new(fun = FUN_2D_2D, domain = PS_2D, ydim = 2, minimize = c(TRUE, FALSE))
