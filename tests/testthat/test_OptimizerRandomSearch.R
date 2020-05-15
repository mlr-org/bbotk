context("OptimizerRandomSearch")


test_that("OptimizerRandomSearch", {
  opt = OptimizerRandomSearch$new()
  expect_class(opt, "Optimizer")
  expect_class(opt, "OptimizerRandomSearch")
  expect_output(print(opt), "<OptimizerRandomSearch>")
  inst = MAKE_INST()
  res = opt$optimize(inst)
  expect_list(res)
  expect_data_table(res$xdt)
  expect_number(res$y)
  expect_list(res$x_opt)
  expect_equal(res$y[[1]], inst$objective$eval(res$x_opt[[1]])$y)
})
