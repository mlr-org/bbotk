#' @title Sequential Model-Based Algorithm Configuration (SMAC3)
#'
#' @include Optimizer.R
#' @name mlr_optimizers_smac
#'
#' @description
#' Calls SMAC3 from Python via the \CRANpkg{reticulate} package.
#'
#' @note
#' All parameters of the search space must have default values.
#'
#' @section Parameters:
#' \describe{
#' \item{`n_init`}{`integer(1)`\cr
#'   Number of initial configurations to evaluate before starting the optimization.
#'   Defaults to `10` times the number of hyperparameters.}
#' \item{`facade`}{`character(1)`\cr
#'   Facade to use.
#'   Either `"smac4bb"` (Black-Box Facade) or `"smac4hb"` (Hyperparameter Optimization Facade).
#'   Default is `"smac4bb"`.}
#' \item{`output_directory`}{`character(1)`\cr
#'   Directory to store the output of SMAC3.
#'   Default is a temporary directory.}
#' }
#'
#' @template section_progress_bars
#'
#' @source
#' `r format_bib("lindauer_2022")`
#'
#' @export
#' @examples
#' \dontrun{
#' # define the objective function
#' fun = function(xs) {
#'   list(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain (all parameters must have defaults for ConfigSpace)
#' domain = ps(
#'   x1 = p_dbl(-10, 10, default = 0),
#'   x2 = p_dbl(-5, 5, default = 0)
#' )
#'
#' # set codomain
#' codomain = ps(
#'   y = p_dbl(tags = "maximize")
#' )
#'
#' # create objective
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
#'
#' # initialize instance
#' instance = oi(
#'   objective = objective,
#'   terminator = trm("evals", n_evals = 20)
#' )
#'
#' # load optimizer
#' optimizer = opt("smac")
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
OptimizerBatchSmac3 = R6Class("OptimizerBatchSmac3",
  inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        n_init = p_int(lower = 1L),
        facade = p_fct(levels = c("smac4bb", "smac4hb"), init = "smac4bb"),
        output_directory = p_uty(init = tempdir())
      )
      super$initialize(
        id = "smac",
        param_set = param_set,
        param_classes = c("ParamDbl", "ParamInt", "ParamFct", "ParamLgl"),
        properties = c("dependencies", "single-crit"),
        packages = "reticulate",
        label = "Sequential Model-Based Algorithm Configuration",
        man = "bbotk::mlr_optimizers_smac"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      assert_python_packages(c("smac", "ConfigSpace"))
      smac = reticulate::import("smac")

      pv = self$param_set$values
      search_space = inst$search_space

      # convert paradox search space to ConfigSpace
      cs = paramset_to_configspace(search_space)

      terminator = inst$terminator
      if (inherits(terminator, "TerminatorEvals")) {
        n_trials = terminator$param_set$values$n_evals
      } else {
        # use a large number for other terminators
        n_trials = .Machine$integer.max
      }

      n_init = pv$n_init %??% (10L * search_space$length)

      scenario = smac$Scenario(
        configspace = cs,
        deterministic = TRUE,
        n_trials = as.integer(n_trials),
        seed = as.integer(sample.int(.Machine$integer.max, 1L)),
        output_directory = pv$output_directory
      )

      if (pv$facade == "smac4bb") {
        facade_class = smac$BlackBoxFacade
      } else {
        facade_class = smac$HyperparameterOptimizationFacade
      }

      intensifier = facade_class$get_intensifier(
        scenario,
        max_config_calls = 1L
      )

      # create initial design
      initial_design = facade_class$get_initial_design(
        scenario,
        n_configs = as.integer(n_init)
      )

      # create smac optimizer
      # use a dummy target function since we use the ask-tell interface
      # SMAC validates the function signature, so we create a Python function directly
      reticulate::py_run_string("def _dummy_target_fn(config, seed): return 0.0")
      dummy_fn = reticulate::py$`_dummy_target_fn`

      smac_optimizer = facade_class(
        scenario = scenario,
        target_function = dummy_fn,
        intensifier = intensifier,
        initial_design = initial_design,
        overwrite = TRUE
      )

      # import TrialValue for reporting results
      TrialValue = smac$runhistory$dataclasses$TrialValue

      repeat {
        # ask for next configuration
        trial_info = tryCatch(
          smac_optimizer$ask(),
          error = function(e) NULL
        )

        if (is.null(trial_info)) {
          break
        }

        # extract configuration as named list
        config = trial_info$config
        config_dict = reticulate::py_to_r(config$get_dictionary())

        # inactive parameters are not in the config dictionary
        # create data.table with all parameters (inactive ones are NA)
        all_params = search_space$ids()
        xdt = setDT(lapply(set_names(all_params), function(p) config_dict[[p]] %??% NA))

        # fix logical parameters (ConfigSpace uses strings "TRUE"/"FALSE")
        lgl_params = search_space$ids(class = "ParamLgl")
        if (length(lgl_params)) {
          xdt[, (lgl_params) := lapply(.SD, as.logical), .SDcols = lgl_params]
        }

        res = inst$eval_batch(xdt)
        cost = res[[inst$archive$cols_y]] * inst$objective_multiplicator

        # tell smac the result
        trial_value = TrialValue(cost = cost, time = 0.0)
        smac_optimizer$tell(trial_info, trial_value)
      }
    }
  )
)

mlr_optimizers$add("smac", OptimizerBatchSmac3)
