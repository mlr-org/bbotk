#' @title Optimization via Design Points
#'
#' @include Optimizer.R
#' @name mlr_optimizers_design_points
#'
#' @description
#' `OptimizerBatchDesignPoints` class that implements optimization w.r.t. fixed
#' design points. We simply search over a set of points fully specified by the
#' user. The points in the design are evaluated in order as given.
#'
#' In order to support general termination criteria and parallelization, we
#' evaluate points in a batch-fashion of size `batch_size`. Larger batches mean
#' we can parallelize more, smaller batches imply a more fine-grained checking
#' of termination criteria.
#'
#' @templateVar id design_points
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' \describe{
#' \item{`batch_size`}{`integer(1)`\cr
#' Maximum number of configurations to try in a batch.}
#' \item{`design`}{[data.table::data.table]\cr
#' Design points to try in search, one per row.}
#' }
#'
#' @template section_progress_bars
#'
#' @export
#' @examples
#' library(data.table)
#' search_space = domain = ps(x = p_dbl(lower = -1, upper = 1))
#'
#' codomain = ps(y = p_dbl(tags = "minimize"))
#'
#' objective_function = function(xs) {
#'   list(y = as.numeric(xs)^2)
#' }
#'
#' objective = ObjectiveRFun$new(
#'   fun = objective_function,
#'   domain = domain,
#'   codomain = codomain)
#'
#' instance = OptimInstanceBatchSingleCrit$new(
#'   objective = objective,
#'   search_space = search_space,
#'   terminator = trm("evals", n_evals = 10))
#'
#' design = data.table(x = c(0, 1))
#'
#' optimizer = opt("design_points", design = design)
#'
#' # Modifies the instance by reference
#' optimizer$optimize(instance)
#'
#' # Returns best scoring evaluation
#' instance$result
#'
#' # Allows access of data.table of full path of all evaluations
#' as.data.table(instance$archive)
OptimizerBatchDesignPoints = R6Class("OptimizerBatchDesignPoints", inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        batch_size = p_int(lower = 1L, tags = "required"),
        design = p_uty(tags = "required", custom_check = function(x) {
          check_data_table(x, min.rows = 1, min.cols = 1, null.ok = TRUE)
        })
      )
      param_set$values = list(batch_size = 1L, design = NULL)
      super$initialize(
        id = "design_points",
        param_set = param_set,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"),
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Design Points",
        man = "bbotk::mlr_optimizers_design_points"
      )
    }
  ),

  private = list(
    .optimize = function(instance) {
      pv = self$param_set$values
      if (is.null(pv$design)) {
        stopf("Please set design datatable!")
      }
      design = instance$search_space$assert_dt(pv$design)

      ch = chunk_vector(seq_row(design), chunk_size = pv$batch_size,
        shuffle = FALSE)
      for (inds in ch) {
        instance$eval_batch(design[inds, ])
      }
    }
  )
)

mlr_optimizers$add("design_points", OptimizerBatchDesignPoints)
