#' @title Optimization via Ax (Adaptive Experimentation Platform)
#'
#' @include Optimizer.R
#' @name mlr_optimizers_ax
#'
#' @description
#' `OptimizerBatchAx` class that implements optimization via the Python
#' Ax framework. Calls Ax via \CRANpkg{reticulate}.
#'
#' @templateVar id ax
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`n_sobol`}{`integer(1)`\cr
#'   Number of quasi-random (Sobol) initialization trials before Bayesian optimization starts.
#'   If `NULL` (default), Ax determines the number automatically based on the search space.}
#' \item{`seed`}{`integer(1)`\cr
#'   Random seed passed to the `AxClient` for reproducibility.
#'   Default is `NULL` (no fixed seed).}
#' }
#'
#' @template section_progress_bars
#'
#' @export
OptimizerBatchAx = R6Class(
  "OptimizerBatchAx",
  inherit = OptimizerBatch,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        n_sobol = p_int(lower = 1L, special_vals = list(NULL)),
        seed = p_int(lower = 1L, special_vals = list(NULL))
      )

      super$initialize(
        id = "ax",
        param_set = param_set,
        param_classes = c("ParamDbl", "ParamInt", "ParamFct", "ParamLgl"),
        properties = c("single-crit", "multi-crit"),
        packages = "reticulate",
        label = "Ax",
        man = "bbotk::mlr_optimizers_ax"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      assert_python_packages("ax")
      ax_service = reticulate::import("ax.service.ax_client")

      pv = self$param_set$values
      search_space = inst$search_space
      codomain = inst$archive$codomain

      # Build Ax parameter definitions from paradox search space
      parameters = private$.search_space_to_ax_params(search_space)

      # Build objectives dict from codomain
      objective_ids = codomain$ids()
      objectives = setNames(
        lapply(objective_ids, function(id) {
          minimize = !("maximize" %in% codomain$params[[id]]$tags)
          ax_service$ObjectiveProperties(minimize = minimize)
        }),
        objective_ids
      )

      # Build AxClient args; optionally set seed and custom generation strategy
      client_args = list(verbose_logging = FALSE)
      if (!is.null(pv$seed)) {
        client_args$random_seed = as.integer(pv$seed)
      }
      if (!is.null(pv$n_sobol)) {
        ax_gs = reticulate::import("ax.modelbridge.generation_strategy")
        ax_models = reticulate::import("ax.modelbridge.registry")
        n_sobol = as.integer(pv$n_sobol)
        client_args$generation_strategy = ax_gs$GenerationStrategy(
          steps = list(
            ax_gs$GenerationStep(
              model = ax_models$Models$SOBOL,
              num_trials = n_sobol,
              min_trials_observed = n_sobol
            ),
            ax_gs$GenerationStep(
              model = ax_models$Models$BOTORCH_MODULAR,
              num_trials = -1L
            )
          )
        )
      }

      ax_client = invoke(ax_service$AxClient, .args = client_args)

      ax_client$create_experiment(
        name = "bbotk_experiment",
        parameters = parameters,
        objectives = objectives
      )

      # Ask-and-tell loop
      repeat {
        result = tryCatch(
          ax_client$get_next_trial(),
          error = function(e) NULL
        )
        if (is.null(result)) break

        params = reticulate::py_to_r(result[[1L]])
        trial_index = result[[2L]]

        xdt = private$.params_to_xdt(params, search_space)
        inst$eval_batch(xdt)

        n = nrow(inst$archive$data)
        y_vals = unlist(inst$archive$data[n, inst$archive$cols_y, with = FALSE])

        ax_client$complete_trial(trial_index = trial_index, raw_data = as.list(y_vals))
      }
    },

    .search_space_to_ax_params = function(search_space) {
      ids = search_space$ids()
      classes = search_space$class
      lapply(ids, function(id) {
        switch(
          classes[[id]],
          ParamDbl = list(
            name = id,
            type = "range",
            bounds = list(as.double(search_space$lower[[id]]), as.double(search_space$upper[[id]])),
            value_type = "float"
          ),
          ParamInt = list(
            name = id,
            type = "range",
            bounds = list(as.integer(search_space$lower[[id]]), as.integer(search_space$upper[[id]])),
            value_type = "int"
          ),
          ParamFct = list(
            name = id,
            type = "choice",
            values = as.list(search_space$levels[[id]]),
            value_type = "str"
          ),
          ParamLgl = list(
            name = id,
            type = "choice",
            values = list(TRUE, FALSE),
            value_type = "bool"
          )
        )
      })
    },

    .params_to_xdt = function(params, search_space) {
      ids = search_space$ids()
      classes = search_space$class
      xs = lapply(ids, function(id) {
        val = params[[id]]
        switch(
          classes[[id]],
          ParamDbl = as.double(val),
          ParamInt = as.integer(val),
          ParamFct = as.character(val),
          ParamLgl = as.logical(val)
        )
      })
      as.data.table(setNames(xs, ids))
    }
  )
)

mlr_optimizers$add("ax", OptimizerBatchAx)
