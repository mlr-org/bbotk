
roxygenize()
load_all()


ps1 = ParamDbl$new("x")$rep(2)
# ps2 = ParamDbl$new("y")$rep(1)

fn = function(x) {
  sum(as.numeric(x)^2)
}

obj = Objective$new(fun = fn, domain = ps1, minimize = TRUE)
print(obj)
a = Archive$new(obj$domain, obj$codomain)
print(a)
print(a$cols_x)
print(a$cols_y)

term = TerminatorEvals$new()
term$param_set$values$n_evals = 2
print(term$is_terminated(a))


ev = Evaluator$new(obj, a, term)
ev$eval(xdt)
print(a)

