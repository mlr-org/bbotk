roxygenize()
load_all()


ps1 = ParamDbl$new("x")$rep(2)
# ps2 = ParamDbl$new("y")$rep(1)

fn = function(dt) {
  y = map_dbl(seq_row(dt), function(i) {
    x = dt[i,]
    sum(x^2)
  })
  data.table(y = y)
}

obj = ObjectiveSO$new(fun = fn, domain = ps1, minimize = TRUE)
print(obj)
a = Archive$new(obj$domain, obj$codomain)
print(a)
print(a$cols_x)
print(a$cols_y)

term = TerminatorEvals$new()
term$param_set$values$n_evals = 2
print(term$is_terminated(a))

xdt = data.table(x_rep_1 = c(1,2), x_rep_2 = c(2, 3))
print(xdt)
ydt = obj$eval(xdt)
print(ydt)
xydt = cbind(xdt, ydt)
a$add_evals(xydt)
print(term$is_terminated(a))
print(a)

ev = Evaluator$new(obj, a, term)
ev$eval(xdt)
print(a)

