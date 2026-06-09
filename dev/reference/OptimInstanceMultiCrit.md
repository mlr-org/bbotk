# Multi Criteria Optimization Instance for Batch Optimization

`OptimInstanceMultiCrit` is a deprecated class that is now a wrapper
around
[OptimInstanceBatchMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.md).

## See also

[OptimInstanceBatchMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.md)

## Super classes

[`EvalInstance`](https://bbotk.mlr-org.com/dev/reference/EvalInstance.md)
-\>
[`OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\>
[`OptimInstanceBatch`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md)
-\>
[`OptimInstanceBatchMultiCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.md)
-\> `OptimInstanceMultiCrit`

## Methods

### Public methods

- [`OptimInstanceMultiCrit$new()`](#method-OptimInstanceMultiCrit-initialize)

- [`OptimInstanceMultiCrit$clone()`](#method-OptimInstanceMultiCrit-clone)

Inherited methods

- [`EvalInstance$format()`](https://bbotk.mlr-org.com/dev/reference/EvalInstance.html#method-format)
- [`OptimInstance$clear()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-clear)
- [`OptimInstance$print()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-print)
- [`OptimInstanceBatch$eval_batch()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-eval_batch)
- [`OptimInstanceBatch$objective_function()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-objective_function)
- [`OptimInstanceBatchMultiCrit$assign_result()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.html#method-assign_result)

------------------------------------------------------------------------

### `OptimInstanceMultiCrit$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceMultiCrit$new(
      objective,
      search_space = NULL,
      terminator,
      keep_evals = "all",
      check_values = TRUE,
      callbacks = NULL
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

- `keep_evals`:

  (`character(1)`)  
  Keep `all` or only `best` evaluations in archive?

- `check_values`:

  (`logical(1)`)  
  Should points before the evaluation and the results be checked for
  validity?

- `callbacks`:

  (list of
  [mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html))  
  List of callbacks.

------------------------------------------------------------------------

### `OptimInstanceMultiCrit$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstanceMultiCrit$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
