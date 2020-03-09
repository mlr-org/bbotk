#' @title Container for objective function evaluations
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Container around a data.table which stores all performed [Objective] function calls by the [Evaluator].
#'
#' @section Construction:
#' ```
#' archive = Archive$new(domain, codomain)
#' ```
#'
#' * `domain` :: [paradox::ParamSet]\cr
#'   Domain of objective function that is logged into archive.
#' * `codomain` :: [paradox::ParamSet]\cr
#'   Codomain of objective function that is logged into archive.
#'
#' @section Fields:
#' * `domain` :: [paradox::ParamSet] from construction\cr
#' * `codomain` :: [paradox::ParamSet] from construction\cr
#' * `data` :: [data.table::data.table]\cr
#'   Holds data of the archive.
#' * `n_evals` :: `integer(1)`\cr
#'   Number of evaluations stored in the container.
#'
#' @section Methods:
#' * `add_evals(dt)`\cr
#'   [data.table::data.table] -> `self`\cr
#'   Adds function evaluations to the archive table.
#'
#' @export
#FIXME: doc cols of "data"

Archive = R6Class("Archive",
  public = list(
    data = NULL,
    domain = NULL,
    codomain = NULL,

    initialize = function(domain, codomain) {
      assert_param_set(domain)
      assert_param_set(codomain)
      self$domain = domain
      self$codomain = codomain
      self$data = data.table()
    },

    add_evals = function(xs, xdt, ydt) {
      # FIXME: add checks here for the dts and their domains
      assert_data_table(xdt)
      assert_data_table(ydt)
      colnames(ydt) = self$objective$codomain$ids()
      xydt[, ("opt_x") := list(parlist_untrafoed)]
      batch_nr = self$archive$data$batch_nr
      batch_nr = if (length(batch_nr)) max(batch_nr) + 1L else 1L
      xydt[, ("batch_nr") := batch_nr]
      self$data = rbindlist(list(self$data, dt), fill = TRUE, use.names = TRUE)
    },

    print = function() {
      catf("Archive:")
      print(self$data)
    }
  ),

  active = list(
    n_evals = function() nrow(self$data),
    cols_x = function() self$domain$ids(),
    cols_y = function() self$codomain$ids()
    # idx_unevaled = function() self$data$y
  ),
)

