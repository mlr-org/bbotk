test_that("search_start helper works", {
  ps = ps(
    x1 = p_dbl(lower = -1, upper = 1),
    x2 = p_dbl(lower = 10, upper = 50)
  )

  start_values = search_start(search_space = ps, type = "random")
  expect_named(start_values, c("x1", "x2"))
  expect_gte(start_values[1], ps$lower[1])
  expect_lte(start_values[1], ps$upper[1])
  expect_gte(start_values[2], ps$lower[2])
  expect_lte(start_values[2], ps$upper[2])

  start_values = search_start(search_space = ps, type = "center")
  expect_equal(start_values, c("x1" = 0, "x2" = 30))

  expect_error(search_start(search_space = ps, type = "middle"),
    regexp = "Must be element of set {'random','center'}, but is 'middle'",
    fixed = TRUE)

  ps = ps(x1 = p_dbl(lower = -1, upper = 1), x2 = p_lgl())

  expect_error(search_start(search_space = ps, type = "center"),
    regexp = "Cannot generate center values of non-numeric parameters.",
    fixed = TRUE)
})
