library(testthat)

check_test_results = function(testres) {
  for (i in seq_along(testres)) {
    expect_true(testres[[i]], info = names(testres)[i], label = names(testres)[i])
  }
}




test_that("c_test_get_list_el_by_name", {
  test_list = list(a = 1, b = "foo")
  testres = .Call("c_test_get_list_el_by_name", test_list, PACKAGE = "bbotk")
  check_test_results(testres)
})

test_that("c_test_random_int", {
  testres = .Call("c_test_random_int", PACKAGE = "bbotk")
  check_test_results(testres)
})

test_that("c_test_random_normal", {
  testres = .Call("c_test_random_normal", PACKAGE = "bbotk")
  check_test_results(testres)
})

test_that("c_test_extract_ss_info", {
  search_space = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_int(0, 10),
    x3 = paradox::p_fct(c("a", "b", "c")),
    x4 = paradox::p_lgl()
  )
  testres = .Call("c_test_extract_ss_info", search_space, PACKAGE = "bbotk")
  check_test_results(testres)
})

test_that("c_test_dt_utils", {
  ss = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_int(0, 10),
    x3 = paradox::p_fct(c("a", "b")),
    x4 = paradox::p_lgl()
  )
  ctrl = local_search_control(mut_sd = 2)
  testres = .Call("c_test_dt_utils", ss, ctrl, PACKAGE = "bbotk")
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
  testres = .Call("c_test_toposort_params", ps1, c(0L, 1L, 2L), integer(0), PACKAGE = "bbotk")
  check_test_results(testres)

  # Simple dependency (B -> A)
  ps2 = paradox::ps(
    A = paradox::p_dbl(0, 1),
    B = paradox::p_fct(c("a", "b"))
  )
  ps2$add_dep("A", on = "B", cond = paradox::CondEqual$new("a"))
  testres = .Call("c_test_toposort_params", ps2, c(1L, 0L), c(0L), PACKAGE = "bbotk")
  check_test_results(testres)

  # Chain of dependencies (C -> B -> A)
  ps3 = paradox::ps(
    A = paradox::p_dbl(0, 1),
    B = paradox::p_fct(c("b1", "b2")),
    C = paradox::p_fct(c("c1", "c2"))
  )
  ps3$add_dep("A", on = "B", cond = paradox::CondEqual$new("b1"))
  ps3$add_dep("B", on = "C", cond = paradox::CondEqual$new("c1"))
  testres = .Call("c_test_toposort_params", ps3, c(2L, 1L, 0L), c(1L, 0L), PACKAGE = "bbotk")
  check_test_results(testres)

  # Multiple dependencies (A -> C, B -> C)
  ps4 = paradox::ps(
    A = paradox::p_fct(c("a", "b")),
    B = paradox::p_fct(c("c", "d")),
    C = paradox::p_dbl(0, 1)
  )
  ps4$add_dep("C", on = "A", cond = paradox::CondEqual$new("a"))
  ps4$add_dep("C", on = "B", cond = paradox::CondEqual$new("c"))
  testres = .Call("c_test_toposort_params", ps4, c(0L, 1L, 2L), c(2L, 2L), PACKAGE = "bbotk")
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
  testres = .Call("c_test_toposort_params", ps5, c(3L, 0L, 2L, 1L), c(0L, 2L, 1L, 1L), PACKAGE = "bbotk")
  check_test_results(testres)
})

