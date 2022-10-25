paradox_to_irace = function(param_set) {
  assertClass(param_set, "ParamSet")
  if ("ParamUty" %in% param_set$class) stop("<ParamUty> not supported by <OptimizerIrace>")

  # types
  paradox_types = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct")
  irace_types = c("c", "i", "r", "c")
  types = irace_types[match(param_set$class, paradox_types)]

  # range
  range = pmap_chr(list(param_set$lower, param_set$upper, param_set$levels), function(lower, upper, levels, ...) {
    if (is.null(levels)) {
      paste0("(", lower, ",", upper, ")")
    } else {
      paste0("(", paste0(levels, collapse = ","), ")")
    }
  })

  # dependencies
  deps = if (param_set$has_deps) {
    deps = pmap_dtr(param_set$deps, function(id, on, cond) {
      rhs = if (is.character(cond$rhs)) sQuote(cond$rhs, q = FALSE) else cond$rhs
      cond = if (test_class(cond, "CondEqual")) {
        paste(on, "==", rhs)
      } else {
        paste(on, "%in%", paste0("c(", paste0(rhs, collapse = ","), ")"))
      }
      data.table(id = id, cond = cond)
    })

    # reduce to one row per parameter
    deps = deps[, list("cond" =  paste(cond, collapse = " & ")), by = id]

    # add parameters without dependency
    deps[, cond := paste("|", cond)]
    deps = merge(data.table(id = param_set$ids(), by = "id"), deps, all.x = TRUE, sort = FALSE)
    deps[is.na(cond), cond := ""]
  } else {
    NULL
  }

  irace::readParameters(text = paste(param_set$ids(), '""', types, range, deps$cond, collapse = "\n"))
}

target_runner_default = function(experiment, exec.target.runner, scenario, target.runner) { # nolint
  optim_instance = scenario$targetRunnerData$inst

  xdt = map_dtr(experiment, function(e) {
    configuration = as.data.table(e$configuration)
    # add configuration and instance id to archive
    set(configuration, j = "configuration", value = e$id.configuration)
    set(configuration, j = "instance", value = e$id.instance)
    # fix logicals
    configuration[, map(.SD, function(x) ifelse(x %in% c("TRUE", "FALSE"), as.logical(x), x))]
  })

  # provide experiment instances to objective
  optim_instance$objective$constants$values$instances = map(experiment, function(e) e$instance)

  # evaluate configuration
  res = optim_instance$eval_batch(xdt)

  # return cost (minimize) and dummy time to irace
  map(transpose_list(res), function(cost) {
    list(cost = unlist(cost) * optim_instance$objective_multiplicator, time = NA_real_)
  })
}
