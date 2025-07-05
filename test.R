load_all(".")
library(devtools)
library(paradox)
library(microbenchmark)

set.seed(124)

loglevel = "warn"
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

instance = OptimInstanceBatchSingleCrit$new(
  objective = objective,
  search_space = search_space,
  terminator = tt
)


optimizer$optimize(instance)
result = instance$result
archive_data = as.data.table(instance$archive$data)

cat("Optimization completed!\n")
cat("Best point found:\n")
print(result)

##################################################

cat("Running microbenchmark...\n")

mb = microbenchmark(
  ls1 = {
    ii = OptimInstanceBatchSingleCrit$new(
        objective = objective,
        search_space = search_space,
        terminator = trm("evals", n_evals = 20)
    )
    optimizer$optimize(ii)
  },
  times = 5,
  unit = "ms"
)

print(mb)

