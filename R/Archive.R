Archive = R6Class("Archive",
  public = list(
    data = NULL,
    domain = NULL,
    codomain = NULL,

    initialize = function(domain, codomain) {
      self$domain = domain
      self$codomain = codomain
      self$data = data.table()
    },

    add_evals = function(dt) {
      self$data = rbindlist(list(self$data, dt), fill = TRUE, use.names = TRUE)
    },

    print = function() {
      catf("Archive:")
      print(self$data)
    }
  ),

  active = list(
    n_evals = function() nrow(self$data)
    # idx_unevaled = function() self$data$y
  ),
)

