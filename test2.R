library(devtools)
library(paradox)
library(microbenchmark)
load_all(".")

loglevel = "info"
lgr::get_logger()$set_threshold(loglevel)
lgr::get_logger("bbotk")$set_threshold(loglevel)
lgr::get_logger("mlr3")$set_threshold(loglevel)

square_function = function(xs) {
  list(objective = xs$x^2 + xs$y^2)
}

search_space = ps(
  x = p_dbl(lower = -2, upper = 2),
  y = p_dbl(lower = -2, upper = 2)
)

codomain = ps(objective = p_dbl(tags = "minimize"))

objective = ObjectiveRFun$new(
  fun = square_function,
  domain = search_space,
  codomain = codomain
)

instance = OptimInstanceBatchSingleCrit$new(
  objective = objective,
  search_space = search_space,
  terminator = trm("evals", n_evals = 30)
)

optimizer = opt("local_search_2",
  n_searches = 2,
  n_neighbors = 2,
  mut_sd = 0.1,
  n_steps = 1
)

optimizer$optimize(instance)
result = instance$result
archive_data = as.data.table(instance$archive$data)

cat("Optimization completed!\n")
cat("Best point found:\n")
print(result)

##################################################

# cat("Running microbenchmark...\n")

# mb = microbenchmark(times = 5, unit = "ms", ls1 = {
#     ii = OptimInstanceBatchSingleCrit$new(
#         objective = objective,
#         search_space = search_space,
#         terminator = trm("evals", n_evals = 20)
#     )
#     optimizer$optimize(ii)
# })

# print(mb)

