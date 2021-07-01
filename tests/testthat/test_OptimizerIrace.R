test_that("OptimizerIrace works", {
  skip_if_not_installed("irace")

  search_space = domain = ps(
    x1 = p_dbl(-5, 10),
    x2 = p_dbl(0, 15)
  )
  
  ObjectiveIrace = R6Class("ObjectiveIrace", inherit = Objective,
    public = list(
      irace_instance = NULL
    ),

    private = list(
      .eval_many = function(xss) {
        # branin function with `tau` noise 
        a = 1
        b = 5.1 / (4 * (pi ^ 2))
        c = 5 / pi
        r = 6
        s = 10
        t = 1 / (8 * pi)
        t0 = Sys.time()

        data.table(y = mapply(function(xs, tau) {
          a * ((xs$x2 -
          b * (xs$x1 ^ 2) +
          c * xs$x1 - r) ^ 2) +
          ((s * (1 - t)) * cos(xs$x1)) +
          tau
        }, xss, self$irace_instance),
        time = as.numeric(difftime(Sys.time(), t0, units = "secs")))
      }
    )
  )

  codomain = ps(y = p_dbl(tags = "minimize"))
  objective = ObjectiveIrace$new(domain = domain,  codomain = codomain)
  
  instance = OptimInstanceSingleCrit$new(
    objective = objective,
    search_space = search_space,
    terminator = trm("evals", n_evals = 96))
  
  irace_instance = rnorm(10, mean = 0, sd = 0.1)
  optimizer = opt("irace", instances = irace_instance)
  optimizer$optimize(instance)

  a = instance$archive$data
  expect_subset(c("id_configuration", "id_instance"), names(a))

  # check for mean performance
  expect_equal(instance$result$y, mean(a[id_configuration == instance$result$id_configuration,]$y))
})