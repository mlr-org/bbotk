PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(x) sum(as.numeric(x)^2)
OBJ_2D = Objective$new(fun = FUN_2D, domain = PS_2D)
