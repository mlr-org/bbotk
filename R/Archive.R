#' @title Data Storage
#'
#' @description
#' The `Archive`` class stores all evaluated points and performance scores
#'
#' @details
#' The `Archive` is an abstract class that implements the base functionality each archive must provide.
#'
#' @template field_search_space
#' @template field_codomain
#' @template field_start_time
#' @template field_label
#' @template field_man
#'
#' @template param_search_space
#' @template param_codomain
#' @template param_label
#' @template param_man
#'
#' @export
Archive = R6Class("Archive",
  public = list(

    search_space = NULL,

    codomain = NULL,

    start_time = NULL,

    #' @field check_values (`logical(1)`)\cr
    #' Determines if points and results are checked for validity.
    check_values = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param check_values (`logical(1)`)\cr
    #' Should x-values that are added to the archive be checked for validity?
    #' Search space that is logged into archive.
    initialize = function(
      search_space,
      codomain,
      check_values = FALSE,
      label = NA_character_,
      man = NA_character_
      ) {
      self$search_space = assert_param_set(search_space)
      assert_param_set(codomain)
      # get "codomain" element if present (new paradox) or default to $params (old paradox)
      params = get0("domains", codomain, ifnotfound = codomain$params)
      self$codomain = Codomain$new(params)
      self$check_values = assert_flag(check_values)

      private$.label = assert_string(label, na.ok = TRUE)
      private$.man = assert_string(man, na.ok = TRUE)
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
    print = function() {
      cli_h1(sprintf("%s %s", class(self)[1L], if (is.na(self$label)) "" else paste0("- ", self$label)))
      print(as.data.table(self, unnest = "x_domain"), digits = 1)
    },

    #' @description
    #' Clear all evaluation results from archive.
    clear = function() {
      self$start_time = NULL
      invisible(self)
    },

    #' @description
    #' Opens the corresponding help page referenced by field `$man`.
    help = function() {
      open_help(self$man)
    }
  ),

  active = list(

    #' @field cols_x (`character()`)\cr
    #' Column names of search space parameters.
    cols_x = function() self$search_space$ids(),

    #' @field cols_y (`character()`)\cr
    #' Column names of codomain target parameters.
    cols_y = function() self$codomain$target_ids,

    label = function(rhs) {
      assert_ro_binding(rhs)
      private$.label
    },

    man = function(rhs) {
assert_ro_binding(rhs)
      private$.man
    }
  ),

  private = list(
    .label = NULL,
    .man = NULL
  )
)

