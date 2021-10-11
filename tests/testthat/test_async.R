test_that("async with batch on single worker", {

  # single-crit 1D function
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(async = TRUE, single_worker = TRUE)

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
  expect_numeric(archive$data$y)

  # single-crit 2D function
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(async = TRUE, single_worker = TRUE)

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
  expect_numeric(archive$data$y)

  # multi-crit 2D function
  instance = MAKE_INST(objective = OBJ_2D_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(async = TRUE, single_worker = TRUE)

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
  expect_numeric(archive$data$y1)
  expect_numeric(archive$data$y2)

  # evaluated and unevaluated points
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  instance$eval_batch(xdt)
  archive = instance$archive

  xdt = generate_design_random(PS_2D, 10)$data
  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, nrows = 20, ncols = 7)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "y", "x_domain", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, c(rep("evaluated", 10), rep("proposed", 10)))

  instance$eval_proposed(async = TRUE, single_worker = TRUE)

  expect_data_table(archive$data, nrows = 20, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "y", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, c(rep(NA, 10), seq_len(10)))
  expect_identical(archive$data$promise[[1]], archive$data$promise[[10]])
  expect_equal(archive$data$status, c(rep("evaluated", 10),rep("in_progress", 10)))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, nrows = 20, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y)

  # empty archive
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  expect_invisible(instance$eval_proposed(async = TRUE, single_worker = TRUE))
  expect_data_table(instance$eval_proposed(async = TRUE, single_worker = TRUE), nrow = 0)
})

test_that("async with points on separate workers", {

  # single-crit 1D function
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(async = TRUE, single_worker = FALSE)

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
  expect_numeric(archive$data$y)

  # single-crit 2D function
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(async = TRUE, single_worker = FALSE)

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
  expect_numeric(archive$data$y)

  # multi-crit 2D function
  instance = MAKE_INST(objective = OBJ_2D_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 5)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(async = TRUE, single_worker = FALSE)

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
  expect_numeric(archive$data$y1)
  expect_numeric(archive$data$y2)

  # evaluated and unevaluated points
  instance = MAKE_INST(objective = OBJ_2D, search_space = PS_2D, terminator = 100L)
  xdt = generate_design_random(PS_2D, 10)$data
  instance$eval_batch(xdt)
  archive = instance$archive

  xdt = generate_design_random(PS_2D, 10)$data
  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, nrows = 20, ncols = 7)
  expect_names(colnames(archive$data), permutation.of = c("x1", "x2", "y", "x_domain", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, c(rep("evaluated", 10), rep("proposed", 10)))

  instance$eval_proposed(async = TRUE, single_worker = FALSE)

  expect_data_table(archive$data, nrows = 20, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "y", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, c(rep(NA, 10), rep(1, 10)))
  expect_true(!identical(archive$data$promise[[11]], archive$data$promise[[20]]))
  expect_equal(archive$data$status, c(rep("evaluated", 10), rep("in_progress", 10)))

  instance$archive$resolve_promise()

  expect_data_table(archive$data, nrows = 20, ncols = 9)
  expect_names(colnames(archive$data),
    permutation.of = c("x1", "x2", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y)

  # specified rows
  instance = MAKE_INST(objective = OBJ_1D, search_space = PS_1D, terminator = 100L)
  xdt = generate_design_random(PS_1D, 10)$data
  archive = instance$archive

  archive$add_evals(xdt, status = "proposed")

  expect_data_table(archive$data, any.missing = FALSE, nrows = 10, ncols = 4)
  expect_names(colnames(archive$data), permutation.of = c("x", "timestamp", "batch_nr", "status"))
  expect_equal(archive$data$status, rep("proposed", 10))

  instance$eval_proposed(i = seq(5), async = TRUE, single_worker = FALSE)
  expect_error(instance$eval_proposed(i = 20:30, async = TRUE, single_worker = FALSE),
    "Assertion on 'i' failed: Must be a subset of")

  expect_data_table(archive$data, nrows = 10, ncols = 7)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id"))
  expect_equal(archive$data$resolve_id, c(rep(1, 5), rep(NA, 5)))
  expect_true(!identical(archive$data$promise[[1]], archive$data$promise[[5]]))
  expect_equal(archive$data$status, c(rep("in_progress", 5), rep("proposed", 5)))

  instance$archive$resolve_promise(i = seq(5))

  expect_data_table(archive$data, nrows = 10, ncols = 8)
  expect_names(colnames(archive$data),
    permutation.of = c("x", "timestamp", "batch_nr", "status", "x_domain", "promise", "resolve_id", "y"))
  expect_numeric(archive$data$y)
  expect_equal(archive$data$status, c(rep("evaluated", 5), rep("proposed", 5)))
})
