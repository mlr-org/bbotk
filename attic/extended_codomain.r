# define objective function
fun = function(xs) {
  list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10,
       time = rnorm(1))
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y = p_dbl(tags = "maximize"),
  time = p_dbl()
)

# create Objective object
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# Define termination criterion
terminator = trm("evals", n_evals = 10)

# create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = objective,
  terminator = terminator
)

# load optimizer
optimizer = opt("gensa")

# trigger optimization
optimizer$optimize(instance)
