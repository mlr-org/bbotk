test_that("mlr_test_functions", {
  expect_dictionary(mlr_test_functions, min_items = 1L)
  keys = mlr_test_functions$keys()

  for (key in keys) {
    obj = otfun(key)
    expect_r6(obj, "ObjectiveTestFunction")
    expect_r6(obj, "ObjectiveRFun")
    expect_number(obj$optimum)
    expect_list(obj$optimum_x, types = "list", min.len = 1)
  }
})

test_that("mlr_test_functions sugar", {
  expect_class(otfun("branin"), "ObjectiveTestFunction")
  expect_class(otfuns(c("branin", "sphere")), "list")
})

test_that("as.data.table objects parameter", {
  tab = as.data.table(mlr_test_functions, objects = TRUE)
  expect_data_table(tab)
  expect_list(tab$object, "ObjectiveTestFunction", any.missing = FALSE)
  expect_names(names(tab), must.include = c("key", "label", "optimum", "optimum_x"))
})

test_that("test functions evaluate correctly at known optima", {
  for (key in mlr_test_functions$keys()) {
    obj = otfun(key)
    xs = obj$optimum_x[[1]]
    val = obj$eval(xs)$y
    expect_equal(val, obj$optimum, tolerance = 0.01, info = key)
  }
})

test_that("dictionary returns independent clones", {
  obj1 = otfun("branin")
  obj2 = otfun("branin")
  expect_false(identical(obj1$domain, obj2$domain))
})

test_that("branin_wu fidelity constant works", {
  obj = otfun("branin_wu")
  expect_equal(obj$constants$values$fidelity, 1)

  xs = list(x1 = pi, x2 = 2.275)
  val_full = obj$eval(xs)$y

  obj$constants$values$fidelity = 0.5
  val_low = obj$eval(xs)$y
  expect_true(val_full != val_low)
})
