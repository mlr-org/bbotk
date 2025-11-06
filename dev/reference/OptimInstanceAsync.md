# Optimization Instance for Asynchronous Optimization

The `OptimInstanceAsync` specifies an optimization problem for an
[OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md).
The function
[`oi_async()`](https://bbotk.mlr-org.com/dev/reference/oi_async.md)
creates an
[OptimInstanceAsyncSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncSingleCrit.md)
or
[OptimInstanceAsyncMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncMultiCrit.md).

## Details

`OptimInstanceAsync` is an abstract base class that implements the base
functionality each instance must provide.

## See also

[`oi_async()`](https://bbotk.mlr-org.com/dev/reference/oi_async.md),
[OptimInstanceAsyncSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncSingleCrit.md),
[OptimInstanceAsyncMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncMultiCrit.md)

## Super class

[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\> `OptimInstanceAsync`

## Public fields

- `rush`:

  (`Rush`)  
  Rush controller for parallel optimization.

## Methods

### Public methods

- [`OptimInstanceAsync$new()`](#method-OptimInstanceAsync-new)

- [`OptimInstanceAsync$print()`](#method-OptimInstanceAsync-print)

- [`OptimInstanceAsync$clear()`](#method-OptimInstanceAsync-clear)

- [`OptimInstanceAsync$reconnect()`](#method-OptimInstanceAsync-reconnect)

- [`OptimInstanceAsync$clone()`](#method-OptimInstanceAsync-clone)

Inherited methods

- [`bbotk::OptimInstance$assign_result()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-assign_result)
- [`bbotk::OptimInstance$format()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-format)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceAsync$new(
      objective,
      search_space = NULL,
      terminator,
      check_values = FALSE,
      callbacks = NULL,
      archive = NULL,
      rush = NULL,
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

- `rush`:

  (`Rush`)  
  If a rush instance is supplied, the tuning runs without batches.

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

    OptimInstanceAsync$print(...)

#### Arguments

- `...`:

  (ignored).

------------------------------------------------------------------------

### Method `clear()`

Reset terminator and clear all evaluation results from archive and
results.

#### Usage

    OptimInstanceAsync$clear()

------------------------------------------------------------------------

### Method `reconnect()`

Reconnect to Redis. The connection breaks when the
[rush::Rush](https://rush.mlr-org.com/reference/Rush.html) is saved to
disk. Call this method to reconnect after loading the object.

#### Usage

    OptimInstanceAsync$reconnect()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstanceAsync$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
