context("test_sugar")

test_that("sugar", {
  expect_class(trm("clock_time"), "Terminator")
  expect_class(trms(c("clock_time", "evals")), "list")
  expect_class(opt("random_search"), "Optimizer")
  expect_class(opts(c("random_search", "random_search")), "list")
})
