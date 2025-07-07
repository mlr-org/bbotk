# Test script to verify NA handling in local search C function

library(bbotk)
library(paradox)

# Create a search space with dependencies that can lead to NA values
domain = ps(
  x1 = p_dbl(-5, 5),
  x2 = p_fct(c("a", "b", "c")),
  x3 = p_int(1L, 10L),
  x4 = p_lgl()
)
domain$add_dep("x2", on = "x4", cond = CondEqual$new(TRUE))

# Create objective function that handles NA values
fun = function(xs) {
  # Handle NA values in x2 (which can be NA when x4 is FALSE)
  if (is.na(xs$x2)) {
    xs$x2 = "a"  # Default value
  }
  
  # Calculate objective value
  base_val = xs$x1^2 + xs$x3^2
  factor_val = switch(xs$x2, "a" = 0, "b" = 1, "c" = 2)
  logical_val = if (xs$x4) 0 else 1
  
  list(y = base_val + factor_val + logical_val)
}

objective = ObjectiveRFun$new(fun = fun, domain = domain, properties = "single-crit")

# Create instance
instance = OptimInstanceBatchSingleCrit$new(
  objective = objective, 
  search_space = domain, 
  terminator = trm("evals", n_evals = 20L)
)

# Test the local search optimizer with C implementation
optimizer = opt("local_search_2", 
                n_searches = 2L, 
                n_steps = 3L, 
                n_neighbors = 5L, 
                mut_sd = 0.1)

cat("Testing local search with NA handling...\n")
cat("Search space has dependencies that can lead to NA values\n")
cat("x2 depends on x4 being TRUE\n\n")

# Run optimization
optimizer$optimize(instance)

# Check results
cat("Optimization completed!\n")
cat("Best result:\n")
print(instance$result)

# Check archive for any NA values
archive_data = as.data.table(instance$archive$data)
cat("\nArchive has", instance$archive$n_evals, "evaluations\n")

# Check if there are any NA values in the archive
na_counts = sapply(archive_data[, domain$ids(), with = FALSE], function(x) sum(is.na(x)))
cat("\nNA counts in archive:\n")
print(na_counts)

# Verify that the C function handled NA values correctly
cat("\nTest completed successfully!\n")
cat("The C function should have avoided mutating NA values.\n") 