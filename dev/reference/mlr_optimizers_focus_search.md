# Optimization via Focus Search

`OptimizerBatchFocusSearch` class that implements a Focus Search.

Focus Search starts with evaluating `n_points` drawn uniformly at
random. For 1 to `maxit` batches, `n_points` are then drawn uniformly at
random and if the best value of a batch outperforms the previous best
value over all batches evaluated so far, the search space is shrinked
around this new best point prior to the next batch being sampled and
evaluated.

For details on the shrinking, see
[shrink_ps](https://bbotk.mlr-org.com/dev/reference/shrink_ps.md).

Depending on the
[Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md) this
procedure simply restarts after `maxit` is reached.

## Dictionary

This [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
or with the associated sugar function
[`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md):

    mlr_optimizers$get("focus_search")
    opt("focus_search")

## Parameters

- `n_points`:

  `integer(1)`  
  Number of points to evaluate in each random search batch.

- `maxit`:

  `integer(1)`  
  Number of random search batches to run.

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## Super classes

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\>
[`bbotk::OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchFocusSearch`

## Methods

### Public methods

- [`OptimizerBatchFocusSearch$new()`](#method-OptimizerBatchFocusSearch-new)

- [`OptimizerBatchFocusSearch$clone()`](#method-OptimizerBatchFocusSearch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`bbotk::OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchFocusSearch$new()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatchFocusSearch$clone(deep = FALSE)

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
optimizer = opt("focus_search", n_points = 10, maxit = 10)

# trigger optimization
optimizer$optimize(instance)
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 2.935626 -2.575073 <list[2]> 8.944041

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:     8  3.35   -72 2025-11-26 11:10:15        1           8        3.35
#>  2:     8  0.01   -37 2025-11-26 11:10:15        1           8        0.01
#>  3:    -6  1.02   -72 2025-11-26 11:10:15        1          -6        1.02
#>  4:     7 -0.31   -25 2025-11-26 11:10:15        1           7       -0.31
#>  5:   -10  3.86  -175 2025-11-26 11:10:15        1         -10        3.86
#>  6:     8  1.71   -45 2025-11-26 11:10:15        1           8        1.71
#>  7:    -2 -1.06   -11 2025-11-26 11:10:15        1          -2       -1.06
#>  8:    -8  0.51  -112 2025-11-26 11:10:15        1          -8        0.51
#>  9:     3 -2.58     9 2025-11-26 11:10:15        1           3       -2.58
#> 10:     8 -2.97   -30 2025-11-26 11:10:15        1           8       -2.97
#> 11:    -9 -2.43  -103 2025-11-26 11:10:15        2          -9       -2.43
#> 12:    -4  1.14   -41 2025-11-26 11:10:15        2          -4        1.14
#> 13:    10 -0.59   -58 2025-11-26 11:10:15        2          10       -0.59
#> 14:    -8 -1.84   -85 2025-11-26 11:10:15        2          -8       -1.84
#> 15:     4 -3.99     4 2025-11-26 11:10:15        2           4       -3.99
#> 16:    -5 -2.27   -46 2025-11-26 11:10:15        2          -5       -2.27
#> 17:    -7  1.54   -98 2025-11-26 11:10:15        2          -7        1.54
#> 18:     9  4.28   -86 2025-11-26 11:10:15        2           9        4.28
#> 19:     8 -4.73   -28 2025-11-26 11:10:15        2           8       -4.73
#> 20:    -6  0.59   -66 2025-11-26 11:10:15        2          -6        0.59
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2

# best performing configuration
instance$result
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 2.935626 -2.575073 <list[2]> 8.944041
```
