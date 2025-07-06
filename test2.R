library(devtools)
library(paradox)
library(microbenchmark)
load_all(".")

set.seed(124)

loglevel = "warn"
lgr::get_logger("mlr3/bbotk")$set_threshold(loglevel)


objfun = function(xdt) {
  data.table(objective = xdt$x1^2 + xdt$x2^2)
}

ss = ps(
  x1 = p_dbl(lower = -2, upper = 2),
  x2 = p_dbl(lower = -2, upper = 2)
)

cd = ps(objective = p_dbl(tags = "minimize"))

# FIXME: sowoh die instance wie die objective checken ob die values korrekt sind

obj = ObjectiveRFunDt$new(
  fun = objfun,
  domain = ss,
  codomain = cd,
  check_values = FALSE
)

n_searches = 10
n_neighbors = 10
n_steps = 300
mut_sd = 0.1

tt = trm("evals", n_evals = n_searches * n_neighbors * n_steps)

ii = OptimInstanceBatchSingleCrit$new(
  objective = obj,
  search_space = ss,
  terminator = tt,
  check_values = FALSE
)

oo1 = opt("local_search",
  n_initial_points = n_searches,
  initial_random_sample_size = n_searches,
  neighbors_per_point = n_neighbors,
  mutation_sd = mut_sd
)


oo2 = opt("local_search_2",
  n_searches = n_searches,
  n_neighbors = n_neighbors,
  mut_sd = mut_sd,
  n_steps = n_steps
)

# oo2$optimize(ii)
# result = ii$result
# aa = as.data.table(ii$archive$data)
# cat("Optimization completed!\n")
# cat("Best point found:\n")
# print(result)
# print("Number of evaluations:")
# print(nrow(aa))

##################################################

cat("Running microbenchmark...\n")

mb = microbenchmark(times = 1, unit = "ms", 
  ls1 = {ii$clear(); oo1$optimize(ii)},
  ls2 = {ii$clear(); oo2$optimize(ii)}
)

print(mb)

##################################################

# library(profvis)

# # Interactive profiling with flame graph
# pv = profvis::profvis({
#   ii$clear()
#   oo2$optimize(ii)
# })
# htmlwidgets::saveWidget(pv, "profile.html")
# browseURL("profile.html")