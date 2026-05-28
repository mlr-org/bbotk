#' @title Optimization via Optuna
#'
#' @include Optimizer.R
#' @name mlr_optimizers_optuna
#'
#' @description
#' `OptimizerBatchOptuna` class that implements optimization via the Python
#' Optuna framework. Calls Optuna via \CRANpkg{reticulate}.
#'
#' @templateVar id optuna
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`sampler`}{`character(1)`\cr
#'   Optuna sampler to use.
#'   One of `"tpe"` (Tree-structured Parzen Estimator), `"cmaes"` (CMA-ES),
#'   `"gp"` (Gaussian Process), `"nsga2"` (NSGA-II), `"nsga3"` (NSGA-III),
#'   `"qmc"` (Quasi-Monte Carlo), `"bruteforce"`, or `"random"`.
#'   `"nsga2"` and `"nsga3"` are recommended for multi-criteria optimization.
#'   Default is `"tpe"`.}
#' \item{`n_startup_trials`}{`integer(1)`\cr
#'   Number of random startup trials before the TPE sampler model is fitted.
#'   Only used when `sampler = "tpe"`.
#'   Default is `10L`.}
#' \item{`seed`}{`integer(1)`\cr
#'   Random seed passed to the sampler for reproducibility.
#'   Default is `NULL` (no fixed seed).}
#' }
#'
#' @template section_progress_bars
#'
#' @export
OptimizerBatchOptuna = R6Class(
  "OptimizerBatchOptuna",
  inherit = OptimizerBatch,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        sampler = p_fct(levels = c("tpe", "cmaes", "gp", "nsga2", "nsga3", "qmc", "bruteforce", "random"), default = "tpe"),
        n_startup_trials = p_int(lower = 1L),
        seed = p_int(lower = 1L, special_vals = list(NULL))
      )

      super$initialize(
        id = "optuna",
        param_set = param_set,
        param_classes = c("ParamDbl", "ParamInt", "ParamFct", "ParamLgl"),
        properties = c("single-crit", "multi-crit"),
        packages = "reticulate",
        label = "Optuna",
        man = "bbotk::mlr_optimizers_optuna"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      assert_python_packages("optuna")
      optuna = reticulate::import("optuna")
      optuna$logging$set_verbosity(optuna$logging$WARNING)

      pv = self$param_set$values

      codomain = inst$archive$codomain

      # Determine whether the objectives are to be maximized/minimized
      directions = vapply(
        codomain$ids(),
        function(id) {
          if ("maximize" %in% codomain$params[[id]]$tags) "maximize" else "minimize"
        },
        character(1L)
      )

      sampler = switch(
        pv$sampler %??% "tpe",
        tpe = optuna$samplers$TPESampler(n_startup_trials = pv$n_startup_trials, seed = pv$seed),
        cmaes = optuna$samplers$CmaEsSampler(seed = pv$seed),
        gp = optuna$samplers$GPSampler(seed = pv$seed),
        nsga2 = optuna$samplers$NSGAIISampler(seed = pv$seed),
        nsga3 = optuna$samplers$NSGAIIISampler(seed = pv$seed),
        qmc = optuna$samplers$QMCSampler(seed = pv$seed),
        bruteforce = optuna$samplers$BruteForceSampler(),
        random = optuna$samplers$RandomSampler(seed = pv$seed)
      )

      if (length(directions) == 1L) {
        study = optuna$create_study(direction = directions[[1L]], sampler = sampler)
      } else {
        study = optuna$create_study(directions = as.list(unname(directions)), sampler = sampler)
      }

      # Ask-and-tell loop
      repeat {
        trial = study$ask()
        xdt = private$.trial_to_xdt(trial, inst$search_space)
        inst$eval_batch(xdt)

        n = nrow(inst$archive$data)
        y_vals = unlist(inst$archive$data[n, inst$archive$cols_y, with = FALSE])

        if (length(y_vals) == 1L) {
          study$tell(trial, y_vals[[1L]])
        } else {
          study$tell(trial, as.list(y_vals))
        }
      }
    },

    # Convert an Optuna trial to a single-row data.table in bbotk's search space
    .trial_to_xdt = function(trial, search_space) {
      ids = search_space$ids()
      classes = search_space$class
      xs = lapply(ids, function(id) {
        switch(
          classes[[id]],
          ParamDbl = as.double(trial$suggest_float(id, search_space$lower[[id]], search_space$upper[[id]])),
          ParamInt = as.integer(trial$suggest_int(
            id,
            as.integer(search_space$lower[[id]]),
            as.integer(search_space$upper[[id]])
          )),
          ParamFct = as.character(trial$suggest_categorical(id, as.list(search_space$levels[[id]]))),
          ParamLgl = as.logical(trial$suggest_categorical(id, list(TRUE, FALSE)))
        )
      })
      as.data.table(setNames(xs, ids))
    }
  )
)

mlr_optimizers$add("optuna", OptimizerBatchOptuna)
