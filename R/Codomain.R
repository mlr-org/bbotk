#' @title Codomain of Function
#'
#' @description
#' A [paradox::ParamSet] defining the codomain of a function.
#' The parameter set must contain at least one target parameter tagged with
#' `"minimize"`, `"maximize"`, or `"learn"`.
#' The codomain may contain extra parameters which are ignored when calling the [Archive] methods
#' `$best()`, `$nds_selection()` and `$cols_y`.
#' This class is usually constructed internally from a [paradox::ParamSet] when [Objective] is initialized.
#'
#' @export
#' @examples
#'
#' # define objective function
#' fun = function(xs) {
#'   c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
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
#'   y = p_dbl(tags = "maximize"),
#'   time = p_dbl()
#' )
#'
#' # create Objective object
#' objective = ObjectiveRFun$new(
#'   fun = fun,
#'   domain = domain,
#'   codomain = codomain,
#'   properties = "deterministic"
#' )
Codomain = R6Class(
  "Codomain",
  inherit = paradox::ParamSet,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param params (`list()`)\cr
    #'   Named list with which to initialize the codomain.
    #'   This argument is analogous to [paradox::ParamSet]'s `$initialize()` `params` argument.
    initialize = function(params) {
      assert_list(params)

      super$initialize(params)

      # only check for codomain parameters tagged with minimize, maximize, or learn
      for (id in self$target_ids) {
        # all numeric
        if (!self$is_number[id]) {
          stopf("%s in codomain is not numeric", id)
        }
        # every parameter's tags contain at most one of the target tags
        if (sum(self$tags[[id]] %in% c("minimize", "maximize", "learn")) > 1) {
          stopf("%s in codomain contains multiple target tags", id)
        }
      }

      # assert at least one target parameter
      if (!any(self$is_target) && self$length) {
        stop("Codomain contains no parameter tagged with 'minimize', 'maximize', or 'learn'")
      }
    }
  ),

  active = list(
    #' @field is_target (named `logical()`)\cr
    #' Position is `TRUE` for target parameters.
    is_target = function() {
      self$ids() %in% self$target_ids
    },

    #' @field target_length (`integer()`)\cr
    #' Returns number of target parameters.
    target_length = function() {
      length(self$target_ids)
    },

    #' @field target_ids (`character()`)\cr
    #' IDs of contained target parameters.
    target_ids = function() {
      if ("any_tags" %in% names(formals(self$ids))) {
        self$ids(any_tags = c("minimize", "maximize", "learn"))
      } else {
        # old paradox
        self$ids()[map_lgl(self$tags, function(x) any(c("minimize", "maximize", "learn") %in% x))]
      }
    },

    #' @field target_tags (named `list()` of `character()`)\cr
    #' Tags of target parameters.
    target_tags = function() {
      self$tags[self$target_ids]
    },

    #' @field maximization_to_minimization (`integer()`)\cr
    #' Returns a numeric vector with values -1 and 1. Multiply with the outcome
    #' of a maximization problem to turn it into a minimization problem.
    maximization_to_minimization = function() {
      .Deprecated("direction", old = "maximization_to_minimization")
      ifelse(map_lgl(self$target_tags, has_element, "minimize"), 1L, -1L)
    },

    #' @field direction (`integer()`)\cr
    #' Returns `1` for minimization, `-1` for maximization, and `0` for learning.
    #' If the codomain contains multiple parameters an integer vector is returned.
    #' Multiply with the outcome of a maximization problem to turn it into a minimization problem.
    direction = function() {
      map_int(self$target_tags, function(tags) {
        if ("minimize" %in% tags) {
          1L
        } else if ("maximize" %in% tags) {
          -1L
        } else {
          0L
        } # learn
      })
    }
  )
)

# Paradox 2 upgrades the inherited ParamSet state itself, then asks bbotk only
# to reconstruct the additive Codomain surface. These namespace-local hooks
# deliberately inspect no legacy methods or private ParamSet representation.
.inspect_legacy_codomain = function(x) {
  list(
    state = NULL,
    dependencies = structure(list(), names = character())
  )
}

.rebuild_legacy_codomain = function(base, state, dependencies) {
  Codomain$new(base$domains)
}

