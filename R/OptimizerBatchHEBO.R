#' @title Heteroscedastic Evolutionary Bayesian Optimization (HEBO)
#'
#' @include Optimizer.R
#' @name mlr_optimizers_hebo
#'
#' @description
#' `OptimizerBatchHEBO` class that implements optimization via the Python
#' HEBO framework. Calls HEBO via \CRANpkg{reticulate}.
#'
#' @templateVar id hebo
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`n_suggestions`}{`integer(1)`\cr
#'   Number of candidate configurations to suggest per iteration.
#'   Default is `1L`.}
#' \item{`n_init`}{`integer(1)`\cr
#'   Number of random initialization points before the surrogate model is fitted.
#'   Default is `1 + number of parameters`.}
#' \item{`seed`}{`integer(1)`\cr
#'   Random seed for the scramble sequence.
#'   Default is `NULL` (no fixed seed).}
#' \item{`surrogate`}{`character(1)`\cr
#'   Surrogate model to use.
#'   `"gp"` (Gaussian Process) or `"rf"` (Random Forest).
#'   Default is `"gp"`.}
#' \item{`rf_n_estimators`}{`integer(1)`\cr
#'   Number of trees in the Random Forest surrogate.
#'   Only used when `surrogate = "rf"`.
#'   Default is `20L`.}
#' \item{`gp_lr`}{`numeric(1)`\cr
#'   Learning rate for the GP model.
#'   Only used when `surrogate = "gp"`.
#'   Default is `0.01`.}
#' \item{`gp_num_epochs`}{`integer(1)`\cr
#'   Number of training epochs for the GP model.
#'   Only used when `surrogate = "gp"`.
#'   Default is `100L`.}
#' \item{`gp_noise_free`}{`logical(1)`\cr
#'   Whether to treat the objective as noise-free.
#'   Only used when `surrogate = "gp"`.
#'   Default is `FALSE`.}
#' \item{`gp_noise_lb`}{`numeric(1)`\cr
#'   Lower bound on GP noise variance.
#'   Only used when `surrogate = "gp"`.
#'   Default is `8e-4`.}
#' \item{`gp_pred_likeli`}{`logical(1)`\cr
#'   Whether to use predictive likelihood.
#'   Only used when `surrogate = "gp"`.
#'   Default is `FALSE`.}
#' \item{`acq_function`}{`character(1)`\cr
#'   Acquisition function to use.
#'   `"mace"` (Multi-Objective Acquisition Criterion Ensemble) or `"lcb"` (Lower Confidence Bound).
#'   Default is `"mace"`.}
#' \item{`es`}{`character(1)`\cr
#'   Evolutionary strategy for acquisition function optimization.
#'   One of `"ga"`, `"brkga"`, `"de"`, `"nelder-mead"`, `"pattern-search"`, `"cmaes"`, `"pso"`,
#'   `"nsga2"`, `"rnsga2"`, `"nsga3"`, `"unsga3"`, `"rnsga3"`, `"moead"`, `"ctaea"`.
#'   Default is `"nsga2"`.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
#'

OptimizerBatchHEBO = R6Class(
  "OptimizerBatchHEBO",
  inherit = OptimizerBatch,
  public = list(
    initialize = function() {
      param_set = ps(
        # optimizer interface
        n_suggestions = p_int(lower = 1L, init = 1L), # remove as HEBO only handles single crit
        n_init = p_int(lower = 1L),
        seed = p_int(lower = 0L),

        # surrogate model
        surrogate = p_fct(levels = c("gp", "rf"), init = "gp"),
        rf_n_estimators = p_int(lower = 1L, depends = quote(surrogate == "rf")),
        gp_lr = p_dbl(lower = 0, depends = quote(surrogate == "gp")),
        gp_num_epochs = p_int(lower = 1L, depends = quote(surrogate == "gp")),
        gp_noise_free = p_lgl(depends = quote(surrogate == "gp")),
        gp_noise_lb = p_dbl(lower = 0, depends = quote(surrogate == "gp")),
        gp_pred_likeli = p_lgl(depends = quote(surrogate == "gp")),

        # acquisition function
        acq_function = p_fct(levels = c("mace", "lcb"), init = "mace"),

        # evolutionary search for acquisition optimization
        es = p_fct(
          levels = c(
            "ga",
            "brkga",
            "de",
            "nelder-mead",
            "pattern-search",
            "cmaes",
            "pso",
            "nsga2",
            "rnsga2",
            "nsga3",
            "unsga3",
            "rnsga3",
            "moead",
            "ctaea"
          ),
          init = "nsga2"
        )
      )

      super$initialize(
        id = "hebo",
        param_set = param_set,
        param_classes = c("ParamDbl", "ParamInt", "ParamFct", "ParamLgl"),
        properties = c("single-crit"),
        packages = "reticulate",
        label = "Heteroscedastic Evolutionary Bayesian Optimization",
        man = "bbotk::mlr_optimizers_hebo"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      assert_python_packages(c("hebo"))
      hebo = reticulate::import("hebo")

      pv = self$param_set$values

      search_space = inst$search_space
      space = paramset_to_hebo_space(search_space)
      optimizer_args = list(
        space = space,
        rand_sample = as.integer(pv$n_init %??% (1L + search_space$length)),
        es = pv$es %??% "nsga2"
      )

      # add nn; evtl boosting
      # add unit tests see SMAC3
      if (!is.null(pv$surrogate)) {
        if (pv$surrogate == "rf") {
          optimizer_args$model_name = "rf"
          optimizer_args$model_config = list(
            n_estimators = as.integer(pv$rf_n_estimators %??% 20L)
          )
        } else if (pv$surrogate == "gp") {
          optimizer_args$model_name = "gp"
          optimizer_args$model_config = list(
            lr = pv$gp_lr %??% 0.01,
            num_epochs = as.integer(pv$gp_num_epochs %??% 100L),
            verbose = pv$gp_verbose %??% FALSE,
            print_every = as.integer(pv$gp_print_every %??% 10L),
            noise_free = pv$gp_noise_free %??% FALSE,
            noise_lb = pv$gp_noise_lb %??% 8e-4,
            pred_likeli = pv$gp_pred_likeli %??% FALSE
          )
        }
      }

      if (!is.null(pv$acq_function)) {
        acq_mod = hebo$acquisitions$acq
        optimizer_args$acq_cls = switch(
          pv$acq_function,
          "lcb" = acq_mod$LCB,
          "mace" = acq_mod$MACE,
          stopf(
            "Unsupported HEBO acquisition function '%s'. Supported values are 'mace' and 'lcb'.",
            pv$acq_function
          )
        )
      }

      if (!is.null(pv$seed)) {
        optimizer_args$scramble_seed = as.integer(pv$seed)
      }

      hebo_optimizer = invoke(hebo$optimizers$hebo$HEBO, .args = optimizer_args)

      repeat {
        if (inst$is_terminated) {
          break
        }

        # tryCatch muss noch etwas ausgestaltet werden, siehe folgender Kommentar
        # hebo$optimizers$hebo$HEBO()$quasi_sample --- default HEBO sampler evtl notwendig, wenn suggest fehlschlägt; useful wenn SM zusammenbricht; wrappen in Trycatch von suggest funktion falls das passiert
        # ISSUE 1 - HEBO suggest doesnt expose metadata as SMAC3
        # trial_info exposes paraeters as a pandas DataFrame
        trial_info = tryCatch(
          hebo_optimizer$suggest(n_suggestions = as.integer(pv$n_suggestions %??% 1L)),
          # rausfinden wie HEBO suggest verwendet um mehrere configs oder einzelne configs zu kriegen; gibt mehrere Möglichkeiten das zu machen bei MBO interessant wie HEBO das macht
          error = function(e) NULL
        )
        if (is.null(trial_info)) {
          break
        }

        # convert pandas DataFrame to R data.frame-like object
        trial_info_dt = setDT(reticulate::py_to_r(trial_info))

        # evaluation of that config
        res = inst$eval_batch(trial_info_dt)

        # evaluated target columns are turned into a numeric matrix
        y = as.matrix(res[, inst$archive$cols_y, with = FALSE])

        # signs are flipped
        # ist es möglich bei HEBO auch multi-objective zu machen, also dass da mehrere y zurückkomen; das auch wichtig für denOptimizer ob er nicht nur SingleCrit oder auch MultiCrit kann
        y = y * matrix(inst$objective_multiplicator, nrow = nrow(y), ncol = ncol(y), byrow = TRUE)

        hebo_optimizer$observe(trial_info, y)
      }
    }
  )
)

mlr_optimizers$add("hebo", OptimizerBatchHEBO)
