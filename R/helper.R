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
#' Returns which points from a set are dominated by another point in the set.
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
#' Transforms a given `data.table()` to a list with transformed x values.
#' If no trafo is defined it will just convert the `data.table()` to a list.
#' Mainly for internal usage.
#'
#' @template param_xdt
#' @template param_search_space
#' @return `list()`.
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
#' @description
#' Used internally in the [Optimizer].
#' Brings together the private `.optimize()` method and the private `.assign_result()` method.
#'
#' @param inst [OptimInstance]
#' @param self [Optimizer]
#' @param private (`environment()`)
#'
#' @return [data.table::data.table]
#'
#' @keywords internal
#' @export
optimize_default = function(inst, self, private) {
  assert_instance_properties(self, inst)
  inst$archive$start_time = Sys.time()
  if (isNamespaceLoaded("progressr")) {
    # initialize progressor
    # progressor must be initialized here because progressor finishes when exiting a function since version 0.7.0
    max_steps = assert_int(inst$terminator$status(inst$archive)["max_steps"])
    unit = assert_character(inst$terminator$unit)
    progressor = progressr::progressor(steps = max_steps)
    inst$progressor = Progressor$new(progressor, unit)
    inst$progressor$max_steps = max_steps
  }

  # start optimization
  lg$info("Starting to optimize %i parameter(s) with '%s' and '%s'",
    inst$search_space$length, self$format(), inst$terminator$format(with_params = TRUE))
  tryCatch({
    private$.optimize(inst)
  }, terminated_error = function(cond) {
  })
  private$.assign_result(inst)
  lg$info("Finished optimizing after %i evaluation(s)", inst$archive$n_evals)
  lg$info("Result:")
  lg$info(capture.output(print(
    inst$result, lass = FALSE, row.names = FALSE, print.keys = FALSE)))
  return(inst$result)
}

#' @title Default assign_result function
#' @description
#' Used internally in the [Optimizer].
#' It is the default way to determine the result by simply obtaining the best performing result from the archive.
#'
#' @param inst [OptimInstance]
#'
#' @keywords internal
#' @export
assign_result_default = function(inst) {
  res = inst$archive$best()

  xdt = res[, inst$search_space$ids(), with = FALSE]

  if (inherits(inst, "OptimInstanceMultiCrit")) {
    ydt = res[, inst$archive$cols_y, with = FALSE]
    inst$assign_result(xdt, ydt)
  } else {
    # unlist keeps name!
    y = unlist(res[, inst$archive$cols_y, with = FALSE])
    inst$assign_result(xdt, y)
  }

  invisible(NULL)
}

get_private = function(x) {
  x[[".__enclos_env__"]][["private"]]
}

#' @title Get start values for optimizers
#'
#' @description
#' Returns a named numeric vector with start
#' values for optimizers.
#'
#' @param search_space [ParamSet].
#' @param type (`character(1)`)\cr
#' `random` start values or `center` of search space?
#'
#' @return named 'numeric()'
#'
#' @keywords internal
search_start = function(search_space, type = "random") {
  assert_choice(type, c("random", "center"))
  if (type == "random") {
    unlist(generate_design_random(search_space, 1)$data[1, ])
  } else if (type == "center") {
    if (!all(search_space$storage_type == "numeric")) {
      stop("Cannot generate center values of non-numeric parameters.")
    }
    (search_space$upper + search_space$lower) / 2
  }
}

#' @title Branin Function
#'
#' @description
#' Augmented 2-D Branin function with fidelity parameter.
#'
#' @source
#' `r format_bib("wu_2019")`
#'
#' @param xs
#'   List with the input for a single point
#'   (e.g. `list(x1 = 1, x2 = 2, fidelity = 0.5)`).
#'
#' @return `list(1)`
#'
#' @export
#' @examples
#' branin(list(x1 = 12, x2 = 2, fidelity = 1))
branin = function(xs) {
  list(y = (xs[["x2"]] - ((5.1 / (4 * pi^2)) - 0.1 * (1 - xs[["fidelity"]])) * xs[["x1"]]^2 + (5 / pi) * xs[["x1"]] - 6) ^ 2 +  10 * (1 - (1 / (8 * pi))) * cos(xs[["x1"]]) + 10)
}
