# Single Criterion Optimization Instance for Batch Optimization

`OptimInstanceSingleCrit` is a deprecated class that is now a wrapper
around `OptimInstanceBatchSingleCrit`.

## See also

[OptimInstanceBatchSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchSingleCrit.md)

## Super classes

[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\>
[`bbotk::OptimInstanceBatch`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md)
-\>
[`bbotk::OptimInstanceBatchSingleCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchSingleCrit.md)
-\> `OptimInstanceSingleCrit`

## Methods

### Public methods

- [`OptimInstanceSingleCrit$new()`](#method-OptimInstanceSingleCrit-new)

- [`OptimInstanceSingleCrit$clone()`](#method-OptimInstanceSingleCrit-clone)

Inherited methods

- [`bbotk::OptimInstance$clear()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-clear)
- [`bbotk::OptimInstance$format()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-format)
- [`bbotk::OptimInstance$print()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-print)
- [`bbotk::OptimInstanceBatch$eval_batch()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-eval_batch)
- [`bbotk::OptimInstanceBatch$objective_function()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-objective_function)
- [`bbotk::OptimInstanceBatchSingleCrit$assign_result()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchSingleCrit.html#method-assign_result)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceSingleCrit$new(
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

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstanceSingleCrit$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
