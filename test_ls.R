library(testthat)
library(devtools)
#roxygen2::roxygenize()
load_all()


ss = paradox::ps(
  x = paradox::p_int(0, 1)
)


obj = function(xdt) {
  #print(str(xdt))
  xdt$x^2
}

ctrl = local_search_control()
zz = local_search(obj, ss, ctrl)
print(zz)


# obj = function(xdt) {
#   data.table(y = xdt$x^2)
# }
# objective = ObjectiveRFunDt$new(fun = obj, domain = ss, properties = "single-crit")
# instance = oi(objective = objective, search_space = ss, terminator = trm("evals", n_evals = 500L))
# optimizer = opt("local_search", n_searches = 10L, n_steps = 5L, n_neighs = 10L)
# optimizer$optimize(instance)


