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
#'
#' \item{`n_init`}{`integer(1)`\cr
#'   Number of initial configurations to evaluate before starting the optimization.
#'   Defaults to `10` times the number of hyperparameters.}
#'
#' \item{`facade`}{`character(1)`\cr
#'   Facade to use:
#'   `"smac4bb"` (Black-Box Facade, uses Gaussian Process),
#'   `"smac4hb"` (Hyperparameter Optimization Facade, uses Random Forest),
#'   `"smac4ac"` (Algorithm Configuration Facade),
#'   `"smac4mf"` (Multi-Fidelity Facade, uses Hyperband),
#'   `"smac4rs"` (Random Facade / ROAR, no surrogate model).
#'   Default is `"smac4bb"`.}
#'
#' \item{`output_directory`}{`character(1)`\cr
#'   Directory to store the output of SMAC3.
#'   Default is a temporary directory.}
#'
#' \item{`deterministic`}{`logical(1)`\cr
#'   Whether the objective function is deterministic.
#'   If `FALSE`, SMAC may re-evaluate configurations with different seeds.
#'   Default is `TRUE`.}
#'
#' \item{`crash_cost`}{`numeric(1)`\cr
#'   Cost assigned to crashed or failed trials.}
#'
#' \item{`seed`}{`integer(1)`\cr
#'   Seed for the random number generator in SMAC.
#'   Default is a random seed.}
#'
#' \item{`surrogate`}{`character(1)`\cr
#'   Surrogate model to use.
#'   `"rf"` (Random Forest) or `"gp"` (Gaussian Process).
#'   Default is the facade's default (GP for `"smac4bb"`, RF for `"smac4hb"` and `"smac4ac"`).}
#'
#' \item{`rf.n_trees`}{`integer(1)`\cr
#'   Number of trees in the Random Forest surrogate.
#'   Only used when `surrogate = "rf"`.
#'   Default is `10`.}
#'
#' \item{`rf.ratio_features`}{`numeric(1)`\cr
#'   Ratio of features used per tree in the Random Forest.
#'   Only used when `surrogate = "rf"`.
#'   Default is `1.0`.}
#'
#' \item{`rf.min_samples_split`}{`integer(1)`\cr
#'   Minimum number of samples to split a node in the Random Forest.
#'   Only used when `surrogate = "rf"`.
#'   Default is `2`.}
#'
#' \item{`rf.min_samples_leaf`}{`integer(1)`\cr
#'   Minimum number of samples per leaf in the Random Forest.
#'   Only used when `surrogate = "rf"`.
#'   Default is `1`.}
#'
#' \item{`rf.max_depth`}{`integer(1)`\cr
#'   Maximum depth of trees in the Random Forest.
#'   Only used when `surrogate = "rf"`.
#'   Default is `1048576`.}
#'
#' \item{`gp.n_restarts`}{`integer(1)`\cr
#'   Number of restarts for Gaussian Process hyperparameter optimization.
#'   Only used when `surrogate = "gp"`.
#'   Default is `10`.}
#'
#' \item{`acq_function`}{`character(1)`\cr
#'   Acquisition function to use.
#'   `"ei"` (Expected Improvement), `"lcb"` (Lower Confidence Bound),
#'   `"pi"` (Probability of Improvement), or `"ts"` (Thompson Sampling).
#'   Default is the facade's default.}
#'
#' \item{`acq_function.xi`}{`numeric(1)`\cr
#'   Exploration-exploitation trade-off parameter for Expected Improvement and
#'   Probability of Improvement.
#'   Only used when `acq_function` is `"ei"` or `"pi"`.
#'   Default is `0.0`.}
#'
#' \item{`acq_function.beta`}{`numeric(1)`\cr
#'   Exploration-exploitation trade-off parameter for Lower Confidence Bound.
#'   Only used when `acq_function = "lcb"`.
#'   Default is `1.0`.}
#'
#' \item{`initial_design`}{`character(1)`\cr
#'   Initial design strategy.
#'   `"sobol"`, `"random"`, `"lhc"` (Latin Hypercube), `"factorial"`, or `"default"`.
#'   Default is the facade's default.}
#'
#' \item{`max_config_calls`}{`integer(1)`\cr
#'   Maximum number of evaluations per configuration.
#'   Values larger than `1` are useful for stochastic objectives.
#'   Default is `1`.}
#'
#' \item{`random_design`}{`character(1)`\cr
#'   Strategy for interleaving random configurations during optimization.
#'   `"probability"` or `"modulus"`.
#'   Default is the facade's default.}
#'
#' \item{`random_design.probability`}{`numeric(1)`\cr
#'   Probability of sampling a random configuration instead of using the surrogate model.
#'   Only used when `random_design = "probability"`.}
#'
#' \item{`random_design.modulus`}{`numeric(1)`\cr
#'   Every `modulus`-th configuration is drawn randomly.
#'   Only used when `random_design = "modulus"`.}
#'
#' \item{`eta`}{`integer(1)`\cr
#'   Halving factor for Successive Halving / Hyperband.
#'   Only used when `facade = "smac4mf"`.
#'   Default is `3`.}
#'
#' \item{`min_budget`}{`numeric(1)`\cr
#'   Minimum budget for multi-fidelity optimization (e.g., epochs, subset fraction).
#'   Only used when `facade = "smac4mf"`.}
#'
#' \item{`max_budget`}{`numeric(1)`\cr
#'   Maximum budget for multi-fidelity optimization.
#'   Only used when `facade = "smac4mf"`.}
#'
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
        # scenario
        n_init = p_int(lower = 1L),
        facade = p_fct(levels = c("smac4bb", "smac4hb", "smac4ac", "smac4mf", "smac4rs"), init = "smac4bb"),
        output_directory = p_uty(init = tempdir()),
        deterministic = p_lgl(init = TRUE),
        crash_cost = p_dbl(),
        seed = p_int(lower = 0L),

        # surrogate model
        surrogate = p_fct(levels = c("rf", "gp")),
        rf.n_trees = p_int(lower = 1L, depends = quote(surrogate == "rf")),
        rf.ratio_features = p_dbl(lower = 0, upper = 1, depends = quote(surrogate == "rf")),
        rf.min_samples_split = p_int(lower = 2L, depends = quote(surrogate == "rf")),
        rf.min_samples_leaf = p_int(lower = 1L, depends = quote(surrogate == "rf")),
        rf.max_depth = p_int(lower = 1L, depends = quote(surrogate == "rf")),
        gp.n_restarts = p_int(lower = 0L, depends = quote(surrogate == "gp")),

        # acquisition function
        acq_function = p_fct(levels = c("ei", "lcb", "pi", "ts")),
        acq_function.xi = p_dbl(lower = 0, depends = quote(acq_function %in% c("ei", "pi"))),
        acq_function.beta = p_dbl(lower = 0, depends = quote(acq_function == "lcb")),

        # initial design
        initial_design = p_fct(levels = c("sobol", "random", "lhc", "factorial", "default")),

        # intensifier
        max_config_calls = p_int(lower = 1L),

        # random design
        random_design = p_fct(levels = c("probability", "modulus")),
        random_design.probability = p_dbl(lower = 0, upper = 1, depends = quote(random_design == "probability")),
        random_design.modulus = p_dbl(lower = 1, depends = quote(random_design == "modulus")),

        # multi-fidelity
        eta = p_int(lower = 2L, depends = quote(facade == "smac4mf")),
        min_budget = p_dbl(lower = 0, depends = quote(facade == "smac4mf")),
        max_budget = p_dbl(lower = 0, depends = quote(facade == "smac4mf"))
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

      # build scenario
      scenario_args = list(
        configspace = cs,
        deterministic = pv$deterministic,
        n_trials = as.integer(n_trials),
        seed = as.integer(pv$seed %??% sample.int(.Machine$integer.max, 1L)),
        output_directory = pv$output_directory
      )

      if (!is.null(pv$crash_cost)) {
        scenario_args$crash_cost = pv$crash_cost
      }

      if (!is.null(pv$min_budget)) {
        scenario_args$min_budget = pv$min_budget
      }

      if (!is.null(pv$max_budget)) {
        scenario_args$max_budget = pv$max_budget
      }

      scenario = invoke(smac$Scenario, .args = scenario_args)

      # map facade
      facade_class = switch(pv$facade,
        "smac4bb" = smac$BlackBoxFacade,
        "smac4hb" = smac$HyperparameterOptimizationFacade,
        "smac4ac" = smac$AlgorithmConfigurationFacade,
        "smac4mf" = smac$MultiFidelityFacade,
        "smac4rs" = smac$RandomFacade
      )

      # build surrogate model
      model = NULL
      if (!is.null(pv$surrogate)) {
        if (pv$surrogate == "rf") {
          model = smac$model$random_forest$RandomForest(
            configspace = cs,
            n_trees = as.integer(pv$rf.n_trees %??% 10L),
            ratio_features = pv$rf.ratio_features %??% 1.0,
            min_samples_split = as.integer(pv$rf.min_samples_split %??% 2L),
            min_samples_leaf = as.integer(pv$rf.min_samples_leaf %??% 1L),
            max_depth = as.integer(pv$rf.max_depth %??% 1048576L),
            seed = as.integer(scenario_args$seed)
          )
        } else if (pv$surrogate == "gp") {
          kernel = facade_class$get_kernel(scenario)
          model = smac$model$gaussian_process$GaussianProcess(
            configspace = cs,
            kernel = kernel,
            n_restarts = as.integer(pv$gp.n_restarts %??% 10L),
            seed = as.integer(scenario_args$seed)
          )
        }
      }

      # build acquisition function
      acq_function = NULL
      if (!is.null(pv$acq_function)) {
        acq_mod = smac$acquisition[["function"]]
        acq_function = switch(pv$acq_function,
          "ei" = acq_mod$EI(xi = pv$acq_function.xi %??% 0.0),
          "lcb" = acq_mod$LCB(beta = pv$acq_function.beta %??% 1.0),
          "pi" = acq_mod$PI(xi = pv$acq_function.xi %??% 0.0),
          "ts" = acq_mod$TS()
        )
      }

      # build initial design
      initial_design_obj = NULL
      if (!is.null(pv$initial_design)) {
        initial_design_obj = switch(pv$initial_design,
          "sobol" = smac$initial_design$SobolInitialDesign(scenario, n_configs = as.integer(n_init)),
          "random" = smac$initial_design$RandomInitialDesign(scenario, n_configs = as.integer(n_init)),
          "lhc" = smac$initial_design$LatinHypercubeInitialDesign(scenario, n_configs = as.integer(n_init)),
          "factorial" = smac$initial_design$FactorialInitialDesign(scenario, n_configs = as.integer(n_init)),
          "default" = smac$initial_design$DefaultInitialDesign(scenario)
        )
      } else if (pv$facade %in% c("smac4bb", "smac4hb", "smac4mf")) {
        initial_design_obj = facade_class$get_initial_design(
          scenario,
          n_configs = as.integer(n_init)
        )
      } else {
        # AlgorithmConfigurationFacade and RandomFacade use their own default initial designs
        initial_design_obj = facade_class$get_initial_design(scenario)
      }

      # build random design
      random_design = NULL
      if (!is.null(pv$random_design)) {
        random_design = switch(pv$random_design,
          "probability" = smac$random_design$ProbabilityRandomDesign(
            probability = pv$random_design.probability %??% 0.08447),
          "modulus" = smac$random_design$ModulusRandomDesign(
            modulus = pv$random_design.modulus %??% 2.0)
        )
      }

      # build intensifier
      if (pv$facade == "smac4mf") {
        # MultiFidelityFacade uses Hyperband which takes eta, not max_config_calls
        intensifier_args = list(scenario)
        if (!is.null(pv$eta)) {
          intensifier_args$eta = as.integer(pv$eta)
        }
      } else {
        intensifier_args = list(
          scenario,
          max_config_calls = as.integer(pv$max_config_calls %??% 1L)
        )
      }

      intensifier = invoke(facade_class$get_intensifier, .args = intensifier_args)

      # create smac optimizer
      # use a dummy target function since we use the ask-tell interface
      # SMAC validates the function signature, so we create a Python function directly
      # MultiFidelityFacade requires a 'budget' argument in the target function
      if (pv$facade == "smac4mf") {
        reticulate::py_run_string("def _dummy_target_fn(config, seed, budget): return 0.0")
      } else {
        reticulate::py_run_string("def _dummy_target_fn(config, seed): return 0.0")
      }
      dummy_fn = reticulate::py$`_dummy_target_fn`

      facade_args = list(
        scenario = scenario,
        target_function = dummy_fn,
        intensifier = intensifier,
        initial_design = initial_design_obj,
        overwrite = TRUE
      )

      if (!is.null(model)) {
        facade_args$model = model
      }

      if (!is.null(acq_function)) {
        facade_args$acquisition_function = acq_function
      }

      if (!is.null(random_design)) {
        facade_args$random_design = random_design
      }

      smac_optimizer = invoke(facade_class, .args = facade_args)

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
