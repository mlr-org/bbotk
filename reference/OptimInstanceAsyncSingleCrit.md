# Single Criterion Optimization Instance for Asynchronous Optimization

The `OptimInstanceAsyncSingleCrit` specifies an optimization problem for
an
[OptimizerAsync](https://bbotk.mlr-org.com/reference/OptimizerAsync.md).
The function
[`oi_async()`](https://bbotk.mlr-org.com/reference/oi_async.md) creates
an OptimInstanceAsyncSingleCrit.

## Super classes

[`bbotk::EvalInstance`](https://bbotk.mlr-org.com/reference/EvalInstance.md)
-\>
[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/reference/OptimInstance.md)
-\>
[`bbotk::OptimInstanceAsync`](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.md)
-\> `OptimInstanceAsyncSingleCrit`

## Active bindings

- `result_x_domain`:

  ([`list()`](https://rdrr.io/r/base/list.html))  
  (transformed) x part of the result in the *domain space* of the
  objective.

- `result_y`:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Optimal outcome.

## Methods

### Public methods

- [`OptimInstanceAsyncSingleCrit$new()`](#method-OptimInstanceAsyncSingleCrit-new)

- [`OptimInstanceAsyncSingleCrit$assign_result()`](#method-OptimInstanceAsyncSingleCrit-assign_result)

- [`OptimInstanceAsyncSingleCrit$clone()`](#method-OptimInstanceAsyncSingleCrit-clone)

Inherited methods

- [`bbotk::EvalInstance$format()`](https://bbotk.mlr-org.com/reference/EvalInstance.html#method-format)
- [`bbotk::OptimInstanceAsync$clear()`](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.html#method-clear)
- [`bbotk::OptimInstanceAsync$print()`](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.html#method-print)
- [`bbotk::OptimInstanceAsync$reconnect()`](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.html#method-reconnect)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceAsyncSingleCrit$new(
      objective,
      search_space = NULL,
      terminator,
      check_values = FALSE,
      callbacks = NULL,
      archive = NULL,
      rush = NULL
    )

#### Arguments

- `objective`:

  ([Objective](https://bbotk.mlr-org.com/reference/Objective.md))  
  Objective function.

- `search_space`:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Specifies the search space for the
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md). The
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)
  describes either a subset of the `domain` of the
  [Objective](https://bbotk.mlr-org.com/reference/Objective.md) or it
  describes a set of parameters together with a `trafo` function that
  transforms values from the search space to values of the domain.
  Depending on the context, this value defaults to the domain of the
  objective.

- `terminator`:

  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md)  
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

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

- `rush`:

  (`Rush`)  
  If a rush instance is supplied, the tuning runs without batches.

------------------------------------------------------------------------

### Method `assign_result()`

The
[OptimizerAsync](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
object writes the best found point and estimated performance value here.
For internal use.

#### Usage

    OptimInstanceAsyncSingleCrit$assign_result(xdt, y, extra = NULL, ...)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- `y`:

  (`numeric(1)`)  
  Optimal outcome.

- `extra`:

  ([`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html))  
  Additional information.

- `...`:

  (`any`)  
  ignored.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimInstanceAsyncSingleCrit$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# example only runs if a Redis server is available
if (mlr3misc::require_namespaces(c("rush", "redux", "mirai"), quietly = TRUE) &&
  redux::redis_available()) {
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

# start workers
rush::rush_plan(worker_type = "remote")
mirai::daemons(1)

# initialize instance
instance = oi_async(
  objective = objective,
  terminator = trm("evals", n_evals = 20)
)
}
```
