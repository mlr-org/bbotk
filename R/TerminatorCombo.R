#' @title Combine Terminators
#'
#' @include Terminator.R
#'
#' @description
#' This class takes multiple [Terminator]s and terminates as soon as one or all
#' of the included terminators are positive.
#'
#' @section Parameters:
#' * `any` (`logical(1)`)\cr
#'   Terminate iff any included terminator is positive? (not all), default is `TRUE.
#'
#' @family Terminator
#' @export
#' @examples
#' terminators = c(TerminatorClockTime$new(), TerminatorEvals$new())
#' terminators[[1]]$param_set$values$stop_time = Sys.time() + 60
#' terminators[[2]]$param_set$values$n_evals = 10
#' terminator = TerminatorCombo$new(terminators)
#' terminator$param_set$values$any = FALSE
TerminatorCombo = R6Class("TerminatorCombo",
  inherit = Terminator,

  public = list(
    #' @field terminators (`list()`)\cr
    #'   List of objects of class [Terminator].
    terminators = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param terminators (`list()`)\cr
    #'   List of objects of class [Terminator].
    initialize = function(terminators = list(TerminatorNone$new())) {
      self$terminators = assert_list(terminators, types = "Terminator", min.len = 1L)
      ps = ParamSet$new(list(ParamLgl$new("any", default = TRUE, tags = "required")))
      ps$values = list(any = TRUE)
      properties = Reduce(intersect, map(terminators, "properties"))
      super$initialize(param_set = ps, properties = properties)
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE` otherwise.
    #'
    #' @param archive ([Archive]).
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      g = if (self$param_set$values$any) any else all
      g(map_lgl(self$terminators, function(t) t$is_terminated(archive)))
    },

    #' @description
    #' Printer.
    #'
    #' @param ... (ignored).
    print = function(...) {
      super$print(...)
      catf(str_indent("* Terminators:", paste(map_chr(self$terminators, format), collapse = ",")))
    }

  )
)
