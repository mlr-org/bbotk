paramset_to_hebo_space = function(search_space) {
  hebo = reticulate::import("hebo")
  param = search_space$params
  defs = lapply(seq_len(nrow(param)), function(i) {
    id = param$id[[i]]
    cls = param$cls[[i]]
    if (cls == "ParamDbl") {
      list(name = id, type = "num", lb = as.numeric(param$lower[[i]]), ub = as.numeric(param$upper[[i]]))
    } else if (cls == "ParamInt") {
      list(name = id, type = "int", lb = as.integer(param$lower[[i]]), ub = as.integer(param$upper[[i]]))
    } else if (cls == "ParamLgl") {
      list(name = id, type = "bool")
    } else if (cls == "ParamFct") {
      list(name = id, type = "cat", categories = as.list(param$levels[[i]]))
    } else {
      stop(sprintf("Unsupported parameter class: %s", cls))
    }
  })
  hebo$design_space$design_space$DesignSpace()$parse(defs)
}

# check whether dependencies can (or how) be implemented in HEBO Space
# paradox => ConfigSpace => HEBO-space  (wenn der zweite Pfeil einfach so geht als One-Liner); erstmal nur mit numerischen Räumen ohne dependencies
# kann HEBO hierarchische gemischete Räume???
