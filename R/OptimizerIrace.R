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
#' the algorithm. Use [TerminatorRunTime] or [TerminatorEvals] instead. Other
#' terminators do not work with `TunerIrace`. We subtract 5 seconds from the
#' [TerminatorRunTime] budget for stability reasons.
#' 
#' @section Target Runner and Instances:
#' The irace package uses a `targetRunner` script or R function to evaluate a
#' configuration on a particular instance. Usually it is not necessary to
#' specify a `targetRunner` function when using `OptimizerIrace`. A default
#' function is used that forwards several configurations and an instance to the
#' user defined objective function. As usual, the configurations are passed in
#' `xss` to the objective. The instance is passed via the `$irace_instance`
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
#' @section Result:
#' The optimization result in `instance$result` is the best performing elite of
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
      ps = ParamSet$new(list(
        ParamUty$new("instances", tags = "required"),
        ParamUty$new("targetRunnerParallel", tags = "required"),
        ParamInt$new("debugLevel", default = 0, lower = 0),
        ParamUty$new("logFile"),
        ParamInt$new("seed"),
        ParamDbl$new("postselection", default = 0, lower = 0, upper = 1),
        ParamInt$new("elitist", default = 1, lower = 0, upper = 1),
        ParamInt$new("elitistLimit", default = 2, lower = 0),
        ParamInt$new("nbIterations", default = 0, lower = 0),
        ParamInt$new("nbExperimentsPerIteration", default = 0, lower = 0),
        ParamInt$new("minNbSurvival", default = 0, lower = 0),
        ParamInt$new("nbConfigurations", default = 0, lower = 0),
        ParamInt$new("mu", default = 5, lower = 1),
        ParamInt$new("softRestart", default = 1, lower = 0, upper = 1),
        ParamDbl$new("softRestartThreshold"),
        ParamInt$new("digits", default = 4, lower = 1, upper = 15),
        ParamFct$new("testType", default = "F-test", levels = c("F-test", "t-test", "t-test-bonferroni", "t-test-holm")),
        ParamInt$new("firstTest", default = 5, lower = 0),
        ParamInt$new("eachTest", default = 1, lower = 1),
        ParamDbl$new("confidence", default = 0.95, lower = 0, upper = 1),
        ParamInt$new("capping", default = 0, lower = 0, upper = 1),
        ParamFct$new("cappingType", default = "median", levels = c("median", "mean", "best", "worst")),
        ParamFct$new("boundType", default = "candidate", levels = c("candidate", "instance")),
        ParamDbl$new("boundMax", default = 0),
        ParamInt$new("boundDigits", default = 0),
        ParamDbl$new("boundPar", default = 1),
        ParamDbl$new("boundAsTimeout", default = 1),
        ParamLgl$new("deterministic", default = FALSE)
      ))

      ps$values$debugLevel = 0
      ps$values$logFile = tempfile()
      ps$values$targetRunnerParallel = target_runner_default

      super$initialize(
       param_set = ps,
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
      objective = inst$objective

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

        res = inst$archive$data[get("id_configuration") == private$.result_id, ]
        cols = c(inst$archive$cols_x, "id_configuration")
        xdt = res[1, cols, with = FALSE]
        y = set_names(mean(unlist(res[, inst$archive$cols_y, with = FALSE])), inst$archive$cols_y)
        inst$assign_result(xdt, y)
    },

    .result_id = NULL
  )
)

mlr_optimizers$add("irace", OptimizerIrace)