test_that("c_test_is_condition_satisfied", {
  # simple case
  ps = paradox::ps(
    A = paradox::p_fct(c("a1", "a2")),
    B = paradox::p_dbl(0, 1)
  )
  ps$add_dep("B", on = "A", cond = paradox::CondEqual$new("a1"))
  dt = data.frame(A = "a1", B = 0.5)
  testres = .Call("c_test_is_condition_satisfied", dt, ps, 0L, 1L, PACKAGE = "bbotk")
  dt = data.frame(A = "a2", B = 0.5)
  testres = .Call("c_test_is_condition_satisfied", dt, ps, 0L, 0L, PACKAGE = "bbotk")
  
  # Test CondAnyOf condition
  ps2 = paradox::ps(
    A = paradox::p_fct(c("a1", "a2", "a3")),
    B = paradox::p_int(0, 10)
  )
  ps2$add_dep("B", on = "A", cond = paradox::CondAnyOf$new(c("a1", "a2")))
  dt = data.frame(A = "a1", B = 5)
  testres = .Call("c_test_is_condition_satisfied", dt, ps2, 0L, 1L, PACKAGE = "bbotk")
  dt = data.frame(A = "a3", B = 5) 
  testres = .Call("c_test_is_condition_satisfied", dt, ps2, 0L, 0L, PACKAGE = "bbotk")

  # Test numeric parameter conditions
  ps3 = paradox::ps(
    A = paradox::p_dbl(0, 10),
    B = paradox::p_int(0, 5)
  )
  ps3$add_dep("B", on = "A", cond = paradox::CondEqual$new(5))
  dt = data.frame(A = 5, B = 3)
  testres = .Call("c_test_is_condition_satisfied", dt, ps3, 0L, 1L, PACKAGE = "bbotk")
  dt = data.frame(A = 4.9, B = 3)
  testres = .Call("c_test_is_condition_satisfied", dt, ps3, 0L, 0L, PACKAGE = "bbotk")

  # Test logical parameter conditions
  ps4 = paradox::ps(
    A = paradox::p_lgl(),
    B = paradox::p_dbl(0, 1)
  )
  ps4$add_dep("B", on = "A", cond = paradox::CondEqual$new(TRUE))
  dt = data.frame(A = TRUE, B = 0.5)
  testres = .Call("c_test_is_condition_satisfied", dt, ps4, 0L, 1L, PACKAGE = "bbotk")
  dt = data.frame(A = FALSE, B = 0.5)
  testres = .Call("c_test_is_condition_satisfied", dt, ps4, 0L, 0L, PACKAGE = "bbotk")

  # Test NA handling
  ps5 = paradox::ps(
    A = paradox::p_fct(c("a1", "a2")),
    B = paradox::p_dbl(0, 1)
  )
  ps5$add_dep("B", on = "A", cond = paradox::CondEqual$new("a1"))
  
  dt = data.frame(A = NA, B = NA) # parent is non-active, condition is not satisfied
  testres = .Call("c_test_is_condition_satisfied", dt, ps5, 0L, 0L, PACKAGE = "bbotk")
  dt = data.frame(A = "a1", B = NA) # parent is active and correct, B=NA does not matter
  testres = .Call("c_test_is_condition_satisfied", dt, ps5, 0L, 1L, PACKAGE = "bbotk")
  dt = data.frame(A = NA_character_, B = 0.5) # parent is non-active, condition is not satisfied
  testres = .Call("c_test_is_condition_satisfied", dt, ps5, 0L, 0L, PACKAGE = "bbotk") 
  check_test_results(testres)
})

