test_that("nds_selection works", {
  points = matrix(
    c( # front 1
      # emoa puts always Inf weight on boundary points, so they always survive 
      # points 1 and points 4 have the highest hypervolume contributions 
      1, 4, 
      2, 2, 
      3.9, 1.1, 
      4, 1, 
      # front 2
      # points 5 and points 7 have the highest hypervolume contributions as boundary points
      2.2, 3.2, 
      4, 3,
      4.2, 1,
      # front 3
      6, 6
    ), byrow = FALSE, nrow = 2L
  )

  # list of possible results for each n_select value
  results = list(
    # Point 3 is ommitted first, followed by point 2. Then, 1 or 4 survives randomly.
    "1" = c("1", "4"), 
    # Point 3 is ommitted first, followed by point 2. 1 and 4 survive both.
    "2" = "14",
    # Point 3 is ommited first, so points 1, 2, and 4 survive
    "3" = "124",
    # All points out of front 1 survive
    "4" = "1234",
    # Out of front 2, points 5 is ommitted first, then, either 5 or 7 are sampled randomly
    "5" = c("12345", "12347"),
    # Out of front 2, points 5 is ommitted first, and 5 and 7 survive
    "6" = "123457",
    # Whole front 2 survives
    "7" = "1234567",
    # all candidates survive
    "8" = "12345678"
    )

  for (i in 1:8) {
    for (j in c(-1, 1)) {
      res = replicate(100, nds_selection(j * points, i, minimize = (j == 1)), simplify = FALSE)
      res = sapply(res, paste, collapse = "")
      res = unique(res)
      expect_set_equal(res, results[[i]])
    }
  }

  # changing the sign in one objective will not change the result 
  to_minimize = c(TRUE, FALSE) 
  points_max2d = points * (to_minimize * 2 - 1)

  for (i in 1:8) {
      res = replicate(100, nds_selection(points_max2d, i, minimize = to_minimize), simplify = FALSE)
      res = sapply(res, paste, collapse = "")
      res = unique(res)
      expect_set_equal(res, results[[i]])
  }
})
