#' @title Combine Terminators
#'
#' @name mlr_terminators_combo
#' @include Terminator.R
#'
#' @description
#' This class takes multiple [Terminator]s and terminates as soon as one or all
#' of the included terminators are positive.
#'
#' @templateVar id combo
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`any`}{`logical(1)`\cr
#' Terminate iff any included terminator is positive? (not all), default is
#' `TRUE`.}
#' }
#'
#' @family Terminator
#' @export
#' @examples
#' trm("combo",
#'   list(trm("clock_time", stop_time = Sys.time() + 60),
#'     trm("evals", n_evals = 10)), any = FALSE
#' )
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
      self$terminators = assert_list(terminators, types = "Terminator",
        min.len = 1L)
      ps = ParamSet$new(list(ParamLgl$new("any", default = TRUE,
        tags = "required")))
      ps$values = list(any = TRUE)
      properties = Reduce(intersect, map(terminators, "properties"))
      super$initialize(param_set = ps, properties = properties)
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
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
      catf(str_indent("* Terminators:", paste(map_chr(self$terminators, format),
        collapse = ",")))
    }

  )
)

mlr_terminators$add("combo", TerminatorCombo)
