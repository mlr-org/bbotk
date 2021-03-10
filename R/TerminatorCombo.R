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
#' @template param_archive
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
      properties = properties[properties != "progressr"]
      super$initialize(param_set = ps, properties = properties)
      self$unit = "percent"
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #'
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      assert_r6(archive, "Archive")
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
    },

    #' @description
    #' Returns the remaining runtime in seconds. If `any = TRUE`, the remaining
    #' runtime is determined by the time-based terminator with the shortest time
    #' remaining. If non-time-based terminators are used and `any = FALSE`,
    #' the the remaining runtime is always `Inf`.
    #' @return `integer(1)`.
    remaining_time = function(archive) {
      assert_r6(archive, "Archive")
      min_max = if(self$param_set$values$any) min else max
      min_max(map_dbl(self$terminators, function(t) t$remaining_time(archive)), na.rm = TRUE)
    },

    #' @description
    #' Returns `max_steps` and `current_steps` for each terminator.
    #' @return [data.table::data.table].
    status_long = function(archive) {
      assert_r6(archive, "Archive")
      map_dtr(self$terminators, function(t) {
        cbind(as.data.table(as.list(t$status(archive))), unit = t$unit)
      })
    }
  ),

  private = list(
    .status = function(archive) {
      max_steps = 100
      min_max = if(self$param_set$values$any) max else min
      current_steps = min_max(map_int(self$terminators, function(t) {
        status = t$status(archive)
        as.integer(status["current_steps"]/status["max_steps"]*100)
        }))
      c("max_steps" = max_steps, "current_steps" = current_steps)
    }
  )
)

mlr_terminators$add("combo", TerminatorCombo)
