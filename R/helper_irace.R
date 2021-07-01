paradox_to_irace = function(param_set) {
  assertClass(param_set, "ParamSet")
  if("ParamUty" %in% param_set$class) stop("<ParamUty> not supported by <TunerIrace>")

  class_lookup = data.table(
    paradox = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
    irace = c("c", "i", "r", "c"), stringsAsFactors = FALSE)

  type = unlist(subset(merge(data.table(paradox = param_set$class), class_lookup, sort = FALSE), select = "irace"))
  range = get_irace_range(param_set)
  if (param_set$has_deps) {
    condition = get_irace_condition(param_set)
  } else {
    condition = NULL
  }

  par_tab = paste(param_set$ids(), '""', type, range, condition$cond, collapse = "\n")

  return(irace::readParameters(text = par_tab))
}

get_irace_range = function(param_set) {
  rng = data.table(lower = param_set$lower, upper = param_set$upper, lvl = param_set$levels)

  apply(rng, 1, function(x) {
    if (is.na(x[[1]])) {
      return(paste0("(", paste0(x[[3]], collapse = ","), ")"))
    } else {
      return(paste0("(", x[[1]], ",", x[[2]], ")"))
    }
  })
}

get_irace_condition = function(param_set) {
  cond = rbindlist(apply(param_set$deps, 1, function(x) {
    on = x[[2]]
    cond = x[[3]]$rhs
    if (is.character(cond)) {
      cond = paste0("'", cond, "'")
    }
    if (x[[3]]$type == "equal") {
      condition = paste("|", x[[2]], "==", cond)
    } else {
      condition = paste("|", x[[2]], "%in%", paste0("c(", paste0(cond, collapse = ","), ")"))
    }
    data.table(id = x[[1]], cond = condition)
  }))

  # coercion back and forth from frame/table is due to data.frame sorting even when sort = FALSE
  tab = data.frame(merge(data.table(id = param_set$ids()), cond, by = "id", all.x = TRUE, sort = FALSE))
  tab[is.na(tab)] = ""

  return(tab)
}

target_runner_default = function(experiment, exec.target.runner, scenario, target.runner) {# nolint
  optim_instance = scenario$targetRunnerData$inst

  # fix logicals
  xdt = map_dtr(experiment, function(e) {
    as.data.table(lapply(e$configuration, function(x) {
      if (x %in% c("TRUE", "FALSE")) {
        return(as.logical(x))
      } else {
        return(x)
      }}))})

  # provide experiment instance to objective
  optim_instance$objective$irace_instance = map(experiment, function(e) e$instance)

  # add extra info to archive
  extra = map_dtr(experiment, function(e) {
    data.table(id_configuration = e$id.configuration, id_instance = e$id.instance)
  })
  
  # evaluate configuration
  # objective_function cannot pass extra information
  res = optim_instance$eval_batch(cbind(xdt, extra))

  res = cbind(res, optim_instance$archive$data[batch_nr == optim_instance$archive$n_batch, list(time)])
  colnames(res) = c("cost", "time")
  res[, cost := lapply(cost, function(ct) ct * optim_instance$objective_multiplicator)]
  transpose_list(res)
}
