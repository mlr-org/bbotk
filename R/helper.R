terminated_error = function(optim_instance) {
  msg = sprintf(
    fmt = "Objective (obj:%s, term:%s) terminated",
    optim_instance$objective$id,
    format(optim_instance$terminator)
  )

  set_class(list(message = msg, call = NULL),
    c("terminated_error", "error", "condition"))
}

#' @title Calculate which points are dominated
#' @description
#' Calculates which points are not dominated,
#' i.e. points that belong to the Pareto front.
#'
#' @param ymat (`matrix()`) \cr
#'   A numeric matrix. Each column (!) contains one point.
#' @useDynLib bbotk c_is_dominated
#' @export
is_dominated = function(ymat) {
  assert_matrix(ymat, mode = "double")
  .Call(c_is_dominated, ymat, PACKAGE = "bbotk")
}

#' @title Calculates the transformed x-values
#' @description
#' Transforms a given `data.table` to a list with transformed x values.
#' If no trafo is defined it will just convert the `data.table` to a list.
#' Mainly for internal usage.
#'
#' @template param_xdt
#' @template param_search_space
#' @value `list()`
#' @keywords internal
#' @export
transform_xdt_to_xss = function(xdt, search_space) {
  design = Design$new(
    search_space,
    xdt[, search_space$ids(), with = FALSE],
    remove_dupl = FALSE
  )
  design$transpose(trafo = TRUE, filter_na = TRUE)
}

#' @title Default optimization function
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#'
#' @keywords internal
#' @export
optimize_default = function(inst, self, private) {

  assert_instance_properties(self, inst)
  inst$archive$start_time = Sys.time()
  # start optimization
  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s'",
    inst$search_space$length, self$format(), inst$terminator$format())
  tryCatch({
    private$.optimize(inst)
  }, terminated_error = function(cond) {
  })
  private$.assign_result(inst)
  lg$info("Finished optimizing after %i evaluation(s)",
    inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(
    inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  invisible(NULL)
}

#' @title Default assign_result function
#'
#' @param inst [OptimInstance]
#'
#' @keywords internal
#' @export
assign_result_default = function(inst) {
  res = inst$archive$best()

  xdt = res[, inst$search_space$ids(), with = FALSE]

  if (inherits(inst, "OptimInstanceMultiCrit")) {
    ydt = res[, inst$objective$codomain$ids(), with = FALSE]
    inst$assign_result(xdt, ydt)
  } else {
    # unlist keeps name!
    y = unlist(res[, inst$objective$codomain$ids(), with = FALSE])
    inst$assign_result(xdt, y)
  }

  invisible(NULL)
}
