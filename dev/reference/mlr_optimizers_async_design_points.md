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

  [data.table::data.table](https://rdrr.io/pkg/data.table/man/data.table.html)  
  Design points to try in search, one per row.

## Super classes

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
-\> `OptimizerAsyncDesignPoints`

## Methods

### Public methods

- [`OptimizerAsyncDesignPoints$new()`](#method-OptimizerAsyncDesignPoints-initialize)

- [`OptimizerAsyncDesignPoints$optimize()`](#method-OptimizerAsyncDesignPoints-optimize)

- [`OptimizerAsyncDesignPoints$clone()`](#method-OptimizerAsyncDesignPoints-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

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

  ([OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)).

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
#> ERROR [09:28:34.499] [rush] Lost worker 'terrorstricken_prairiedog_f2bc7761': Error in !self$is_terminated && self$archive$n_queued_available: invalid 'y' type in 'x && y'
#> Error: Optimization terminated without any finished evaluations.
```
