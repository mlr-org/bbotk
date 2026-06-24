skip_if_not_installed("rush")
skip_if_no_redis()


test_that("ArchiveAsyncFrozen works", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  archive = instance$archive
  frozen_archive = ArchiveAsyncFrozen$new(archive)

  expect_data_table(frozen_archive$data)
  expect_data_table(frozen_archive$queued_data)
  expect_data_table(frozen_archive$running_data)
  expect_data_table(frozen_archive$finished_data)
  expect_data_table(frozen_archive$failed_data)
  expect_number(frozen_archive$n_queued)
  expect_number(frozen_archive$n_running)
  expect_number(frozen_archive$n_finished)
  expect_number(frozen_archive$n_failed)
  expect_number(frozen_archive$n_evals)

  expect_data_table(as.data.table(frozen_archive))
})

test_that("ArchiveAsyncFrozen rejects all write methods", {
  rush = start_rush()
  on.exit({
    rush$reset()
    mirai::daemons(0)
  })

  instance = oi_async(
    objective = OBJ_2D,
    search_space = PS_2D,
    terminator = trm("evals", n_evals = 5L),
    rush = rush
  )

  optimizer = opt("async_random_search")
  optimizer$optimize(instance)

  frozen_archive = ArchiveAsyncFrozen$new(instance$archive)

  xs = list(x1 = 1, x2 = 2)
  expect_error(frozen_archive$push_points(list(xs)), "Archive is frozen")
  expect_error(frozen_archive$push_point(xs), "Archive is frozen")
  expect_error(frozen_archive$push_running_points(list(xs)), "Archive is frozen")
  expect_error(frozen_archive$push_running_point(xs), "Archive is frozen")
  expect_error(frozen_archive$push_finished_points(list(xs), list(list(y = 1))), "Archive is frozen")
  expect_error(frozen_archive$push_finished_point(xs, list(y = 1)), "Archive is frozen")
  expect_error(frozen_archive$push_failed_points(list(xs), conditions = list(list(message = "e"))), "Archive is frozen")
  expect_error(frozen_archive$push_failed_point(xs, message = "e"), "Archive is frozen")
  expect_error(frozen_archive$pop_point(), "Archive is frozen")
  expect_error(frozen_archive$finish_point("key", list(y = 1), x_domain = xs), "Archive is frozen")
  expect_error(frozen_archive$fail_point("key", message = "e"), "Archive is frozen")
  expect_error(frozen_archive$push_result("key", list(y = 1), x_domain = xs), "Archive is frozen")
})
