test_that("OptimizerBatchChain", {
  z = test_optimizer_1d(
    "chain",
    term_evals = 20L,
    optimizers = list(opt("random_search"), opt("grid_search")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L))
  )
  expect_class(z$optimizer, "OptimizerBatchChain")
  expect_output(print(z$optimizer), "OptimizerBatchChain")
  expect_identical(z$instance$archive$data[.optimizer_id == "OptimizerBatchRandomSearch_1"]$batch_nr, 1:10)
  expect_identical(z$instance$archive$data[.optimizer_id == "OptimizerBatchGridSearch_1"]$batch_nr, 11:20)

  z = test_optimizer_2d(
    "chain",
    term_evals = 20L,
    optimizers = list(opt("random_search"), opt("grid_search")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L))
  )
  expect_class(z$optimizer, "OptimizerBatchChain")
  expect_output(print(z$optimizer), "OptimizerBatchChain")
  expect_identical(z$instance$archive$data[.optimizer_id == "OptimizerBatchRandomSearch_1"]$batch_nr, 1:10)
  expect_identical(z$instance$archive$data[.optimizer_id == "OptimizerBatchGridSearch_1"]$batch_nr, 11:20)

  z = test_optimizer_2d(
    "chain",
    term_evals = 20L,
    optimizers = list(opt("random_search", batch_size = 10L), opt("grid_search", batch_size = 10L)),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L))
  )
  expect_class(z$optimizer, "OptimizerBatchChain")
  expect_output(print(z$optimizer), "OptimizerBatchChain")
  expect_identical(unique(z$instance$archive$data[.optimizer_id == "OptimizerBatchRandomSearch_1"]$batch_nr), 1L)
  expect_identical(unique(z$instance$archive$data[.optimizer_id == "OptimizerBatchGridSearch_1"]$batch_nr), 2L)

  z = test_optimizer_dependencies(
    "chain",
    term_evals = 20L,
    optimizers = list(opt("random_search"), opt("grid_search")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L))
  )
  expect_class(z$optimizer, "OptimizerBatchChain")
  expect_output(print(z$optimizer), "OptimizerBatchChain")
  expect_identical(z$instance$archive$data[.optimizer_id == "OptimizerBatchRandomSearch_1"]$batch_nr, 1:10)
  expect_identical(z$instance$archive$data[.optimizer_id == "OptimizerBatchGridSearch_1"]$batch_nr, 11:20)

  # random restarts
  terminator = trm("none")
  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = terminator
  )
  skip_if_not_installed("GenSA")
  z = test_optimizer(
    instance = instance,
    key = "chain",
    optimizers = list(opt("gensa"), opt("gensa")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L)),
    real_evals = 20L
  )
  expect_identical(unique(z$instance$archive$data$.optimizer_id), c("OptimizerBatchGenSA_1", "OptimizerBatchGenSA_2"))

  # packages, properties, param_set, etc.
  optimizer = OptimizerBatchChain$new(optimizers = list(opt("random_search"), opt("gensa")))
  expect_set_equal(optimizer$packages, c("bbotk", "GenSA"))
  expect_identical(optimizer$properties, "single-crit")
  expect_identical(optimizer$param_classes, "ParamDbl")

  expected_ids = c(
    paste0("OptimizerBatchRandomSearch_1.", opt("random_search")$param_set$ids()),
    paste0("OptimizerBatchGenSA_1.", opt("gensa")$param_set$ids())
  )

  expect_set_equal(
    optimizer$param_set$ids(),
    expected_ids
  )
})

test_that("OptimizerBatchChain respects the terminator of the instance", {
  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10L)
  )

  optimizer = opt(
    "chain",
    optimizers = list(opt("random_search", batch_size = 1L), opt("random_search", batch_size = 1L)),
    terminators = list(trm("evals", n_evals = 8L), trm("evals", n_evals = 8L))
  )
  optimizer$optimize(instance)

  expect_equal(instance$archive$n_evals, 10L)
  expect_equal(instance$archive$data$batch_nr, 1:10)
  expect_equal(
    instance$archive$data$.optimizer_id,
    c(rep("OptimizerBatchRandomSearch_1", 8L), rep("OptimizerBatchRandomSearch_2", 2L))
  )
})

test_that("OptimizerBatchChain does not duplicate pre-evaluated points", {
  instance = OptimInstanceBatchSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = trm("evals", n_evals = 10L)
  )
  instance$eval_batch(data.table(x = 0.5))

  optimizer = opt(
    "chain",
    optimizers = list(opt("random_search", batch_size = 1L), opt("random_search", batch_size = 1L)),
    terminators = list(trm("evals", n_evals = 2L), trm("evals", n_evals = 2L))
  )
  optimizer$optimize(instance)

  expect_equal(instance$archive$n_evals, 5L)
  expect_equal(instance$archive$data$batch_nr, 1:5)
  expect_equal(sum(instance$archive$data$x == 0.5), 1L)
})

test_that("OptimizerBatchChain runtime terminator of the instance is not restarted", {
  objective = ObjectiveRFun$new(
    fun = function(xs) {
      Sys.sleep(0.1)
      list(y = xs$x^2)
    },
    domain = PS_1D,
    properties = "single-crit"
  )

  instance = OptimInstanceBatchSingleCrit$new(
    objective = objective,
    search_space = PS_1D,
    terminator = trm("run_time", secs = 1L)
  )

  optimizer = opt(
    "chain",
    optimizers = list(opt("random_search", batch_size = 1L), opt("random_search", batch_size = 1L)),
    terminators = list(trm("evals", n_evals = 100L), trm("evals", n_evals = 100L))
  )
  optimizer$optimize(instance)

  # the runtime terminator of the instance stops the first optimizer before it uses up its 100 evaluations
  expect_lt(instance$archive$n_evals, 50L)
})
