# Objective interface for basic R functions.

Objective interface where user can pass an R function that works on an
`data.table()`.

## See also

[ObjectiveRFun](https://bbotk.mlr-org.com/reference/ObjectiveRFun.md),
[ObjectiveRFunMany](https://bbotk.mlr-org.com/reference/ObjectiveRFunMany.md)

## Super class

[`bbotk::Objective`](https://bbotk.mlr-org.com/reference/Objective.md)
-\> `ObjectiveRFunDt`

## Active bindings

- `fun`:

  (`function`)  
  Objective function.

## Methods

### Public methods

- [`ObjectiveRFunDt$new()`](#method-ObjectiveRFunDt-new)

- [`ObjectiveRFunDt$eval_many()`](#method-ObjectiveRFunDt-eval_many)

- [`ObjectiveRFunDt$eval_dt()`](#method-ObjectiveRFunDt-eval_dt)

- [`ObjectiveRFunDt$clone()`](#method-ObjectiveRFunDt-clone)

Inherited methods

- [`bbotk::Objective$eval()`](https://bbotk.mlr-org.com/reference/Objective.html#method-eval)
- [`bbotk::Objective$format()`](https://bbotk.mlr-org.com/reference/Objective.html#method-format)
- [`bbotk::Objective$help()`](https://bbotk.mlr-org.com/reference/Objective.html#method-help)
- [`bbotk::Objective$print()`](https://bbotk.mlr-org.com/reference/Objective.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ObjectiveRFunDt$new(
      fun,
      domain,
      codomain = NULL,
      id = "function",
      properties = character(),
      constants = ps(),
      packages = character(),
      check_values = TRUE
    )

#### Arguments

- `fun`:

  (`function`)  
  R function that encodes objective and expects an `data.table()` as
  input whereas each point is represented by one row.

- `domain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies domain of function. The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  should describe all possible input parameters of the objective
  function. This includes their `id`, their types and the possible
  range.

- `codomain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies codomain of function. Most importantly the tags of each
  output "Parameter" define whether it should be minimized or maximized.
  The default is to minimize each component.

- `id`:

  (`character(1)`).

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html)).

- `constants`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Changeable constants or parameters that are not subject to tuning can
  be stored and accessed here.

- `packages`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of required packages to run the objective function.

- `check_values`:

  (`logical(1)`)  
  Should points before the evaluation and the results be checked for
  validity?

------------------------------------------------------------------------

### Method `eval_many()`

Evaluates multiple input values received as a list, converted to a
`data.table()` on the objective function. Missing columns in xss are
filled with `NA`s in `xdt`.

#### Usage

    ObjectiveRFunDt$eval_many(xss)

#### Arguments

- `xss`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  A list of lists that contains multiple x values, e.g.
  `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.

#### Returns

[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
that contains one y-column for single-criteria functions and multiple
y-columns for multi-criteria functions, e.g. `data.table(y = 1:2)` or
`data.table(y1 = 1:2, y2 = 3:4)`.

------------------------------------------------------------------------

### Method `eval_dt()`

Evaluates multiple input values on the objective function supplied by
the user.

#### Usage

    ObjectiveRFunDt$eval_dt(xdt)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

#### Returns

data.table::data.table()\] that contains one y-column for
single-criteria functions and multiple y-columns for multi-criteria
functions, e.g. `data.table(y = 1:2)` or
`data.table(y1 = 1:2, y2 = 3:4)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ObjectiveRFunDt$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# define objective function
fun = function(xdt) {
  data.table::data.table(y = xdt$x1 + xdt$x2)
}

# set domain
domain = ps(
  x1 = p_dbl(-10, 10),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y = p_dbl(tags = "maximize")
)

# create objective
objective = ObjectiveRFunDt$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# evaluate objective function
objective$eval(list(x1 = 1, x2 = 2))
#> $y
#> [1] 3
#> 

# evaluate multiple input values
objective$eval_many(list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4)))
#>        y
#>    <num>
#> 1:     3
#> 2:     7

# evaluate multiple input values as data.table
objective$eval_dt(data.table::data.table(x1 = 1:2, x2 = 3:4))
#>        y
#>    <int>
#> 1:     4
#> 2:     6
```
