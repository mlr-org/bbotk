library(devtools)
load_all()

set.seed(123)

ss = ps(
  x1 = p_fct(c("a", "b", "c")),
  x2 = p_dbl(0, 1, depends = x1 == "a")
)

fun = function(xs) {
  list(y = 1)
}

obj = ObjectiveRFun$new(fun = fun, domain = ss, properties = "single-crit")

instance = OptimInstanceBatchSingleCrit$new(
  objective = obj,
  search_space = ss,
  terminator = trm("evals", n_evals = 10)
)

oo = opt("local_search", 
    n_searches = 1,
    n_steps = 1,
    n_neighbors = 1
)
print(class(oo))

oo$optimize(instance)

