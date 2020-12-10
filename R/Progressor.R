#' @title Progressor
#'
#' @description
#' Wraps `progressr::progressor()` function and stores current progress.
#'
#' @export
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
    #'
    #' @param max_steps (`integer(1)`)\cr
    #' Total number of steps.
    #' @param unit (`character(1)`)\cr
    #' Unit of steps.
    initialize = function(max_steps, unit) {
      self$max_steps = assert_int(max_steps)
      self$unit = assert_character(unit)

      self$progressor = progressr::progressor(steps = self$max_steps)
    },

    #' @description
    #' Updates `progressr::progressor()` with current steps.
    #'
    #' @param current_steps (`integer(1)`)\cr
    #' Current steps.
    #' @param best_y ([data.table::data.table])\cr
    #' Best outcome in archive.
    update = function(current_steps, best_y) {
      amount = current_steps - self$current_steps
      self$current_steps = current_steps
      best_y = map_chr(as.list(best_y), function(x) str_collapse(round(x, 3)))

      if(self$unit == "percent") {
        message = sprintf("Best: %s", str_collapse(paste0(names(best_y), ": ", best_y)))
      } else {
        message = sprintf("%i/%i %s Best: %s", self$current_steps, self$max_steps, self$unit, str_collapse(paste0(names(best_y), ": ", best_y)))
      }

      self$progressor(message = message, amount = amount)
    }
  )
)
