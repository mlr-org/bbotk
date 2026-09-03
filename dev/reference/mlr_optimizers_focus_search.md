# Optimization via Focus Search

`OptimizerBatchFocusSearch` class that implements a Focus Search.

Focus Search starts with evaluating `n_points` drawn uniformly at
random. For 1 to `maxit` batches, `n_points` are then drawn uniformly at
random and if the best value of a batch outperforms the previous best
value over all batches evaluated so far, the search space is shrunk
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

[`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) -\>
[`OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
-\> `OptimizerBatchFocusSearch`

## Methods

### Public methods

- [`OptimizerBatchFocusSearch$new()`](#method-OptimizerBatchFocusSearch-initialize)

- [`OptimizerBatchFocusSearch$clone()`](#method-OptimizerBatchFocusSearch-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)
- [`OptimizerBatch$optimize()`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.html#method-optimize)

------------------------------------------------------------------------

### `OptimizerBatchFocusSearch$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    OptimizerBatchFocusSearch$new()

------------------------------------------------------------------------

### `OptimizerBatchFocusSearch$clone()`

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
#>          x1       x2  x_domain        y
#>       <num>    <num>    <list>    <num>
#> 1: 2.075008 -1.12518 <list[2]> 6.479424

# all evaluated configurations
instance$archive
#> 
#> ── <ArchiveBatch> - Data Table Storage ─────────────────────────────────────────
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>
#>  1:  -4.2   2.8   -63 2026-09-03 11:40:20        1        -4.2         2.8
#>  2:  -9.7  -4.7  -130 2026-09-03 11:40:20        1        -9.7        -4.7
#>  3:   7.1   2.9   -50 2026-09-03 11:40:20        1         7.1         2.9
#>  4:  -1.7  -3.3    -4 2026-09-03 11:40:20        1        -1.7        -3.3
#>  5:   5.0  -4.7    -2 2026-09-03 11:40:20        1         5.0        -4.7
#>  6:   4.4   2.9   -30 2026-09-03 11:40:20        1         4.4         2.9
#>  7:   0.3   3.3   -32 2026-09-03 11:40:20        1         0.3         3.3
#>  8:   9.5   4.7  -105 2026-09-03 11:40:20        1         9.5         4.7
#>  9:  -2.8  -1.2   -16 2026-09-03 11:40:20        1        -2.8        -1.2
#> 10:  -6.6  -3.3   -64 2026-09-03 11:40:20        1        -6.6        -3.3
#> 11:   2.1  -1.1     6 2026-09-03 11:40:20        2         2.1        -1.1
#> 12:   6.1   2.1   -33 2026-09-03 11:40:20        2         6.1         2.1
#> 13:  -9.3   2.0  -142 2026-09-03 11:40:20        2        -9.3         2.0
#> 14:   4.7   4.3   -50 2026-09-03 11:40:20        2         4.7         4.3
#> 15:  -5.7  -0.4   -56 2026-09-03 11:40:20        2        -5.7        -0.4
#> 16:  -9.7   1.0  -142 2026-09-03 11:40:20        2        -9.7         1.0
#> 17:  -7.4  -3.3   -79 2026-09-03 11:40:20        2        -7.4        -3.3
#> 18:   3.7   0.7    -6 2026-09-03 11:40:20        2         3.7         0.7
#> 19:   2.8   4.0   -39 2026-09-03 11:40:20        2         2.8         4.0
#> 20:  -3.5   0.9   -35 2026-09-03 11:40:20        2        -3.5         0.9
#>        x1    x2     y           timestamp batch_nr x_domain_x1 x_domain_x2
#>     <num> <num> <num>              <POSc>    <int>       <num>       <num>

# best performing configuration
instance$result
#>          x1       x2  x_domain        y
#>       <num>    <num>    <list>    <num>
#> 1: 2.075008 -1.12518 <list[2]> 6.479424
```
