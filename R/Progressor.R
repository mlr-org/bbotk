#' @title Progressor
#'
#' @description
#' Wraps `progressr::progressor()` function and stores current progress.
#' 
#' @template param_archive
Progressor = R6Class("Progressor",
  public = list(

    #' @field progressor (`progressr::progressor()`).
    progressor = NULL,

    #' @field max_steps (`integer(1)`).
    max_steps = NULL,

    #' @field current_steps (`integer(1)`).
    current_steps = NULL,

    #' @field unit (`character(1)`).
    unit = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param progressor (`progressr::progressor()`)\cr
    #'   Progressor function.
    #' @param unit (`character(1)`)\cr
    #'   Unit of progress.
    initialize = function(progressor, unit) {
      self$progressor = progressor
      self$unit = unit
      self$current_steps = 0
    },

    #' @description
    #' Updates `progressr::progressor()` with current steps.
    #'
    #' @param terminator ([Terminator]).
    update = function(terminator, archive) {
      if(archive$n_evals != 0) {
        current_steps = assert_int(terminator$status(archive)["current_steps"])
        ydt = archive$best()[, archive$cols_y, with=FALSE]

        amount = current_steps - self$current_steps
        self$current_steps = current_steps
        best_y = map_chr(as.list(ydt), function(x) str_collapse(signif(x, 2)))

        if(self$unit == "percent") {
          message = sprintf("Best: %s", str_collapse(paste0(names(best_y), ": ", best_y)))
        } else {
          message = sprintf("%i/%i %s. Best: %s", self$current_steps, self$max_steps, self$unit, str_collapse(paste0(names(best_y), ": ", best_y)))
        }
        self$progressor(message = message, amount = amount)
      }
    }
  )
)
