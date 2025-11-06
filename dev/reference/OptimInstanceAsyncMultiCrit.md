# Multi Criteria Optimization Instance for Asynchronous Optimization

The OptimInstanceAsyncMultiCrit specifies an optimization problem for an
[OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md).
The function
[`oi_async()`](https://bbotk.mlr-org.com/dev/reference/oi_async.md)
creates an OptimInstanceAsyncMultiCrit.

## Super classes

[`bbotk::OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
-\>
[`bbotk::OptimInstanceAsync`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.md)
-\> `OptimInstanceAsyncMultiCrit`

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

- [`OptimInstanceAsyncMultiCrit$new()`](#method-OptimInstanceAsyncMultiCrit-new)

- [`OptimInstanceAsyncMultiCrit$assign_result()`](#method-OptimInstanceAsyncMultiCrit-assign_result)

- [`OptimInstanceAsyncMultiCrit$clone()`](#method-OptimInstanceAsyncMultiCrit-clone)

Inherited methods

- [`bbotk::OptimInstance$format()`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.html#method-format)
- [`bbotk::OptimInstanceAsync$clear()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.html#method-clear)
- [`bbotk::OptimInstanceAsync$print()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.html#method-print)
- [`bbotk::OptimInstanceAsync$reconnect()`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.html#method-reconnect)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimInstanceAsyncMultiCrit$new(
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

------------------------------------------------------------------------

### Method `assign_result()`

The
[OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
writes the best found points and estimated performance values here
(probably the Pareto set / front). For internal use.

#### Usage

    OptimInstanceAsyncMultiCrit$assign_result(xdt, ydt, extra = NULL, ...)

#### Arguments

- `xdt`:

  ([`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html))  
  Set of untransformed points / points from the *search space*. One
  point per row, e.g. `data.table(x1 = c(1, 3), x2 = c(2, 4))`. Column
  names have to match ids of the `search_space`. However, `xdt` can
  contain additional columns.

- `ydt`:

  (`numeric(1)`)  
  Optimal outcomes, e.g. the Pareto front.

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

    OptimInstanceAsyncMultiCrit$clone(deep = FALSE)

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

# start workers
rush::rush_plan(worker_type = "remote")
mirai::daemons(1)

# initialize instance
instance = oi_async(
  objective = objective,
  terminator = trm("evals", n_evals = 100))
}
```
