load_all(".")
library(devtools)
library(paradox)
library(microbenchmark)

set.seed(124)

loglevel = "warn"
lgr::get_logger("mlr3/bbotk")$set_threshold(loglevel)

objfun = function(xdt) {
  data.table(y = xdt$x1^2 + xdt$x2^2)
}

ss = ps(
  x1 = p_dbl(lower = -2, upper = 2),
  x2 = p_dbl(lower = -2, upper = 2)
)

cd = ps(y = p_dbl(tags = "minimize"))

obj = ObjectiveRFunDt$new(
  fun = objfun,
  domain = ss,
  codomain = cd
)

tt = trm("none")

ii = OptimInstanceBatchSingleCrit$new(
  objective = obj,
  search_space = ss,
  terminator = tt
)

oo = opt("local_search_2",
  n_searches = 2,
  n_neighbors = 2,
  mut_sd = 0.1,
  n_steps = 2
)

oo$optimize(ii)
result = ii$result
aa = as.data.table(ii$archive$data)

cat("Optimization completed!\n")
cat("Best point found:\n")
print(result)
print(aa)