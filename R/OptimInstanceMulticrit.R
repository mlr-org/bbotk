#' @title Optimization Instance with budget and archive
#'
#' @description
#' Wraps an multi-criteria [Objective] function with extra services for convenient evaluation.
#' Inherits from [OptimInstance]
#'
#' @template param_xdt
#' @template param_ydt
#' @export
OptimInstanceMulticrit = R6Class("OptimInstanceMulticrit",
  inherit = OptimInstance,
  public = list(

    #' @description
    #' The [Optimizer] object writes the best found points
    #' and estimated performance values here (e.g. the Pareto Front). For internal use.
    #'
    #' @param xdt (`data.table`)\cr
    #'   x values as `data.table`.
    #'   Each row is one point.
    #'   Contains the value in the *search space* of the [OptimInstance] object.
    #'   Can contain additional columns for extra information.
    #' @param ydt (`numeric(1)`)\cr
    #'   Optimal outcomes, e.g. the Pareto front.
    #' @param opt_x (`list()`)\cr
    #'   Transformed x values / points from the *domain* of the [Objective] as a list of named lists.
    #'   Corresponds to the points in `xdt`.
    assign_result = function(xdt, ydt, opt_x = NULL) {
      #FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_data_table(ydt)
      assert_names(names(ydt), permutation.of = self$objective$codomain$ids())
      if (is.null(opt_x)) {
        design = Design$new(
          self$search_space,
          xdt[, self$search_space$ids(), with = FALSE],
          remove_dupl = FALSE
        )
        opt_x = design$transpose(trafo = TRUE, filter_na = TRUE)
      }
      assert_list(opt_x, len = nrow(xdt))
      private$.result = cbind(xdt, opt_x = opt_x, ydt)
    }
  ),

  active = list(
    #' @field result_opt_x (`list()`)\cr
    #'   (transformed) x part of the result in the *domain space* of the objective.
    result_opt_x = function() {
      private$.result$opt_x
    },

    #' @field result_y (`numeric(1)`)\cr
    #'   Optimal outcome.
    result_y = function() {
      private$.result[, self$objective$codomain$ids(), with = FALSE]
    }
  ),

  private = list(
    .result = NULL
  )
)
