#' @title Dictionary of Optimizer
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [mlr3misc::Dictionary].
#'
#' @description
#' A simple [mlr3misc::Dictionary] storing objects of class [Optimizer]. Each
#' optimizer has an associated help page, see `mlr_optimizer_[id]`.
#'
#' This dictionary can get populated with additional optimizer by add-on
#' packages.
#'
#' For a more convenient way to retrieve and construct optimizer, see
#' [opt()]/[opts()].
#'
#' @section Methods:
#' See [mlr3misc::Dictionary].
#'
#' @family Optimizer
#' @seealso
#' Sugar functions: [opt()], [opts()]
#' @export
#' @examples
#' opt("random_search", batch_size = 10)
mlr_optimizers = R6Class("DictionaryOptimizer", inherit = Dictionary, cloneable = FALSE)$new()

#' @export
as.data.table.DictionaryOptimizer = function(x, ...) {
  setkeyv(map_dtr(x$keys(), function(key) {
    t = tryCatch(x$get(key),
      missingDefaultError = function(e) NULL)
    if (is.null(t)) {
      return(list(key = key))
    }

    list(
      key = key,
      param_classes = list(t$param_classes),
      properties = list(t$properties),
      packages = list(t$packages),
      man = t$man
    )
  }, .fill = TRUE), "key")[]
}
