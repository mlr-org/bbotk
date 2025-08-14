#' @title Optimizer
#'
#' @include mlr_optimizers.R
#'
#' @description
#' The `Optimizer` implements the optimization algorithm.
#'
#' @details
#' `Optimizer` is an abstract base class that implements the base functionality each optimizer must provide.
#' A `Optimizer` object describes the optimization strategy.
#' A `Optimizer` object must write its result to the `$assign_result()` method of the [OptimInstance] at the end in order to store the best point and its estimated performance vector.
#'
#' @template section_progress_bars
#'
#' @template field_param_set
#' @template field_label
#' @template field_man
#'
#' @template param_id
#' @template param_param_set
#' @template param_label
#' @template param_man
#'
#' @export
Optimizer = R6Class("Optimizer",
  inherit = Mlr3Component,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param id (`character(1)`)\cr
    #'   Dictionary entry of the optimizer.
    #'
    #' @param param_set ([paradox::ParamSet])\cr
    #'   Parameter set of the optimizer.
    #'
    #' @param param_classes (`character()`)\cr
    #'   Supported parameter classes that the optimizer can optimize, as given in the [`paradox::ParamSet`] `$class` field.
    #'
    #' @param properties (`character()`)\cr
    #'   Set of properties of the optimizer.
    #'   Must be a subset of [`bbotk_reflections$optimizer_properties`][bbotk_reflections].
    #'
    #' @param packages (`character()`)\cr
    #'   Set of required packages.
    #'   A warning is signaled by the constructor if at least one of the packages is not installed, but loaded (not attached) later on-demand via [requireNamespace()].
    initialize = function(
      id,
      param_set,
      param_classes,
      properties,
      packages = character(0),
      label,
      man
    ) {
      if (!missing(label) || !missing(man)) {
        deprecated_component("label and man are deprecated for Optimizer construction and will be removed in the future.")
      }

      super$initialize(dict_entry = id, dict_shortaccess = "opt",
        param_set = param_set, packages = packages, properties = properties
      )
      private$.param_classes = assert_subset(param_classes, c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct", "ParamUty"))
      # has to have at least multi-crit or single-crit property
      assert_subset(properties, bbotk_reflections$optimizer_properties, empty.ok = FALSE)
    },

    #' @description
    #' Print method.
    #'
    #' @return (`character()`).
    print = function() {
      msg_h = if (is.na(self$label)) "" else paste0(" - ", self$label)
      msg_params = cli_vec(lapply(self$param_classes, function(cls) format_inline('{.cls {cls}}')),
                          style = list(last = ' and ', sep = ', '))

      cat_cli({
        cli_h1("{.cls {class(self)[1L]}}{msg_h}")
        cli_li("Parameters: {.args {as_short_string(self$param_set$values)}}")
        cli_li("Parameter classes: {msg_params}")
        cli_li("Properties: {self$properties}")
        cli_li("Packages: {.pkg {self$packages}}")
      })
    }
  ),

  active = list(
    #' @field param_classes (`character()`)\cr
    #'   Supported parameter classes that the optimizer can optimize, as given in the [`paradox::ParamSet`] `$class` field.
    param_classes = function(rhs) {
      if (!missing(rhs) && !identical(rhs, private$.param_classes)) {
        stop("$param_classes is read-only.")
      }
      private$.param_classes
    }
  ),

  private = list(
    .optimize = function(inst) stop("abstract"),

    .assign_result = function(inst) {
      assign_result_default(inst)
    },

    .param_classes = NULL
  )
)

#' @title Default Assign Result Function
#'
#' @description
#' Used internally in the [Optimizer].
#' It is the default way to determine the result by simply obtaining the best performing result from the archive.
#'
#' @param inst [OptimInstance]
#'
#' @keywords internal
#' @export
assign_result_default = function(inst) {
  assert_r6(inst, "OptimInstance")

  xydt = inst$archive$best()
  cols_x = inst$archive$cols_x
  cols_y = inst$archive$cols_y

  xdt = xydt[, cols_x, with = FALSE]
  extra = xydt[, !c(cols_x, cols_y), with = FALSE]

  if (inherits(inst, "OptimInstanceBatchMultiCrit") || inherits(inst, "OptimInstanceAsyncMultiCrit")) {
    ydt = xydt[, inst$archive$cols_y, with = FALSE]
    inst$assign_result(xdt, ydt, extra = extra)
  } else {
    # unlist keeps name!
    y = unlist(xydt[, inst$archive$cols_y, with = FALSE])
    inst$assign_result(xdt, y, extra = extra)
  }

  invisible(NULL)
}
