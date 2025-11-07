# Worker loop for Rush

Loop run on the workers. Pops a task from the queue and evaluates it
with the objective function. Pushes the results back to the data base.

## Usage

``` r
bbotk_worker_loop(rush, optimizer, instance)
```

## Arguments

- rush:

  (`Rush`)  
  If a rush instance is supplied, the tuning runs without batches.

- optimizer:

  [OptimizerAsync](https://bbotk.mlr-org.com/reference/OptimizerAsync.md).

- instance:

  [OptimInstanceAsync](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.md).
