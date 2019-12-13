roxygenize()
load_all()


ps1 = ParamDbl$new("x")$rep(2)
# ps2 = ParamDbl$new("y")$rep(1)

# FIXME: this looks super clumsy
fn = function(dt) {
  y = map_dbl(seq_row(dt), function(i) {
    x = dt[i,]
    sum(x^2)
  })
  data.table(y = y)
}

obj = ObjectiveSO$new(fun = fn, domain = ps1)
print(obj)
a = Archive$new(ps1, ps2)
print(a)

term = TerminatorEvals$new()
term$param_set$values$n_evals = 2
print(term$is_terminated(a))

dt = data.table(x_rep_1 = c(1,2), x_rep_2 = c(2, 3))
print(dt)
y = obj$eval(dt)
print(y)
print(term$is_terminated(a))

