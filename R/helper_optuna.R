trial_to_xdt = function(trial, search_space) {
  ids = search_space$ids()
  classes = search_space$class
  xs = lapply(ids, function(id) {
    switch(
      classes[[id]],
      ParamDbl = as.double(trial$suggest_float(id, search_space$lower[[id]], search_space$upper[[id]])),
      ParamInt = as.integer(trial$suggest_int(
        id,
        as.integer(search_space$lower[[id]]),
        as.integer(search_space$upper[[id]])
      )),
      ParamFct = as.character(trial$suggest_categorical(id, as.list(search_space$levels[[id]]))),
      ParamLgl = as.logical(trial$suggest_categorical(id, list(TRUE, FALSE)))
    )
  })
  as.data.table(setNames(xs, ids))
}
