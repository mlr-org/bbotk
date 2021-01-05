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
    initialize = function() {},

    #' @description
    #' Creates `progressr::progressor()`.
    #'
    #' @param terminator ([Terminator]).
    setup = function(terminator, archive) {
      self$max_steps = assert_int(terminator$status(archive)["max_steps"])
      self$unit = assert_character(terminator$unit)
      self$progressor = progressr::progressor(steps = self$max_steps)
    },

    #' @description
    #' Updates `progressr::progressor()` with current steps.
    #'
    #' @param terminator ([Terminator]).
    update = function(terminator, archive) {
      if(isNamespaceLoaded("progressr")) {
        if(is.null(self$progressor)) {
          self$setup(terminator, archive)
        } else {
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
    }
  )
)
