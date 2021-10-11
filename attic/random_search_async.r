# define objective function
fun = function(xs) {
  Sys.sleep(sample(5:10, 1))
  c(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y = p_dbl(tags = "maximize")
)

# create Objective object
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# Define termination criterion
terminator = trm("evals", n_evals = 90)

# create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = objective,
  terminator = terminator
)

library(future)
plan(multisession)

repeat({
  while (instance$archive$n_in_progress < 8) {
    print(instance$archive)
    xdt = generate_design_random(domain, 1)$data
    instance$archive$add_evals(xdt, status = "proposed")
    instance$eval_proposed(async = TRUE, single_worker = FALSE)
  }
  instance$archive$resolve_promise()
})


