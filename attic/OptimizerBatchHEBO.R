#' @title Heteroscedastic evolutionary bayesian optimization
#'
#'
#'
#' @export
#' @examples
#' \dontrun{
#' # define the objective function
#' fun = function(xs) {
#'   list(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain (all parameters must have defaults for ConfigSpace)
#' domain = ps(
#'   x1 = p_dbl(-10, 10, default = 0),
#'   x2 = p_dbl(-5, 5, default = 0)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
#' # load optimizer
#' optimizer = opt("smac")
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configurations
#' instance$archive
#'
#' # best performing configuration
#' instance$result
#' }

# IMPORTANT; configspace sind Python Objekte
# search space -- R Objekt
# cs // config_space -- Python Objekt
optimize = function(inst) {
  # installing of packages
  assert_python_packages(c("hebo"))
  hebo = reticulate::import("hebo")

  # initialization of search space
  # pv = self$param_set$values
  search_space = inst$search_space

  space = paramset_to_hebo_space(search_space)

  # terminator criterion
  terminator = inst$terminator

  optimizer = hebo$optimizers$hebo$HEBO(space = space)

  repeat {
    # tryCatch muss noch etwas ausgestaltet werden, siehe folgender Kommentar
    # hebo$optimizers$hebo$HEBO()$quasi_sample --- default HEBO sampler evtl notwendig, wenn suggest fehlschlägt; useful wenn SM zusammenbricht; wrappen in Trycatch von suggest funktion falls das passiert
    trial_info = tryCatch(
      optimizer$suggest(),
      error = function(e) NULL
    )
    if (is.null(trial_info)) {
      break
    }

    proposal_dt = as.data.table(reticulate::py_to_r(trial_info))

    all_params = search_space$ids()
    missing_params = setdiff(all_params, names(proposal_dt))
    if (length(missing_params)) {
      proposal_dt[, (missing_params) := NA]
    }
    xdt = proposal_dt[, ..all_params]

    search_space$assert_dt(xdt)

    ydt = inst$eval_batch(xdt)

    y = as.matrix(ydt[, inst$archive$cols_y, with = FALSE])
    y = y * matrix(inst$objective_multiplicator, nrow = nrow(y), ncol = ncol(y), byrow = TRUE)

    opt$observe(trial_info, y)
  }
}

# EXAMPLE
search_space = ps(
  lr = p_dbl(lower = 1e-4, upper = 3e-1),
  depth = p_int(lower = 2L, upper = 14L),
  booster = p_fct(levels = c("gbtree", "dart", "gblinear")),
  use_bias = p_lgl(),
  reg_lambda = p_dbl(lower = 0, upper = 20),
  subsample = p_dbl(lower = 0.5, upper = 1.0),
  max_bin = p_int(lower = 64L, upper = 512L)
)

objective = ObjectiveRFun$new(
  fun = objective_fun,
  domain = search_space,
  codomain = ps(score = p_dbl(tags = "maximize")),
  properties = "deterministic"
)

terminator = trm(
  "combo",
  list(
    trm("evals", n_evals = 100L),
    trm("stagnation", iters = 15L, threshold = 1e-4)
  )
)

inst = oi(
  objective = objective,
  terminator = terminator
)


optimize(inst)


# build scenario
# paramset wird direkt in HEBO space umgewandelt (ConfigSpace wird nicht verwendet)

# no facade --- (facade would be full high-level configuration that chooses and wires SM/ACQ/ID/INT etc)

# DEFAULT
# challenge: wie kriegen wir es hin das R das ausführt (space = HEBO Design Space - nimmt keine Obj Funiktion due to ask + tell interface)
#hebo$optimizers$hebo$HEBO()$suggest # das schlägt einen Punkt zum Evaluieren vor
# n_suggestions = 1L is the default

# jetzt in R config umwandeln

# build surrogate model
model = NULL
if (!is.null(pv$surrogate)) {
  if (pv$surrogate == "gp") {
    model = hebo$models$model_factory$GP(
      num_cont = ...,
      num_enum = ...,
      num_out = ...
    )
  } else if (pv$surrogate == "rf") {
    model = hebo$models$model_factory$RF(
      num_cont = ...,
      num_enum = ...,
      num_out = ...
    )
  }
}

# build acq func

# build initial design

# build random design

# build intensifier

# creation of HEBO optimizer

# report results via TrialValue

# do evaluation and optimization again and again until termination criterion happens

# extract best configuration as named list
