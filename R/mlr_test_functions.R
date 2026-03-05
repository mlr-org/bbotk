#' @include ObjectiveRFun.R
#'
#' @title Dictionary of Optimization Test Functions
#'
#' @usage NULL
#' @format [R6::R6Class] object inheriting from [mlr3misc::Dictionary].
#'
#' @description
#' A simple [mlr3misc::Dictionary] storing well-known optimization test functions
#' as [ObjectiveRFun] objects.
#'
#' Each objective has two additional fields beyond the standard [ObjectiveRFun] interface:
#' * `optimum` (`numeric(1)`) - Known global optimum value (f*).
#' * `optimum_x` (`list()`) - List of known global optima (each a named list).
#'
#' For a more convenient way to retrieve test functions, see [otfun()]/[otfuns()].
#'
#' @section Methods:
#' See [mlr3misc::Dictionary].
#'
#' @section S3 methods:
#' * `as.data.table(dict, ..., objects = FALSE)`\cr
#'   [mlr3misc::Dictionary] -> [data.table::data.table()]\cr
#'   Returns a [data.table::data.table()] with fields "key", "label", "optimum",
#'   and "optimum_x" as columns.
#'   If `objects` is set to `TRUE`, the constructed objects are returned in the list column named `object`.
#'
#' @seealso
#' Sugar functions: [otfun()], [otfuns()]
#'
#' @export
#' @examples
#' as.data.table(mlr_test_functions)
#' obj = mlr_test_functions$get("branin")
#' obj$eval(list(x1 = 0, x2 = 0))
mlr_test_functions = R6Class("DictionaryTestFunction", inherit = Dictionary,
  cloneable = FALSE)$new()

#' @export
as.data.table.DictionaryTestFunction = function(x, ..., objects = FALSE) {
  assert_flag(objects)

  setkeyv(map_dtr(x$keys(), function(key) {
    obj = x$get(key)
    insert_named(
      list(
        key = key,
        label = obj$label,
        optimum = obj$optimum,
        optimum_x = list(obj$optimum_x)
      ),
      if (objects) list(object = list(obj))
    )
  }, .fill = TRUE), "key")[]
}

#' @title Objective Test Function
#'
#' @description
#' An [ObjectiveRFun] subclass for well-known optimization test functions.
#' Adds `optimum` and `optimum_x` fields with the known global optimum.
#'
#' @export
ObjectiveTestFunction = R6Class("ObjectiveTestFunction",
  inherit = ObjectiveRFun,
  public = list(

    #' @field optimum (`numeric(1)`)\cr
    #' Known global optimum value (f*).
    optimum = NULL,

    #' @field optimum_x (`list()`)\cr
    #' List of known global optima, each a named list of input values.
    optimum_x = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    #'
    #' @param fun (`function`)\cr
    #' Objective function `function(xs)`.
    #' @param id (`character(1)`).
    #' @param label (`character(1)`).
    #' @param optimum (`numeric(1)`)\cr
    #' Known global optimum value.
    #' @param optimum_x (`list()`)\cr
    #' List of known global optima.
    #' @template param_domain
    #' @template param_codomain
    #' @template param_constants
    initialize = function(fun, domain, codomain = NULL, id, label, optimum, optimum_x, constants = ps()) {
      super$initialize(
        fun = fun,
        domain = domain,
        codomain = codomain,
        id = id,
        properties = "deterministic",
        constants = constants,
        check_values = FALSE
      )
      # ObjectiveRFun hardcodes label, override via private field
      private$.label = label
      self$optimum = assert_number(optimum)
      self$optimum_x = assert_list(optimum_x, types = "list")
    }
  )
)

make_test_function = function(id, label, fun, domain, codomain = NULL, optimum, optimum_x, constants = ps()) {
  if (is.null(codomain)) {
    codomain = ps(y = p_dbl(tags = "minimize"))
  }

  force(fun)
  force(domain)
  force(codomain)
  force(id)
  force(label)
  force(optimum)
  force(optimum_x)
  force(constants)

  mlr_test_functions$add(id, function() {
    ObjectiveTestFunction$new(
      fun = fun,
      domain = domain$clone(deep = TRUE),
      codomain = codomain$clone(deep = TRUE),
      id = id,
      label = label,
      optimum = optimum,
      optimum_x = optimum_x,
      constants = constants$clone(deep = TRUE)
    )
  })
}

