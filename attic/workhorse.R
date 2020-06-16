workhorse = function(i, objective, xs) {
  x = as.list(xs[[i]])
  n = length(xs)
  lg$info("Eval point '%s' (batch %i/%i)", as_short_string(x), i, n)
  res = encapsulate(
    method = objective$encapsulate,
    .f = objective$fun,
    .args = list(x = x),
    # FIXME: we likely need to allow the user to configure this? or advice to load all paackaes in the user defined objective function?
    .pkgs = "bbotk",
    .seed = NA_integer_
  )
  # FIXME: encapsulate also returns time and log, we should probably do something with it?
  y = res$result
  assert_numeric(y, len = objective$ydim, any.missing = FALSE, finite = TRUE)
  lg$info("Result '%s'", as_short_string(y))
  as.list(y)
}
