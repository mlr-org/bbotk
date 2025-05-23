#' @title Codomain of Function
#'
#' @description
#' A [paradox::ParamSet] defining the codomain of a function.
#' The parameter set must contain at least one target parameter tagged with `"minimize"` or `"maximize"`.
#' The codomain may contain extra parameters which are ignored when calling the [Archive] methods `$best()`, `$nds_selection()` and `$cols_y`.
#' This class is usually constructed internally from a [paradox::ParamSet] when [Objective] is initialized.
#'
#' @export
#' @examples
#'
#' # define objective function
#' fun = function(xs) {
#'   c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize"),
#'   time = p_dbl()
#' )
#'
#' # create Objective object
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
Codomain = R6Class("Codomain", inherit = paradox::ParamSet,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param params (`list()`)\cr
    #'   Named list with which to initialize the codomain.
    #'   This argument is analogous to [paradox::ParamSet]'s `$initialize()` `params` argument.
    initialize = function(params) {

      assert_list(params)

      super$initialize(params)

      # only check for codomain parameters tagged with minimize or maximize
      for (id in self$target_ids) {
        # all numeric
        if (!self$is_number[id]) {
          stopf("%s in codomain is not numeric", id)
        }
        # every parameter's tags contain at most one of 'minimize' or 'maximize'
        if (sum(self$tags[[id]] %in% c("minimize", "maximize")) > 1) {
          stopf("%s in codomain contains a 'minimize' and 'maximize' tag", id)
        }
      }

      # assert at least one target eter
      if (!any(self$is_target) && self$length) stop("Codomain contains no parameter tagged with 'minimize' or 'maximize'")
    }
  ),

  active = list(

    #' @field is_target (named `logical()`)\cr
    #' Position is `TRUE` for target parameters.
    is_target = function() {
      self$ids() %in% self$target_ids
    },

    #' @field target_length (`integer()`)\cr
    #' Returns number of target parameters.
    target_length = function() {
      length(self$target_ids)
    },

    #' @field target_ids (`character()`)\cr
    #' IDs of contained target parameters.
    target_ids = function() {
      if ("any_tags" %in% names(formals(self$ids))) {
        self$ids(any_tags = c("minimize", "maximize"))
      } else {
        # old paradox
        self$ids()[map_lgl(self$tags, function(x) any(c("minimize", "maximize") %in% x))]
      }
    },

    #' @field target_tags (named `list()` of `character()`)\cr
    #' Tags of target parameters.
    target_tags = function() {
      self$tags[self$target_ids]
    },

    #' @field maximization_to_minimization (`integer()`)\cr
    #' Returns a numeric vector with values -1 and 1. Multiply with the outcome
    #' of a maximization problem to turn it into a minimization problem.
    maximization_to_minimization = function() {
      .Deprecated("direction", old = "maximization_to_minimization")
      ifelse(map_lgl(self$target_tags, has_element, "minimize"), 1L, -1L)
    },

    #' @field direction (`integer()`)\cr
    #' Returns `1` for minimization and `-1` for maximization.
    #' If the codomain contains multiple parameters an integer vector is returned.
    #' Multiply with the outcome of a maximization problem to turn it into a minimization problem.
    direction = function() {
      ifelse(map_lgl(self$target_tags, has_element, "minimize"), 1L, -1L)
    }
  )
)
