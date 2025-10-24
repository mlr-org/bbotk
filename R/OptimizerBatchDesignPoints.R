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
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
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
#'
#' # load optimizer
#' design = data.table::data.table(x1 = c(0, 1), x2 = c(0, 1))
#' optimizer = opt("design_points", design = design)
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configurations
#' instance$archive
#'
#' # best performing configuration
#' instance$result
OptimizerBatchDesignPoints = R6Class("OptimizerBatchDesignPoints", inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        batch_size = p_int(lower = 1L, tags = "required"),
        design = p_uty(tags = "required", custom_check = function(x) {
          check_data_frame(x, min.rows = 1, min.cols = 1, null.ok = TRUE)
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
