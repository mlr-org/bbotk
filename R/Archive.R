#' @title Container for objective function evaluations
#'
#' @description
#' Container around a data.table which stores all performed [Objective] function
#' calls.
#'
#' @export
Archive = R6Class("Archive",
  public = list(

    #' @field data [data.table::data.table]\cr
    #' Holds data of the archive.
    data = NULL,

    #' @field search_space [paradox::ParamSet]\cr
    #' Search space that is logged into archive.
    search_space = NULL,

    #' @field codomain [paradox::ParamSet]\cr
    #' Codomain of objective function that is logged into archive.
    codomain = NULL,

    #' @field start_time `POSIXct`
    start_time = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #' @param search_space [paradox::ParamSet]\cr
    #' Search space that is logged into archive.
    #' @param codomain [paradox::ParamSet]\cr
    #' Codomain of objective function that is logged into archive.
    initialize = function(search_space, codomain) {
      assert_param_set(search_space)
      assert_param_set(codomain)
      self$search_space = search_space
      self$codomain = codomain
      self$start_time = Sys.time()
      self$data = data.table()
    },

    #' @description
    #' Adds function evaluations to the archive table.
    #' @param xdt [data.table::data.table]
    #' @param xss_trafoed `list()`
    #' @param ydt [data.table::data.table]
    add_evals = function(xdt, xss_trafoed, ydt) {

      # FIXME: add checks here for the dts and their domains
      # FIXME: make asserts better!
      assert_data_table(xdt)
      assert_data_table(ydt)
      assert_list(xss_trafoed)
      xydt = cbind(xdt, ydt)
      assert_subset(c(self$search_space$ids(), self$codomain$ids()), colnames(xydt))
      xydt[, "opt_x" := list(xss_trafoed)]
      xydt[, "timestamp" := as.integer(Sys.time())]
      batch_nr = self$data$batch_nr
      batch_nr = if (length(batch_nr) > 0) max(batch_nr) + 1L else 1L
      xydt[, "batch_nr" := batch_nr]
      self$data = rbindlist(list(self$data, xydt), fill = TRUE, use.names = TRUE)
    },

    #' @description
    #' Returns best scoring evaluation.
    #' @param m `integer()`\cr
    #' Take only batches `m` into account. Default all batches.
    get_best = function(m = NULL) {
      m = assert_integerish(m, null.ok = TRUE)

      if (self$n_batch == 0) {
        stop("No results stored in archive")
      }
      if (is.null(m)) {
        m = 1:self$n_batch
      }

      tab = self$data
      tab = tab[batch_nr %in% m, ]
      if (self$codomain$length == 1) {
        order = if (self$codomain$tags[1] == "minimize") 1 else -1
        setorderv(tab, self$codomain$ids(), order = order)
        res = tab[1, ]
      } else {
        # fixme add pareto calculation here:
        stop ("not supported for multi-objective yet")
      }
      return(res)
    },

    #' @description
    #' Returns data.table which contains all performed [Objective] function
    #' calls.
    #' @param unnest `character()`
    #' Unnested columns are stored in seperate columns instead of list-columns.
    get_data = function(unnest = NULL) {
      dt = copy(self$data)
      assert_choice(unnest, names(dt), null.ok = TRUE)

      if (!is.null(unnest)) {
        dt = unnest(dt, unnest, prefix = paste0(unnest, "_"))
      }
      dt[]
    },

    #' @description
    #' Helper for print outputs.
    format = function() {
      sprintf("<%s>", class(self)[1L])
    },

    #' @description
    #' Printer.
    #' @param ... (ignored).
    print = function() {
      catf(format(self))
      print(self$data)
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      self$data = data.table()
    }
  ),

  active = list(

    #' @field n_evals `ìnteger(1)`\cr
    #' Number of evaluations stored in the archive.
    n_evals = function() nrow(self$data),

    #' @field n_batch `ìnteger(1)`\cr
    #' Number of batches stored in the archive.
    n_batch = function() {
      if (is.null(self$data$batch_nr)) {
        0L
      }
      else {
        max(self$data$batch_nr)
      }
    },

    #' @field cols_x `character()`\cr
    cols_x = function() self$search_space$ids(),

    #' @field cols_y `character()`\cr
    cols_y = function() self$codomain$ids()
    # idx_unevaled = function() self$data$y
  ),
)
