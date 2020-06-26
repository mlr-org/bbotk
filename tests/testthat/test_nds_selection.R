context("nds_selection")

data_matrix = matrix(
    c( # front 1
      1, 4,
      2, 3,
      4, 1,
      # front 2
      2.2, 3.2,
      4, 3,
      4.2, 1,
      # front 3
      3, 5,
      3.2, 4.7,
      6, 2,
      # front 4
      6, 6
    ), byrow = FALSE, nrow = 2L
  )

test_that("nds_selection works from archive", {
  tt = term("evals", n_evals = 10)
  inst = OptimInstanceMulticrit$new(objective = OBJ_2D_2D, search_space = PS_2D, terminator = tt)
  optimizer = OptimizerRandomSearch$new()
  optimizer$optimize(inst)
  expect_data_table(inst$result_y, ncols = 2)
  expect_data_table(inst$result_x_search_space)
  expect_data_table(inst$archive$nds_selection(1))

  a = Archive$new(PS_2D, FUN_2D_2D_CODOMAIN)
  ydt = as.data.table(t(data_matrix))
  colnames(ydt) = FUN_2D_2D_CODOMAIN$ids()
  sampler = SamplerUnif$new(param_set = PS_2D)
  xdt = sampler$sample(nrow(ydt))$data
  a$add_evals(xdt, transpose_list(xdt), ydt)
  res = replicate(n = 100, merge(a$nds_selection(1), ydt)$ind)
  expect_set_equal(res, c(1,7,10))
})

test_that("nds_selection basics", {

  # only the hypervolume contribution of the first front elements was manually
  # calculated, so we can only check for membership in each front, but not for
  # the exact truth

  # list of possible results for each n_select value
  results = list(
    "1" = c("1", "2", "3"),
    "2" = c("13", "23"),
    "3" = c("123"),
    "4" = c("1234", "1236"),
    "5" = c("12346", "12356"),
    "6" = c("123456"),
    "7" = c('1234568','1234567','1234569'),
    "8" = c('12345679','12345689','12345678'),
    "9" = c('123456789'),
    "10" = c('12345678910')
  )
  for (i in 1:10) {
    for (j in c(-1, 1)) {
      res = replicate(100, nds_selection(j * data_matrix, i, minimize = (j == 1)), simplify = FALSE)
      res = unique(res)
      res = sapply(res, paste, collapse = "")
      expect_set_equal(res, results[[i]])
    }
  }
})
