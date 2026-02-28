# Asynchronous Optimization via Design Points

`OptimizerAsyncDesignPoints` class that implements optimization w.r.t.
fixed design points. We simply search over a set of points fully
specified by the ser.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("async_design_points")
    opt("async_design_points")

## Parameters

- `design`:

  [data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html)  
  Design points to try in search, one per row.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncDesignPoints`

## Methods

### Public methods

- [`OptimizerAsyncDesignPoints$new()`](#method-OptimizerAsyncDesignPoints-new)

- [`OptimizerAsyncDesignPoints$optimize()`](#method-OptimizerAsyncDesignPoints-optimize)

- [`OptimizerAsyncDesignPoints$clone()`](#method-OptimizerAsyncDesignPoints-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

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
#> 1: finished     0     0    -3 2026-02-28 07:00:58  9113
#> 2: finished     1     1    -7 2026-02-28 07:00:58  9113
#>                     worker_id        timestamp_ys
#>                        <char>              <POSc>
#> 1: emotionless_astrangiacoral 2026-02-28 07:00:59
#> 2: emotionless_astrangiacoral 2026-02-28 07:00:59
#>                                    keys x_domain_x1 x_domain_x2
#>                                  <char>       <num>       <num>
#> 1: 2e988536-d86f-4f38-b2c7-86ce0f9c7852           0           0
#> 2: 59dfae73-e377-4ee3-8a07-99dfdff8b37d           1           1
```
