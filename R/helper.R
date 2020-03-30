# determines if execution via future will be running locally or remotely
use_future = function() {
  if (!isNamespaceLoaded("future") || inherits(future::plan(), "uniprocess")) {
    return(FALSE)
  }

  if (!requireNamespace("future.apply", quietly = TRUE)) {
    lg$warn("Package 'future.apply' could not be loaded. Parallelization disabled.")
    return(FALSE)
  }

  return(TRUE)
}

terminated_error = function(evaluator) {
  msg = sprintf(
    fmt = "Evaluator (obj:%s, term:%s) terminated",
    evaluator$objective$id,
    format(evaluator$terminator)
  )

  set_class(list(message = msg, call = NULL), c("terminated_error", "error", "condition"))
}
