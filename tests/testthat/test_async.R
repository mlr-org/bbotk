test_that("asynchronous evaluation on single worker of a single-crit 1D function works", {
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, seq_len(10))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on single worker of a single-crit 2D function works", {
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, seq_len(10))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on single worker of a multi-crit 2D function works", {

  # multi-crit 2D function
  instance = MAKE_INST(objective = OBJ_2D_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, seq_len(10))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 10)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y1", "y2"))
  expect_numeric(archive$data$y1, any.missing = FALSE)
  expect_numeric(archive$data$y2, any.missing = FALSE)
})

test_that("mixed asynchronous and sequential evaluation works", {
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  instance$eval_batch(xdt)
  archive = instance$archive

  xdt = generate_design_random(PS_2D, 10)$data
  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, nrows = 20, ncols = 7)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "y", "x_domain", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, c(rep("evaluated", 10), rep("proposed", 10)))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, nrows = 20, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "y", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, c(rep(NA, 10), seq_len(10)))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, c(rep("evaluated", 10), rep("in_progress", 10)))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, nrows = 20, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("eval_proposed works if no proposed points are available", {
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  # call before add_evals
  expect_invisible(instance$eval_proposed(async = TRUE, single_worker = TRUE))
  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrow = 0)

  xdt = generate_design_random(PS_1D, 10)$data
  archive$add_evals(xdt, status = "proposed")

  # repeated call
  instance$eval_proposed(async = TRUE, single_worker = TRUE)
  archive_1 = copy(instance$archive$data)
  instance$eval_proposed(async = TRUE, single_worker = TRUE)
  expect_equal(archive_1, instance$archive$data)
})


test_that("asynchronous evaluation on separate workers of a single-crit 1D function works", {
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = FALSE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, rep(1, 10))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[10]]))
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on separate workers of a single-crit 2D function works", {
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = FALSE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, rep(1, 10))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[10]]))
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on separate workers of a multi-crit 2D function works", {
  instance = MAKE_INST(objective = OBJ_2D_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = FALSE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, rep(1, 10))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[10]]))
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 10)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y1", "y2"))
  expect_numeric(archive$data$y1, any.missing = FALSE)
  expect_numeric(archive$data$y2, any.missing = FALSE)
})

test_that("asynchronous evaluation of selected points works", {
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(i = seq(5), async = TRUE, single_worker = TRUE)
  expect_error(instance$eval_proposed(i = 20:30, async = TRUE, single_worker = TRUE),
    "Assertion on 'i' failed: Must be a subset of")

  expect_data_table(archive$data, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, c(seq_len(5), rep(NA, 5)))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[5]])
  expect_equal(archive$data$status, c(rep("in_progress", 5), rep("proposed", 5)))

  instance$archive$resolve_promise(i = seq(5))

  expect_data_table(archive$data, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y)
  expect_equal(archive$data$status, c(rep("evaluated", 5), rep("proposed", 5)))
})

test_that("asynchronous evaluation on single worker of a single-crit 1D function with dt shortcut works", {
  FUN_1D_DT = function(xdt) {
    data.table(y = as.numeric(xdt$x)^2)
  }
  OBJ_1D_DT = ObjectiveRFunDt$new(fun = FUN_1D_DT, domain = PS_1D_domain, properties = "single-crit")
  instance = MAKE_INST(objective = OBJ_1D_DT, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 6)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, seq_len(10))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on single worker of a single-crit 2D function with dt shortcut works", {
  FUN_2D_DT = function(xdt) {
    pmap_dtr(xdt, function(x1, x2) data.table(y = x1^2 + x2^2))
  }
  OBJ_2D_DT = ObjectiveRFunDt$new(fun = FUN_2D_DT, domain = PS_2D_domain, properties = "single-crit")
  instance = MAKE_INST(objective = OBJ_2D_DT, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, seq_len(10))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on single worker of a multi-crit 2D function with dt shortcut works", {
  FUN_2D_2D_DT = function(xdt) {
    pmap_dtr(xdt, function(x1, x2) data.table(y1 = x1^2, y2 = x2^2))
  }
  OBJ_2D_2D_DT = ObjectiveRFunDt$new(fun = FUN_2D_2D_DT, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN, properties = "multi-crit")
  instance = MAKE_INST(objective = OBJ_2D_2D_DT, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, seq_len(10))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id", "y1", "y2"))
  expect_numeric(archive$data$y1, any.missing = FALSE)
  expect_numeric(archive$data$y2, any.missing = FALSE)
})


