paramset_to_hebo_space = function(search_space) {
  pdt = search_space$params
  defs = lapply(seq_len(nrow(pdt)), function(i) {
    id = pdt$id[[i]]
    cls = pdt$cls[[i]]
    if (cls == "ParamDbl") {
      list(name = id, type = "num", lb = as.numeric(pdt$lower[[i]]), ub = as.numeric(pdt$upper[[i]]))
    } else if (cls == "ParamInt") {
      list(name = id, type = "int", lb = as.integer(pdt$lower[[i]]), ub = as.integer(pdt$upper[[i]]))
    } else if (cls == "ParamLgl") {
      list(name = id, type = "bool")
    } else if (cls == "ParamFct") {
      list(name = id, type = "cat", categories = as.list(pdt$levels[[i]]))
    } else {
      stop(sprintf("Unsupported parameter class: %s", cls))
    }
  })
  hebo$design_space$design_space$DesignSpace()$parse(defs)
}
