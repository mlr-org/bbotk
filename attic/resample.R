# define objective function
fun = function(xs) {
  library(mlr3learners)

  learner = mlr3::lrn("classif.xgboost", nrounds = 100)
  task = mlr3::tsk("pima")
  resampling = mlr3::rsmp("cv", folds = 3)
  rr = mlr3::resample(task, learner, resampling, store_model = TRUE)

  data.table::data.table(classif.ce = rr$aggregate(), resample_result = list(rr))
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  classif.ce = p_dbl(tags = "maximize")
)

# create Objective object
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# Define termination criterion
terminator = trm("evals", n_evals = 100)

# create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = objective,
  terminator = terminator
)

library(future)
plan(multisession)

repeat({
  while (instance$archive$n_in_progress < 8) {
    xdt = generate_design_random(domain, 1)$data
    instance$archive$add_evals(xdt, status = "proposed")
    instance$eval_proposed(async = TRUE, single_worker = FALSE)
  }
  instance$archive$resolve_promise()
})
