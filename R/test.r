devtools::load_all(".")
progressr::handlers("debug")

terminator = trm("evals", n_evals = 500)
inst = MAKE_INST_1D(terminator = terminator)
optimizer = opt("random_search", batch_size = 10)

progressr::with_progress(optimizer$optimize(inst))


#######

devtools::load_all(".")
progressr::handlers(global = TRUE)

terminator = trm("evals", n_evals = 500)
inst = MAKE_INST_1D(terminator = terminator)
optimizer = opt("random_search", batch_size = 10)

optimizer$optimize(inst)