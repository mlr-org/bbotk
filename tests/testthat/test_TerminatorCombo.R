test_that("TerminatorCombo works", {
  terminators = trms(c("evals", "evals"))
  terminators[[1]]$param_set$values$n_evals = 3L
  terminators[[2]]$param_set$values$n_evals = 6L
  terminator = TerminatorCombo$new(terminators)
  expect_output(print(terminator), "TerminatorEvals")
  for (mode in c("any", "all")) {
    terminator$param_set$values$any = (mode == "any")
    inst = MAKE_INST_2D(terminator)
    a = random_search(inst, batch_size = 1L)
    if (mode == "any") {
      expect_equal(a$n_evals, 3L, info = mode)
    } else {
      expect_equal(a$n_evals, 6L, info = mode)
    }
  }
})

test_that("status method works", {
  terminator_1 = trm("evals", n_evals = 10000)
  terminator_2 = trm("run_time", secs = 10)
  terminator = trm("combo", terminators = list(terminator_1, terminator_2), any = TRUE)
  inst = MAKE_INST_1D(terminator = terminator)
  inst$archive$start_time = Sys.time()
  xdt = data.table(x = 1)
  inst$eval_batch(xdt)
  Sys.sleep(1)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps" = 10), tolerance = 11)
  expect_equal(inst$terminator$remaining_time(inst$archive), 9, tolerance = 3)
  expect_data_table(inst$terminator$status_long(inst$archive), nrows = 2, ncols = 3)
  expect_named(inst$terminator$status_long(inst$archive), c("max_steps", "current_steps", "unit"))

  Sys.sleep(1)

  expect_equal(inst$terminator$status(inst$archive)["max_steps"], c("max_steps" = 100))
  expect_equal(inst$terminator$status(inst$archive)["current_steps"], c("current_steps" = 20), tolerance = 11)
  expect_equal(inst$terminator$remaining_time(inst$archive), 8, tolerance = 3)
})

test_that("man exists", {
  terminator = trm("combo")
  expect_man_exists(terminator$man)
})
