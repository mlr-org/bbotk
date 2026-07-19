library(testthat)

test_that("c_local_search initial points", {
  search_space = paradox::ps(
    x1 = paradox::p_dbl(0, 1),
    x2 = paradox::p_dbl(1, 2)
  )
  obj = function(xdt) {
    xdt$x1 * xdt$x2
  }
  ctrl = local_search_control()
  # check that we get an error if the initial points have the wrong number of rows
  ctrl$n_searches = 2
  initp = paradox::generate_design_random(search_space, 3)$data
  expect_error(local_search(obj, search_space, ctrl, initp), "have exactly 2 rows")
  # check that we get an error if the initial points have invalid values
  initp[1, 1] = 100
  ctrl$n_searches = 3
  expect_error(
    local_search(obj, search_space, ctrl, initp),
    paradox_numeric_domain_error("Element 1 is not <= 1")
  )
  # check that we get an error if the initial points have invalid structure
  ctrl$n_searches = 1
  initp = data.table(x1 = 1, x2 = 1, x3 = 1)
  expect_error(local_search(obj, search_space, ctrl, initp), "Parameter 'x3' not available")
  initp = data.table(x1 = 1, x2 = "foo")
  expect_error(
    local_search(obj, search_space, ctrl, initp),
    paradox_numeric_domain_error("not 'character'")
  )

  # n_steps = 0 means we only eval initial points, no search is performed
  ctrl$n_searches = 2
  ctrl$n_steps = 0
  initp = data.table(x1 = c(0, 1), x2 = c(1, 2))
  res = local_search(obj, search_space, ctrl, initp)
  expect_equal(res$x, list(x1 = 0, x2 = 1))
  expect_equal(res$y, 0) # n_steps = 1 means we do one step of local search
})

test_that("c_local_search roots detached dependency snapshots across callbacks", {
  search_space = paradox::ps(
    child = paradox::p_dbl(
      -1,
      1,
      depends = parent %in% c("a", "b")
    ),
    parent = paradox::p_fct(c("a", "b", "c"))
  )
  control = local_search_control(
    n_searches = 1L,
    n_steps = 1L,
    n_neighs = 1L
  )
  initial = data.table::data.table(child = 0, parent = "a")

  # Paradox returns a detached dependency facade. Force its former allocation
  # class to be reused while the objective callback runs; native local-search
  # state must retain the exact facade snapshot for the complete operation.
  pressure = new.env(parent = emptyenv())
  objective = function(xdt) {
    gc()
    pressure$objects = replicate(
      10000L,
      vector("list", 2L),
      simplify = FALSE
    )
    numeric(nrow(xdt))
  }

  result = local_search(objective, search_space, control, initial)
  expect_named(result, c("x", "y"))
})
