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
#' * `as.data.table(dict, ..., objects = FALSE)`\cr
#'   [mlr3misc::Dictionary] -> [data.table::data.table()]\cr
#'   Returns a [data.table::data.table()] with fields "key", "label", "param_classes", "properties" and "packages" as columns.
#'   If `objects` is set to `TRUE`, the constructed objects are returned in the list column named `object`.
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
as.data.table.DictionaryOptimizer = function(x, ..., objects = FALSE) {
  assert_flag(objects)

  setkeyv(map_dtr(x$keys(), function(key) {
    # NOTE: special handling of OptimizerBatchChain due to optimizers being required as an argument during construction
    if (key == "chain") {
      optimizer1 = opt("random_search")
      optimizer2 = opt("random_search")
      opt = withCallingHandlers(x$get(key, optimizers = list(optimizer1, optimizer2)), packageNotFoundWarning = function(w) invokeRestart("muffleWarning"))
      insert_named(
        list(key = key, label = opt$label, param_classes = list(opt$param_classes), properties = list(opt$properties), packages = list(opt$packages)),
        if (objects) list(object = list(opt))
      )
    } else {
      opt = withCallingHandlers(x$get(key),
        packageNotFoundWarning = function(w) invokeRestart("muffleWarning"))
      insert_named(
        list(key = key, label = opt$label, param_classes = list(opt$param_classes), properties = list(opt$properties), packages = list(opt$packages)),
        if (objects) list(object = list(t))
      )
    }
  }, .fill = TRUE), "key")[]
}
