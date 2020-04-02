context("Objective")

test_that("Objective works", {
  ObjectiveTestEval = R6Class("ObjectiveTestEval",
    inherit = Objective,
    public = list(
      eval = function(xs) list(y = sum(as.numeric(xs))^2)
    )
  )
  obj = ObjectiveTestEval$new(domain = PS_2D)
  xs = list(x1=1, x2=2)
  res1 = obj$eval(xs)
  expect_list(res1)
  res_2 = obj$eval_many(replicate(10, xs, simplify = FALSE))
  expect_data_table(res_2)
}

