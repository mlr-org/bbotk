# Optimization Instance

The `OptimInstance` specifies an optimization problem for an
[Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md).
Inherits from
[EvalInstance](https://bbotk.mlr-org.com/dev/reference/EvalInstance.md)
and adds optimization-specific functionality.

## Details

`OptimInstance` is an abstract base class that implements the base
functionality each instance must provide. The
[Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) writes
the final result to the `.result` field by using the `$assign_result()`
method. `.result` stores a
[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html)
consisting of x values in the *search space*, (transformed) x values in
the *domain space* and y values in the *codomain space* of the
[Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md). The
user can access the results with active bindings (see below).

## See also

[EvalInstance](https://bbotk.mlr-org.com/dev/reference/EvalInstance.md),
[OptimInstanceBatch](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md),
[OptimInstanceAsync](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.md)

## Super class

[`bbotk::EvalInstance`](https://bbotk.mlr-org.com/dev/reference/EvalInstance.md)
-\> `OptimInstance`

## Public fields

- `progressor`:

  (`progressor()`)  
  Stores `progressor` function.

## Active bindings

- `result`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Get result

- `result_x_search_space`:

  ([data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html))  
  x part of the result in the *search space*.

## Methods

### Public methods

- [`OptimInstance$new()`](#method-OptimInstance-new)

- [`OptimInstance$print()`](#method-OptimInstance-print)

- [`OptimInstance$assign_result()`](#method-OptimInstance-assign_result)

- [`OptimInstance$clear()`](#method-OptimInstance-clear)

- [`OptimInstance$clone()`](#method-OptimInstance-clone)

Inherited methods

- [`bbotk::EvalInstance$format()`](https://bbotk.mlr-org.com/dev/reference/EvalInstance.html#method-format)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstance$new(
      objective,
      search_space = NULL,
      terminator,
      check_values = TRUE,
      callbacks = NULL,
      archive = NULL,
      label = NA_character_,
      man = NA_character_
    )

#### Arguments

- `objective`:

  ([Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md))  
  Objective function.

- `search_space`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies the search space for the
  [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md). The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  describes either a subset of the `domain` of the
  [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md) or
  it describes a set of parameters together with a `trafo` function that
  transforms values from the search space to values of the domain.
  Depending on the context, this value defaults to the domain of the
  objective.

- `terminator`:

  [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)  
  Termination criterion.

- `check_values`:

  (`logical(1)`)  
  Should points before the evaluation and the results be checked for
  validity?

- `callbacks`:

  (list of
  [mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html))  
  List of callbacks.

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md)).

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

### Method [`print()`](https://rdrr.io/r/base/print.html)

Printer.

#### Usage

    OptimInstance$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `assign_result()`

The [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
object writes the best found point and estimated performance value here.
For internal use.

#### Usage

    OptimInstance$assign_result(xdt, y, ...)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  x values as
  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)
  with one row. Contains the value in the *search space* of the
  OptimInstance object. Can contain additional columns for extra
  information.

- `y`:

  (`numeric(1)`)  
  Optimal outcome.

- `...`:

  (`any`)  
  ignored.

------------------------------------------------------------------------

### Method `clear()`

Reset terminator and clear all evaluation results from archive and
results.

#### Usage

    OptimInstance$clear()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstance$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
