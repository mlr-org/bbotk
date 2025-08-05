library(bbotk)

# Create a search space with dependencies
domain = ps(
  x1 = p_dbl(-5, 5),
  x2 = p_fct(c("a", "b", "c")),
  x3 = p_int(1L, 2L),
  x4 = p_lgl()
)
domain$add_dep("x2", on = "x4", cond = CondEqual$new(TRUE))

# Create objective function
fun = function(xs) {
  if (is.null(xs$x2)) {
    xs$x2 = "a"
  }
  list(y = (xs$x1 - switch(xs$x2, "a" = 0, "b" = 1, "c" = 2)) %% xs$x3 + (if (xs$x4) xs$x1 else pi))
}

objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")

# Create instance
instance = OptimInstanceBatchSingleCrit$new(
  objective = objective, 
  search_space = domain, 
  terminator = trm("evals", n_evals = 50L)
)

# Test the local search optimizer
optimizer = opt("local_search_2", n_searches = 3L, n_steps = 5L, n_neighbors = 10L, mut_sd = 0.1)

# Run optimization
optimizer$optimize(instance)

# Check results
cat("Optimization completed!\n")
cat("Best result:\n")
print(instance$result)

# Check archive
cat("\nArchive has", instance$archive$n_evals, "evaluations\n") 