# Branin
make_test_function(
  id = "branin",
  label = "Branin",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = (x2 - 5.1 / (4 * pi^2) * x1^2 + 5 / pi * x1 - 6)^2 +
      10 * (1 - 1 / (8 * pi)) * cos(x1) + 10)
  },
  domain = ps(x1 = p_dbl(-5, 10), x2 = p_dbl(0, 15)),
  optimum = 0.397887,
  optimum_x = list(
    list(x1 = -pi, x2 = 12.275),
    list(x1 = pi, x2 = 2.275),
    list(x1 = 9.42478, x2 = 2.475)
  )
)

# Branin-Wu (multi-fidelity variant; optimum values hold for fidelity = 1)
make_test_function(
  id = "branin_wu",
  label = "Branin-Wu",
  fun = function(xs, fidelity = 1) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = (x2 - (5.1 / (4 * pi^2) - 0.1 * (1 - fidelity)) * x1^2 +
      5 / pi * x1 - 6)^2 + 10 * (1 - 1 / (8 * pi)) * cos(x1) + 10)
  },
  domain = ps(x1 = p_dbl(-5, 10), x2 = p_dbl(0, 15)),
  constants = ps(fidelity = p_dbl(0, 1, init = 1)),
  optimum = 0.397887,
  optimum_x = list(
    list(x1 = -pi, x2 = 12.275),
    list(x1 = pi, x2 = 2.275),
    list(x1 = 9.42478, x2 = 2.475)
  )
)

# Six-Hump Camel
make_test_function(
  id = "six_hump_camel",
  label = "Six-Hump Camel",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = (4 - 2.1 * x1^2 + x1^4 / 3) * x1^2 + x1 * x2 +
      (-4 + 4 * x2^2) * x2^2)
  },
  domain = ps(x1 = p_dbl(-3, 3), x2 = p_dbl(-2, 2)),
  optimum = -1.0316,
  optimum_x = list(
    list(x1 = 0.0898, x2 = -0.7126),
    list(x1 = -0.0898, x2 = 0.7126)
  )
)

# Goldstein-Price
make_test_function(
  id = "goldstein_price",
  label = "Goldstein-Price",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    a = 1 + (x1 + x2 + 1)^2 * (19 - 14 * x1 + 3 * x1^2 - 14 * x2 +
      6 * x1 * x2 + 3 * x2^2)
    b = 30 + (2 * x1 - 3 * x2)^2 * (18 - 32 * x1 + 12 * x1^2 + 48 * x2 -
      36 * x1 * x2 + 27 * x2^2)
    list(y = a * b)
  },
  domain = ps(x1 = p_dbl(-2, 2), x2 = p_dbl(-2, 2)),
  optimum = 3,
  optimum_x = list(
    list(x1 = 0, x2 = -1)
  )
)

# McCormick
make_test_function(
  id = "mccormick",
  label = "McCormick",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = sin(x1 + x2) + (x1 - x2)^2 - 1.5 * x1 + 2.5 * x2 + 1)
  },
  domain = ps(x1 = p_dbl(-1.5, 4), x2 = p_dbl(-3, 4)),
  optimum = -1.9133,
  optimum_x = list(
    list(x1 = -0.54719, x2 = -1.54719)
  )
)

# Beale
make_test_function(
  id = "beale",
  label = "Beale",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = (1.5 - x1 + x1 * x2)^2 + (2.25 - x1 + x1 * x2^2)^2 +
      (2.625 - x1 + x1 * x2^3)^2)
  },
  domain = ps(x1 = p_dbl(-4.5, 4.5), x2 = p_dbl(-4.5, 4.5)),
  optimum = 0,
  optimum_x = list(
    list(x1 = 3, x2 = 0.5)
  )
)

# Rosenbrock
make_test_function(
  id = "rosenbrock",
  label = "Rosenbrock",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = 100 * (x2 - x1^2)^2 + (1 - x1)^2)
  },
  domain = ps(x1 = p_dbl(-5, 10), x2 = p_dbl(-5, 10)),
  optimum = 0,
  optimum_x = list(
    list(x1 = 1, x2 = 1)
  )
)

