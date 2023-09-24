#' @export
OptimizerSuccessiveHalving = R6Class("OptimizerSuccessiveHalving",
  inherit = Optimizer,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        n           = p_int(lower = 1, default = 16),
        eta         = p_dbl(lower = 1.0001, default = 2),
        sampler     = p_uty(custom_check = function(x) check_r6(x, "Sampler", null.ok = TRUE)),
        repetitions = p_int(lower = 1L, default = 1, special_vals = list(Inf)),
        adjust_minimum_budget = p_lgl(default = FALSE)
      )
      param_set$values = list(n = 16L, eta = 2L, sampler = NULL, repetitions = 1, adjust_minimum_budget = FALSE)

      super$initialize(
        param_classes = c("ParamLgl", "ParamInt", "ParamDbl", "ParamFct"),
        param_set = param_set,
        properties = c("dependencies", "single-crit", "multi-crit"),
        packages = "mlr3hyperband",
        label = "Successive Halving",
        man = "mlr3hyperband::mlr_optimizers_successive_halving"
      )
    }
  ),

  private = list(
    .optimize = function(inst) {
      pars = self$param_set$values
      n = pars$n
      eta = pars$eta
      sampler = pars$sampler
      search_space = inst$search_space
      archive = inst$archive
      budget_id = search_space$ids(tags = "budget")
      minimize = ifelse(archive$codomain$maximization_to_minimization == -1, TRUE, FALSE)
      top_n =  if (archive$codomain$length == 1) "best" else "nds_selection"

      # check budget
      if (length(budget_id) != 1) stopf("Exactly one parameter must be tagged with 'budget'")
      assert_choice(search_space$class[[budget_id]], c("ParamInt", "ParamDbl"))

      # required for calculation of hypervolume
      if (inst$archive$codomain$length > 1) require_namespaces("emoa")

      # sampler
      search_space_sampler = search_space$clone()$subset(setdiff(search_space$ids(), budget_id))
      if (is.null(sampler)) {
        sampler = SamplerUnif$new(search_space_sampler)
      } else {
        assert_set_equal(sampler$param_set$ids(), search_space_sampler$ids())
      }

      # r_min is the budget of a single configuration in the first stage
      # r_max is the maximum budget of a single configuration in the last stage
      # the internal budget is rescaled to a minimum budget of 1
      # for this, the budget is divided by r_min
      # the budget is transformed to the original scale before passing it to the objective function
      r_max = search_space$upper[[budget_id]]
      r_min = search_space$lower[[budget_id]]

      # maximum budget of a single configuration in the last stage (scaled)
      r = r_max / r_min

      # number of stages if each configuration in the first stage uses the minimum budget
      # and each configuration in the last stage uses no more than maximum budget
      sr = floor(log(r, eta))

      # reduce number of stages if n < r_max so that
      # the last stages evaluates at least one configuration
      sn = floor(log(n, eta))

      # s_max + 1 is the number of stages
      s_max = min(sr, sn)

      # increase r_min so that the last stage uses the maximum budget
      if (pars$adjust_minimum_budget) r_min = r * eta^-s_max

      # run n instances of successive halving in parallel
      n_instances = future::nbrOfWorkers()

      # iterate the repetitions
      # repetitions can be Inf
      repetition = 1
      while (repetition <= pars$repetitions) {
        # sample initial configurations
        xdt = sampler$sample(n * n_instances)$data
        set(xdt, j = "repetition", value = repetition)

        # iterate stages
        for (i in 0:s_max) {
          if (i) {
            # number of configurations in stage
            ni = floor(n * eta^(-i)) * n_instances

            # promote configurations
            xdt = archive[[top_n]](archive$n_batch, ni)
          }

          # budget of a single configuration
          ri = r_min * eta^i
          if (search_space$class[[budget_id]] == "ParamInt") ri = round(ri)
          set(xdt, j = budget_id, value = ri)
          set(xdt, j = "stage", value = i)

          inst$eval_batch(xdt[, c(archive$cols_x, "stage", "repetition"), with = FALSE])
        }
        repetition = repetition + 1
      }
    },

    .optimize_async = function(inst) {
      if (inst$archive$codomain$length > 1) require_namespaces("emoa")
      pars = self$param_set$values
      rush = inst$rush
      archive = inst$archive
      search_space = inst$search_space
      sampler = pars$sampler
      budget_id = search_space$ids(tags = "budget")
      eta = pars$eta
      minimize = inst$archive$codomain$maximization_to_minimization == -1

      # top_n
      top_n = if (archive$codomain$length == 1) {
        function(y, n, minimize) {
          head(order(unlist(y), decreasing = minimize), n)
        }
      } else {
        function(y, n, minimize) {
          nds_selection(points = t(as.matrix(y)), n_select = n, minimize = minimize)
        }
      }

      # budget parameter
      if (length(budget_id) != 1) stop("Exactly one parameter must be tagged with 'budget'")
      assert_choice(search_space$class[[budget_id]], c("ParamInt", "ParamDbl"))
      integer_budget = search_space$class[[budget_id]] == "ParamInt"

      # sampler
      search_space_sampler = search_space$clone()$subset(setdiff(search_space$ids(), budget_id))
      if (is.null(sampler)) {
        sampler = SamplerUnif$new(search_space_sampler)
      } else {
        assert_set_equal(sampler$param_set$ids(), search_space_sampler$ids())
      }

      # r_min is the budget of a single configuration in the base stage
      # r_max is the maximum budget of a single configuration in the top stage
      r_max = search_space$upper[[budget_id]]
      r_min = search_space$lower[[budget_id]]

      # s_max + 1 is the number of stages
      s_max = floor(log(r_max / r_min, eta))

      # increase r_min so that the last stage uses the maximum budget
      if (pars$adjust_minimum_budget) r_min = r_max / r_min * eta^-s_max

      # r_min is the budget of a single configuration in the base stage
      # r_max is the maximum budget of a single configuration in the top stage
      r_max = search_space$upper[[budget_id]]
      r_min = search_space$lower[[budget_id]]

      # s_max + 1 is the number of stages
      s_max = floor(log(r_max / r_min, eta))

      # increase r_min so that the last stage uses the maximum budget
      if (pars$adjust_minimum_budget) r_min = r_max / r_min * eta^-s_max

      repeat({
        n_free_workers = rush$n_workers - rush$n_running_tasks - rush$n_queued_tasks

        repeat({
          # repeat for each free worker
          if (n_free_workers <= 0) break
          xdt = NULL

          # fetch configurations with result
          data = rush$fetch_finished_tasks()

          # try to promote configuration
          # iterate stages from top to base stage
          for (s in (s_max - 1):-1) {

            print(s)

            if (s < 0 || !nrow(data)) {
              # no promotion possible
              # sample new configuration
              xdt = sampler$sample(1)$data
              if (integer_budget) r_min = as.integer(round(r_min))
              set(xdt, j = budget_id, value = r_min)
              set(xdt, j = "stage", value = 0L)
              set(xdt, j = "asha_id", value = uuid::UUIDgenerate())
              break
            }

            # configurations in stage
            data_stage = data[list(s), , on = "stage", nomatch = NULL]

            # no configurations in stage
            if (!nrow(data_stage)) next

            # top n configurations in stage
            y = data_stage[[archive$cols_y]]
            n = floor(nrow(data_stage) / eta)
            candidates = data_stage[top_n(y, n, minimize), ]

            # configuration in stage + 1
            next_stage = s + 1

            queued_asha_ids = rush$fetch_queued_tasks(fields = c("xs_extra"))$asha_id
            running_asha_ids = rush$fetch_running_tasks(fields = c("xs_extra"))$asha_id
            finished_asha_ids = rush$fetch_finished_tasks()[list(next_stage), asha_id, on = "stage", nomatch = NULL]
            promotable_asha_ids = setdiff(candidates$asha_id, c(queued_asha_ids, running_asha_ids, finished_asha_ids))

            # promote configuration
            if (length(promotable_asha_ids)) {
              ri = r_min * eta^(s + 1)
              if (integer_budget) ri = as.integer(round(ri))
              xdt = candidates[list(promotable_asha_ids[1]), c(archive$cols_x, "asha_id"), on = "asha_id", with = FALSE]
              set(xdt, j = budget_id, value = ri)
              set(xdt, j = "stage", value = s + 1)
              break
            }
          }

          inst$eval_async(xdt)
          n_free_workers = n_free_workers - 1
        })
      })
    }
  )
)


mlr_optimizers$add("successive_halving", OptimizerSuccessiveHalving)
