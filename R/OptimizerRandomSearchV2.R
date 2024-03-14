#' @export
OptimizerRandomSearchV2 = R6Class("OptimizerRandomSearchV2",
  inherit = Optimizer,

  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      super$initialize(
        id = "random_search",
        param_set = ps(),
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        properties = c("dependencies", "single-crit", "multi-crit"),
        label = "Random Search",
        man = "bbotk::mlr_optimizers_random_search"
      )
    },

    optimize = function(inst) {
      inst$archive$start_time = Sys.time()
      optimize_decentralized(inst, self, private)
    }
  ),

  private = list(
    .optimize = function(inst) {
      search_space = inst$search_space
      rush = inst$rush

      while(!inst$is_terminated) {
        # ask
        sampler = SamplerUnif$new(search_space)
        xdt = sampler$sample(1)$data
        xss = transpose_list(xdt)
        xs = xss[[1]][inst$archive$cols_x]
        xs_trafoed = trafo_xs(xs, search_space)
        keys = inst$rush$push_running_task(list(xs), extra = list(list(timestamp_xs = Sys.time())))

        # eval
        ys = inst$objective$eval(xs_trafoed)

        # tell
        rush$push_results(keys, yss = list(ys), extra = list(list(
          x_domain = list(xs_trafoed),
          timestamp_ys = Sys.time())))
      }
    }
  )
)

mlr_optimizers$add("random_search_v2", OptimizerRandomSearchV2)