test_that("c_test_generate_neighs", {
  set.seed(1)
  # No dependencies
  ss = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_int(0, 10),
    x3 = paradox::p_fct(c("a", "b", "c")),
    x4 = paradox::p_lgl()
  )
  ctrl = local_search_control(n_neighs = 30, mut_sd = 2)
  pop = data.table::data.table(
    x1 = 0.5,
    x2 = 5L,
    x3 = "a",
    x4 = TRUE
  )
  pop_copy = data.table::copy(pop)
  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")

  expect_true(is.data.table(neighs))
  expect_equal(nrow(neighs), 1 * ctrl$n_neighs)
  expect_equal(ncol(neighs), ncol(pop))
  # check col types
  expect_true(is.numeric(neighs$x1))
  expect_true(is.integer(neighs$x2))
  expect_true(is.character(neighs$x3))
  expect_true(is.logical(neighs$x4))
  # check that values are within bounds
  expect_true(all(neighs$x1 >= 0 & neighs$x1 <= 1))
  expect_true(all(neighs$x2 >= 0 & neighs$x2 <= 10))
  expect_true(all(neighs$x1 >= 0 & neighs$x1 <= 1))
  expect_true(all(neighs$x2 >= 0 & neighs$x2 <= 10))
  expect_true(all(is.integer(neighs$x2)))
  expect_true(all(neighs$x3 %in% c("a", "b", "c")))
  expect_true(all(is.logical(neighs$x4)))

  # check that exactly 1 param was mutated per row
  for (i in 1:nrow(neighs)) {
    diffs = mapply("!=", as.data.frame(neighs[i,]), as.data.frame(pop))
    diffs[1] = abs(neighs[i,]$x1 - pop$x1) > 1e-8  # special handling for numeric
    expect_equal(sum(diffs), 1)
  }
 
  # With dependencies
  ss = paradox::ps(
    A = paradox::p_fct(c("a1", "a2")),
    B = paradox::p_dbl(0, 1)
  )
  ss$add_dep("B", on = "A", cond = paradox::CondEqual$new("a1"))

  # Case 1: condition is met (A="a1"), B has a value. If A is mutated to "a2", B must become NA.
  pop = data.table::data.table(A = "a1", B = 0.5)

  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")

  mutated_A_to_a2 = which(neighs$A == "a2")
  expect_true(length(mutated_A_to_a2) > 0) # check A was mutated to "a2"
  expect_true(all(is.na(neighs[mutated_A_to_a2, ]$B)))

  not_mutated_A = which(neighs$A == "a1")
  expect_true(all(!is.na(neighs[not_mutated_A, ]$B)))

  # Case 2: condition not met (A="a2"), B is NA. The only mutable param is A.
  # So A must be mutated to "a1" in ALL neighbors.
  # When A is mutated to "a1", B must get a value.
  pop = data.table::data.table(A = "a2", B = NA_real_)
  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")
  # All neighbors should have A mutated to "a1"
  expect_true(all(neighs$A == "a1"))
  # All neighbors should have a non-NA value for B
  expect_true(all(!is.na(neighs$B)))
  # and be within bounds
  expect_true(all(neighs$B >= 0 & neighs$B <= 1))

  # More complex dependencies
  # Chain of dependencies (C -> B -> A)
  ss = paradox::ps(
    A = paradox::p_dbl(0, 1),
    B = paradox::p_fct(c("b1", "b2")),
    C = paradox::p_fct(c("c1", "c2"))
  )
  ss$add_dep("A", on = "B", cond = paradox::CondEqual$new("b1"))
  ss$add_dep("B", on = "C", cond = paradox::CondEqual$new("c1"))

  # Case 3.1: Start with everything active. Mutate C to "c2". B and A must become NA.
  pop = data.table::data.table(A = 0.5, B = "b1", C = "c1")
  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")

  mutated_C_to_c2 = which(neighs$C == "c2")
  expect_true(length(mutated_C_to_c2) > 0)
  expect_true(all(is.na(neighs[mutated_C_to_c2, ]$B)))
  expect_true(all(is.na(neighs[mutated_C_to_c2, ]$A)))

  # Case 3.2: Start with everything active. Mutate B to "b2". A must become NA.
  mutated_B_to_b2 = which(neighs$B == "b2" & neighs$C == "c1")
  expect_true(length(mutated_B_to_b2) > 0)
  expect_true(all(is.na(neighs[mutated_B_to_b2, ]$A)))
  expect_true(all(neighs[mutated_B_to_b2, ]$C == "c1")) # C should not change

  # Case 3.3: Start with C="c2", B and A are NA. Only C is mutable.
  # It must be mutated to "c1".
  # Then B must get a value.
  # If B gets "b1", A must get a value.
  pop = data.table::data.table(A = NA_real_, B = NA_character_, C = "c2")
  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")

  expect_true(all(neighs$C == "c1"))
  expect_true(all(!is.na(neighs$B)))

  b1_indices = which(neighs$B == "b1")
  b2_indices = which(neighs$B == "b2")
  expect_true(length(b1_indices) + length(b2_indices) == nrow(neighs))

  if (length(b1_indices) > 0) {
    expect_true(all(!is.na(neighs[b1_indices, ]$A)))
    expect_true(all(neighs[b1_indices, ]$A >= 0 & neighs[b1_indices, ]$A <= 1))
  }
  if (length(b2_indices) > 0) {
    expect_true(all(is.na(neighs[b2_indices, ]$A)))
  }

  # Multiple dependencies (C depends on A and B)
  ss = paradox::ps(
    A = paradox::p_fct(c("a", "b")),
    B = paradox::p_fct(c("c", "d")),
    C = paradox::p_dbl(0, 1)
  )
  ss$add_dep("C", on = "A", cond = paradox::CondEqual$new("a"))
  ss$add_dep("C", on = "B", cond = paradox::CondEqual$new("c"))

  # Case 4.1: Start with everything active. Mutating A or B deactivates C.
  pop = data.table::data.table(A = "a", B = "c", C = 0.5)
  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")

  mutated_A = which(neighs$A == "b")
  expect_true(length(mutated_A) > 0)
  expect_true(all(is.na(neighs[mutated_A, ]$C)))
  expect_true(all(neighs[mutated_A, ]$B == "c"))

  mutated_B = which(neighs$B == "d")
  expect_true(length(mutated_B) > 0)
  expect_true(all(is.na(neighs[mutated_B, ]$C)))
  expect_true(all(neighs[mutated_B, ]$A == "a"))

  # Case 4.2: Start with C inactive because of A. Mutating A to "a" makes C active.
  pop = data.table::data.table(A = "b", B = "c", C = NA_real_)
  neighs = .Call("c_test_generate_neighs", ss, ctrl, pop, PACKAGE = "bbotk")

  # some neighbors will have B mutated to "d" which keeps C inactive
  mutated_A_to_a = which(neighs$A == "a" & neighs$B == "c")
  expect_true(length(mutated_A_to_a) > 0)
  expect_true(all(!is.na(neighs[mutated_A_to_a, ]$C)))
  expect_true(all(neighs[mutated_A_to_a, ]$C >= 0 & neighs[mutated_A_to_a, ]$C <= 1))
})

