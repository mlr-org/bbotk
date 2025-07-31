library(testthat)

check_test_results = function(testres) {
  for (i in seq_along(testres)) {
    expect_true(testres[[i]], info = names(testres)[i], label = names(testres)[i])
  }
}




test_that("c_test_get_list_el_by_name", {
  test_list = list(a = 1, b = "foo")
  testres = .Call("c_test_get_list_el_by_name", test_list)
  check_test_results(testres)
})

test_that("c_test_random_int", {
  testres = .Call("c_test_random_int")
  check_test_results(testres)
})

test_that("c_test_random_normal", {
  testres = .Call("c_test_random_normal")
  check_test_results(testres)
})

test_that("c_test_extract_ss_info", {
  search_space = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_int(0, 10),
    x3 = paradox::p_fct(c("a", "b", "c")),
    x4 = paradox::p_lgl()
  )
  testres = .Call("c_test_extract_ss_info", search_space)
  check_test_results(testres)
})

test_that("c_test_dt_utils", {
  search_space = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_int(0, 10),
    x3 = paradox::p_fct(c("a", "b")),
    x4 = paradox::p_lgl()
  )
  testres = .Call("c_test_dt_utils", search_space)
  check_test_results(testres)
})