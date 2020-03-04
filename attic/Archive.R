Archive = R6Class("Archive",
  public = list(
    data = NULL,
    domain = NULL,
    codomain = NULL,

    initialize = function(domain, codomain) {
      assert_param_set(domain)
      assert_param_set(codomain)
      self$domain = domain
      self$codomain = codomain
      self$data = data.table()
    },

    add_evals = function(dt) {
      assert_data_table(dt)
      self$data = rbindlist(list(self$data, dt), fill = TRUE, use.names = TRUE)
    },

    print = function() {
      catf("Archive:")
      print(self$data)
    }
  ),

  active = list(
    n_evals = function() nrow(self$data),
    cols_x = function() self$domain$ids(),
    cols_y = function() self$codomain$ids()
    # idx_unevaled = function() self$data$y
  ),
)

