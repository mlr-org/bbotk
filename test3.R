library(devtools)
library(paradox)
library(microbenchmark)
library(mlr3)
library(mlr3learners)

load_all(".")

set.seed(124)

loglevel = "warn"
lgr::get_logger("mlr3/bbotk")$set_threshold(loglevel)


# objective we approx with an SM
true_obj = function(xdt) {
    data.table(y = xdt$x1^2 + xdt$x2^2)
}
search_space = ps(
  x1 = p_dbl(lower = -2, upper = 2),
  x2 = p_dbl(lower = -2, upper = 2)
)
codomain = ps(y = p_dbl(tags = "minimize"))

#################################################################

# train data, SM, SM objective
n_train = 100
mylrn = lrn("regr.ranger")
design = generate_design_random(search_space, n = 100)
design$data$y = true_obj(design$data)
mytask = as_task_regr(design$data, target = "y")
mylrn$train(task = mytask)

ppp = get_private(mylrn)$.predict

sm_obj = ObjectiveRFunDt$new(
  fun = function(xdt) {
    #p = mylrn$predict_newdata(xdt)
    #data.table(y = p$data$response)
    ttt = as_task_regr(xdt, target = "y")
    ppp(task = ttt)
    data.table(y = p$data$response)
  },
  domain = search_space,
  codomain = codomain,
  check_values = FALSE
)

#################################################################


n_searches = 2
n_neighbors = 2
n_steps = 2
# n_searches = 10
# n_neighbors = 10
# n_steps = 300
mut_sd = 0.1

tt = trm("evals", n_evals = n_searches * n_neighbors * n_steps)

ii = OptimInstanceBatchSingleCrit$new(
  objective = sm_obj,
  search_space = search_space,
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

oo2$optimize(ii)
result = ii$result
aa = as.data.table(ii$archive$data)
cat("Optimization completed!\n")
cat("Best point found:\n")
print(result)
print("Number of evaluations:")
print(nrow(aa))

##################################################

# cat("Running microbenchmark...\n")

# mb = microbenchmark(times = 5, unit = "ms", 
#   ls1 = {ii$clear(); oo1$optimize(ii)},
#   ls2 = {ii$clear(); oo2$optimize(ii)}
# )

# print(mb)

##################################################

# library(profvis)

# # Interactive profiling with flame graph
# pv = profvis::profvis({
#   ii$clear()
#   oo2$optimize(ii)
# })
# htmlwidgets::saveWidget(pv, "profile.html")
# browseURL("profile.html")