test_that("c_test_copy_best_neighs_to_pop", {
  ss = paradox::ps(
    x = paradox::p_dbl(0, 1)
  )
  ctrl = local_search_control(n_searches = 2, n_neighs = 3)

  pop_x = data.table::data.table(x = c(0.5, 0.8))
  pop_y = c(10, 20)

  neighs_x = data.table::data.table(x = c(0.1, 0.2, 0.3, 0.9, 0.7, 0.6))
  neighs_y = c(5, 12, 8, 25, 18, 15)

  res = .Call("c_test_copy_best_neighs_to_pop", ss, ctrl, pop_x, pop_y, neighs_x, neighs_y, PACKAGE = "bbotk")
  expect_equal(res$pop_x$x, c(0.1, 0.6))
  expect_equal(res$pop_y, c(5, 15))

  # No improvement
  neighs_y = c(11, 12, 13, 21, 22, 23)
  res = .Call("c_test_copy_best_neighs_to_pop", ss, ctrl, pop_x, pop_y, neighs_x, neighs_y, PACKAGE = "bbotk")
  expect_equal(res$pop_x$x, pop_x$x)
  expect_equal(res$pop_y, pop_y)
})

test_that("c_test_get_best_pop_element", {
  # test minimization
  ss = paradox::ps(
    x1 = paradox::p_dbl(0, 1)
  )
  ctrl = local_search_control(minimize = TRUE)
  pop_x = data.table::data.table(x1 = c(0.1, 0.5, 0.9))
  pop_y = c(10, 5, 20) 
  best = .Call("c_test_get_best_pop_element", ss, ctrl, pop_x, pop_y, PACKAGE = "bbotk")
  expect_equal(best$y, 5)
  expect_equal(best$x, as.list(pop_x[2, ]))

  # test maximizatio; internally we assume that the evaln multiplies with -1
  ctrl$minimize = FALSE
  pop_y = pop_y * -1
  best = .Call("c_test_get_best_pop_element", ss, ctrl, pop_x, pop_y, PACKAGE = "bbotk")
  expect_equal(best$y, 20)
  expect_equal(best$x, as.list(pop_x[3, ]))

  # test with NA value in best row
  pop_x[3, x1 := NA_real_]
  best = .Call("c_test_get_best_pop_element", ss, ctrl, pop_x, pop_y, PACKAGE = "bbotk")
  expect_equal(best$y, 20)
  expect_equal(best$x, as.list(pop_x[3, ]))

})


