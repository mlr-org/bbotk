#' @title Container for objective function evaluations
#'
#' @usage NULL
#' @format [R6::R6Class] object.
#'
#' @description
#' Container around a data.table which stores all performed [Objective] function calls by the [Evaluator].
#'
#' @section Construction:
#' ```
#' archive = Archive$new(search_space, codomain, minimize)
#' ```
#'
#' * `search_space` :: [paradox::ParamSet]\cr
#'   Search space that is logged into archive.
#' * `codomain` :: [paradox::ParamSet]\cr
#'   Codomain of objective function that is logged into archive.
#' * `minimize` :: named `logical`.
#'   Should objective (component) function be minimized (or maximized)?
#'
#' @section Fields:
#' * `search_space` :: [paradox::ParamSet] from construction\cr
#' * `codomain` :: [paradox::ParamSet] from construction\cr
#' * `minimize` :: named `logical`; from construction
#' * `data` :: [data.table::data.table]\cr
#'   Holds data of the archive.
#' * `n_evals` :: `integer(1)`\cr
#'   Number of evaluations stored in the container.
#'
#' @section Methods:
#' * `add_evals(dt)`\cr
#'   [data.table::data.table] -> `self`\cr
#'   Adds function evaluations to the archive table.
#'
#' @export
#FIXME: doc cols of "data"

Archive = R6Class("Archive",
  public = list(
    data = NULL,
    search_space = NULL,
    codomain = NULL,
    start_time = NULL,

    initialize = function(search_space, codomain) {
      assert_param_set(search_space)
      assert_param_set(codomain)
      self$search_space = search_space
      self$codomain = codomain
      self$start_time = Sys.time()
      self$data = data.table()
    },

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

    get_best = function(m = NULL) {
      m = assert_integerish(m, null.ok = TRUE)

      if (self$n_batch == 0) {
        stop("No results stored in archive")
      }
      if(is.null(m)) {
        m = 1:self$n_batch
      }

      tab = self$data
      tab = tab[batch_nr %in% m,]
      # FIXME: the minimize info needs to be taken from codomain
      order = if (self$codomain$tags[1] == "minimize") 1 else -1
      setorderv(tab, self$codomain$ids(), order = order)
      tab[1,]
    },
    
    #' @description 
    #' Returns data.table which contains all performed [Objective] function
    #' calls.
    #' @param unnest `character()`
    #' Unnested columns are stored in seperate columns instead of list-columns.
    get_data = function(unnest = NULL) {
      dt = copy(self$data)
      assert_choice(unnest, names(dt), null.ok = TRUE)
      
      if(!is.null(unnest)) {
        dt = unnest(dt, unnest, prefix = paste0(unnest, "_"))
      }
      dt[]
    },

    print = function() {
      catf("Archive:")
      print(self$data)
    },

    clear = function() {
      self$data = data.table()
    }
  ),

  active = list(
    n_evals = function() nrow(self$data),
    n_batch = function() if(is.null(self$data$batch_nr)) 0L else max(self$data$batch_nr),
    cols_x = function() self$search_space$ids(),
    cols_y = function() self$codomain$ids()
    # idx_unevaled = function() self$data$y
  ),
)

