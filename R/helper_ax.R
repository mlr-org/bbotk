ax_params_to_xdt = function(params, search_space) {
  ids = search_space$ids()
  classes = search_space$class
  xs = lapply(ids, function(id) {
    val = params[[id]]
    switch(
      classes[[id]],
      ParamDbl = as.double(val),
      ParamInt = as.integer(val),
      ParamFct = as.character(val),
      ParamLgl = as.logical(val)
    )
  })
  as.data.table(setNames(xs, ids))
}

paramset_to_ax_params = function(search_space) {
  ids = search_space$ids()
  classes = search_space$class
  lapply(ids, function(id) {
    switch(
      classes[[id]],
      ParamDbl = list(
        name = id,
        type = "range",
        bounds = list(as.double(search_space$lower[[id]]), as.double(search_space$upper[[id]])),
        value_type = "float"
      ),
      ParamInt = list(
        name = id,
        type = "range",
        bounds = list(as.integer(search_space$lower[[id]]), as.integer(search_space$upper[[id]])),
        value_type = "int"
      ),
      ParamFct = list(
        name = id,
        type = "choice",
        values = as.list(search_space$levels[[id]]),
        value_type = "str"
      ),
      ParamLgl = list(
        name = id,
        type = "choice",
        values = list(TRUE, FALSE),
        value_type = "bool"
      )
    )
  })
}
