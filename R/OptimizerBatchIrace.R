#' @title Iterated Racing
#'
#' @include Optimizer.R
#' @name mlr_optimizers_irace
#'
#' @description
#' `OptimizerBatchIrace` class that implements iterated racing.
#' Calls [irace::irace()] from package \CRANpkg{irace}.
#'
#' @section Parameters:
#' \describe{
#' \item{`instances`}{`list()`\cr
#'   A list of instances where the configurations executed on.}
#' \item{`targetRunnerParallel`}{`function()`\cr
#'   A function that executes the objective function with a specific parameter configuration and instance.
#'   A default function is provided, see section "Target Runner and Instances".}
#' }
#'
#' For the meaning of all other parameters, see [irace::defaultScenario()].
#'
#' @section Internal Termination Parameters:
#' The algorithm can terminated with [TerminatorEvals].
#' Other [Terminator]s do not work with `OptimizerBatchIrace`.
#' Additionally, the following internal termination parameters can be used:
#'
#' \describe{
#' \item{`maxExperiments`}{`integer(1)`\cr
#'   Maximum number of runs (invocations of targetRunner) that will be performed.
#'   It determines the maximum budget of experiments for the tuning.
#'   Default is 0.}
#' \item{`minExperiments`}{`integer(1)`\cr
#'   Minimum number of runs (invocations of targetRunner) that will be performed.
#'   It determines the minimum budget of experiments for the tuning.
#'   The actual budget depends on the number of parameters and minSurvival.
#'   Default is NA.}
#' \item{`maxTime`}{`integer(1)`\cr
#'   Maximum total execution time for the executions of targetRunner.
#'   targetRunner must return two values: cost and time.
#'   This value and the one returned by targetRunner must use the same units (seconds, minutes, iterations, evaluations, ...).
#'   Default is 0.}
#' \item{`budgetEstimation`}{`numeric(1)`\cr
#'   Fraction (smaller than 1) of the budget used to estimate the mean computation time of a configuration.
#'   Only used when maxTime > 0
#'   Default is 0.05.}
#' \item{`minMeasurableTime`}{`numeric(1)`\cr
#'   Minimum time unit that is still (significantly) measureable.
#'   Default is 0.01.}
#' }
#'
#' @section Initial parameter values:
#' - `digits`:
#'   - Adjusted default: 15.
#'   - This represents double parameters with a higher precision and avoids rounding errors.
#'
#' @section Target Runner and Instances:
#' The irace package uses a `targetRunner` script or R function to evaluate a configuration on a particular instance.
#' Usually it is not necessary to specify a `targetRunner` function when using `OptimizerBatchIrace`.
#' A default function is used that forwards several configurations and instances to the user defined objective function.
#' As usually, the user defined function has  a `xs`, `xss` or `xdt` parameter depending on the used [Objective] class.
#' For irace, the function needs an additional `instances` parameter.
#'
#' ```
#' fun = function(xs, instances) {
#'  # function to evaluate configuration in `xs` on instance `instances`
#' }
#' ```
#'
#' @section Archive:
#' The [Archive] holds the following additional columns:
#'  * `"race"` (`integer(1)`)\cr
#'    Race iteration.
#'  * `"step"` (`integer(1)`)\cr
#'    Step number of race.
#'  * `"instance"` (`integer(1)`)\cr
#'    Identifies instances across races and steps.
#'  * `"configuration"` (`integer(1)`)\cr
#'    Identifies configurations across races and steps.
#'
#' @section Result:
#' The optimization result (`instance$result`) is the best performing elite of the final race.
#' The reported performance is the average performance estimated on all used instances.
#'
#' @templateVar id irace
#' @template section_dictionary_optimizers
#'
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("lopez_2016")`
#'
#' @export
#' @examples
#' # example only runs if irace is available
#' if (mlr3misc::require_namespaces("irace", quietly = TRUE)) {
#' # runtime of the example is too long
#' \donttest{
#' library(data.table)
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-5, 10),
#'   x2 = p_dbl(0, 15)
#' )
#'
#' # set codomain
#' codomain = ps(y = p_dbl(tags = "minimize"))
#'
#' # branin function with noise
#' # the noise generates different instances of the branin function
#' # the noise values are passed via the `instances` parameter
#' fun = function(xdt, instances) {
#'   ys = branin(xdt[["x1"]], xdt[["x2"]], noise = as.numeric(instances))
#'   data.table(y = ys)
#' }
#'
#' # define objective with instances as a constant
#' objective = ObjectiveRFunDt$new(
#'  fun = fun,
#'  domain = domain,
#'  codomain = codomain,
#'  constants = ps(instances = p_uty()))
#'
#' instance = oi(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 96))
#'
#' # create instances of branin function
#' instances = rnorm(10, mean = 0, sd = 0.1)
#'
#' # load optimizer and set branin instances
#' optimizer = opt("irace", instances = instances)
#'
#' # trigger optimization
#' optimizer$optimize(instance)
#'
#' # all evaluated configurations
#' instance$archive
#'
#' # best performing configuration
#' instance$result
#' }
#' }
OptimizerBatchIrace = R6Class("OptimizerBatchIrace",
  inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        instances = p_uty(tags = "required"),
        targetRunnerParallel = p_uty(init = target_runner_default, tags = "required"),
        debugLevel = p_int(default = 0, lower = 0),
        logFile = p_uty(init = tempfile(fileext = ".Rdata")),
        seed = p_int(),
        postselection = p_dbl(default = 0, lower = 0, upper = 1),
        elitist = p_int(default = 1, lower = 0, upper = 1),
        elitistLimit = p_int(default = 2, lower = 0),
        nbIterations = p_int(default = 0, lower = 0),
        nbExperimentsPerIteration = p_int(default = 0, lower = 0),
        minNbSurvival = p_int(default = 0, lower = 0),
        nbConfigurations = p_int(default = 0, lower = 0),
        mu = p_int(default = 5, lower = 1),
        softRestart = p_int(default = 1, lower = 0, upper = 1),
        softRestartThreshold = p_dbl(),
        digits = p_int(lower = 1, upper = 15, init = 15, tags = "required"),
        testType = p_fct(default = "F-test", levels = c("F-test", "t-test", "t-test-bonferroni", "t-test-holm")),
        firstTest = p_int(default = 5, lower = 0),
        eachTest = p_int(default = 1, lower = 1),
        confidence = p_dbl(default = 0.95, lower = 0, upper = 1),
        capping = p_int(default = 0, lower = 0, upper = 1),
        cappingType = p_fct(default = "median", levels = c("median", "mean", "best", "worst")),
        boundType = p_fct(default = "candidate", levels = c("candidate", "instance")),
        boundMax = p_dbl(default = 0),
        boundDigits = p_int(default = 0),
        boundPar = p_dbl(default = 1),
        boundAsTimeout = p_dbl(default = 1),
        deterministic = p_lgl(default = FALSE)
      )

      super$initialize(
        id = "irace",
        param_set = param_set,
        param_classes = c("ParamDbl", "ParamInt", "ParamFct", "ParamLgl"),
        properties = c("dependencies", "single-crit"),
        packages = "irace",
        label = "Iterated Racing",
        man = "bbotk::mlr_optimizers_irace"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      terminator = inst$terminator

      # check terminators
      if (!(inherits(terminator, "TerminatorEvals"))) {
        stopf("%s is not supported. Use <TerminatorEvals> instead.", format(inst$terminator))
      }

      # check for instances constant
      if ("instances" %nin% inst$objective$constants$ids()) {
        inst$objective$constants = c(inst$objective$constants, ps(instances = p_uty()))
      }

      # make scenario
      digits = pv$digits
      pv$digits = NULL

      scenario = list(
        parameters = paradox_to_irace(inst$search_space, pv$digits),
        maxExperiments = terminator$param_set$values$n_evals,
        targetRunnerData = list(inst = inst))
      scenario = insert_named(scenario, pv)

      # run irace
      res = invoke(irace::irace, scenario = scenario, .opts = allow_partial_matching)

      # add race and step to archive
      iraceResults = irace::read_logfile(self$param_set$values$logFile)
      log = iraceResults$state$experiment_log
      log[, "step" := rleid("instance"), by = "iteration"]
      set(inst$archive$data, j = "race", value = log$iteration)
      set(inst$archive$data, j = "step", value = log$step)
      setcolorder(inst$archive$data, c(inst$archive$cols_x, inst$archive$cols_y, "race", "step", "instance", "configuration"))

      # temporarily store best elite of final race
      private$.result_id = res$.ID.[1]
    },

    # the final configurations returned by irace are the elites of the final race
    # we store the best performing one
    # the reported performance value is the average of all resampling iterations
    .assign_result = function(inst) {
      if (length(private$.result_id) == 0) {
        stop("`irace::irace` did not return a result. The evaluated configurations are still accessible through the archive.")
      }

      res = inst$archive$data[get("configuration") == private$.result_id, ]
      cols_x = c(inst$archive$cols_x, "configuration")
      cols_y = inst$archive$cols_y
      xdt = res[1, cols_x, with = FALSE]
      y = set_names(mean(unlist(res[, cols_y, with = FALSE])), cols_y)
      extra = res[, !c(cols_x, cols_y), with = FALSE]

      inst$assign_result(xdt, y, extra = extra)
    },

    .result_id = NULL
  )
)

mlr_optimizers$add("irace", OptimizerBatchIrace)

target_runner_default = function(experiment, exec_target_runner, scenario, target_runner) { # nolint
  optim_instance = scenario$targetRunnerData$inst

  xdt = map_dtr(experiment, function(e) {
    configuration = as.data.table(e$configuration)
    # add configuration and instance id to archive
    set(configuration, j = "configuration", value = e$id_configuration)
    set(configuration, j = "instance", value = e$id_instance)
    configuration
  })
  # fix logicals
  lgl_params = as.data.table(optim_instance$search_space)[class == "ParamLgl", "id"][[1]]
  if (length(lgl_params)) xdt[, (lgl_params) := lapply(.SD, as.logical), .SDcols = lgl_params]

  # provide experiment instances to objective
  optim_instance$objective$constants$values$instances = map(experiment, function(e) e$instance)

  # evaluate configuration
  res = optim_instance$eval_batch(xdt)

  # return cost (minimize) and dummy time to irace
  map(transpose_list(res), function(cost) {
    list(cost = unlist(cost) * optim_instance$objective_multiplicator, time = NA_real_)
  })
}

paradox_to_irace = function(param_set, digits) {
  assertClass(param_set, "ParamSet")
  # workaround for mlr3tuning 0.15.0
  digits = assert_int(digits %??% 15, lower = 0)
  if ("ParamUty" %in% param_set$class) stop("<ParamUty> not supported by <OptimizerBatchIrace>")

  # types
  paradox_types = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct")
  irace_types = c("c", "i", "r", "c")
  types = irace_types[match(param_set$class, paradox_types)]

  # range
  range = pmap_chr(list(param_set$lower, param_set$upper, param_set$levels), function(lower, upper, levels, ...) {
    if (is.null(levels)) {
      paste0("(", lower, ",", upper, ")")
    } else {
      paste0("(", paste0(levels, collapse = ","), ")")
    }
  })

  # dependencies
  deps = if (param_set$has_deps) {
    deps = pmap_dtr(param_set$deps, function(id, on, cond) {
      rhs = if (is.character(cond$rhs)) sQuote(cond$rhs, q = FALSE) else cond$rhs
      cond = if (test_class(cond, "CondEqual")) {
        paste(on, "==", rhs)
      } else {
        paste(on, "%in%", paste0("c(", paste0(rhs, collapse = ","), ")"))
      }
      data.table(id = id, cond = cond)
    })

    # reduce to one row per parameter
    deps = deps[, list("cond" =  paste(get("cond"), collapse = " & ")), by = "id"]

    # add parameters without dependency
    deps[, "cond" := paste("|", get("cond"))]
    deps = merge(data.table(id = param_set$ids(), by = "id"), deps, all.x = TRUE, sort = FALSE)
    deps[is.na(get("cond")), "cond" := ""]
  } else {
    NULL
  }

  irace::readParameters(text = paste(param_set$ids(), '""', types, range, deps$cond, collapse = "\n"), digits = digits)
}