# Himmelblau
make_test_function(
  id = "himmelblau",
  label = "Himmelblau",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = (x1^2 + x2 - 11)^2 + (x1 + x2^2 - 7)^2)
  },
  domain = ps(x1 = p_dbl(-5, 5), x2 = p_dbl(-5, 5)),
  optimum = 0,
  optimum_x = list(
    list(x1 = 3, x2 = 2),
    list(x1 = -2.805118, x2 = 3.131312),
    list(x1 = -3.779310, x2 = -3.283186),
    list(x1 = 3.584428, x2 = -1.848126)
  )
)

# Cross-in-Tray
make_test_function(
  id = "cross_in_tray",
  label = "Cross-in-Tray",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = -0.0001 * (abs(sin(x1) * sin(x2) *
      exp(abs(100 - sqrt(x1^2 + x2^2) / pi))) + 1)^0.1)
  },
  domain = ps(x1 = p_dbl(-10, 10), x2 = p_dbl(-10, 10)),
  optimum = -2.06261,
  optimum_x = list(
    list(x1 = 1.3491, x2 = 1.3491),
    list(x1 = 1.3491, x2 = -1.3491),
    list(x1 = -1.3491, x2 = 1.3491),
    list(x1 = -1.3491, x2 = -1.3491)
  )
)

# Eggholder
make_test_function(
  id = "eggholder",
  label = "Eggholder",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = -(x2 + 47) * sin(sqrt(abs(x2 + x1 / 2 + 47))) -
      x1 * sin(sqrt(abs(x1 - (x2 + 47)))))
  },
  domain = ps(x1 = p_dbl(-512, 512), x2 = p_dbl(-512, 512)),
  optimum = -959.6407,
  optimum_x = list(
    list(x1 = 512, x2 = 404.2319)
  )
)

# Holder Table
make_test_function(
  id = "holder_table",
  label = "Holder Table",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = -abs(sin(x1) * cos(x2) *
      exp(abs(1 - sqrt(x1^2 + x2^2) / pi))))
  },
  domain = ps(x1 = p_dbl(-10, 10), x2 = p_dbl(-10, 10)),
  optimum = -19.2085,
  optimum_x = list(
    list(x1 = 8.05502, x2 = 9.66459),
    list(x1 = 8.05502, x2 = -9.66459),
    list(x1 = -8.05502, x2 = 9.66459),
    list(x1 = -8.05502, x2 = -9.66459)
  )
)

# Sphere
make_test_function(
  id = "sphere",
  label = "Sphere",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = x1^2 + x2^2)
  },
  domain = ps(x1 = p_dbl(-5.12, 5.12), x2 = p_dbl(-5.12, 5.12)),
  optimum = 0,
  optimum_x = list(
    list(x1 = 0, x2 = 0)
  )
)

# Rastrigin
make_test_function(
  id = "rastrigin",
  label = "Rastrigin",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = 20 + (x1^2 - 10 * cos(2 * pi * x1)) +
      (x2^2 - 10 * cos(2 * pi * x2)))
  },
  domain = ps(x1 = p_dbl(-5.12, 5.12), x2 = p_dbl(-5.12, 5.12)),
  optimum = 0,
  optimum_x = list(
    list(x1 = 0, x2 = 0)
  )
)

# Styblinski-Tang
make_test_function(
  id = "styblinski_tang",
  label = "Styblinski-Tang",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = 0.5 * ((x1^4 - 16 * x1^2 + 5 * x1) +
      (x2^4 - 16 * x2^2 + 5 * x2)))
  },
  domain = ps(x1 = p_dbl(-5, 5), x2 = p_dbl(-5, 5)),
  optimum = -78.33198,
  optimum_x = list(
    list(x1 = -2.903534, x2 = -2.903534)
  )
)

# Schwefel
make_test_function(
  id = "schwefel",
  label = "Schwefel",
  fun = function(xs) {
    x1 = xs[["x1"]]
    x2 = xs[["x2"]]
    list(y = 2 * 418.9829 - x1 * sin(sqrt(abs(x1))) -
      x2 * sin(sqrt(abs(x2))))
  },
  domain = ps(x1 = p_dbl(-500, 500), x2 = p_dbl(-500, 500)),
  optimum = 0,
  optimum_x = list(
    list(x1 = 420.9687, x2 = 420.9687)
  )
)
