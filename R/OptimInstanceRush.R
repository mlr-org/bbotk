#' @title Optimization Instance with Rush
#'
#' @include OptimInstance.R
#'
#' @description
#' Abstract base class for [OptimInstanceRushSingleCrit] and [OptimInstanceRushMultiCrit].
#' The optimization instances specify an optimization problem for [Optimizer]s.
#' Points are evaluated asynchronously with the `rush` package.
#' The function [oi()] creates an [OptimInstanceRushSingleCrit] or [OptimInstanceRushMultiCrit] and the function [bb_optimize()] creates an instance internally.
#'
#' @template param_objective
#' @template param_search_space
#' @template param_terminator
#' @template param_rush
#' @template param_callbacks
#' @template param_archive
#'
#' @template field_objective
#' @template field_search_space
#' @template field_terminator
#' @template field_rush
#' @template field_callbacks
#' @template field_archive_rush
#'
#' @export
OptimInstanceRush = R6Class("OptimInstanceRush",
  public = list(

    objective = NULL,

    search_space = NULL,

    terminator = NULL,

    rush = NULL,

    callbacks = NULL,

    archive = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(
      objective,
      search_space = NULL,
      terminator,
      rush,
      callbacks = list(),
      archive = NULL
      ) {
      self$objective = assert_r6(objective, "Objective")
      self$search_space = choose_search_space(self$objective, search_space)
      self$terminator = assert_terminator(terminator, self)
      self$rush = assert_class(rush, "Rush")
      self$callbacks = assert_callbacks(as_callbacks(callbacks))

      # archive is passed when a downstream packages creates a new archive class
      self$archive = if (is.null(archive)) {
        ArchiveRush$new(search_space = self$search_space, codomain = self$objective$codomain, rush = self$rush)
      } else {
        assert_r6(archive, "ArchiveRush")
      }
    },

    #' @description
    #' Helper for print outputs.
    #' @param ... (ignored).
    format = function(...) {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Printer.
    #'
    #' @param ... (ignored).
    print = function(...) {
      catf(format(self))
      catf(str_indent("* State: ", if (is.null(private$.result)) "Not optimized" else "Optimized"))
      catf(str_indent("* Objective:", format(self$objective)))
      catf("* Search Space:")
      print(as.data.table(self$search_space)[, c("id", "class", "lower", "upper", "nlevels"), with = FALSE])
      catf(str_indent("* Terminator:", format(self$terminator)))
      catf(str_indent("* Workers:", self$rush$n_workers))
      if (!is.null(private$.result)) {
        catf("* Result:")
        print(self$result[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
        catf("* Archive:")
        print(as.data.table(self$archive)[, c(self$archive$cols_x, self$archive$cols_y), with = FALSE])
      }
    },

    #' @description
    #' Start workers with the `future` package.
    #'
    #' @template param_n_workers
    #' @template param_packages
    #' @template param_host
    #' @template param_heartbeat_period
    #' @template param_heartbeat_expire
    #' @template param_lgr_thresholds
    #' @template param_await_workers
    #' @template param_detect_lost_tasks
    #' @template param_freeze_archive
    start_workers = function(
      n_workers = NULL,
      packages = NULL,
      host = "local",
      heartbeat_period = NULL,
      heartbeat_expire = NULL,
      lgr_thresholds = NULL,
      await_workers = TRUE,
      detect_lost_tasks = FALSE,
      freeze_archive = FALSE
      ) {
      private$.detect_lost_tasks = assert_flag(detect_lost_tasks)
      private$.freeze_archive = assert_flag(freeze_archive)

      # decouple globals from instance
      objective = self$objective
      search_space = self$search_space

      worker_ids = self$rush$start_workers(
        worker_loop = bbotk_worker_loop,
        n_workers = n_workers,
        globals = c("objective", "search_space"),
        packages = c(packages, "bbotk"),
        host = host,
        heartbeat_period = heartbeat_period,
        heartbeat_expire = heartbeat_expire,
        lgr_thresholds = lgr_thresholds,
        objective = objective,
        search_space = search_space,
        await_workers = await_workers)

      lg$info("Starting %i worker(s) with future.", length(worker_ids))
    },

    #' @description
    #' Adds points in `xdt` to the queue.
    #' The points are evaluated by calling the [Objective] asynchronously.
    #'
    #' @param xdt (`data.table::data.table()`)\cr
    #' x values as `data.table()` with one point per row.
    #' Contains the value in  the *search space* of the [OptimInstance] object.
    #' Can contain additional columns for extra information.
    #' @param wait (`logical(1)`)\cr
    #' If `TRUE`, wait for all evaluations to finish.
    eval_async = function(xdt, wait = FALSE) {
      assert_data_table(xdt)
      assert_names(colnames(xdt), must.include = self$search_space$ids())

      if (self$is_terminated) stop(terminated_error(self))

      lg$info("Sending %i configuration(s) to workers:", max(1, nrow(xdt)))
      lg$info(capture.output(print(xdt, class = FALSE, row.names = FALSE, print.keys = FALSE)))

      xss = transpose_list(xdt[, self$search_space$ids(), with = FALSE])
      xdt[, timestamp_xs := Sys.time()]
      extra = transpose_list(xdt[, !self$search_space$ids(), with = FALSE])

      # push to shared queue or priority queues
      if (!is.null(xdt$priority_id)) {
        keys = self$rush$push_priority_tasks(xss, extra, priority = xdt$priority_id)
      } else {
        keys = self$rush$push_tasks(xss, extra)
      }

      # optimizer can request to wait for all evaluations to finish
      if (wait) {
        self$rush$await_tasks(keys, detect_lost_tasks = private$.detect_lost_tasks)
      }

      # terminate optimization if all workers crashed
      if (!self$rush$n_running_workers)  {
        lg$warn("Optimization terminated because all workers crashed.")
        stop(terminated_error(self))
      }

      if (private$.detect_lost_tasks) self$rush$detect_lost_tasks()

      return(invisible(keys))
    },

    #' @description
    #' Reset terminator and clear all evaluation results from archive and results.
    clear = function() {
      self$rush$reset()
      self$archive$clear()
      private$.result = NULL
      invisible(self)
    }
  ),

  active = list(
    #' @field result ([data.table::data.table])\cr
    #' Get result
    result = function() {
      private$.result
    },

    #' @field result_x_search_space ([data.table::data.table])\cr
    #' x part of the result in the *search space*.
    result_x_search_space = function() {
      private$.result[, self$search_space$ids(), with = FALSE]
    },

    #' @field result_x_domain (`list()`)\cr
    #' (transformed) x part of the result in the *domain space* of the objective.
    result_x_domain = function() {
      private$.result$x_domain[[1]]
    },

    #' @field result_y (`numeric()`)\cr
    #' Optimal outcome.
    result_y = function() {
      unlist(private$.result[, self$objective$codomain$ids(), with = FALSE])
    },

    #' @field is_terminated (`logical(1)`).
    is_terminated = function() {
      self$terminator$is_terminated(self$archive)
    }
  ),

  private = list(
    .xdt = NULL,
    .result = NULL,
    .objective_function = NULL,
    .context = NULL,
    .freeze_archive = NULL,
    .detect_lost_tasks = NULL,

    .assign_result = function(xdt, y) {
      stop("Abstract class")
    },

    deep_clone = function(name, value) {
      switch(name,
        objective = value$clone(deep = TRUE),
        search_space = value$clone(deep = TRUE),
        terminator = value$clone(deep = TRUE),
        archive = value$clone(deep = TRUE),
        value
      )
    }
  )
)

