# Multi Criteria Optimization Instance for Batch Optimization

The OptimInstanceBatchMultiCrit specifies an optimization problem for an
[OptimizerBatch](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md).
The function [`oi()`](https://bbotk.mlr-org.com/dev/reference/oi.md)
creates an OptimInstanceBatchMultiCrit.

## Super classes

[`bbotk::EvalInstance`](https://bbotk.mlr-org.com/dev/reference/EvalInstance.md)
-\>
[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\>
[`bbotk::OptimInstanceBatch`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md)
-\> `OptimInstanceBatchMultiCrit`

## Active bindings

- `result_x_domain`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  (transformed) x part of the result in the *domain space* of the
  objective.

- `result_y`:

  (`numeric(1)`)  
  Optimal outcome.

## Methods

### Public methods

- [`OptimInstanceBatchMultiCrit$new()`](#method-OptimInstanceBatchMultiCrit-new)

- [`OptimInstanceBatchMultiCrit$assign_result()`](#method-OptimInstanceBatchMultiCrit-assign_result)

- [`OptimInstanceBatchMultiCrit$clone()`](#method-OptimInstanceBatchMultiCrit-clone)

Inherited methods

- [`bbotk::EvalInstance$format()`](https://bbotk.mlr-org.com/dev/reference/EvalInstance.html#method-format)
- [`bbotk::OptimInstance$clear()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-clear)
- [`bbotk::OptimInstance$print()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-print)
- [`bbotk::OptimInstanceBatch$eval_batch()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-eval_batch)
- [`bbotk::OptimInstanceBatch$objective_function()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.html#method-objective_function)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceBatchMultiCrit$new(
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
object writes the best found points and estimated performance values
here (probably the Pareto set / front). For internal use.

#### Usage

    OptimInstanceBatchMultiCrit$assign_result(xdt, ydt, extra = NULL, ...)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- `ydt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
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

    OptimInstanceBatchMultiCrit$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# define the objective function
fun = function(xs) {
  data.table(
    y1 = xs$x1^2 +  xs$x2^2,
    y2 = (xs$x1 - 2)^2 + (xs$x2 - 1)^2
  )
}

# set domain
domain = ps(
  x1 = p_dbl(-5, 5),
  x2 = p_dbl(-5, 5)
)

# set codomain
codomain = ps(
  y1 = p_dbl(tags = "minimize"),
  y2 = p_dbl(tags = "minimize")
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
  terminator = trm("evals", n_evals = 100))
```
