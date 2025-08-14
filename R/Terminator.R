#' @title Abstract Terminator Class
#'
#' @include mlr_terminators.R
#'
#' @description
#' Abstract `Terminator` class that implements the base functionality each terminator must provide.
#' A terminator is an object that determines when to stop the optimization.
#'
#' Termination of optimization works as follows:
#'
#' * Evaluations in a instance are performed in batches.
#' * Before each batch evaluation, the [Terminator] is checked, and if it is positive, we stop.
#' * The optimization algorithm itself might decide not to produce any more points, or even might decide to do a smaller batch in its last evaluation.
#'
#' Therefore the following note seems in order:
#' While it is definitely possible to execute a fine-grained control for termination, and for many optimization algorithms we can specify exactly when to stop, it might happen that too few or even too many evaluations are performed, especially if multiple points are evaluated in a single batch (c.f. batch size parameter of many optimization algorithms).
#' So it is advised to check the size of the returned archive, in particular if you are benchmarking multiple optimization algorithms.
#'
#' @section Technical details:
#' `Terminator` subclasses can overwrite `.status()` to support progress bars via the package \CRANpkg{progressr}.
#' The method must return the maximum number of steps (`max_steps`) and the currently achieved number of steps (`current_steps`) as a named integer vector.
#'
#' @family Terminator
#'
#' @template field_param_set
#' @template field_label
#' @template field_man
#'
#' @template param_id
#' @template param_param_set
#' @template param_label
#' @template param_man
#' @template param_archive
#'
#' @export
Terminator = R6Class("Terminator",
  inherit = Mlr3Component,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param properties (`character()`)\cr
    #'   Set of properties of the terminator.
    #'   Must be a subset of [`bbotk_reflections$terminator_properties`][bbotk_reflections].
    #'
    #' @param unit (`character()`)\cr
    #'   Unit of steps.
    initialize = function(id, param_set = ps(), properties = character(), unit = "percent", label, man) {
      if (!missing(label) || !missing(man)) {
        deprecated_component("label and man are deprecated for Terminator construction and will be removed in the future.")
      }

      super$initialize(dict_entry = id, dict_shortaccess = "trm",
        param_set = param_set, properties = properties
      )

      assert_subset(properties, bbotk_reflections$terminator_properties)
      private$.unit = assert_string(unit)
    },

    #' @description
    #' Helper for print outputs.
    #' @param with_params (`logical(1)`)\cr
    #'   Add parameter values to format string.
    #' @param ... (ignored).
    format = function(with_params = FALSE, ...) {
      if (with_params && length(self$param_set$values)) {
        sprintf("<%s> [%s]", class(self)[1L], as_short_string(self$param_set$values))
      } else {
        sprintf("<%s>", class(self)[1L])
      }
    },

    #' @description
    #' Printer.
    #'
    #' @param ... (ignored).
    print = function(...) {
      msg_h = if (is.na(self$label)) "" else paste0(" - ", self$label)
      terminators = map_chr(self$terminators, function(t) {class(t)[1L]})
      msg_trms = cli_vec(lapply(terminators, function(trm) format_inline('{.cls {trm}}')),
                         style = list(last = ' and ', sep = ', '))

      cat_cli({
        cli_h1("{.cls {class(self)[1L]}}{msg_h}")
        cli_li("Parameters: {as_short_string(self$param_set$values)}")
        cli_li("Terminators: {msg_trms}")
      })
    },

    #' @description
    #' Returns how many progression steps are made (`current_steps`) and the
    #' amount steps needed for termination (`max_steps`).
    #'
    #' @return named `integer(2)`.
    status = function(archive) {
      #assert_r6(archive, "Archive")
      private$.status(archive)
    },

    #' @description
    #' Returns remaining runtime in seconds. If the terminator is not
    #' time-based, the reaming runtime is `Inf`.
    #'
    #' @return `integer(1)`.
    remaining_time = function(archive) {
      assert_r6(archive, "Archive")
      if (isTRUE(self$unit == "seconds")) {
        status = self$status(archive)
        unname(status["max_steps"] - status["current_steps"])
      } else {
        Inf
      }
    }
  ),

  active = list(
    #' @field unit (`character()`)\cr
    #'   Unit of steps.
    unit = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.unit)) {
        stop("$unit is read-only.")
      }
      private$.unit
    }
  ),

  private = list(
    .status = function(archive) {
      max_steps = 100
      current_steps = if (self$is_terminated(archive)) 100 else 0
      c("max_steps" = max_steps, "current_steps" = current_steps)
    },
    .unit = NULL
  )
)
