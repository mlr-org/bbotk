library(devtools)
library(paradox)
library(microbenchmark)
load_all(".")

set.seed(123)

loglevel = "info"
lgr::get_logger("mlr3/bbotk")$set_threshold(loglevel)

square_function = function(xs) {
  list(objective = xs$x1^2 + xs$x2^2)
}

search_space = ps(
  x1 = p_dbl(lower = -2, upper = 2),
  x2 = p_dbl(lower = -2, upper = 2)
)

codomain = ps(objective = p_dbl(tags = "minimize"))

objective = ObjectiveRFun$new(
  fun = square_function,
  domain = search_space,
  codomain = codomain
)

tt = trm("none")

ii = OptimInstanceBatchSingleCrit$new(
  objective = objective,
  search_space = search_space,
  terminator = tt
)

oo = opt("local_search_2",
  n_searches = 10,
  n_neighbors = 10,
  mut_sd = 0.1,
  n_steps = 10
)

oo$optimize(ii)
result = ii$result
aa = as.data.table(ii$archive$data)

cat("Optimization completed!\n")
cat("Best point found:\n")
print(result)
print("Number of evaluations:")
print(nrow(aa))

##################################################

# cat("Running microbenchmark...\n")

# mb = microbenchmark(times = 5, unit = "ms", ls1 = {
#     ii = OptimInstanceBatchSingleCrit$new(
#         objective = objective,
#         search_space = search_space,
#         terminator = tt
#     )
#     oo$optimize(ii)
# })

# print(mb)

