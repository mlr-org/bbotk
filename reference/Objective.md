# Objective Function with Domain and Codomain

The `Objective` class describes a black-box objective function that maps
an arbitrary domain to a numerical codomain.

## Details

`Objective` objects can have the following properties: `"noisy"`,
`"deterministic"`, `"single-crit"` and `"multi-crit"`.

## See also

[ObjectiveRFun](https://bbotk.mlr-org.com/reference/ObjectiveRFun.md),
[ObjectiveRFunMany](https://bbotk.mlr-org.com/reference/ObjectiveRFunMany.md),
[ObjectiveRFunDt](https://bbotk.mlr-org.com/reference/ObjectiveRFunDt.md)

## Public fields

- `callbacks`:

  (list of
  [mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html))  
  Callbacks applied during the optimization.

- `context`:

  ([ContextBatch](https://bbotk.mlr-org.com/reference/ContextBatch.md))  
  Stores the context for the callbacks.

- `id`:

  (`character(1)`)).

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html)).

- `domain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies domain of function, hence its input parameters, their types
  and ranges.

- `codomain`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies codomain of function, hence its feasible values.

- `constants`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)).  
  Changeable constants or parameters that are not subject to tuning can
  be stored and accessed here. Set constant values are passed to
  `$.eval()` and `$.eval_many()` as named arguments.

- `check_values`:

  (`logical(1)`)  

## Active bindings

- `label`:

  (`character(1)`)  
  Label for this object. Can be used in tables, plot and text output
  instead of the ID.

- `man`:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

- `xdim`:

  (`integer(1)`)  
  Dimension of domain.

- `ydim`:

  (`integer(1)`)  
  Dimension of codomain.

- `packages`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of required packages to run the objective function. Packages are
  loaded on each worker when the objective is called by
  [OptimizerAsync](https://bbotk.mlr-org.com/reference/OptimizerAsync.md).

## Methods

### Public methods

- [`Objective$new()`](#method-Objective-new)

- [`Objective$format()`](#method-Objective-format)

- [`Objective$print()`](#method-Objective-print)

- [`Objective$eval()`](#method-Objective-eval)

- [`Objective$eval_many()`](#method-Objective-eval_many)

- [`Objective$eval_dt()`](#method-Objective-eval_dt)

- [`Objective$help()`](#method-Objective-help)

- [`Objective$clone()`](#method-Objective-clone)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    Objective$new(
      id = "f",
      properties = character(),
      domain,
      codomain = ps(y = p_dbl(tags = "minimize")),
      constants = ps(),
      packages = character(),
      check_values = TRUE,
      label = NA_character_,
      man = NA_character_
    )

#### Arguments

- `id`:

  (`character(1)`).

- `properties`:

  ([`character()`](https://rdrr.io/r/base/character.html)).

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

- `label`:

  (`character(1)`)  
  Label for this object. Can be used in tables, plot and text output
  instead of the ID.

- `man`:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

------------------------------------------------------------------------

### Method [`format()`](https://rdrr.io/r/base/format.html)

Helper for print outputs.

#### Usage

    Objective$format(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print method.

#### Usage

    Objective$print()

#### Returns

[`character()`](https://rdrr.io/r/base/character.html).

------------------------------------------------------------------------

### Method [`eval()`](https://rdrr.io/r/base/eval.html)

Evaluates a single input value on the objective function. If
`check_values = TRUE`, the validity of the point as well as the validity
of the result is checked.

#### Usage

    Objective$eval(xs)

#### Arguments

- `xs`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  A list that contains a single x value, e.g. `list(x1 = 1, x2 = 2)`.

#### Returns

[`list()`](https://rdrr.io/r/base/list.html) that contains the result of
the evaluation, e.g. `list(y = 1)`. The list can also contain additional
*named* entries that will be stored in the archive if called through the
[OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md).
These extra entries are referred to as *extras*.

------------------------------------------------------------------------

### Method `eval_many()`

Evaluates multiple input values on the objective function. If
`check_values = TRUE`, the validity of the points as well as the
validity of the results are checked. *bbotk* does not take care of
parallelization. If the function should make use of parallel computing,
it has to be implemented by deriving from this class and overwriting
this function.

#### Usage

    Objective$eval_many(xss)

#### Arguments

- `xss`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  A list of lists that contains multiple x values, e.g.
  `list(list(x1 = 1, x2 = 2), list(x1 = 3, x2 = 4))`.

#### Returns

data.table::data.table()\] that contains one y-column for
single-criteria functions and multiple y-columns for multi-criteria
functions, e.g. `data.table(y = 1:2)` or
`data.table(y1 = 1:2, y2 = 3:4)`. It may also contain additional columns
that will be stored in the archive if called through the
[OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md).
These extra columns are referred to as *extras*.

------------------------------------------------------------------------

### Method `eval_dt()`

Evaluates multiple input values on the objective function

#### Usage

    Objective$eval_dt(xdt)

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

### Method [`help()`](https://rdrr.io/r/utils/help.html)

Opens the corresponding help page referenced by field `$man`.

#### Usage

    Objective$help()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Objective$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
