random_search = function(inst, batch_size = 10) {
  assert_r6(inst, "OptimInstance")
  batch_size = assert_int(batch_size, coerce = TRUE)
  optim = OptimizerRandomSearch$new()
  optim$param_set$values$batch_size = batch_size
  optim$optimize(inst)
  return(inst$archive)
}

# ps1 = ParamDbl$new("x", lower = -1, upper = 1)$rep(2)
# fn = function(x) sum(as.numeric(x)^2)
# obj = Objective$new(fun = fn, domain = ps1, minimize = TRUE, encapsulate = "none")
# term = TerminatorEvals$new()
# term$param_set$values$n_evals = 2
# a = random_search(obj, term)
# print(a)
