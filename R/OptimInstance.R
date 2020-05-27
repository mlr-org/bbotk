#' @title Optimization Instance with budget and archive
#'
#' @description
#' Wraps an [Objective] function with extra services for convenient evaluation.
#'
#' * Automatic storing of results in an [Archive] after evaluation.
#' * Automatic checking for termination. Evaluations of design points are
#'   performed in batches. Before a batch is evaluated, the [Terminator] is
#'   queried for the remaining budget. If the available budget is exhausted, an
#'   exception is raised, and no further evaluations can be performed from this
#'   point on.
#'
#' @template param_xdt
#' @export
OptimInstance = R6Class("OptimInstance",
  public = list(

    #' @field objective ([Objective]).
    objective = NULL,

    #' @field search_space ([paradox::ParamSet]).
    search_space = NULL,

    #' @field terminator ([Terminator]).
    terminator = NULL,

    #' @field is_terminated (`logical(1)`).
    is_terminated = FALSE,

    #' @field archive ([Archive]).
    archive = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param objective ([Objective]).
    #' @param search_space ([paradox::ParamSet]).
    #' @param terminator ([Terminator]).
    initialize = function(objective, search_space, terminator) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = assert_param_set(search_space)
      self$terminator = assert_terminator(terminator)
      self$archive = Archive$new(search_space = search_space,
        codomain = objective$codomain)
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Printer.
    #'
    #' @param ... (ignored).
    print = function(...) {
      catf(format(self))
      catf(str_indent("* Objective:", format(self$objective)))
      catf(str_indent("* Search Space:", format(self$search_space)))
      catf(str_indent("* Terminator:", format(self$terminator)))
      catf(str_indent("* Terminated:", self$is_terminated))
      print(self$archive)
    },

    #' @description
    #' Evaluates all input values in `xdt` by calling
    #' the [Objective]. Applies possible transformations to the input values
    #' and writes the results to the [Archive].
    #'
    #' Before each batch-evaluation, the [Terminator] is checked, and if it
    #' is positive, an exception of class `terminated_error` is raised. This
    #' function should be internally called by the [Optimizer].
    eval_batch = function(xdt) {
      if (self$is_terminated || self$terminator$is_terminated(self$archive)) {
        self$is_terminated = TRUE
        stop(terminated_error(self))
      }
      design = Design$new(
        self$search_space,
        xdt[, self$search_space$ids(), with = FALSE],
        remove_dupl = FALSE
      )
      xss_trafoed = design$transpose(trafo = TRUE, filter_na = TRUE)
      ydt = self$objective$eval_many(xss_trafoed)
      self$archive$add_evals(xdt, xss_trafoed, ydt)
      return(invisible(ydt))
    },

    #' @description
    #' The [Optimizer] object writes the best found point
    #' and estimated performance values here. For internal use.
    #'
    #' @param y (`numeric(1)`)\cr
    #'   Optimal outcome.
    #' @param opt_x (`list()`)\cr
    #'   Transformed x values / points from the *domain* of the [Objective] as a named list.
    assign_result = function(xdt, y, opt_x = NULL) {
      #FIXME: We could have one way that just lets us put a 1xn DT as result directly.
      assert_data_table(xdt, nrows = 1)
      assert_names(names(xdt), must.include = self$search_space$ids())
      assert_number(y)
      assert_names(names(y), permutation.of = self$objective$codomain$ids())
      if (is.null(opt_x)) {
        design = Design$new(
          self$search_space,
          xdt[, self$search_space$ids(), with = FALSE],
          remove_dupl = FALSE
        )
        opt_x = design$transpose(trafo = TRUE, filter_na = TRUE)[[1]]
      }
      assert_list(opt_x)
      assert_names(names(opt_x), subset.of = self$objective$domain$ids()) #the domain can be bigger then the search space after trafo
      private$.result = cbind(xdt, opt_x = list(opt_x), t(y)) #t(y) so the name of y stays
    }
  ),

  active = list(
    #' @field result (`list()`)\cr
    #' Get result
    result = function() {
      private$.result
    },

    #' @field result_x (`data.frame()`)\cr
    #'   x part of the result in the *search space*.
    result_x = function() {
      private$.result[, self$search_space$ids(), with = FALSE]
    },

    #' @field result_opt_x (`list()`)\cr
    #'   (transformed) x part of the result in the *domain space* of the objective.
    result_opt_x = function() {
      private$.result$opt_x[[1]]
    },

    #' @field result_y (`numeric(1)`)
    #'   Optimal outcome.
    result_y = function() {
      unlist(private$.result[, self$objective$codomain$ids(), with = FALSE])
    }
  ),

  private = list(
    .result = NULL
  )
)
