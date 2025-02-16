#' @title OptimizerBatchDEoptim
#'
#' @include Optimizer.R
#' @name mlr_optimizers_deoptim
#'
#' @description
#' `OptimizerBatchDEoptim` class that implements Differential Evolution.
#' Calls [DEoptim::DEoptim()] from package \CRANpkg{DEoptim}.
#'
#' @templateVar id deoptim
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`start_values`}{`character(1)`\cr
#' Create `random` start values or based on `center` of search space?
#' In the latter case, it is the center of the parameters before a trafo is applied.}
#' }
#'
#' For the meaning of the control parameters, see [DEoptim::DEoptim()].
#' Note that we have removed all control parameters which refer to the termination of the algorithm and where our terminators allow to obtain the same behavior.
#' We set `itermax = 10000` to allow the termination via our terminators.
#' If more iterations are needed, set `itermax` to a higher value in the parameter set.
#'
#' @template section_progress_bars
#'
#' @export
OptimizerBatchDEoptim = R6Class("OptimizerBatchDEoptim",
  inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        strategy = p_uty(),
        bs = p_lgl(default = FALSE),
        NP = p_int(),
        itermax = p_int(0, default = 10000),
        CR = p_dbl(0, 1, default = 0.5),
        F = p_dbl(0, 2, default = 0.8),
        initialpop = p_uty(),
        p = p_dbl(0, 1),
        c = p_dbl(0, 1),
        reltol = p_dbl(),
        steptol = p_dbl()
      )

      param_set$set_values(itermax = 10000)

      super$initialize(
        id = "deoptim",
        param_set = param_set,
        param_classes = "ParamDbl",
        properties = "single-crit",
        packages = "DEoptim",
        label = "Differential Evolution",
        man = "bbotk::mlr_optimizers_deoptim"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      control = invoke(DEoptim::DEoptim.control, .args = pv)

      DEoptim::DEoptim(fn = inst$objective_function, lower = inst$search_space$lower, upper = inst$search_space$upper, control = control)
    }
  )
)

mlr_optimizers$add("deoptim", OptimizerBatchDEoptim)
