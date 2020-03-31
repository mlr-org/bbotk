PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(xdt) {
  xdt$y1 = apply(xdt, 1, function(x) sum(x)^2)
  return(xdt)
}
OBJ_2D = Objective$new(fun = FUN_2D, domain = PS_2D)

FUN_2D_2D = function(xdt) {
  xdt$y1 = xdt$x1^2
  xdt$y2 = -xdt$x2^2
  return(xdt)
}
OBJ_2D_2D = Objective$new(fun = FUN_2D_2D, domain = PS_2D, ydim = 2, minimize = c(TRUE, FALSE))
