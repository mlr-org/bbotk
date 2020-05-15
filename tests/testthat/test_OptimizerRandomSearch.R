context("OptimizerRandomSearch")


test_that("OptimizerRandomSearch", {
  opt = OptimizerRandomSearch$new()
  expect_class(opt, "Optimizer")
  expect_class(opt, "OptimizerRandomSearch")
  expect_output(print(opt), "<OptimizerRandomSearch>")
  inst = MAKE_INST()
  opt$optimize(inst)
  expect_data_table(inst$result)
  expect_number(inst$result_y)
  expect_list(inst$result_opt_x)
  expect_equal(inst$result_y, unlist(inst$objective$eval(inst$result_opt_x)["y"]))
})
