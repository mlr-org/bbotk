#' @title Terminator that Limits Total Budget Component Evaluation
#'
#' @name mlr_terminators_budget
#' @include Terminator.R
#'
#' @description
#' [`Terminator`][bbotk::Terminator] that terminates after the sum (or similar
#' aggregate) of a given "budget" search space component crosses a threshold.
#'
#' @templateVar id budget
#' @template section_dictionary_terminator
#'
#' @section Parameters:
#' \describe{
#' \item{`budget`}{`numeric(1)`\cr
#' Total budget available, after which to stop. Initialized to `Inf`.}
#' \item{`aggregate`}{`function`\cr
#' Function taking a vector of values of the budget search space component,
#' returning a scalar value to be compared to the `budget` configuration
#' parameter. If this function returns a value greater or equal to `budget` the
#' termination criterion is matched. Calling this function with `NULL` must
#' return the lower bound of the budget value; percentage progress is reported
#' as the progress from this lower bound to the value of `budget`. Initialized
#' to `sum()`}
#' }
#'
#' @family Terminator
#' @template param_archive
#' @export
#' @examples
#' TerminatorBudget$new()
#'
#' # evaluate until sum of budget component of evaluated configs is >= 100
#' trm("budget", budget = 100)
#'
#' # evaluate until sum of two to the power of budget component is >= 100
#' trm("budget", budget = 1024, aggregate = function(x) sum(2 ^ x))
#' @export
TerminatorBudget = R6Class("TerminatorBudget", inherit = Terminator,
  public = list(

    #' @description
    #' Initialize the `TerminatorBudget` object.
    initialize = function() {
      param_set = ps(
        budget = p_dbl(tags = "required"), aggregate =
          p_uty(tags = "required", custom_check = function(x) {
            if (test_function(x) && test_number(x(NULL), finite = TRUE)) return(TRUE)
            "must be a function with one argument, which when called with NULL must return a finite numeric value."
          })
        )
      param_set$values = list(budget = Inf, aggregate = sum)
      super$initialize(param_set = param_set, properties = c("single-crit", "multi-crit"))
      self$unit = "percent"
    },

    #' @description
    #' Is `TRUE` iff the termination criterion is positive, and `FALSE`
    #' otherwise.
    #' @return `logical(1)`.
    is_terminated = function(archive) {
      assert_r6(archive, "Archive")
      params = self$param_set$get_values()
      budget_id = archive$search_space$ids(tags = "budget")
      if (length(budget_id) != 1) stopf("Need exactly one budget parameter, but found %s: %s",
        length(budget_id), str_collapse(budget_id))

      budget_data = if (!archive$n_evals) NULL else archive$data["evaluated", budget_id, on = "status", with = FALSE][[1]]
      params$aggregate(budget_data) >= params$budget
    }
  ),

  private = list(
    .status = function(archive) {
      params = self$param_set$get_values()
      budget_id = archive$search_space$ids(tags = "budget")
      if (length(budget_id) != 1) stopf("Need exactly one budget parameter, but found %s: %s",
        length(budget_id), str_collapse(budget_id))
      budget_data = if (!archive$n_evals) NULL else archive$data["evaluated", budget_id, on = "status", with = FALSE][[1]]

      origin = params$aggregate(NULL)
      aggregated = params$aggregate(budget_data)
      max_steps = if (params$budget <= origin) 0 else 100
      # when budget <= origin, then we are terminated from the beginning,
      # and want to avoid negative numbers / division by 0.
      current_steps = if (params$budget <= origin) 0 else floor((aggregated - origin) / (params$budget - origin) * 100)
      c("max_steps" = max_steps, "current_steps" = current_steps)
    }
  )
)

mlr_terminators$add("budget", TerminatorBudget)
