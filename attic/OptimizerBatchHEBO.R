#' @title Heteroscedastic evolutionary bayesian optimization
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
  browser()
  # installing of packages
  assert_python_packages(c("hebo"))
  hebo = reticulate::import("hebo")

  # initialization of search space
  # pv = self$param_set$values
  search_space = inst$search_space

  space = paramset_to_hebo_space(search_space)

  optimizer = hebo$optimizers$hebo$HEBO(space = space)

  repeat {
    if (inst$is_terminated) {
      break
    }

    # tryCatch muss noch etwas ausgestaltet werden, siehe folgender Kommentar
    # hebo$optimizers$hebo$HEBO()$quasi_sample --- default HEBO sampler evtl notwendig, wenn suggest fehlschlägt; useful wenn SM zusammenbricht; wrappen in Trycatch von suggest funktion falls das passiert
    # ISSUE 1 - HEBO suggest doesnt expose metadata as SMAC3
    # trial_info exposes paraeters as a pandas DataFrame
    trial_info = tryCatch(
      optimizer$suggest(),
      # rausfinden wie HEBO suggest verwendet um mehrere configs oder einzelne configs zu kriegen; gibt mehrere Möglichkeiten das zu machen bei MBO interessant wie HEBO das macht
      error = function(e) NULL
    )
    if (is.null(trial_info)) {
      break
    }

    # convert pandas DataFrame to R data.frame-like object
    trial_info_dt = setDT(reticulate::py_to_r(trial_info))

    # load paramset names
    # all_params = search_space$ids()

    # identify missing parameters
    # missing_params = setdiff(all_params, names(trial_info_dt))

    # when there are missing parameters we set them to NA
    # if (length(missing_params)) {
    #   trial_info_dt[, (missing_params) := NA]
    # }

    # keep only columns in all params and saved as xdt
    # xdt = trial_info_dt[, ..all_params]

    # search_space$assert_dt(xdt)

    # evaluation of that config
    res = inst$eval_batch(xdt)

    # evaluated target columns are turned into a numeric matrix
    y = as.matrix(res[, inst$archive$cols_y, with = FALSE])

    # signs are flipped
    # ist es möglich bei HEBO auch multi-objective zu machen, also dass da mehrere y zurückkomen; das auch wichtig für denOptimizer ob er nicht nur SingleCrit oder auch MultiCrit kann
    y = y * matrix(inst$objective_multiplicator, nrow = nrow(y), ncol = ncol(y), byrow = TRUE)

    optimizer$observe(trial_info, y)
  }
}

# 1 - rausfinden ob HEBO mixed/mixed hierarchical kann; falls nein alles andere außer numeric rauskicken

# EXAMPLE
objective_fun = function(xs) {
  booster_term = if (xs$booster == "dart") {
    0.8
  } else if (xs$booster == "gbtree") {
    0.4
  } else {
    0.0
  }
  bias_term = if (isTRUE(xs$use_bias)) 0.25 else -0.15

  score = 12 -
    (log10(xs$lr) + 1.1)^2 -
    ((xs$depth - 7) / 3)^2 -
    0.03 * (xs$reg_lambda - 4)^2 -
    8 * (xs$subsample - 0.82)^2 -
    ((xs$max_bin - 256) / 200)^2 +
    booster_term +
    bias_term

  list(score = score)
}

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
