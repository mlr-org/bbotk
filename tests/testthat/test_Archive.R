test_that("Archive", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  expect_output(print(a), "Archive")
  expect_equal(a$n_evals, 0)
  expect_equal(a$cols_x, c("x1", "x2"))
  expect_equal(a$cols_y, c("y"))
  xdt = data.table(x1 = 0, x2 = 1)
  xss_trafoed = list(list(x1 = 0, x2 = 1))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$n_evals, 1)
  expect_equal(a$data$x_domain, xss_trafoed)
  adt = as.data.table(a)
  expect_data_table(adt, nrows = 1)
  expect_names(colnames(adt), identical.to = c("x1", "x2", "y", "timestamp", "batch_nr", "x_domain_x1", "x_domain_x2"))
  a$clear()
  expect_data_table(a$data, nrows = 0)
  adt = as.data.table(a)
  expect_data_table(adt, nrows = 0)

  # with no xss_trafoed
  a$add_evals(xdt, NULL, ydt)
  adt = as.data.table(a)
  expect_data_table(adt, nrows = 1)
  expect_names(colnames(adt), identical.to = c("x1", "x2", "y", "timestamp", "batch_nr"))
})

test_that("Archive best works", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = c(0, 0.5), x2 = c(1, 1))
  xss_trafoed = list(list(x1 = c(0, 0.5), x2 = c(1, 1)))
  ydt = data.table(y = c(1, 0.25))
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$best()$y, 0.25)

  xdt = data.table(x1 = 1, x2 = 1)
  xss_trafoed = list(list(x1 = 1, x2 = 1))
  ydt = data.table(y = 2)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$best(batch = 2)$batch_nr, 2L)

  a = Archive$new(PS_2D, FUN_2D_2D_CODOMAIN)
  xdt = data.table(x1 = c(-1, -1, -1), x2 = c(1, 0, -1))
  xss_trafoed = list(list(x1 = -1, x2 = 1), list(x1 = -1, x2 = 0), list(x1 = -1, x2 = 1))
  ydt = data.table(y1 = c(1, 1, 1), y2 = c(-1, 0, -1))
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$best()$y2, 0)
})

test_that("Archive on 1D problem works", {
  a = Archive$new(PS_1D, FUN_1D_CODOMAIN)
  xdt = data.table(x = 1)
  xss_trafoed = list(list(x = 1))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  expect_equal(a$n_evals, 1)
  expect_equal(a$data$x_domain, xss_trafoed)
  expect_list(a$data$x_domain[[1]])

  xdt = data.table(x = 2)
  expect_error(a$add_evals(xdt, transpose_list(xdt), ydt), "Element 1 is not")
})

test_that("Unnest columns", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = 0, x2 = 1)
  xss_trafoed = list(list(x1 = 1, x2 = 2))
  ydt = data.table(y = 1)
  a$add_evals(xdt, xss_trafoed, ydt)
  adt = as.data.table(a)
  expect_names(colnames(adt), identical.to = c("x1", "x2", "y", "timestamp", "batch_nr", "x_domain_x1", "x_domain_x2"))
  expect_equal(adt$x_domain_x1, 1)
  expect_equal(adt$x_domain_x2, 2)

  # checks
  xdt = data.table(x1 = 0.5, x2 = 2)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt), "Element 1 is not")
})

test_that("NAs in ydt throw an error", {
  a = Archive$new(PS_1D, FUN_1D_CODOMAIN)
  xdt = data.table(x = 1)
  xss_trafoed = list(list(x = 1))
  ydt = data.table(y = NA)
  expect_error(a$add_evals(xdt, xss_trafoed, ydt), "Contains missing values")
})

test_that("start_time is set by Optimizer", {
  inst = MAKE_INST()
  expect_null(inst$archive$start_time)
  optimizer = OptimizerRandomSearch$new()
  time = Sys.time()
  optimizer$optimize(inst)
  expect_equal(inst$archive$start_time, time, tolerance = 0.5)
})

