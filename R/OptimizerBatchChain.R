#' @title Run Optimizers Sequentially
#'
#' @include Optimizer.R
#' @name mlr_optimizers_chain
#'
#' @description
#' `OptimizerBatchChain` allows to run multiple [OptimizerBatch] sequentially.
#'
#' For each [OptimizerBatch] an (optional) additional [Terminator] can be specified during construction.
#' While the original [Terminator] of the [OptimInstanceBatch] guards the optimization process as a whole,
#' the additional [Terminator]s guard each individual [OptimizerBatch].
#'
#' The optimization process works as follows:
#' The first [OptimizerBatch] is run on the [OptimInstanceBatch] relying on a [TerminatorCombo] of the original
#' [Terminator] of the [OptimInstanceBatch] and the (optional) additional [Terminator] as passed during construction.
#' Once this [TerminatorCombo] indicates termination (usually via the additional [Terminator]), the second [OptimizerBatch] is run.
#' This continues for all optimizers unless the original [Terminator] of the [OptimInstanceBatch] indicates termination.
#'
#' [OptimizerBatchChain] can also be used for random restarts of the same
#' [Optimizer] (if applicable) by setting the [Terminator] of the [OptimInstanceBatch] to
#' [TerminatorNone] and setting identical additional [Terminator]s during construction.
#'
#' @templateVar id chain
#' @template section_dictionary_optimizers
#'
#' @section Parameters:
#' Parameters are inherited from the individual [OptimizerBatch] and collected as a
#' [paradox::ParamSetCollection] (with `set_id`s potentially postfixed via `_1`, `_2`,
#' ..., if the same [OptimizerBatch] are used multiple times).
#'
#' @template section_progress_bars
#'
#' @export
#' @examplesIf requireNamespace("GenSA", quietly = TRUE)
#' @examples
#' domain = ps(x = p_dbl(lower = -1, upper = 1))
#'
#' search_space = ps(x = p_dbl(lower = -1, upper = 1))
#'
#' codomain = ps(y = p_dbl(tags = "minimize"))
#'
#' objective_function = function(xs) {
#'   list(y = as.numeric(xs)^2)
#' }
#'
#' objective = ObjectiveRFun$new(
#'   fun = objective_function,
#'   domain = domain,
#'   codomain = codomain
#' )
#'
#' terminator = trm("evals", n_evals = 10)
#'
#' # run optimizers sequentially
#' instance = OptimInstanceBatchSingleCrit$new(
#'   objective = objective,
#'   search_space = search_space,
#'   terminator = terminator
#' )
#'
#' optimizer = opt("chain",
#'   optimizers = list(opt("random_search"), opt("grid_search")),
#'   terminators = list(trm("evals", n_evals = 5), trm("evals", n_evals = 5))
#' )
#'
#' optimizer$optimize(instance)
#'
#' # random restarts
#' instance = OptimInstanceBatchSingleCrit$new(
#'   objective = objective,
#'   search_space = search_space,
#'   terminator = trm("none")
#' )
#' optimizer = opt("chain",
#'   optimizers = list(opt("gensa"), opt("gensa")),
#'   terminators = list(trm("evals", n_evals = 10), trm("evals", n_evals = 10))
#' )
#' optimizer$optimize(instance)
OptimizerBatchChain = R6Class("OptimizerBatchChain", inherit = OptimizerBatch,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param optimizers (list of [Optimizer]s).
    #' @param terminators (list of [Terminator]s | NULL).
    initialize = function(optimizers, terminators = rep(list(NULL), length(optimizers))) {
      assert_list(optimizers, types = "Optimizer", any.missing = FALSE)
      assert_list(terminators, types = c("Terminator", "NULL"), len = length(optimizers))

      class_counts = list()
      param_sets = vector("list", length(optimizers))
      param_set_ids = character(length(optimizers))

      for (i in seq_along(optimizers)) {
        optimizer = optimizers[[i]]
        ps = optimizer$param_set$clone(deep = TRUE)
        class_name = class(optimizer)[[1L]]

        if (is.null(class_counts[[class_name]])) {
          class_counts[[class_name]] = 1L
        } else {
          class_counts[[class_name]] = class_counts[[class_name]] + 1L
        }

        suffix = class_counts[[class_name]]
        param_set_id = paste0(class_name, "_", suffix)

        param_set_ids[[i]] = param_set_id
        param_sets[[i]] = ps
      }

      param_sets = setNames(param_sets, nm = param_set_ids)
      private$.ids = param_set_ids

      super$initialize(
        id = "chain",
        param_set = ParamSetCollection$new(param_sets),
        param_classes = Reduce(intersect, mlr3misc::map(optimizers, "param_classes")),
        properties = Reduce(intersect, mlr3misc::map(optimizers, "properties")),
        packages = unique(unlist(mlr3misc::map(optimizers, "packages"))),
        label = "Chain Multiple Optimizers Sequentially",
        man = "bbotk::mlr_optimizers_chain"
      )
      private$.optimizers = optimizers
      private$.terminators = terminators
    }
  ),

  private = list(
    .optimizers = NULL,
    .terminators = NULL,
    .ids = NULL,

    .optimize = function(inst) {
      terminator = inst$terminator
      on.exit({inst$terminator = terminator})
      inner_inst = inst$clone(deep = TRUE)

      for (i in seq_along(private$.optimizers)) {
        inner_terminator = private$.terminators[[i]]
        if (!is.null(inner_terminator)) {
          inner_inst$terminator = TerminatorCombo$new(list(inner_terminator, terminator))
        } else {
          inner_inst$terminator = terminator
        }
        optimizer = private$.optimizers[[i]]
        optimizer$param_set$values = self$param_set$.__enclos_env__$private$.sets[[i]]$values
        optimizer$optimize(inner_inst)
        set(inner_inst$archive$data, j = "batch_nr", value = max(inst$archive$data$batch_nr, 0L) + inner_inst$archive$data$batch_nr)
        set(inner_inst$archive$data, j = ".optimizer_id", value = private$.ids[i])
        inst$archive$data = rbind(inst$archive$data, inner_inst$archive$data, fill = TRUE)
        inner_inst$archive$data = data.table()
        if (terminator$is_terminated(inst$archive)) {
          break
        }
      }
    },

    deep_clone = function(name, value) {
      switch(
        name,
        .optimizers = mlr3misc::map(value, .f = function(x) x$clone(deep = TRUE)),
        .terminators = mlr3misc::map(value, .f = function(x) if (!is.null(x)) x$clone(deep = TRUE)),
        value
      )
    }
  )
)

mlr_optimizers$add("chain", OptimizerBatchChain)