.register_paradox_codomain_upgrader = function() {
  if (!"register_paradox_object_upgrader" %in%
      getNamespaceExports("paradox")) {
    return(invisible(FALSE))
  }
  getExportedValue("paradox", "register_paradox_object_upgrader")(
    owner_package = "bbotk",
    legacy_class = c("Codomain", "ParamSet", "R6"),
    migration_kind = "additive",
    inspector = ".inspect_legacy_codomain",
    rebuilder = ".rebuild_legacy_codomain",
    retired_bindings = character()
  )
  invisible(TRUE)
}

.leanify_codomain_v2 = function(
  generator, namespace = generator$parent_env) {
  old_classname = generator$classname
  on.exit({
    generator$classname = old_classname
  })
  generator$classname = "bbotkv2_Codomain"
  mlr3misc::leanify_r6(generator, namespace)
  invisible(TRUE)
}

.legacy_codomain_graph_api = function() {
  "upgrade_paradox_object_graph" %in% getNamespaceExports("paradox")
}

.upgrade_legacy_codomain_first_use = function(self, target) {
  if (!.legacy_codomain_graph_api()) return(FALSE)
  action = getOption("paradox.legacy_object_action", "error")
  if (!identical(action, "upgrade")) {
    stop(
      sprintf(
        paste0(
          "A serialized Paradox 1 object tried to call `bbotk::%s`. ",
          "Upgrade the containing object with ",
          "`upgrade_paradox_object_graph(x)`. To perform this migration ",
          "silently on first use, set ",
          "`options(paradox.legacy_object_action = \"upgrade\")`."
        ),
        target
      ),
      call. = FALSE
    )
  }
  getExportedValue("paradox", "upgrade_paradox_object_graph")(self)
  TRUE
}

.replay_codomain_active = function(self, member) {
  if (!exists(member, envir = self, inherits = FALSE) ||
      !bindingIsActive(member, self)) {
    stop(sprintf(
      "The legacy Codomain binding `%s` was retired by Paradox 2",
      member
    ))
  }
  activeBindingFunction(member, self)()
}

# bbotk 1.x serialized these owner-level Codomain stubs. Keep their exact
# targets cold: current objects use the versioned targets installed below,
# while historical objects either fail with migration guidance or upgrade
# before replaying the requested operation.
.__Codomain__initialize = function(self, private, super, params) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__initialize")) {
    return(.__bbotkv2_Codomain__initialize(
      self, private, super, params
    ))
  }
  self$initialize(params)
}

.__Codomain__clone = function(self, private, super, deep = FALSE) {
  if (!.upgrade_legacy_codomain_first_use(self, ".__Codomain__clone")) {
    return(.__bbotkv2_Codomain__clone(
      self, private, super, deep = deep
    ))
  }
  self$clone(deep = deep)
}

.__Codomain__is_target = function(self, private, super) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__is_target")) {
    return(.__bbotkv2_Codomain__is_target(self, private, super))
  }
  .replay_codomain_active(self, "is_target")
}

.__Codomain__target_length = function(self, private, super) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__target_length")) {
    return(.__bbotkv2_Codomain__target_length(self, private, super))
  }
  .replay_codomain_active(self, "target_length")
}

.__Codomain__target_ids = function(self, private, super) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__target_ids")) {
    return(.__bbotkv2_Codomain__target_ids(self, private, super))
  }
  .replay_codomain_active(self, "target_ids")
}

.__Codomain__target_tags = function(self, private, super) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__target_tags")) {
    return(.__bbotkv2_Codomain__target_tags(self, private, super))
  }
  .replay_codomain_active(self, "target_tags")
}

.__Codomain__maximization_to_minimization = function(
    self, private, super) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__maximization_to_minimization")) {
    return(.__bbotkv2_Codomain__maximization_to_minimization(
      self, private, super
    ))
  }
  .replay_codomain_active(self, "maximization_to_minimization")
}

.__Codomain__direction = function(self, private, super) {
  if (!.upgrade_legacy_codomain_first_use(
      self, ".__Codomain__direction")) {
    return(.__bbotkv2_Codomain__direction(self, private, super))
  }
  .replay_codomain_active(self, "direction")
}
