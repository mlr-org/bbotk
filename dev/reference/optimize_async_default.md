# Default Asynchronous Optimization

Used internally in
[OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md).

## Usage

``` r
optimize_async_default(instance, optimizer, design = NULL, n_workers = NULL)
```

## Arguments

- instance:

  [OptimInstanceAsync](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.md).

- optimizer:

  [OptimizerAsync](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md).

- design:

  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)  
  (Initial) design send to the queue.

- n_workers:

  Number of workers to be started. Defaults to the number of workers set
  by
  [`rush::rush_plan()`](https://rush.mlr-org.com/reference/rush_plan.html).
