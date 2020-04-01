# Simple 2D Function
PS_2D = ParamSet$new(list(
  ParamDbl$new("x1", lower = -1, upper = 1),
  ParamDbl$new("x2", lower = -1, upper = 1)
))
FUN_2D = function(xss) {
  ys = map_dbl(xss, function(x) sum(as.numeric(x))^2)
  data.table(y1 = ys)
}
OBJ_2D = function(n_evals = 2L) {
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2L
  Objective$new(fun = FUN_2D, domain = PS_2D, terminator = term)
}
# Simple 2D Function with trafo
PS_2D_TRF = PS_2D$clone()
PS_2D_TRF$trafo = function(x, param_set) {
  x$x2 + 2
  return(x)
}
FUN_2D_TRF = function(xss) {
  ys = map_dbl(xss, function(x) x[[1]]^2 + (x[[2]]-2)^2)
  data.table(y1 = ys)
}
OBJ_2D_TRF = function(n_evals = 2L) {
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2L
  Objective$new(fun = FUN_2D_TRF, domain = PS_2D_TRF, terminator = term)
}
# Multi-objecitve 2D->2D function
FUN_2D_2D = function(xss) {
  ys = map(xss, function(x) list(x[[1]]^2 , -x[[2]]^2))
  ys = rbindlist(ys)
  colnames(ys) = c("y1", "y2")
  return(ys)
}
OBJ_2D_2D = function(n_evals = 2L) {
  term = TerminatorEvals$new()
  term$param_set$values$n_evals = 2L
  Objective$new(fun = FUN_2D_2D, domain = PS_2D, ydim = 2, minimize = c(TRUE, FALSE),
    terminator = term)
}

