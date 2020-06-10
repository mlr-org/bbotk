context("TerminatorPerfReached")

test_that("TerminatorPerfReached works", {
  terminator = TerminatorPerfReached$new()
  terminator$param_set$values$level = c(y = 0.2)
  expect_output(print(terminator), "TerminatorPerfReached")
  inst = MAKE_INST_2D(terminator)
  a = random_search(inst, batch_size = 1L)
  expect_equal(sum(a$data()$y < 0.2), 1)
  expect_true(tail(a$data()$y, 1) < 0.2)
})

# FIXME: Reenable one OptimInstanceMulticrit is implemented
# test_that("TerminatorPerfReached works for multi-objective", {
#   terminator = TerminatorPerfReached$new()
#   terminator$param_set$values$level = c(y1 = 0.2, y2 = -0.2)
#   inst = MAKE_INST_2D_2D(terminator)
#   a = random_search(inst, batch_size = 1L)
#   a$data[, both := y1 <= 0.2 & y2 >= -0.2]
#   expect_equal(sum(a$data$both), 1)
#   expect_true(tail(a$data$both, 1))
# })
