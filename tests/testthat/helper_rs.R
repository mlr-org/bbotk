random_search = function(objective, terminator, batch_size = 10) {
  assert_r6(objective, "Objective")
  assert_r6(terminator, "Terminator")
  batch_size = assert_int(batch_size, coerce = TRUE)
  archive = Archive$new(objective)
  ev = Evaluator$new(objective, archive, terminator)
  while(!terminator$is_terminated(archive)) {
    des = generate_design_random(objective$domain, batch_size)
    ev$eval_batch(des$data)
  }
  return(archive)
}

# ps1 = ParamDbl$new("x", lower = -1, upper = 1)$rep(2)
# fn = function(x) sum(as.numeric(x)^2)
# obj = Objective$new(fun = fn, domain = ps1, minimize = TRUE, encapsulate = "none")
# term = TerminatorEvals$new()
# term$param_set$values$n_evals = 2
# a = random_search(obj, term)
# print(a)


