test_that("OptimizerChain", {
  z = test_optimizer_1d("chain", term_evals = 20L,
    optimizers = list(opt("random_search"), opt("grid_search")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L)))
  expect_class(z$optimizer, "OptimizerChain")
  expect_output(print(z$optimizer), "OptimizerChain")
  expect_identical(z$instance$archive$data[optimizer == "OptimizerRandomSearch"]$batch_nr, 1:10)
  expect_identical(z$instance$archive$data[optimizer == "OptimizerGridSearch"]$batch_nr, 11:20)

  z = test_optimizer_2d("chain", term_evals = 20L,
    optimizers = list(opt("random_search"), opt("grid_search")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L)))
  expect_class(z$optimizer, "OptimizerChain")
  expect_output(print(z$optimizer), "OptimizerChain")
  expect_identical(z$instance$archive$data[optimizer == "OptimizerRandomSearch"]$batch_nr, 1:10)
  expect_identical(z$instance$archive$data[optimizer == "OptimizerGridSearch"]$batch_nr, 11:20)

  z = test_optimizer_2d("chain", term_evals = 20L,
    optimizers = list(opt("random_search", batch_size = 10L), opt("grid_search", batch_size = 10L)),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L)))
  expect_class(z$optimizer, "OptimizerChain")
  expect_output(print(z$optimizer), "OptimizerChain")
  expect_identical(unique(z$instance$archive$data[optimizer == "OptimizerRandomSearch"]$batch_nr), 1L)
  expect_identical(unique(z$instance$archive$data[optimizer == "OptimizerGridSearch"]$batch_nr), 2L)

  z = test_optimizer_dependencies("chain", term_evals = 20L,
    optimizers = list(opt("random_search"), opt("grid_search")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L)))
  expect_class(z$optimizer, "OptimizerChain")
  expect_output(print(z$optimizer), "OptimizerChain")
  expect_identical(z$instance$archive$data[optimizer == "OptimizerRandomSearch"]$batch_nr, 1:10)
  expect_identical(z$instance$archive$data[optimizer == "OptimizerGridSearch"]$batch_nr, 11:20)

  # random restarts
  terminator = trm("none")
  instance = OptimInstanceSingleCrit$new(
    objective = OBJ_1D,
    search_space = PS_1D,
    terminator = terminator
  )
  z = test_optimizer(
    instance = instance,
    key = "chain",
    optimizers = list(opt("gensa"), opt("gensa")),
    terminators = list(trm("evals", n_evals = 10L), trm("evals", n_evals = 10L)),
    real_evals = 20L
  )
  expect_identical(unique(z$instance$archive$data$optimizer), c("OptimizerGenSA", "OptimizerGenSA_1"))

  # packages, properties, param_set, etc.
  optimizer = OptimizerChain$new(optimizers = list(opt("random_search"), opt("gensa")))
  expect_identical(optimizer$packages, "GenSA")
  expect_identical(optimizer$properties, "single-crit")
  expect_identical(optimizer$param_classes, "ParamDbl")
  expect_set_equal(
    optimizer$param_set$ids(),
    c("OptimizerRandomSearch.batch_size", "OptimizerGenSA.smooth", "OptimizerGenSA.temperature",
      "OptimizerGenSA.acceptance.param", "OptimizerGenSA.verbose", "OptimizerGenSA.trace.mat")
  )
})