test_that("check_values flag works", {
  a = Archive$new(PS_2D, FUN_2D_CODOMAIN, check_values = FALSE)
  xdt = data.table(x1 = c(0, 2), x2 = c(1, 1))
  xss_trafoed = list(list(x1 = c(0, 0.5), x2 = c(1, 1)))
  ydt = data.table(y = c(1, 0.25))
  a$add_evals(xdt, xss_trafoed, ydt)

  a = Archive$new(PS_2D, FUN_2D_CODOMAIN, check_values = TRUE)
  xdt = data.table(x1 = c(0, 2), x2 = c(1, 1))
  xss_trafoed = list(list(x1 = c(0, 0.5), x2 = c(1, 1)))
  ydt = data.table(y = c(1, 0.25))
  expect_error(a$add_evals(xdt, xss_trafoed, ydt), "x1: Element 1 is not <= 1.", fixed = TRUE)
})

test_that("deep clone works", {
  a1 = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = 0, x2 = 1)
  xss_trafoed = list(list(x1 = 0, x2 = 1))
  ydt = data.table(y = 1)
  a1$add_evals(xdt, xss_trafoed, ydt)
  a2 = a1$clone(deep = TRUE)

  expect_different_address(a1$data, a2$data)
  expect_different_address(a1$search_space, a2$search_space)
  expect_different_address(a1$codomain, a2$codomain)
})

test_that("best method works with maximization", {
  codomain = FUN_2D_CODOMAIN
  tryCatch({
    codomain$tags$y = "maximize"
  }, error = function(e) {
    # old paradox
    codomain$params$y$tags = "maximize"
  })

  archive = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = runif(5), x2 = runif(5))
  xss_trafoed = list(list(x1 = runif(5), x2 = runif(5)))
  ydt = data.table(y = c(1, 0.25, 2, 0.5, 0.3))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_equal(archive$best()$y, 2)
})

test_that("best method works with minimization", {
  codomain = FUN_2D_CODOMAIN
  tryCatch({
    codomain$tags$y = "minimize"
  }, error = function(e) {
    # old paradox
    codomain$params$y$tags = "minimize"
  })


  archive = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = runif(5), x2 = runif(5))
  xss_trafoed = list(list(x1 = runif(5), x2 = runif(5)))
  ydt = data.table(y = c(1, 0.25, 2, 0.5, 0.3))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_equal(archive$best()$y, 0.25)
})

test_that("best method returns top n results with maximization", {
  codomain = FUN_2D_CODOMAIN
  tryCatch({
    codomain$tags$y = "maximize"
  }, error = function(e) {
    # old paradox
    codomain$params$y$tags = "maximize"
  })


  archive = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = runif(5), x2 = runif(5))
  xss_trafoed = list(list(x1 = runif(5), x2 = runif(5)))
  ydt = data.table(y = c(1, 0.25, 2, 0.5, 0.3))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_equal(archive$best(n_select = 2)$y, c(2, 1))
})

test_that("best method returns top n results with maximization and ties", {
  codomain = FUN_2D_CODOMAIN
  codomain$params$y$tags = "maximize"

  archive = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = runif(5), x2 = runif(5))
  xss_trafoed = list(list(x1 = runif(5), x2 = runif(5)))
  ydt = data.table(y = c(1, 1, 2, 0.5, 0.5))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_equal(archive$best(n_select = 2)$y, c(2, 1))
})

test_that("best method returns top n results with minimization", {
  codomain = FUN_2D_CODOMAIN
  tryCatch({
    codomain$tags$y = "minimize"
  }, error = function(e) {
    # old paradox
    codomain$params$y$tags = "minimize"
  })

  archive = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = runif(5), x2 = runif(5))
  xss_trafoed = list(list(x1 = runif(5), x2 = runif(5)))
  ydt = data.table(y = c(1, 0.25, 2, 0.5, 0.3))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_equal(archive$best(n_select = 2)$y, c(0.25, 0.3))
})

test_that("best method returns top n results with minimization and ties", {
  codomain = FUN_2D_CODOMAIN
  codomain$params$y$tags = "minimize"

  archive = Archive$new(PS_2D, FUN_2D_CODOMAIN)
  xdt = data.table(x1 = runif(5), x2 = runif(5))
  xss_trafoed = list(list(x1 = runif(5), x2 = runif(5)))
  ydt = data.table(y = c(1, 0.25, 0.5, 0.3, 0.3))
  archive$add_evals(xdt, xss_trafoed, ydt)

  expect_equal(archive$best(n_select = 2)$y, c(0.25, 0.3))
})
