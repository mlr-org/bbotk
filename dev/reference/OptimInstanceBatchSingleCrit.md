# Single Criterion Optimization Instance for Batch Optimization

The OptimInstanceBatchSingleCrit specifies an optimization problem for
an
[OptimizerBatch](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md).
The function [`oi()`](https://bbotk.mlr-org.com/dev/reference/oi.md)
creates an OptimInstanceBatchSingleCrit.

## Super classes

[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\>
[`bbotk::OptimInstanceBatch`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md)
-\> `OptimInstanceBatchSingleCrit`

## Methods

### Public methods

- [`OptimInstanceBatchSingleCrit$new()`](#method-OptimInstanceBatchSingleCrit-new)

- [`OptimInstanceBatchSingleCrit$assign_result()`](#method-OptimInstanceBatchSingleCrit-assign_result)

- [`OptimInstanceBatchSingleCrit$clone()`](#method-OptimInstanceBatchSingleCrit-clone)

Inherited methods

- [`bbotk::OptimInstance$clear()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-clear)
- [`bbotk::OptimInstance$format()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-format)
- [`bbotk::OptimInstance$print()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-print)
- [`bbotk::OptimInstanceBatch$eval_batch()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-eval_batch)
- [`bbotk::OptimInstanceBatch$objective_function()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-objective_function)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceBatchSingleCrit$new(
      objective,
      search_space = NULL,
      terminator,
      check_values = TRUE,
      callbacks = NULL,
      archive = NULL
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

------------------------------------------------------------------------

### Method `assign_result()`

The [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
object writes the best found point and estimated performance value here.
For internal use.

#### Usage

    OptimInstanceBatchSingleCrit$assign_result(xdt, y, extra = NULL, ...)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- `y`:

  (`numeric(1)`)  
  Optimal outcome.

- `extra`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Additional information.

- `...`:

  (`any`)  
  ignored.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstanceBatchSingleCrit$clone(deep = FALSE)

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

# initialize instance
instance = oi(
  objective = objective,
  terminator = trm("evals", n_evals = 20)
)
```
