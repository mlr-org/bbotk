test_that("nds_selection works", {
  points = matrix(
    c(# front 1
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

  s1 = list(
    # Point 3 is ommitted first, followed by point 2. Then, 1 or 4 survives randomly.
    list(1L, 4L),
    # Point 3 is ommitted first, followed by point 2. 1 and 4 survive both
    list(c(1L, 4L)),
    # Point 3 is ommited first, so points 1, 2, and 4 survive
    list(c(1L, 2L, 4L)),
    # All points out of front 1 survive
    list(c(1L, 2L, 3L, 4L)),
    # Out of front 2, points 5 is ommitted first, then, either 5 or 7 are sampled randomly
    list(c(1L, 2L, 3L, 4L, 5L), c(1L, 2L, 3L, 4L, 7L)),
    # Out of front 2, points 5 is ommitted first, and 5 and 7 survive
    list(c(1L, 2L, 3L, 4L, 5L, 7L)),
    # Whole front 2 survives
    list(c(1L, 2L, 3L, 4L, 5L, 6L, 7L)),
    # all candidates survive
    list(c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L))
  )

  s2 = map(map(seq_len(8),function(i) replicate(100, nds_selection(points, n_select = i), simplify = FALSE)), unique)

  pmap_lgl(list(s1, s2), function(ss1, ss2) {
    expect_true(all(map_lgl(ss2, function(sss2) {
      any(map_lgl(ss1, function(sss1) {
        identical(sss1, sss2)
    }))
    })))
  })

  # change sign
  s2 = map(map(seq_len(8),function(i) replicate(100, nds_selection(-1 * points, n_select = i, minimize = FALSE), simplify = FALSE)), unique)

  pmap_lgl(list(s1, s2), function(ss1, ss2) {
    expect_true(all(map_lgl(ss2, function(sss2) {
      any(map_lgl(ss1, function(sss1) {
        identical(sss1, sss2)
    }))
    })))
  })

  # changing the sign in one objective will not change the result 
  to_minimize = c(TRUE, FALSE)
  points_max2d = points * (to_minimize * 2 - 1)
  s2 = map(map(seq_len(8),function(i) replicate(100, nds_selection(points_max2d, n_select = i, minimize = to_minimize), simplify = FALSE)), unique)

  pmap_lgl(list(s1, s2), function(ss1, ss2) {
    expect_true(all(map_lgl(ss2, function(sss2) {
      any(map_lgl(ss1, function(sss1) {
        identical(sss1, sss2)
    }))
    })))
  })
})

test_that("nds_selection in Archive works", {
  domain = ps(x1 = p_dbl())
  codomain = ps(
    y1 = p_dbl(tags = "minimize"),
    y2 = p_dbl(tags = "minimize")
  )
  a = Archive$new(domain, codomain)

  xdt = data.table(x1 = as.numeric(seq_len(8)))
  ydt = data.table(
    y1 = c(1, 2, 3.9, 4, 2.2, 4, 4.2, 6),
    y2 = c(4, 2, 1.1, 1, 3.2, 3, 1, 6)
  )

  a$add_evals(xdt, transpose_list(xdt), ydt)

  s1 = list(
    # Point 3 is ommitted first, followed by point 2. Then, 1 or 4 survives randomly.
    list(1, 4),
    # Point 3 is ommitted first, followed by point 2. 1 and 4 survive both
    list(c(1, 4)),
    # Point 3 is ommited first, so points 1, 2, and 4 survive
    list(c(1, 2, 4)),
    # All points out of front 1 survive
    list(c(1, 2, 3, 4)),
    # Out of front 2, points 5 is ommitted first, then, either 5 or 7 are sampled randomly
    list(c(1, 2, 3, 4, 5), c(1, 2, 3, 4, 7)),
    # Out of front 2, points 5 is ommitted first, and 5 and 7 survive
    list(c(1, 2, 3, 4, 5, 7)),
    # Whole front 2 survives
    list(c(1, 2, 3, 4, 5, 6, 7)),
    # all candidates survive
    list(c(1, 2, 3, 4, 5, 6, 7, 8))
  )
  s2 = map(map(seq_len(8),function(i) replicate(100, a$nds_selection(n_select = i)$x1,simplify = FALSE)), unique)

  pmap_lgl(list(s1, s2), function(ss1, ss2) {
    expect_true(all(map_lgl(ss2, function(sss2) {
      any(map_lgl(ss1, function(sss1) {
        identical(sss1, sss2)
    }))
    })))
  })
})
