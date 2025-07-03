#!/usr/bin/env Rscript

# Test script for local search optimizer
# Tests the local search on a 2D square function f(x,y) = x^2 + y^2

# Load devtools and install/load the package
if (!require(devtools)) {
  install.packages("devtools")
}
library(devtools)

# Load the package from current directory
load_all(".")

# Load required packages
library(bbotk)
library(paradox)

# Define the 2D square function: f(x,y) = x^2 + y^2
square_function = function(xs) {
  x = xs$x
  y = xs$y
  list(objective = x^2 + y^2)
}

# Create search space: x and y in [-2, 2]
search_space = ps(
  x = p_dbl(lower = -2, upper = 2),
  y = p_dbl(lower = -2, upper = 2)
)

# Create codomain (objective to minimize)
codomain = ps(objective = p_dbl(tags = "minimize"))

# Create objective function
objective = ObjectiveRFun$new(
  fun = square_function,
  domain = search_space,
  codomain = codomain
)

# Create optimization instance
instance = OptimInstanceBatchSingleCrit$new(
  objective = objective,
  search_space = search_space,
  terminator = trm("evals", n_evals = 100)
)

# Create local search optimizer
optimizer = opt("local_search",
  n_initial_points = 5,
  initial_random_sample_size = 20,
  neighbors_per_point = 10,
  mutation_sd = 0.1
)

cat("Starting local search optimization on 2D square function...\n")
cat("Search space: x, y in [-2, 2]\n")
cat("Objective: minimize f(x,y) = x^2 + y^2\n")
cat("Expected minimum: (0, 0) with value 0\n\n")

# Run optimization
optimizer$optimize(instance)

# Get results
result = instance$result
archive_data = as.data.table(instance$archive$data)

cat("Optimization completed!\n")
cat("Best point found:\n")
print(result)

cat("Archive contains", nrow(archive_data), "evaluations\n")
cat("Best 5 points:\n")
print(head(archive_data[order(objective)], 5))

# Plot results if ggplot2 is available
if (require(ggplot2)) {
  cat("\nCreating visualization...\n")
  
  # Create contour plot
  p = ggplot(archive_data, aes(x = x, y = y, color = objective)) +
    geom_point(size = 2) +
    scale_color_gradient(low = "blue", high = "red") +
    geom_contour(data = expand.grid(x = seq(-2, 2, 0.1), y = seq(-2, 2, 0.1)), 
                 aes(x = x, y = y, z = x^2 + y^2), color = "black", alpha = 0.5) +
    geom_point(data = data.frame(x = result$x, y = result$y), 
               color = "green", size = 4, shape = 17) +
    labs(title = "Local Search on 2D Square Function",
         subtitle = paste("Best point: (", round(result$x, 3), ", ", round(result$y, 3), ") = ", round(result$objective, 6), sep = ""),
         color = "f(x,y)") +
    theme_minimal()
  
  print(p)
  
  # Save plot
  ggsave("local_search_test.png", p, width = 8, height = 6)
  cat("Plot saved as 'local_search_test.png'\n")
}

cat("\nTest completed successfully!\n") 