#' @title Dictionary of Terminators
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [mlr3misc::Dictionary].
#'
#' @description
#' A simple [mlr3misc::Dictionary] storing objects of class [Terminator].
#' Each terminator has an associated help page, see `mlr_terminators_[id]`.
#'
#' This dictionary can get populated with additional terminators by add-on packages.
#'
#' For a more convenient way to retrieve and construct terminator, see [trm()]/[trms()].
#'
#' @section Methods:
#' See [mlr3misc::Dictionary].
#'
#' @section S3 methods:
#' * `as.data.table(dict)`\cr
#'   [mlr3misc::Dictionary] -> [data.table::data.table()]\cr
#'   Returns a [data.table::data.table()] with fields "key", "param_classes", "properties" and "packages" as columns.
#'
#' @family Terminator
#' @seealso
#' Sugar functions: [trm()], [trms()]
#'
#' @export
#' @examples
#' as.data.table(mlr_terminators)
#' mlr_terminators$get("evals")
#' trm("evals", n_evals = 10)
mlr_terminators = R6Class("DictionaryTerminator", inherit = Dictionary,
  cloneable = FALSE)$new()

#' @export
as.data.table.DictionaryTerminator = function(x, ...,extra_cols = character()) {
  assert_character(extra_cols, any.missing = FALSE)

  setkeyv(map_dtr(x$keys(), function(key) {
    t = tryCatch(x$get(key),
      missingDefaultError = function(e) NULL)
    if (is.null(t)) {
      return(list(key = key))
    }

    c(
      list(key = key, properties = list(t$properties), unit = t$unit),
      mget(extra_cols, envir = t)
    )
  }, .fill = TRUE), "key")[]
}