test_that("asynchronous evaluation on separate workers of a single-crit 1D function with dt shortcut works", {
  FUN_1D_DT = function(xdt) {
    data.table(y = as.numeric(xdt$x)^2)
  }
  OBJ_1D_DT = ObjectiveRFunDt$new(fun = FUN_1D_DT, domain = PS_1D_domain, properties = "single-crit")
  instance = MAKE_INST(objective = OBJ_1D_DT, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = FALSE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 6)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, rep(1, 10))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[10]]))
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on separate workers of a single-crit 2D function with dt shortcut works", {
  FUN_2D_DT = function(xdt) {
    pmap_dtr(xdt, function(x1, x2) data.table(y = x1^2 + x2^2))
  }
  OBJ_2D_DT = ObjectiveRFunDt$new(fun = FUN_2D_DT, domain = PS_2D_domain, properties = "single-crit")
  instance = MAKE_INST(objective = OBJ_2D_DT, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = FALSE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, rep(1, 10))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[10]]))
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y, any.missing = FALSE)
})

test_that("asynchronous evaluation on separate workers of a multi-crit 2D function with dt shortcut works", {
  FUN_2D_2D_DT = function(xdt) {
    pmap_dtr(xdt, function(x1, x2) data.table(y1 = x1^2, y2 = x2^2))
  }
  OBJ_2D_2D_DT = ObjectiveRFunDt$new(fun = FUN_2D_2D_DT, domain = PS_2D, codomain = FUN_2D_2D_CODOMAIN, properties = "multi-crit")
  instance = MAKE_INST(objective = OBJ_2D_2D_DT, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = FALSE), nrows = 10)

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, rep(1, 10))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[10]]))
  expect_equal(archive$data$status, rep("in_progress", 10))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "promise", "resolve_id", "y1", "y2"))
  expect_numeric(archive$data$y1, any.missing = FALSE)
  expect_numeric(archive$data$y2, any.missing = FALSE)
})

test_that("asynchronous and sequential evaluations results are consistent", {
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive
  archive$add_evals(xdt, status = "proposed")
    expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)
  instance$archive$resolve_promise()

  res_async = instance$archive$data$y

  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  archive = instance$archive
  archive$add_evals(xdt, status = "proposed")
  instance$eval_proposed(async = FALSE, single_worker = TRUE)

  res_seq = instance$archive$data$y

  expect_equal(res_async, res_seq)
})

test_that("asynchronous and sequential evaluations with shortcut results are consistent", {
  FUN_1D_DT = function(xdt) {
    data.table(y = as.numeric(xdt$x)^2)
  }
  OBJ_1D_DT = ObjectiveRFunDt$new(fun = FUN_1D_DT, domain = PS_1D_domain, properties = "single-crit")
  instance = MAKE_INST(objective = OBJ_1D_DT, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive
  archive$add_evals(xdt, status = "proposed")
    expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrows = 10)
  instance$archive$resolve_promise()

  res_async = instance$archive$data$y

  instance = MAKE_INST(objective = OBJ_1D_DT, search_space = PS_1D, terminator = 100L)
  archive = instance$archive
  archive$add_evals(xdt, status = "proposed")
  instance$eval_proposed(async = FALSE, single_worker = TRUE)

  res_seq = instance$archive$data$y

  expect_equal(res_async, res_seq)
})
