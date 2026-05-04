#' @import data.table
#' @import checkmate
#' @import paradox
#' @import mlr3misc
#' @import cli
#' @importFrom R6 R6Class
#' @importFrom utils capture.output head tail
#' @importFrom methods formalArgs
#' @importFrom stats setNames
#'
#' @section Package Options:
#' * `"bbotk.debug"`: If set to `TRUE`, asynchronous optimization is run in the main process.
#' * `"bbotk.tiny_logging"`: If set to `TRUE`, the logging is simplified to only show points and results.
#'   NA values are removed.
"_PACKAGE"

.onLoad = function(libname, pkgname) {
  # nocov start

  # callbacks
  x = utils::getFromNamespace("mlr_callbacks", ns = "mlr3misc")
  x$add("bbotk.backup", load_callback_backup)
  x$add("bbotk.async_freeze_archive", load_callback_freeze_archive)

  lg = lgr::get_logger("mlr3/bbotk")
  assign("lg", lg, envir = parent.env(environment()))
  f = function(event) {
    event$msg = paste("[bbotk]", event$msg)
    TRUE
  }
  lg$set_filters(f)

  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
} # nocov end

utils::globalVariables(c("batch_nr", "start_values"))

leanify_package()
