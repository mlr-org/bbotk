context("Objective")

test_that("Objective works", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    public = list(
      eval = function(xs) list(y = sum(as.numeric(xs))^2)
    )
  )
  obj = ObjectiveTestEval$new(domain = PS_2D)
  xs = list(x1 = 1, x2 = 2)
  xss = replicate(10, xs, simplify = FALSE)
  res1 = obj$eval(xs)
  expect_list(res1)
  res2 = obj$eval_many(xss)
  expect_data_table(res2)

  ObjectiveTestEvalMany = R6Class("ObjectiveTestEvalMany",
    inherit = Objective,
    public = list(
      eval_many = function(xss) {
        data.table(y = map_dbl(xss, function(xs) sum(as.numeric(xs))^2))
      }
    )
  )
  obj = ObjectiveTestEvalMany$new(domain = PS_2D)
  res1many = obj$eval(xs)
  expect_list(res1many)
  res2many = obj$eval_many(replicate(10, xs, simplify = FALSE))
  expect_data_table(res2many)

  expect_equal(res1, res1many)
  expect_equal(res2, res2many)
})
