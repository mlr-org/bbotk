# FIXME: do we want to export this? or rather have a subclass in ParamSet?
# FIXME: also name is bad, as we use this mainly for objectives
make_ps_reals = function(d = 1, id = "y") {
  ParamSet$new(lapply(1:d, function(i) ParamDbl$new(id = paste0(id, i), tags = "minimize")))
}

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

terminated_error = function(optim_instance) {
  msg = sprintf(
    fmt = "Objective (obj:%s, term:%s) terminated",
    optim_instance$objective$id,
    format(optim_instance$terminator)
  )

  set_class(list(message = msg, call = NULL), c("terminated_error", "error", "condition"))
}
