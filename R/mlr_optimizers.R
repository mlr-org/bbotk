#' @title Dictionary of Optimizer
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [mlr3misc::Dictionary].
#'
#' @description
#' A simple [mlr3misc::Dictionary] storing objects of class [Optimizer].
#' Each optimizer has an associated help page, see `mlr_optimizer_[id]`.
#'
#' This dictionary can get populated with additional optimizer by add-on packages.
#'
#' For a more convenient way to retrieve and construct optimizer, see [opt()]/[opts()].
#'
#' @section Methods:
#' See [mlr3misc::Dictionary].
#'
#' @section S3 methods:
#' * `as.data.table(dict)`\cr
#'   [mlr3misc::Dictionary] -> [data.table::data.table()]\cr
#'   Returns a [data.table::data.table()] with fields "key", "param_classes", "properties" and "packages" as columns.
#'
#' @family Dictionary
#' @family Optimizer
#' @seealso
#' Sugar functions: [opt()], [opts()]
#'
#' @export
#' @examples
#' as.data.table(mlr_optimizers)
#' mlr_optimizers$get("random_search")
#' opt("random_search")
mlr_optimizers = R6Class("DictionaryOptimizer", inherit = Dictionary, cloneable = FALSE)$new()

#' @export
as.data.table.DictionaryOptimizer = function(x, extra_cols = character(), ...) {
  assert_character(extra_cols, any.missing = FALSE)

  setkeyv(map_dtr(x$keys(), function(key) {
    t = tryCatch(x$get(key),
      missingDefaultError = function(e) NULL)
    if (is.null(t)) {
      return(list(key = key))
    }

    c(
      list(key = key, param_classes = list(t$param_classes), properties = list(t$properties), packages = list(t$packages)),
      mget(extra_cols, envir = t)
    )
  }, .fill = TRUE), "key")[]
}
