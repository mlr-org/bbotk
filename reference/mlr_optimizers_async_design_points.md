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

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/reference/OptimizerAsync.md)
-\> `OptimizerAsyncDesignPoints`

## Methods

### Public methods

- [`OptimizerAsyncDesignPoints$new()`](#method-OptimizerAsyncDesignPoints-initialize)

- [`OptimizerAsyncDesignPoints$optimize()`](#method-OptimizerAsyncDesignPoints-optimize)

- [`OptimizerAsyncDesignPoints$clone()`](#method-OptimizerAsyncDesignPoints-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### `OptimizerAsyncDesignPoints$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerAsyncDesignPoints$new()

------------------------------------------------------------------------

### `OptimizerAsyncDesignPoints$optimize()`

Starts the asynchronous optimization.

#### Usage

    OptimizerAsyncDesignPoints$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstance](https://bbotk.mlr-org.com/reference/OptimInstance.md)).

#### Returns

[data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html).

------------------------------------------------------------------------

### `OptimizerAsyncDesignPoints$clone()`

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
rush::rush_plan(worker_type = "mirai")
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
#>       state    x1    x2     y        timestamp_xs                 worker_id
#>      <char> <num> <num> <num>              <POSc>                    <char>
#> 1: finished     0     0    -3 2026-06-27 12:47:01 terrorstricken_prairiedog
#> 2: finished     1     1    -7 2026-06-27 12:47:01 terrorstricken_prairiedog
#>           timestamp_ys                                 keys x_domain_x1
#>                 <POSc>                               <char>       <num>
#> 1: 2026-06-27 12:47:02 2ea0161d-c809-47cb-99e1-ea0e989af83f           0
#> 2: 2026-06-27 12:47:02 6702dcdf-f7b7-4c70-9a18-8ed2e09517d1           1
#>    x_domain_x2
#>          <num>
#> 1:           0
#> 2:           1
```
