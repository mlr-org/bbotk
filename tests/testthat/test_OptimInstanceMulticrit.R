context("OptimInstanceMulticrit")


test_that("OptimInstanceMulticrit", {
  inst = MAKE_INST_2D_2D(20L)
  expect_output(print(inst), "OptimInstanceMulticrit")
  expect_r6(inst$archive, "Archive")
  expect_data_table(inst$archive$data(), nrows = 0L)
  expect_identical(inst$archive$n_evals, 0L)
  expect_identical(inst$archive$n_batch, 0L)

  xdt = data.table(x1 = c(-1,-1,-1), x2 = c(1, 0, -1))
  inst$eval_batch(xdt)
  expect_data_table(inst$archive$data(), nrows = 3L)
  expect_equal(inst$archive$data()$y1, c(1, 1, 1))
  expect_equal(inst$archive$data()$y2, c(-1, 0, -1))
  expect_identical(inst$archive$n_evals, 3L)
  expect_identical(inst$archive$n_batch, 1L)
  expect_equal(inst$archive$best()$y2, 0)
  expect_null(inst$result)

  xdt = data.table(x1 = c(0,0), x2 = c(list(0),list(0)))
  ydt = data.table(y1 = c(-10, -10), y2 = c(10, 10))
  inst$assign_result(xdt = xdt, ydt = ydt)
  expect_equal(inst$result_x_seach_space, xdt)
  expect_equal(inst$result_y, ydt)
  expect_equal(inst$result_x_domain, replicate(n = 2, list(x1 = 0, x2 = 0), simplify = FALSE))

})

test_that("Terminator assertions work", {
  terminator = term("perf_reached")
  expect_error(MAKE_INST_2D_2D(terminator))
})
