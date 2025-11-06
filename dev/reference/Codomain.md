# Codomain of Function

A
[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
defining the codomain of a function. The parameter set must contain at
least one target parameter tagged with `"minimize"` or `"maximize"`. The
codomain may contain extra parameters which are ignored when calling the
[Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md) methods
`$best()`, `$nds_selection()` and `$cols_y`. This class is usually
constructed internally from a
[paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
when [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md)
is initialized.

## Super class

[`paradox::ParamSet`](https://paradox.mlr-org.com/reference/ParamSet.html)
-\> `Codomain`

## Active bindings

- `is_target`:

  (named [`logical()`](https://rdrr.io/r/base/logical.html))  
  Position is `TRUE` for target parameters.

- `target_length`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Returns number of target parameters.

- `target_ids`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  IDs of contained target parameters.

- `target_tags`:

  (named [`list()`](https://rdrr.io/r/base/list.html) of
  [`character()`](https://rdrr.io/r/base/character.html))  
  Tags of target parameters.

- `maximization_to_minimization`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Returns a numeric vector with values -1 and 1. Multiply with the
  outcome of a maximization problem to turn it into a minimization
  problem.

- `direction`:

  ([`integer()`](https://rdrr.io/r/base/integer.html))  
  Returns `1` for minimization and `-1` for maximization. If the
  codomain contains multiple parameters an integer vector is returned.
  Multiply with the outcome of a maximization problem to turn it into a
  minimization problem.

## Methods

### Public methods

- [`Codomain$new()`](#method-Codomain-new)

- [`Codomain$clone()`](#method-Codomain-clone)

Inherited methods

- [`paradox::ParamSet$add_dep()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-add_dep)
- [`paradox::ParamSet$aggr_internal_tuned_values()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-aggr_internal_tuned_values)
- [`paradox::ParamSet$assert()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-assert)
- [`paradox::ParamSet$assert_dt()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-assert_dt)
- [`paradox::ParamSet$check()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-check)
- [`paradox::ParamSet$check_dependencies()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-check_dependencies)
- [`paradox::ParamSet$check_dt()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-check_dt)
- [`paradox::ParamSet$convert_internal_search_space()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-convert_internal_search_space)
- [`paradox::ParamSet$disable_internal_tuning()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-disable_internal_tuning)
- [`paradox::ParamSet$flatten()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-flatten)
- [`paradox::ParamSet$format()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-format)
- [`paradox::ParamSet$get_domain()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-get_domain)
- [`paradox::ParamSet$get_values()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-get_values)
- [`paradox::ParamSet$ids()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-ids)
- [`paradox::ParamSet$print()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-print)
- [`paradox::ParamSet$qunif()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-qunif)
- [`paradox::ParamSet$search_space()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-search_space)
- [`paradox::ParamSet$set_values()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-set_values)
- [`paradox::ParamSet$subset()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-subset)
- [`paradox::ParamSet$subspaces()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-subspaces)
- [`paradox::ParamSet$test()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-test)
- [`paradox::ParamSet$test_constraint()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-test_constraint)
- [`paradox::ParamSet$test_constraint_dt()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-test_constraint_dt)
- [`paradox::ParamSet$test_dt()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-test_dt)
- [`paradox::ParamSet$trafo()`](https://paradox.mlr-org.com/reference/ParamSet.html#method-trafo)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    Codomain$new(params)

#### Arguments

- `params`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  Named list with which to initialize the codomain. This argument is
  analogous to
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)'s
  `$initialize()` `params` argument.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Codomain$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# define objective function
fun = function(xs) {
  c(y = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y = p_dbl(tags = "maximize"),
  time = p_dbl()
)

# create Objective object
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)
```
