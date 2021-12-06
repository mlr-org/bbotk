#' @title Optimizer Optuna
#'
#' @export
OptimizerOptunaTpe = R6Class("OptimizerOptunaTpe",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        param_set = ps(optuna_objective = p_uty()),
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit")
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      terminator = inst$terminator
      pv = self$param_set$values
      source_python(pv$optuna_objective)
      optuna = import("optuna")

      # check terminators
      if (!(inherits(terminator, "TerminatorEvals"))) {
        stopf("%s is not supported. Use <TerminatorEvals> instead.", format(terminator))
      }

      # transfer domain
      param_set = as.data.table(inst$search_space)[, c("id", "class", "lower", "upper", "levels"), with = FALSE]
      obj = Objective(param_set)

      # optimize
      study = optuna$create_study()
      study$optimize(obj, n_trials = terminator$param_set$values$n_evals)

      # add to archive
      res = setDT(study$trials_dataframe())
      xdt = setnames(res[, paste0("params_", inst$archive$cols_x), with = FALSE], inst$archive$cols_x)
      ydt = setnames(res[, "value", with = FALSE], inst$archive$cols_y)
      inst$archive$add_evals(xdt, ydt = ydt)
      set(inst$archive$data, j = "timestamp", value = res$datetime_complete)
    }
  )
)

mlr_optimizers$add("optuna_tpe", OptimizerOptunaTpe)


