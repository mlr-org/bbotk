# Optimization Instance for Batch Optimization

The `OptimInstanceBatch` specifies an optimization problem for an
[OptimizerBatch](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md).
The function [`oi()`](https://bbotk.mlr-org.com/dev/reference/oi.md)
creates an
[OptimInstanceAsyncSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncSingleCrit.md)
or
[OptimInstanceAsyncMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncMultiCrit.md).

## See also

[`oi()`](https://bbotk.mlr-org.com/dev/reference/oi.md),
[OptimInstanceBatchSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchSingleCrit.md),
[OptimInstanceBatchMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.md)

## Super class

[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\> `OptimInstanceBatch`

## Public fields

- `objective_multiplicator`:

  ([`integer()`](https://rdrr.io/r/base/integer.html)).

## Active bindings

- `result`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Get result

- `result_x_search_space`:

  ([data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  x part of the result in the *search space*.

- `result_x_domain`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  (transformed) x part of the result in the *domain space* of the
  objective.

- `result_y`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Optimal outcome.

- `is_terminated`:

  (`logical(1)`).

## Methods

### Public methods

- [`OptimInstanceBatch$new()`](#method-OptimInstanceBatch-new)

- [`OptimInstanceBatch$eval_batch()`](#method-OptimInstanceBatch-eval_batch)

- [`OptimInstanceBatch$objective_function()`](#method-OptimInstanceBatch-objective_function)

- [`OptimInstanceBatch$clone()`](#method-OptimInstanceBatch-clone)

Inherited methods

- [`bbotk::OptimInstance$assign_result()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-assign_result)
- [`bbotk::OptimInstance$clear()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-clear)
- [`bbotk::OptimInstance$format()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-format)
- [`bbotk::OptimInstance$print()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceBatch$new(
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

### Method `eval_batch()`

Evaluates all input values in `xdt` by calling the
[Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md).
Applies possible transformations to the input values and writes the
results to the
[Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md).

Before each batch-evaluation, the
[Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md) is
checked, and if it is positive, an exception of class `terminated_error`
is raised. This function should be internally called by the
[Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md).

#### Usage

    OptimInstanceBatch$eval_batch(xdt)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  x values as `data.table()` with one point per row. Contains the value
  in the *search space* of the
  [OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
  object. Can contain additional columns for extra information.

------------------------------------------------------------------------

### Method `objective_function()`

Evaluates (untransformed) points of only numeric values. Returns a
numeric scalar for single-crit or a numeric vector for multi-crit. The
return value(s) are negated if the measure is maximized. Internally,
`$eval_batch()` is called with a single row. This function serves as a
objective function for optimizers of numeric spaces - which should
always be minimized.

#### Usage

    OptimInstanceBatch$objective_function(x)

#### Arguments

- `x`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Untransformed points.

#### Returns

Objective value as `numeric(1)`, negated for maximization problems.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstanceBatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
