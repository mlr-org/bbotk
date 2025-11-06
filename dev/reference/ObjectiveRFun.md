# Objective interface with custom R function

Objective interface where the user can pass a custom R function that
expects a list as input. If the return of the function is unnamed, it is
named with the ids of the codomain.

## See also

[ObjectiveRFunMany](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFunMany.md),
[ObjectiveRFunDt](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFunDt.md)

## Super class

[`bbotk::Objective`](https://bbotk.mlr-org.com/dev/reference/Objective.md)
-\> `ObjectiveRFun`

## Active bindings

- `fun`:

  (`function`)  
  Objective function.

## Methods

### Public methods

- [`ObjectiveRFun$new()`](#method-ObjectiveRFun-new)

- [`ObjectiveRFun$eval()`](#method-ObjectiveRFun-eval)

- [`ObjectiveRFun$clone()`](#method-ObjectiveRFun-clone)

Inherited methods

- [`bbotk::Objective$eval_dt()`](https://bbotk.mlr-org.com/dev/reference/Objective.html#method-eval_dt)
- [`bbotk::Objective$eval_many()`](https://bbotk.mlr-org.com/dev/reference/Objective.html#method-eval_many)
- [`bbotk::Objective$format()`](https://bbotk.mlr-org.com/dev/reference/Objective.html#method-format)
- [`bbotk::Objective$help()`](https://bbotk.mlr-org.com/dev/reference/Objective.html#method-help)
- [`bbotk::Objective$print()`](https://bbotk.mlr-org.com/dev/reference/Objective.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ObjectiveRFun$new(
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
  R function that encodes objective and expects a list with the input
  for a single point (e.g. `list(x1 = 1, x2 = 2)`) and returns the
  result either as a numeric vector or a list (e.g. `list(y = 3)`).

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

### Method [`eval()`](https://rdrr.io/r/base/eval.html)

Evaluates input value(s) on the objective function. Calls the R function
supplied by the user.

#### Usage

    ObjectiveRFun$eval(xs)

#### Arguments

- `xs`:

  Input values.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ObjectiveRFun$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# define the objective function
fun = function(xs) {
  list(y = - (xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
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
objective = ObjectiveRFun$new(
  fun = fun,
  domain = domain,
  codomain = codomain,
  properties = "deterministic"
)

# evaluate objective function
objective$eval(list(x1 = 1, x2 = 2))
#> $y
#> [1] -16
#> 

# evaluate multiple input values
objective$eval_many(list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4)))
#>        y
#>    <num>
#> 1:   -16
#> 2:   -40

# evaluate multiple input values as data.table
objective$eval_dt(data.table::data.table(x1 = 1:2, x2 = 3:4))
#>        y
#>    <num>
#> 1:   -27
#> 2:   -39
```
