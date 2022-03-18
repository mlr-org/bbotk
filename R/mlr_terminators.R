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
#' * `as.data.table(dict, ..., objects = FALSE)`\cr
#'   [mlr3misc::Dictionary] -> [data.table::data.table()]\cr
#'   Returns a [data.table::data.table()] with fields "key", "label", "properties" and "unit" as columns.
#'   If `objects` is set to `TRUE`, the constructed objects are returned in the list column named `object`.
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
as.data.table.DictionaryTerminator = function(x, ..., objects = FALSE) {
  assert_flag(objects)

  setkeyv(map_dtr(x$keys(), function(key) {
    t = withCallingHandlers(x$get(key),
      packageNotFoundWarning = function(w) invokeRestart("muffleWarning"))
    insert_named(
      list(key = key, label = t$label, properties = list(t$properties), unit = t$unit),
      if (objects) list(object = list(t))
    )
  }, .fill = TRUE), "key")[]
}
