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

    #' @field max (`integer(1)`).
    max = NULL,

    #' @field current .
    current = NULL,

    #' @field unit (`character(1)`).
    unit = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param max (`integer(1)`)\cr
    #' Total number of steps.
    #' @param unit (`character(1)`)\cr
    #' Unit of steps.
    initialize = function(max, unit) {
      self$max = assert_int(max)
      self$unit = assert_character(unit)

      self$progressor = progressr::progressor(steps = self$max)
    },

    #' @description
    #' Updates `progressr::progressor()` with current steps.
    #'
    #' @param current (`integer(1)`)\cr
    #' Current steps.
    update = function(current) {
      amount = current - self$current
      self$current = current

      self$progressor(message = sprintf("%i of %i %s", self$current, self$max, self$unit),
        amount = amount)
    }
  )
)
