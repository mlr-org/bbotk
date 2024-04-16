test_that("initializing OptimInstanceAsyncSingleCrit works", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush_plan(n_workers = 2)

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
  )

  expect_r6(instance$archive, "ArchiveAsync")
  expect_r6(instance$objective, "Objective")
  expect_r6(instance$search_space, "ParamSet")
  expect_r6(instance$terminator, "Terminator")
  expect_r6(instance$rush, "Rush")
  expect_null(instance$result)

  expect_rush_reset(instance$rush)
})

test_that("rush controller can be passed to OptimInstanceAsyncSingleCrit", {
  skip_on_cran()
  skip_if_not_installed("rush")
  flush_redis()

  rush = rsh(network_id = "remote_network")

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  expect_class(instance$rush, "Rush")
  expect_equal(instance$rush$network_id, "remote_network")
})
