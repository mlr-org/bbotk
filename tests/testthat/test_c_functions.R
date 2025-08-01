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

test_that("c_test_toposort_params", {
  # No dependencies
  ps1 = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_dbl(0, 1),
    x3 = paradox::p_dbl(0, 1)
  )
  # actually, the order is undefined here.... but our algo will use the vars in their order in the SS
  testres = .Call("c_test_toposort_params", ps1, c(0L, 1L, 2L))
  check_test_results(testres)

  # Simple dependency (B -> A)
  ps2 = paradox::ps(
    A = paradox::p_dbl(0, 1),
    B = paradox::p_fct(c("a", "b"))
  )
  ps2$add_dep("A", on = "B", cond = paradox::CondEqual$new("a"))
  testres = .Call("c_test_toposort_params", ps2, c(1L, 0L))
  check_test_results(testres)

  # Chain of dependencies (C -> B -> A)
  ps3 = paradox::ps(
    A = paradox::p_dbl(0, 1),
    B = paradox::p_fct(c("b1", "b2")),
    C = paradox::p_fct(c("c1", "c2"))
  )
  ps3$add_dep("A", on = "B", cond = paradox::CondEqual$new("b1"))
  ps3$add_dep("B", on = "C", cond = paradox::CondEqual$new("c1"))
  testres = .Call("c_test_toposort_params", ps3, c(2L, 1L, 0L))
  check_test_results(testres)

  # Multiple dependencies (A -> C, B -> C)
  ps4 = paradox::ps(
    A = paradox::p_fct(c("a", "b")),
    B = paradox::p_fct(c("c", "d")),
    C = paradox::p_dbl(0, 1)
  )
  ps4$add_dep("C", on = "A", cond = paradox::CondEqual$new("a"))
  ps4$add_dep("C", on = "B", cond = paradox::CondEqual$new("c"))
  testres = .Call("c_test_toposort_params", ps4, c(0L, 1L, 2L))
  check_test_results(testres)

  # Complex dependencies (D -> A, C -> A, D -> B, C -> B)
  ps5 = paradox::ps(
    A = paradox::p_fct(c("a", "b")),
    B = paradox::p_fct(c("a", "b")),
    C = paradox::p_fct(c("a", "b")),
    D = paradox::p_fct(c("a", "b"))
  )
  ps5$add_dep("B", on = "C", cond = paradox::CondEqual$new("a"))
  ps5$add_dep("B", on = "D", cond = paradox::CondEqual$new("a"))
  ps5$add_dep("A", on = "D", cond = paradox::CondEqual$new("a"))
  ps5$add_dep("C", on = "A", cond = paradox::CondEqual$new("a"))
  testres = .Call("c_test_toposort_params", ps5, c(3L, 0L, 2L, 1L))
  check_test_results(testres)
})