# Black-Box Optimization

This function optimizes a function or
[Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md) with a
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
  [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md)).

- method:

  (`character(1)` \|
  [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md))  
  Key to retrieve optimizer from
  [mlr_optimizers](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
  dictionary or
  [Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md).

- max_evals:

  (`integer(1)`)  
  Number of allowed evaluations.

- max_time:

  (`integer(1)`)  
  Maximum allowed time in seconds.

- ...:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named arguments passed to objective function. Ignored if
  [Objective](https://bbotk.mlr-org.com/dev/reference/Objective.md) is
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
  [OptimInstanceBatchSingleCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchSingleCrit.md)
  \|
  [OptimInstanceBatchMultiCrit](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.md)

## Note

If both `max_evals` and `max_time` are `NULL`,
[TerminatorNone](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md)
is used. This is useful if the
[Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) can
terminate itself. If both are given,
[TerminatorCombo](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md)
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
#>           x1         x2
#>        <num>      <num>
#> 1: -9.438781 -0.3401281
#> 
#> $value
#>        y1 
#> -127.9206 
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
#>           x1         x2        y1
#>        <num>      <num>     <num>
#> 1: -9.438781 -0.3401281 -127.9206
#> • Archive:
#>        y1    x1    x2 x_domain_x1 x_domain_x2
#>     <num> <num> <num>       <num>       <num>
#>  1:   -28  -0.1   2.8        -0.1         2.8
#>  2:   -79  -5.9   2.1        -5.9         2.1
#>  3:  -107  -8.7  -1.5        -8.7        -1.5
#>  4:   -11   6.5  -2.3         6.5        -2.3
#>  5:     8   1.4  -1.6         1.4        -1.6
#>  6:    10   1.9  -3.1         1.9        -3.1
#>  7:   -50   9.0   0.4         9.0         0.4
#>  8:     8   0.9  -2.2         0.9        -2.2
#>  9:    -2  -1.1  -1.3        -1.1        -1.3
#> 10:  -128  -9.4  -0.3        -9.4        -0.3
#> 

# function and constant
fun = function(xs, c) {
  -(xs[[1]] - 2)^2 - (xs[[2]] + 3)^2 + c
}

bb_optimize(fun, lower = c(-10, -5), upper = c(10, 5), max_evals = 10, c = 1)
#> $par
#>          x1        x2
#>       <num>     <num>
#> 1: 9.941383 -3.509645
#> 
#> $value
#>       y1 
#> -62.3253 
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
#>          x1        x2       y1
#>       <num>     <num>    <num>
#> 1: 9.941383 -3.509645 -62.3253
#> • Archive:
#>        y1    x1    x2 x_domain_x1 x_domain_x2
#>     <num> <num> <num>       <num>       <num>
#>  1:   -32  -2.5   0.6        -2.5         0.6
#>  2:   -29   7.1  -1.2         7.1        -1.2
#>  3:   -17   0.6   1.0         0.6         1.0
#>  4:   -46  -4.8  -2.1        -4.8        -2.1
#>  5:   -57  -0.4   4.2        -0.4         4.2
#>  6:   -15  -2.0  -2.9        -2.0        -2.9
#>  7:    -3   3.4  -4.4         3.4        -4.4
#>  8:   -62   9.9  -3.5         9.9        -3.5
#>  9:   -43   0.4   3.5         0.4         3.5
#> 10:    -5   4.4  -2.6         4.4        -2.6
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
#> 1: -9.770409 3.882496
#> 
#> $value
#>         z 
#> -175.9113 
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
#>           x1       x2         z
#>        <num>    <num>     <num>
#> 1: -9.770409 3.882496 -175.9113
#> • Archive:
#>         z    x1     x2 x_domain_x1 x_domain_x2
#>     <num> <num>  <num>       <num>       <num>
#>  1:  -128  -9.4 -0.306        -9.4      -0.306
#>  2:   -45   6.1  3.141         6.1       3.141
#>  3:    -5  -1.9 -2.816        -1.9      -2.816
#>  4:   -25  -1.6  1.689        -1.6       1.689
#>  5:   -15   0.2  1.604         0.2       1.604
#>  6:   -34   0.2  3.356         0.2       3.356
#>  7:   -40   4.2  3.742         4.2       3.742
#>  8:  -176  -9.8  3.882        -9.8       3.882
#>  9:   -62   9.9  0.002         9.9       0.002
#> 10:   -46  -2.8  2.749        -2.8       2.749
#> 
```
