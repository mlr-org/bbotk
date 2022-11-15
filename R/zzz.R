#' @import data.table
#' @import checkmate
#' @import paradox
#' @import mlr3misc
#' @importFrom R6 R6Class
#' @importFrom utils capture.output head tail
#' @importFrom methods formalArgs
"_PACKAGE"

.onLoad = function(libname, pkgname) {
  # nocov start

  # callbacks
  x = utils::getFromNamespace("mlr_callbacks", ns = "mlr3misc")
  x$add("bbotk.backup", load_callback_backup)

  lg = lgr::get_logger("bbotk")
  assign("lg", lg, envir = parent.env(environment()))
  f = function(event) {
    event$msg = paste("[bbotk]", event$msg)
    TRUE
  }
  lg$set_filters(f)

  register_namespace_callback("bbotk", "mlr3", function(pkgname, pkgpath) {
    x = utils::getFromNamespace("mlr_reflections", ns = "mlr3")
    if (is.list(x$loggers)) { # be backward compatible with mlr3 <= 0.13.0
      x$loggers[["bbotk"]] = lg
    }
  })

  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }

  if (isNamespaceLoaded("roxygen2")) {
    attachNamespace("roxygen2")
    registerS3method("roxy_tag_parse", "roxy_tag_cparam", roxy_tag_parse.roxy_tag_cparam)
    registerS3method("roxy_tag_rd", "roxy_tag_cparam", roxy_tag_rd.roxy_tag_cparam)
  }
} # nocov end


leanify_package()