test_that("c_test_dt_repair_row", {
  # Simple dependency: B depends on A.
  ss = paradox::ps(
    A = paradox::p_fct(c("a1", "a2")),
    B = paradox::p_dbl(0, 1)
  )
  ss$add_dep("B", on = "A", cond = paradox::CondEqual$new("a1"))

  # Case 1: Condition not met (A="a2"), B has a value. B should become NA.
  dt1 = data.table::data.table(A = "a2", B = 0.5)
  dt2 = .Call("c_test_dt_repair_row", ss, dt1, PACKAGE = "bbotk")
  expect_equal(dt2, data.table::data.table(A = "a2", B = NA_real_))

  # Case 2: Condition met (A="a1"), but B is NA. B should get a valid (non-NA) value.
  dt1 = data.table::data.table(A = "a1", B = NA_real_)
  dt2 = .Call("c_test_dt_repair_row", ss, dt1, PACKAGE = "bbotk")
  expect_equal(dt2$A, "a1")
  expect_true(is.numeric(dt2$B) && !is.na(dt2$B))
  expect_true(dt2$B >= 0 && dt2$B <= 1)

  # Chained dependencies (C -> B -> A)
  ss = paradox::ps(
    A = paradox::p_dbl(0, 1),
    B = paradox::p_fct(c("b1", "b2")),
    C = paradox::p_fct(c("c1", "c2"))
  )
  ss$add_dep("A", on = "B", cond = paradox::CondEqual$new("b1"))
  ss$add_dep("B", on = "C", cond = paradox::CondEqual$new("c1"))

  # Case 3: Deactivating C should deactivate B and A.
  dt1 = data.table::data.table(A = 0.5, B = "b1", C = "c2")
  dt2 = .Call("c_test_dt_repair_row", ss, dt1, PACKAGE = "bbotk")
  expect_equal(dt2$C, "c2")
  expect_true(is.na(dt2$B))
  expect_true(is.na(dt2$A))

  # Multiple dependencies (C depends on A and B)
  ss = paradox::ps(
    A = paradox::p_fct(c("a", "b")),
    B = paradox::p_fct(c("c", "d")),
    C = paradox::p_dbl(0, 1)
  )
  ss$add_dep("C", on = "A", cond = paradox::CondEqual$new("a"))
  ss$add_dep("C", on = "B", cond = paradox::CondEqual$new("c"))

  # Case 4.1: Only one condition met. C should be NA.
  dt1 = data.table::data.table(A = "a", B = "d", C = 0.5)
  dt2 = .Call("c_test_dt_repair_row", ss, dt1, PACKAGE = "bbotk")
  expect_equal(dt2$A, "a")
  expect_equal(dt2$B, "d")
  expect_true(is.na(dt2$C))

  # Case 4.2: Both conditions met, C is NA. C should get a value.
  dt1 = data.table::data.table(A = "a", B = "c", C = NA_real_)
  dt2 = .Call("c_test_dt_repair_row", ss, dt1, PACKAGE = "bbotk")
  expect_equal(dt2$A, "a")
  expect_equal(dt2$B, "c")
  expect_true(!is.na(dt2$C))
  expect_true(dt2$C >= 0 && dt2$C <= 1)
})

test_that("c_test_restart_stagnated_searches", {
  set.seed(1)
  ss = paradox::ps(
    x = paradox::p_dbl(0, 1)
  )
  ctrl = local_search_control(stagnate_max = 2)
  pop_x = data.table::data.table(x = c(0.1, 0.5, 0.9))
  stagnate_count = c(1L, 2L, 0L) # 2nd search should be restarted
  restarted_pop = .Call("c_test_restart_stagnated_searches", ss, ctrl, pop_x, stagnate_count, PACKAGE = "bbotk")
  # The first and third rows should be unchanged
  expect_equal(restarted_pop[1, ], pop_x[1, ])
  expect_equal(restarted_pop[3, ], pop_x[3, ])
  # The second row should be different (restarted)
  expect_true(restarted_pop[2, ]$x != pop_x[2, ]$x)
  # The new value should be within bounds
  expect_true(restarted_pop[2, ]$x >= 0 && restarted_pop[2, ]$x <= 1)
})

test_that("c_test_dt_set_random_row", {
  set.seed(1)
  ss = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_int(0, 10),
    x3 = paradox::p_fct(c("a", "b", "c")),
    x4 = paradox::p_lgl()
  )
   # NB: the condition should not matter for dt_set_random_row
  ss$add_dep("x1", on = "x3", cond = paradox::CondEqual$new("a"))
  # A DT with one row of "wrong" values that should be overwritten
  dt = data.table::data.table(x1 = 2, x2 = 11L, x3 = "d", x4 = NA)
  
  random_dt = .Call("c_test_dt_set_random_row", ss, dt, PACKAGE = "bbotk")

  # Check that values are within bounds
  expect_true(random_dt$x1 >= 0 && random_dt$x1 <= 1)
  expect_true(random_dt$x2 >= 0 && random_dt$x2 <= 10)
  expect_true(is.integer(random_dt$x2))
  expect_true(random_dt$x3 %in% c("a", "b", "c"))
  expect_true(is.logical(random_dt$x4))
  expect_true(!is.na(random_dt$x4))
})

