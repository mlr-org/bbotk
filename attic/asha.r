#########
# helper
#########

top_rung = function(archive, k, eta) {
  if(nrow(archive$data) == 0) return(data.table())
  # evaluated configurations of rung
  data = archive$data[rung == k & status == "evaluated"]
  if(nrow(data) > 0) {
    n = floor(nrow(data) / eta)
    head(setorderv(data, archive$cols_y), n)
  } else {
    data.table()
  }
}

ids_rung = function(archive, k) {
  if (nrow(archive$data) == 0) NULL  else archive$data[rung == k, asha_id]
}

n_rung = function(archive, k) {
  if (nrow(archive$data) == 0) 0 else nrow(archive$data[rung == k])
}

#########
# get_job
#########

#' @description
#' This function returns a hyperparameter configurations and the rung of the
#' configuration.
#'
#' The function iterates the rungs and, if possible, promotes configurations to
#' the next rung i.e. returns the configuration with the increased budget of the
#' next rung. If no promotion is possible, a new hyperparameter configuration is
#' drawn in the bottom rung.
#'
#' @param eta (`numeric(1)`)\cr
#'   Reduction factor `eta`.
#' @param s (`integer(1)`)\cr
#'   Minimum early stopping rate. Lower values correspond to more aggresive
#'   early-stopping, with `s = 0` using the minimum resource `r` in the first
#'   rung.
#' @param search_space ([paradox::ParamSet])\cr
#'   Defines the tuning space of the hyperparameters and the budget parameter.
#'   The lower and upper bounds of the budget parameter define the minimum
#'   resource `r` and the maximum resource `R`.
#' @param archive ([Archive])\cr
#'   Schedules the training of different configurations and stores the results.
#' @param sampler ([paradox::Sampler])\cr
#'   Object defining how the samples of the hyperparameter space should be drawn.
#'   The default is uniform sampling.
#' @return `list(xs = list(), rung = integer(1))`
get_job = function(eta, s, search_space, archive, sampler = NULL) {
  # budget id
  budget_id = search_space$ids(tags = "budget")
  # minimum resource `r`
  r_min = search_space$lower[[budget_id]]
  # maximimum resource `R`
  r_max = search_space$upper[[budget_id]]
  # sampler
  search_space_sampler = search_space$clone()$subset(setdiff(search_space$ids(), budget_id))
  if (is.null(sampler)) {
    sampler = SamplerUnif$new(search_space_sampler)
  }

  # number of rungs so that each configuration in the fist stage uses r_min
  # (`r`) resources and each configuration in the last stage uses not more than
  # r_max (`R`) resources
  # rungs are called stages in the hyperband paper
  k_max = ceiling(log(r_max / r_min, eta))

  for (k in (k_max  - s - 1):0) {
    # top configurations (n = |rung|/eta)
    candidates = top_rung(archive, k, eta)
    # select canidates that are not promoted yet
    promotable = setdiff(candidates$asha_id, ids_rung(archive, k + 1))

    # promote configuration
    if (length(promotable) > 0) {
      # increased budget
      ri = r_min * eta^(k + s + 1)
      xdt = candidates[asha_id == promotable[1], archive$cols_x, with = FALSE]
      set(xdt, j = budget_id, value = ri)
      asha_id = candidates[asha_id == promotable[1], asha_id]
      set(xdt, j = "rung", value = k + 1)
      set(xdt, j = "asha_id", value = asha_id)
      return(xdt)
    }
  }
  # If no promotion is possible, add new configuration to buttom rung
  xdt = sampler$sample(1)$data
  set(xdt, j = budget_id, value = r_min * eta^s)
  set(xdt, j = "rung", value = 0)
  return(xdt)
}

######
# Asha
######


library(future)
plan(multisession)

# define objective function
fun = function(xdt) {
  Sys.sleep(max(1, round(rnorm(n = 1, mean = xdt[["fidelity"]] * 1000, s = 3))))

  a = 1
  b = 5.1 / (4 * (pi ^ 2))
  c = 5 / pi
  r = 6
  s = 10
  t = 1 / (8 * pi)
  data.table::data.table(y =
    (a * ((xdt[["x2"]] -
    b * (xdt[["x1"]] ^ 2L) +
    c * xdt[["x1"]] - r) ^ 2) +
    ((s * (1 - t)) * cos(xdt[["x1"]])) +
    s - (5 * xdt[["fidelity"]] * xdt[["x1"]])))
}

# set domain
search_space = domain = ps(
   x1 = p_dbl(-5, 10),
   x2 = p_dbl(0, 15),
   fidelity = p_dbl(1e-2, 1, tags = "budget")
 )

# set codomain
codomain = ps(
  y = p_dbl(tags = "minimize")
)

# create Objective object
objective = ObjectiveRFunDt$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# create optimization instance
instance = OptimInstanceSingleCrit$new(
  objective = objective,
  search_space = search_space,
  terminator = trm("evals", n_evals = 100)
)

eta = 2
s = 0
#archive = instance$archive

repeat({
  replicate(4 - instance$archive$n_in_progress, {
    xdt = get_job(eta, s, search_space, instance$archive)

    print(instance$archive$data)

    if (is.null(xdt$asha_id)) set(xdt, j = "asha_id", value = n_rung(instance$archive, 0) + 1)

    instance$archive$add_evals(xdt, status = "proposed")
    instance$eval_proposed(async = TRUE, single_worker = FALSE)
  })

instance$archive$resolve_promise()
})
