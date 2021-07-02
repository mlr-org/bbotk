#' @title Optimization via Iterated Racing
#'
#' @include Optimizer.R
#' @name mlr_optimizers_irace
#'
#' @description
#' `OptimizerIrace` class that implements iterated racing. Calls
#' [irace::irace()] from package \CRANpkg{irace}.
#'  
#' @section Parameters:
#' \describe{
#' \item{`instances`}{`list()`\cr
#' A list of instances where the target algorithm is executed on.}
#' \item{`targetRunner`}{`function()`\cr
#' A function that executes the target algorithm with a specific parameter configuration and instance.}
#' }
#'
#' For the meaning of all other parameters, see [irace::defaultScenario()]. Note
#' that we have removed all control parameters which refer to the termination of
#' the algorithm. Use [TerminatorEvals] instead. Other terminators do not work
#' with `OptimizerIrace`.
#' 
#' @section Target Runner and Instances:
#' The irace package uses a `targetRunner` script or R function to evaluate a
#' configuration on a particular instance. Usually it is not necessary to
#' specify a `targetRunner` function when using `OptimizerIrace`. A default
#' function is used that forwards several configurations and an instance to the
#' user defined objective function. As usual, the configurations are passed in
#' `xss` to the objective. The instance passed via the `$irace_instance`
#' public field. 
#' 
#' ```
#' ObjectiveIrace = R6Class("ObjectiveIrace", inherit = Objective,
#'   public = list(
#'     irace_instance = NULL
#'   ),
#' 
#'   private = list(
#'     .eval_many = function(xss) {
#'       # objective function to evaluate configurations in xss
#'       # access irace instance via self$irace_instance
#'     }
#'   )
#' )
#' ```
#' 
#' Alternatively, `$.eval(xs)` can be implemented which only passes one
#' configuration at once. The use of `$.eval_many(xss)` allows us to implement
#' a parallelization e.g. with the \CRANpkg{future} package.
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
#' The optimization result (`instance$result`) is the best performing elite of
#' the final race. The reported performance is the average performance estimated
#' on all used instances.
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
#' library(data.table)
#' library(R6)
#' 
#' search_space = domain = ps(
#'   x1 = p_dbl(-5, 10),
#'   x2 = p_dbl(0, 15)
#' )
#' 
#' ObjectiveIrace = R6Class("ObjectiveIrace", inherit = Objective,
#'   public = list(
#'     irace_instance = NULL
#'   ),
#' 
#'   private = list(
#'     .eval_many = function(xss) {
#'       # branin function with `tau` noise 
#'       a = 1
#'       b = 5.1 / (4 * (pi ^ 2))
#'       c = 5 / pi
#'       r = 6
#'       s = 10
#'       t = 1 / (8 * pi)
#'  
#'       data.table(y = mapply(function(xs, tau) {
#'        a * ((xs$x2 -
#'        b * (xs$x1 ^ 2) +
#'        c * xs$x1 - r) ^ 2) +
#'        ((s * (1 - t)) * cos(xs$x1)) +
#'        tau
#'       }, xss, self$irace_instance))
#'     }
#'   )
#' )
#' 
#' codomain = ps(y = p_dbl(tags = "minimize"))
#' objective = ObjectiveIrace$new(domain = domain,  codomain = codomain)
#' 
#' instance = OptimInstanceSingleCrit$new(
#'   objective = objective,
#'   search_space = search_space,
#'   terminator = trm("evals", n_evals = 1000))
#' 
#' # create instances of branin function
#' irace_instance = rnorm(10, mean = 0, sd = 0.1)
#' optimizer = opt("irace", instances = irace_instance)
#' 
#' # modifies the instance by reference
#' optimizer$optimize(instance)
#' 
#' # best scoring evaluation
#' instance$result
#' 
#' # all evaluations
#' as.data.table(instance$archive)
OptimizerIrace = R6Class("OptimizerIrace",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        instances = p_uty(tags = "required"),
        targetRunnerParallel = p_uty(tags = "required"),
        debugLevel = p_int(default = 0, lower = 0),
        logFile = p_uty(),
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
        digits = p_int(default = 4, lower = 1, upper = 15),
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
      param_set$values$debugLevel = 0
      param_set$values$logFile = tempfile(fileext = ".Rdata")
      param_set$values$targetRunnerParallel = target_runner_default

      super$initialize(
       param_set = param_set,
        param_classes = c("ParamDbl", "ParamInt", "ParamFct", "ParamLgl"),
        properties = c("dependencies", "single-crit"),
        packages = "irace"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pv = self$param_set$values
      terminator = inst$terminator

      # Check terminators 
      if (!(inherits(terminator, "TerminatorEvals"))) {
        stopf("%s is not supported. Use <TerminatorEvals> instead.", format(inst$terminator))
      }

      # Make scenario
      scenario = c(list(
        maxExperiments = terminator$param_set$values$n_evals,
        targetRunnerData = list(inst = inst)
      ), pv)

      res = irace::irace(scenario = scenario, parameters = paradox_to_irace(inst$search_space))

      # add race and step to archive
      iraceResults = NULL
      load(self$param_set$values$logFile) 
      log = as.data.table(iraceResults$experimentLog)
      log[, "step" := rleid("instance"), by = "iteration"]
      set(inst$archive$data, j = "race", value = log$iteration)
      set(inst$archive$data, j = "step", value = log$step)
      setcolorder(inst$archive$data, c(inst$archive$cols_x, inst$archive$cols_y, "race", "step", "instance", "configuration"))

      # Temporarily store result
      private$.result_id = res$.ID.[1]
    },

    # The final configurations returned by irace are the elites of the final race.
    # We store the best performing one.
    # The reported performance value is the average of all resampling iterations.
    .assign_result = function(inst) {
        if(length(private$.result_id) == 0) {
          stop("`irace::irace` did not return a result. The evaluated configurations are still accessible through the archive.")
        }

        res = inst$archive$data[get("configuration") == private$.result_id, ]
        cols = c(inst$archive$cols_x, "configuration")
        xdt = res[1, cols, with = FALSE]
        y = set_names(mean(unlist(res[, inst$archive$cols_y, with = FALSE])), inst$archive$cols_y)
        inst$assign_result(xdt, y)
    },

    .result_id = NULL
  )
)

mlr_optimizers$add("irace", OptimizerIrace)
