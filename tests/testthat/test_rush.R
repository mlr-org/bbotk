test_that("archive is froozen", {
  skip_on_cran()

  rush = Rush$new("test")
  rush$reset()

  instance = OptimInstanceSingleCrit$new(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 10L),
    rush = rush,
    freeze_archive = TRUE
  )

  future::plan("multisession", workers = 2L)
  instance$start_workers()
  instance$rush$await_workers(2L)

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_null(instance$archive$rush)
  expect_data_table(instance$archive$data, min.rows = 10L)
})
