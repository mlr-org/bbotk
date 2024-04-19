test_that("backup callback works", {
  on.exit(unlink("./archive.rds"))

  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10),
    callbacks = clbk("bbotk.backup", path = "./archive.rds"),
  )

  optimizer = opt("random_search")
  optimizer$optimize(instance)

  expect_file_exists("./archive.rds")
  expect_data_table(readRDS("./archive.rds"))
})
