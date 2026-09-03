skip_if_not_installed("rush")
skip_if_no_redis()

test_that("initializing OptimInstanceAsyncMultiCrit works", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_r6(instance, "OptimInstanceAsyncMultiCrit")
  expect_r6(instance$archive, "ArchiveAsync")
  expect_null(instance$result)
})

test_that("terminators are checked against the codomain of an async multi-crit instance", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  expect_error(
    oi_async(
      objective = OBJ_2D_2D,
      search_space = PS_2D,
      terminator = trm("perf_reached", level = 0.1),
      rush = rush
    ),
    "does not support multi-crit"
  )

  instance = oi_async(
    objective = OBJ_2D_2D,
    search_space = PS_2D,
    terminator = trm("stagnation_hypervolume"),
    rush = rush
  )
  expect_r6(instance$terminator, "TerminatorStagnationHypervolume")
})
