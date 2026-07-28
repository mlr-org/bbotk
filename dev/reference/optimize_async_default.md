# Default Asynchronous Optimization

Used internally in
[OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md).

## Usage

``` r
optimize_async_default(
  instance,
  optimizer,
  design = NULL,
  n_workers = NULL,
  profiles = NULL
)
```

## Arguments

- instance:

  [OptimInstanceAsync](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.md).

- optimizer:

  [OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md).

- design:

  [`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)  
  (Initial) design send to the queue.

- n_workers:

  Number of workers to be started. Defaults to the number of workers set
  by
  [`rush::rush_plan()`](https://rush.mlr-org.com/reference/rush_plan.html).

- profiles:

  (named [`integer()`](https://rdrr.io/r/base/integer.html))  
  Number of workers to be started on each
  [mirai](https://CRAN.R-project.org/package=mirai) compute profile,
  e.g. `c(cpu = 2, gpu = 2)`. Defaults to the profiles set by
  [`rush::rush_plan()`](https://rush.mlr-org.com/reference/rush_plan.html).
  Cannot be combined with `n_workers`.
