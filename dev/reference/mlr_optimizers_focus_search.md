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
#> 1: 1.876732 -2.387624 <list[2]> 9.609801

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:    -5   0.2   -47 2026-03-18 14:00:54        1          -5         0.2
#>  2:     4  -0.3    -2 2026-03-18 14:00:54        1           4        -0.3
#>  3:     9  -4.0   -45 2026-03-18 14:00:54        1           9        -4.0
#>  4:     3   0.2    -1 2026-03-18 14:00:54        1           3         0.2
#>  5:     6  -0.5   -12 2026-03-18 14:00:54        1           6        -0.5
#>  6:    -9   0.5  -113 2026-03-18 14:00:54        1          -9         0.5
#>  7:     8   1.5   -43 2026-03-18 14:00:54        1           8         1.5
#>  8:     7  -3.4   -11 2026-03-18 14:00:54        1           7        -3.4
#>  9:     5  -2.1     3 2026-03-18 14:00:54        1           5        -2.1
#> 10:    -3   3.9   -59 2026-03-18 14:00:54        1          -3         3.9
#> 11:     2  -2.0     9 2026-03-18 14:00:54        2           2        -2.0
#> 12:     3  -4.1     8 2026-03-18 14:00:54        2           3        -4.1
#> 13:    -5   2.6   -68 2026-03-18 14:00:54        2          -5         2.6
#> 14:    -4   2.7   -55 2026-03-18 14:00:54        2          -4         2.7
#> 15:    -3  -1.0   -21 2026-03-18 14:00:54        2          -3        -1.0
#> 16:     5  -4.4    -2 2026-03-18 14:00:54        2           5        -4.4
#> 17:   -10   2.5  -159 2026-03-18 14:00:54        2         -10         2.5
#> 18:    -9   0.3  -116 2026-03-18 14:00:54        2          -9         0.3
#> 19:    -5  -2.2   -36 2026-03-18 14:00:54        2          -5        -2.2
#> 20:     2  -2.4    10 2026-03-18 14:00:54        2           2        -2.4
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1        x2  x_domain        y
#>       <num>     <num>    <list>    <num>
#> 1: 1.876732 -2.387624 <list[2]> 9.609801
```
