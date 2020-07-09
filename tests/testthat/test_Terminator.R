context("Terminator")

test_that("progressr works", {
  terminator = Terminator$new()
  expect_error(terminator$progressr_steps(), "Abstract class")
  expect_error(terminator$progressr_update(), "Abstract class")
})
