# Optimization via Design Points

`OptimizerBatchDesignPoints` class that implements optimization w.r.t.
fixed design points. We simply search over a set of points fully
specified by the user. The points in the design are evaluated in order
as given.

In order to support general termination criteria and parallelization, we
evaluate points in a batch-fashion of size `batch_size`. Larger batches
mean we can parallelize more, smaller batches imply a more fine-grained
checking of termination criteria.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/reference/opt.md):

    mlr_optimizers$get("design_points")
    opt("design_points")

## Parameters

- `batch_size`:

  `integer(1)`  
  Maximum number of configurations to try in a batch.

- `design`:

  [data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  Design points to try in search, one per row.

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/reference/OptimizerBatch.md)
-\> `OptimizerBatchDesignPoints`

## Methods

### Public methods

- [`OptimizerBatchDesignPoints$new()`](#method-OptimizerBatchDesignPoints-new)

- [`OptimizerBatchDesignPoints$clone()`](#method-OptimizerBatchDesignPoints-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchDesignPoints$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchDesignPoints$clone(deep = FALSE)

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

# load optimizer
design = data.table::data.table(x1 = c(0, 1), x2 = c(0, 1))
optimizer = opt("design_points", design = design)

# trigger optimization
optimizer$optimize(instance)
#>       x1    x2  x_domain     y
#>    <num> <num>    <list> <num>
#> 1:     0     0 <list[2]>    -3

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>       x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>    <num> <num> <num>              <POSc>    <int>       <num>       <num>
#> 1:     0     0    -3 2025-11-26 11:04:13        1           0           0
#> 2:     1     1    -7 2025-11-26 11:04:13        2           1           1

# best performing configuration
instance$result
#>       x1    x2  x_domain     y
#>    <num> <num>    <list> <num>
#> 1:     0     0 <list[2]>    -3
```
