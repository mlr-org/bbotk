library(devtools)
library(paradox)
library(microbenchmark)
load_all(".")

set.seed(124)

loglevel = "warn"
lgr::get_logger("mlr3/bbotk")$set_threshold(loglevel)


objfun1 = function(xdt) {
  stop("foo")
}

objfun2 = function(xdt) {
  data.table(y = xdt$x1^2 + xdt$x2^2)
}


ss = ps(
  x1 = p_dbl(lower = -2, upper = 2),
  x2 = p_dbl(lower = -2, upper = 2)
)

codomain = ps(y = p_dbl(tags = "minimize"))


obj = ObjectiveRFunDt$new(
  fun = objfun2,
  domain = ss,
  codomain = codomain,
  check_values = FALSE
)

tt1 = trm("none")
tt2 = trm("evals", n_evals = 5)

ii = OptimInstanceBatchSingleCrit$new(
  objective = obj,
  search_space = ss,
  terminator = tt2,
  check_values = FALSE
)


oo2 = opt("local_search_2",
  n_searches = 5,
  n_neighbors = 5,
  mut_sd = 0.1,
  n_steps = 5
)

oo2$optimize(ii)
print(ii$archive$data)

