#' @title Abstract Terminator Class
#'
#' @include mlr_terminators.R
#'
#' @description
#' Abstract `Terminator` class that implements the base functionality each
#' terminator must provide. A terminator is an object that determines when to
#' stop the optimization.
#'
#' Termination of optimization works as follows:
#'
#' * Evaluations in a instance are performed in batches.
#' * Before each batch evaluation, the [Terminator] is checked, and if it is positive,
#'   we stop.
#' * The optimization algorithm itself might decide not to produce any more points,
#'   or even might decide to do a smaller batch in its last evaluation.
#'
#' Therefore the following note seems in order: While it is definitely possible
#' to execute a fine-grained control for termination, and for many optimization
#' algorithms we can specify exactly when to stop, it might happen that too few
#' or even too many evaluations are performed, especially if multiple points are
#' evaluated in a single batch (c.f. batch size parameter of many optimization
#' algorithms). So it is advised to check the size of the returned archive, in
#' particular if you are benchmarking multiple optimization algorithms.
#'
<<<<<<< HEAD
#' @section Technical details:
#' `Terminator` subclasses can implement `$progressr_steps()` and
#' `$progressr_update()` to support progress bars via the package
#' \CRANpkg{progressr}. `$progressr_steps()` is called one time in
#' `OptimInstace$eval_batch()` to initialize the progress bar with the total
#' amount of steps. `$progressr_update()` is called each time a new batch is
#' evaluated and must return a named list with the amount of progress made in
#' the last batch (`amount`) and the total amount of progress made (`sum`). Supported
#' terminators need the property `progressr`.
#'
=======
>>>>>>> master
#' @family Terminator
#' @export
Terminator = R6Class("Terminator",
  public = list(
    #' @field param_set [paradox::ParamSet]\cr
    #' Set of control parameters for terminator.
    param_set = NULL,

    #' @field properties (`character()`)\cr
    #' Set of properties.
    properties = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_set ([paradox::ParamSet])\cr
    #'   Set of control parameters for terminator.
    #' @param properties (`character()`)\cr
    #'   Set of properties.
    initialize = function(param_set = ParamSet$new(),
      properties = character()) {
      self$param_set = assert_param_set(param_set)
      self$properties = assert_subset(properties,
        bbotk_reflections$terminator_properties)
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
      catf(self$format())
      catf(str_indent("* Parameters:", as_short_string(self$param_set$values)))
    }
  ),
)
