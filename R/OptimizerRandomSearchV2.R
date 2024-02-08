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

      # start rush workers
      if (rush_available()) {
        inst$rush$start_workers(
          worker_loop = bbotk_worker_loop_decentralized,
          packages = "bbotk",
          optimizer = self,
          instance = inst,
          lgr_thresholds = c(rush = "debug", bbotk = "debug"),
          wait_for_workers = TRUE)
      } else {
        stop("No rush plan available. See `?rush::rush_plan()`")
      }

      lg$info("Starting to optimize %i parameter(s) with '%s' and '%s' on %i worker(s)",
        inst$search_space$length,
        self$format(),
        inst$terminator$format(with_params = TRUE),
        inst$rush$n_running_workers
      )

      # wait
      while(!inst$is_terminated) {
        Sys.sleep(1)
        inst$rush$detect_lost_workers()
      }

      # assign result
      private$.assign_result(inst)

      # assign result
      private$.assign_result(inst)
      lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
      lg$info("Result:")
      lg$info(capture.output(print(inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
      return(inst$result)

      result
    }
  ),

  private = list(
    .optimize_remote = function(inst) {

      while(!inst$is_terminated) {
        # ask
        sampler = SamplerUnif$new(inst$search_space)
        xdt = sampler$sample(1)$data
        xs = transform_xdt_to_xss(xdt, inst$search_space)[[1]]
        key = inst$rush$push_running_task(list(xs))

        # eval
        ys = inst$objective$eval(xs)

        # tell
        inst$rush$push_results(key, list(ys))
      }
    }
  )
)

mlr_optimizers$add("random_search_v2", OptimizerRandomSearchV2)


