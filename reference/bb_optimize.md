# Black-Box Optimization

This function optimizes a function or
[Objective](https://bbotk.mlr-org.com/reference/Objective.md) with a
given method.

## Usage

``` r
bb_optimize(
  x,
  method = "random_search",
  max_evals = 1000,
  max_time = NULL,
  ...
)

# S3 method for class '`function`'
bb_optimize(
  x,
  method = "random_search",
  max_evals = 1000,
  max_time = NULL,
  lower = NULL,
  upper = NULL,
  maximize = FALSE,
  ...
)

# S3 method for class 'Objective'
bb_optimize(
  x,
  method = "random_search",
  max_evals = 1000,
  max_time = NULL,
  search_space = NULL,
  ...
)
```

## Arguments

- x:

  (`function` \|
  [Objective](https://bbotk.mlr-org.com/reference/Objective.md)).

- method:

  (`character(1)` \|
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md))  
  Key to retrieve optimizer from
  [mlr_optimizers](https://bbotk.mlr-org.com/reference/mlr_optimizers.md)
  dictionary or
  [Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md).

- max_evals:

  (`integer(1)`)  
  Number of allowed evaluations.

- max_time:

  (`integer(1)`)  
  Maximum allowed time in seconds.

- ...:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named arguments passed to objective function. Ignored if
  [Objective](https://bbotk.mlr-org.com/reference/Objective.md) is
  optimized.

- lower:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Lower bounds on the parameters. If named, names are used to create the
  domain.

- upper:

  ([`numeric()`](https://rdrr.io/r/base/numeric.html))  
  Upper bounds on the parameters.

- maximize:

  ([`logical()`](https://rdrr.io/r/base/logical.html))  
  Logical vector used to create the codomain e.g. c(TRUE, FALSE) -\>
  ps(y1 = p_dbl(tags = "maximize"), y2 = pd_dbl(tags = "minimize")). If
  named, names are used to create the codomain.

- search_space:

  ([paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html)).

## Value

`list` of

- `"par"` - Best found parameters

- `"value"` - Optimal outcome

- `"instance"` -
  [OptimInstanceBatchSingleCrit](https://bbotk.mlr-org.com/reference/OptimInstanceBatchSingleCrit.md)
  \|
  [OptimInstanceBatchMultiCrit](https://bbotk.mlr-org.com/reference/OptimInstanceBatchMultiCrit.md)

## Note

If both `max_evals` and `max_time` are `NULL`,
[TerminatorNone](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md)
is used. This is useful if the
[Optimizer](https://bbotk.mlr-org.com/reference/Optimizer.md) can
terminate itself. If both are given,
[TerminatorCombo](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md)
is created and the optimization stops if the time or evaluation budget
is exhausted.

## Examples

``` r
# function and bounds
fun = function(xs) {
  -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10
}

bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10)
#> $par
#>           x1        x2
#>        <num>     <num>
#> 1: -9.440879 -0.306157
#> 
#> $value
#>        y1 
#> -128.1505 
#> 
#> $instance
#> 
#> ── <OptimInstanceBatchSingleCrit> ──────────────────────────────────────────────
#> • State: Optimized
#> • Objective: <ObjectiveRFun>
#> • Search Space:
#>        id    class lower upper nlevels
#>    <char>   <char> <num> <num>   <num>
#> 1:     x1 ParamDbl   -10    10     Inf
#> 2:     x2 ParamDbl    -5     5     Inf
#> • Terminator: <TerminatorEvals> (n_evals=10, k=0)
#> • Result:
#>           x1        x2        y1
#>        <num>     <num>     <num>
#> 1: -9.440879 -0.306157 -128.1505
#> • Archive:
#>        y1    x1    x2 x_domain_x1 x_domain_x2
#>     <num> <num> <num>       <num>       <num>
#>  1:   -48  -0.4   4.2        -0.4         4.2
#>  2:    -6  -2.0  -2.9        -2.0        -2.9
#>  3:     6   3.4  -4.4         3.4        -4.4
#>  4:   -53   9.9  -3.5         9.9        -3.5
#>  5:   -34   0.4   3.5         0.4         3.5
#>  6:     4   4.4  -2.6         4.4        -2.6
#>  7:   -31   0.9   3.3         0.9         3.3
#>  8:  -128  -9.4  -0.3        -9.4        -0.3
#>  9:   -45   6.1   3.1         6.1         3.1
#> 10:    -5  -1.9  -2.8        -1.9        -2.8
#> 

# function and constant
fun = function(xs, c) {
  -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + c
}

bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10, c = 1)
#> $par
#>           x1       x2
#>        <num>    <num>
#> 1: -9.770409 3.882496
#> 
#> $value
#>        y1 
#> -184.9113 
#> 
#> $instance
#> 
#> ── <OptimInstanceBatchSingleCrit> ──────────────────────────────────────────────
#> • State: Optimized
#> • Objective: <ObjectiveRFun>
#> • Search Space:
#>        id    class lower upper nlevels
#>    <char>   <char> <num> <num>   <num>
#> 1:     x1 ParamDbl   -10    10     Inf
#> 2:     x2 ParamDbl    -5     5     Inf
#> • Terminator: <TerminatorEvals> (n_evals=10, k=0)
#> • Result:
#>           x1       x2        y1
#>        <num>    <num>     <num>
#> 1: -9.770409 3.882496 -184.9113
#> • Archive:
#>        y1    x1     x2 x_domain_x1 x_domain_x2
#>     <num> <num>  <num>       <num>       <num>
#>  1:   -24   0.2  1.604         0.2       1.604
#>  2:   -43   0.2  3.356         0.2       3.356
#>  3:   -49   4.2  3.742         4.2       3.742
#>  4:  -185  -9.8  3.882        -9.8       3.882
#>  5:   -71   9.9  0.002         9.9       0.002
#>  6:   -55  -2.8  2.749        -2.8       2.749
#>  7:   -18   1.7  1.340         1.7       1.340
#>  8:   -39   7.2  0.669         7.2       0.669
#>  9:   -99  -4.9  4.188        -4.9       4.188
#> 10:   -28   7.3 -2.515         7.3      -2.515
#> 

# objective
fun = function(xs) {
  c(z = -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + 10)
}

# define domain and codomain using a `ParamSet` from paradox
domain = ps(x1 = p_dbl(-10, 10), x2 = p_dbl(-5, 5))
codomain = ps(z = p_dbl(tags = "minimize"))
objective = ObjectiveRFun$new(fun, domain, codomain)

bb_optimize(objective, method = "random_search", max_evals = 10)
#> $par
#>           x1       x2
#>        <num>    <num>
#> 1: -8.586376 4.968915
#> 
#> $value
#>        z 
#> -165.575 
#> 
#> $instance
#> 
#> ── <OptimInstanceBatchSingleCrit> ──────────────────────────────────────────────
#> • State: Optimized
#> • Objective: <ObjectiveRFun>
#> • Search Space:
#>        id    class lower upper nlevels
#>    <char>   <char> <num> <num>   <num>
#> 1:     x1 ParamDbl   -10    10     Inf
#> 2:     x2 ParamDbl    -5     5     Inf
#> • Terminator: <TerminatorEvals> (n_evals=10, k=0)
#> • Result:
#>           x1       x2        z
#>        <num>    <num>    <num>
#> 1: -8.586376 4.968915 -165.575
#> • Archive:
#>         z    x1    x2 x_domain_x1 x_domain_x2
#>     <num> <num> <num>       <num>       <num>
#>  1:   -82    -8  -3.1          -8        -3.1
#>  2:   -87    -7   1.6          -7         1.6
#>  3:   -69     7   4.3           7         4.3
#>  4:    -5     1   0.8           1         0.8
#>  5:     7     4  -2.6           4        -2.6
#>  6:  -164    -9   4.1          -9         4.1
#>  7:  -166    -9   5.0          -9         5.0
#>  8:    10     2  -3.3           2        -3.3
#>  9:   -31     8  -4.6           8        -4.6
#> 10:    10     2  -2.6           2        -2.6
#> 
```
