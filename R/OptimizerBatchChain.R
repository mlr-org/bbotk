#' @title Run Optimizers Sequentially
#'
#' @include Optimizer.R
#' @include Terminator.R
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
#' Each [OptimizerBatch] is run on the [OptimInstanceBatch] until either the [Terminator] of the
#' [OptimInstanceBatch] or the (optional) additional [Terminator] as passed during construction indicates
#' termination.
#' The [Terminator] of the [OptimInstanceBatch] sees all points that were evaluated so far,
#' whereas the additional [Terminator] only sees the points that were evaluated by the current [OptimizerBatch]
#' and measures the runtime from the start of the current [OptimizerBatch].
#' Once the additional [Terminator] indicates termination, the next [OptimizerBatch] is run.
#' This continues for all optimizers unless the [Terminator] of the [OptimInstanceBatch] indicates termination.
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
#' @examples
#' # example only runs if GenSA is available
#' if (mlr3misc::require_namespaces("GenSA", quietly = TRUE)) {
#' # define the objective function
#' fun = function(xs) {
#'   list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
#' }
#'
#' # set domain
#' domain = ps(
#'   x1 = p_dbl(-10, 10),
#'   x2 = p_dbl(-5, 5)
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
#'   terminator = trm("evals", n_evals = 10)
#' )
#'
#' # load optimizer
#' optimizer = opt("chain",
#'   optimizers = list(opt("random_search"), opt("grid_search")),
#'   terminators = list(trm("evals", n_evals = 5), trm("evals", n_evals = 5))
#' )
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
OptimizerBatchChain = R6Class(
  "OptimizerBatchChain",
  inherit = OptimizerBatch,
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
      on.exit({
        inst$terminator = terminator
      })

      for (i in seq_along(private$.optimizers)) {
        inner_terminator = private$.terminators[[i]]
        inst$terminator = if (is.null(inner_terminator)) {
          terminator
        } else {
          TerminatorChainPart$new(terminator, inner_terminator, offset = nrow(inst$archive$data))
        }

        optimizer = private$.optimizers[[i]]
        optimizer$param_set$values = self$param_set$sets[[i]]$values

        # the optimizers are run on the instance itself so that the terminator of the instance sees all evaluated
        # points; the private method is called to avoid resetting the start time of the archive and to only run the
        # callbacks of the chain
        first_row = nrow(inst$archive$data) + 1L
        tryCatch(
          get_private(optimizer)$.optimize(inst),
          Mlr3ErrorBbotkTerminated = function(cond) NULL
        )
        if (nrow(inst$archive$data) >= first_row) {
          set(
            inst$archive$data,
            i = first_row:nrow(inst$archive$data),
            j = ".optimizer_id",
            value = private$.ids[i]
          )
        }

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

# Guards a single optimizer of OptimizerBatchChain.
# `terminator` is the terminator of the instance and sees the complete archive, whereas `inner` only sees the points
# that were evaluated by the current optimizer and measures the runtime from the start of the current optimizer.
# The progress is reported for `terminator` so that the progress bar of the chain increases monotonically.
TerminatorChainPart = R6Class(
  "TerminatorChainPart",
  inherit = Terminator,
  public = list(
    initialize = function(terminator, inner, offset) {
      private$.terminator = assert_r6(terminator, "Terminator")
      private$.inner = assert_r6(inner, "Terminator")
      private$.offset = assert_count(offset)
      private$.start_time = Sys.time()

      super$initialize(
        id = "chain_part",
        properties = intersect(terminator$properties, inner$properties),
        unit = terminator$unit,
        label = "Chain Part"
      )
    },

    is_terminated = function(archive) {
      private$.terminator$is_terminated(archive) || private$.inner$is_terminated(private$.view(archive))
    }
  ),

  private = list(
    .terminator = NULL,
    .inner = NULL,
    .offset = NULL,
    .start_time = NULL,

    # archive that only contains the points of the current optimizer
    .view = function(archive) {
      view = archive$clone(deep = FALSE)
      n = nrow(archive$data)
      view$data = if (n > private$.offset) archive$data[(private$.offset + 1L):n] else archive$data[0L]
      view$start_time = private$.start_time
      view
    },

    .status = function(archive) {
      private$.terminator$status(archive)
    }
  )
)
