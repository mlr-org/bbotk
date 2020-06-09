#' @title Optimizer
#'
#' @description
#' Abstract `Optimizer` class that implements the base functionality each
#' `Optimizer` subclass must provide. A `Optimizer` object describes the
#' optimization strategy.
#'
#' A `Optimizer` object must write its result to the `$assign_result()` method
#' of the [OptimInstance] at the end in order to store the best point  and its
#' estimated performance vector.
#'
#' @section Technical details:
#'
#' In order to replace the default logging messages with custom logging, the
#' `.log_*` private methods can be overwritten in an `Optimizer` subclass:
#'
#' * `$.log_optimize_start()` Called at the beginning of `$optimize()`
#' * `$.log_optimize_finish()` Called at the end of `$optimize()`
#'
#' @export
Optimizer = R6Class("Optimizer",
  public = list(

    #' @field param_set ([paradox::ParamSet]).
    param_set = NULL,

    #' @field param_classes (`character()`).
    param_classes = NULL,

    #' @field properties (`character()`).
    properties = NULL,

    #' @field packages (`character()`).
    packages = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param param_set ([paradox::ParamSet]).
    #' @param param_classes (`character()`).
    #' @param properties (`character()`).
    #' @param packages (`character()`).
    initialize = function(param_set, param_classes, properties,
      packages = character(0)) {
      self$param_set = assert_param_set(param_set)
      self$param_classes = assert_subset(param_classes,
        c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      self$properties = assert_subset(properties, bbotk_reflections$optimizer_properties)
      self$packages = assert_set(packages)
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Print method.
    #' @return (`character()`).
    print = function() {
      catf(format(self))
      catf(str_indent("* Parameters:", as_short_string(self$param_set$values)))
      catf(str_indent("* Parameter classes:", self$param_classes))
      catf(str_indent("* Properties:", self$properties))
      catf(str_indent("* Packages:", self$packages))
    },

    #' @description
    #' Performs the optimization and writes optimization result into [OptimInstance].
    #'
    #' @param inst ([OptimInstance]).
    #' @return NULL
    optimize = function(inst) {

      assert_r6(inst, "OptimInstance")
      require_namespaces(self$packages, "Packages for the Optimization")
      # check dependencies
      if ("dependencies" %nin% self$properties && inst$search_space$has_deps) {
        stopf(
          "Tuner '%s' does not support param sets with dependencies!",
          self$format())
      }
      # check supported parameter class
      not_supported_pclasses = setdiff(
        unique(inst$search_space$class),
        self$param_classes)
      if (length(not_supported_pclasses) > 0L) {
        stopf(
          "Optimizer '%s' does not support param types: '%s'", class(self)[1L],
          paste0(not_supported_pclasses, collapse = ","))
      }
      private$.log_optimize_start(inst)
      tryCatch({
        private$.optimize(inst)
      }, terminated_error = function(cond) { })
      private$.assign_result(inst)
      private$.log_optimize_finish(inst)
      invisible(NULL)
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      assert_r6(inst, "OptimInstance")
      res = inst$archive$get_best()

      xdt = res[, inst$search_space$ids(), with = FALSE]

      if(inst$objective$codomain$length > 1) {
        y = res[, inst$objective$codomain$ids(), with = FALSE]
      } else {
        y = unlist(res[, inst$objective$codomain$ids(), with = FALSE]) # unlist keeps name!
      }

      inst$assign_result(xdt, y)
      invisible(NULL)
    },

    .log_optimize_start = function(inst) {
      lg$info("Starting to optimize %i parameter(s) with '%s' and '%s'",
        inst$search_space$length, self$format(), inst$terminator$format())
    },

    .log_optimize_finish = function(inst) {
      lg$info("Finished optimizing after %i evaluation(s)",
        inst$archive$n_evals)
      lg$info("Result:")
      lg$info(capture.output(print(
        inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
    }
  )
)
