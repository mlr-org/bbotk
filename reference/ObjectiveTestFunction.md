# Objective Test Function

An [ObjectiveRFun](https://bbotk.mlr-org.com/reference/ObjectiveRFun.md)
subclass for well-known optimization test functions. Adds `optimum` and
`optimum_x` fields with the known global optimum.

## Super classes

[`bbotk::Objective`](https://bbotk.mlr-org.com/reference/Objective.md)
-\>
[`bbotk::ObjectiveRFun`](https://bbotk.mlr-org.com/reference/ObjectiveRFun.md)
-\> `ObjectiveTestFunction`

## Public fields

- `optimum`:

  (`numeric(1)`)  
  Known global optimum value (f\*).

- `optimum_x`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  List of known global optima, each a named list of input values.

## Methods

### Public methods

- [`ObjectiveTestFunction$new()`](#method-ObjectiveTestFunction-new)

- [`ObjectiveTestFunction$clone()`](#method-ObjectiveTestFunction-clone)

Inherited methods

- [`bbotk::Objective$eval_dt()`](https://bbotk.mlr-org.com/reference/Objective.html#method-eval_dt)
- [`bbotk::Objective$eval_many()`](https://bbotk.mlr-org.com/reference/Objective.html#method-eval_many)
- [`bbotk::Objective$format()`](https://bbotk.mlr-org.com/reference/Objective.html#method-format)
- [`bbotk::Objective$help()`](https://bbotk.mlr-org.com/reference/Objective.html#method-help)
- [`bbotk::Objective$print()`](https://bbotk.mlr-org.com/reference/Objective.html#method-print)
- [`bbotk::ObjectiveRFun$eval()`](https://bbotk.mlr-org.com/reference/ObjectiveRFun.html#method-eval)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ObjectiveTestFunction$new(
      fun,
      domain,
      codomain = NULL,
      id,
      label,
      optimum,
      optimum_x,
      constants = ps()
    )

#### Arguments

- `fun`:

  (`function`)  
  Objective function `function(xs)`.

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

- `label`:

  (`character(1)`).

- `optimum`:

  (`numeric(1)`)  
  Known global optimum value.

- `optimum_x`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  List of known global optima.

- `constants`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Changeable constants or parameters that are not subject to tuning can
  be stored and accessed here.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ObjectiveTestFunction$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
