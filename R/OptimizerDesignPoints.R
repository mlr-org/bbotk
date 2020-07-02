#' @title Optimization via Design Points
#'
#' @include Optimizer.R
#' @name mlr_optimizers_design_points
#'
#' @description
#' `OptimizerDesignPoints` class that implements optimization w.r.t. fixed
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
#' @export
#' @examples
#' library(paradox)
#' library(data.table)
#'
#' domain = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
#'
#' search_space = ParamSet$new(list(ParamDbl$new("x", lower = -1, upper = 1)))
#'
#' codomain = ParamSet$new(list(ParamDbl$new("y", tags = "minimize")))
#'
#' objective_function = function(xs) {
#'   list(y = as.numeric(xs)^2)
#' }
#'
#' objective = ObjectiveRFun$new(fun = objective_function,
#'                               domain = domain,
#'                               codomain = codomain)
#' terminator = term("evals", n_evals = 10)
#' instance = OptimInstanceSingleCrit$new(objective = objective,
#'                              search_space = search_space,
#'                              terminator = terminator)
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
#' instance$archive$data()
OptimizerDesignPoints = R6Class("OptimizerDesignPoints", inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new("batch_size", lower = 1L, tags = "required"),
        ParamUty$new("design", tags = "required", custom_check = function(x) {
          check_data_table(x, min.rows = 1, min.cols = 1, null.ok = TRUE)
        })
      ))
      ps$values = list(batch_size = 1L, design = NULL)
      super$initialize(
        param_set = ps,
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit")
      )
    }
  ),

  private = list(
    .optimize = function(instance) {
      pv = self$param_set$values
      if (is.null(pv$design))
        stopf("Please set design datatable!")
      d = Design$new(pv$design,
                     param_set = instance$search_space, remove_dupl = FALSE) # does assert for us
      ch = chunk_vector(seq_row(d$data), chunk_size = pv$batch_size,
                        shuffle = FALSE)
      for (inds in ch) {
        instance$eval_batch(d$data[inds, ])
      }
    }
  )
)

mlr_optimizers$add("design_points", OptimizerDesignPoints)
