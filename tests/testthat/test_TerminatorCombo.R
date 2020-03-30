context("TerminatorCombo")

test_that("TerminatorCombo works", {
  obj = OBJ_2D
  for (mode in c("any", "all")) {
    term1 = TerminatorClockTime$new()
    term2 = TerminatorEvals$new()
    now = Sys.time()
    term1$param_set$values$stop_time = now + 2L
    term2$param_set$values$n_evals = 6L
    term = TerminatorCombo$new(list(term1, term2))
    term$param_set$values$any = (mode == "any")
    a = random_search(obj, term, batch_size = 1L)
    time_needed = as.numeric(difftime(Sys.time(), now), units = "secs")
    if (mode == "any") {
      expect_true(time_needed < 2)
      expect_equal(a$n_evals, 6L)
    } else {
      expect_equal(time_needed, 2, tolerance = 0.15)
      expect_true(a$n_evals > 6L)
    }

  }

})
