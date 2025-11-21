# Asynchronous Optimization via Design Points

`OptimizerAsyncDesignPoints` class that implements optimization w.r.t.
fixed design points. We simply search over a set of points fully
specified by the ser.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("async_design_points")
    opt("async_design_points")

## Parameters

- `design`:

  [data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  Design points to try in search, one per row.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncDesignPoints`

## Methods

### Public methods

- [`OptimizerAsyncDesignPoints$new()`](#method-OptimizerAsyncDesignPoints-new)

- [`OptimizerAsyncDesignPoints$optimize()`](#method-OptimizerAsyncDesignPoints-optimize)

- [`OptimizerAsyncDesignPoints$clone()`](#method-OptimizerAsyncDesignPoints-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncDesignPoints$new()

------------------------------------------------------------------------

### Method [`optimize()`](https://rdrr.io/r/stats/optimize.html)

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncDesignPoints$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsyncDesignPoints$clone(deep = FALSE)

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

# load optimizer
design = data.table::data.table(x1 = c(0, 1), x2 = c(0, 1))
optimizer = opt("async_design_points", design = design)

# trigger optimization
optimizer$optimize(instance)

# all evaluated configurations
instance$archive

# best performing configuration
instance$archive$best()

# covert to data.table
as.data.table(instance$archive)
}
#>       state    x1    x2     y        timestamp_xs   pid
#>      <char> <num> <num> <num>              <POSc> <int>
#> 1: finished     0     0    -3 2025-11-21 18:13:52 28593
#> 2: finished     1     1    -7 2025-11-21 18:13:52 28593
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#> 1: emotionless_astrangiacoral 2025-11-21 18:13:53
#> 2: emotionless_astrangiacoral 2025-11-21 18:13:53
#>                                    keys x_domain_x1 x_domain_x2
#>                                  <char>       <num>       <num>
#> 1: 59daea18-a4a8-48c7-9f7d-d1171f18b443           0           0
#> 2: 36452f91-6a7d-4c00-b5d4-e05827b1c4f5           1           1
```
