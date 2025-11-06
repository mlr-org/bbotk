# Batch Optimizer

Abstract `OptimizerBatch` class that implements the base functionality
each `OptimizerBatch` subclass must provide. A `OptimizerBatch` object
describes the optimization strategy. A `OptimizerBatch` object must
write its result to the `$assign_result()` method of the
[OptimInstance](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
at the end in order to store the best point and its estimated
performance vector.

## Progress Bars

`$optimize()` supports progress bars via the package
[progressr](https://CRAN.R-project.org/package=progressr) combined with
a [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md).
Simply wrap the function in
[`progressr::with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
to enable them. We recommend to use package
[progress](https://CRAN.R-project.org/package=progress) as backend;
enable with `progressr::handlers("progress")`.

## See also

[OptimizerBatchDesignPoints](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_design_points.md),
[OptimizerBatchGridSearch](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_grid_search.md),
[OptimizerBatchRandomSearch](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_random_search.md)

## Super class

[`bbotk::Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md)
-\> `OptimizerBatch`

## Methods

### Public methods

- [`OptimizerBatch$optimize()`](#method-OptimizerBatch-optimize)

- [`OptimizerBatch$clone()`](#method-OptimizerBatch-clone)

Inherited methods

- [`bbotk::Optimizer$format()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-format)
- [`bbotk::Optimizer$help()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-help)
- [`bbotk::Optimizer$initialize()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-initialize)
- [`bbotk::Optimizer$print()`](https://bbotk.mlr-org.com/dev/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### Method [`optimize()`](https://rdrr.io/r/stats/optimize.html)

Performs the optimization and writes optimization result into
[OptimInstanceBatch](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md).
The optimization result is returned but the complete optimization path
is stored in
[ArchiveBatch](https://bbotk.mlr-org.com/dev/reference/ArchiveBatch.md)
of
[OptimInstanceBatch](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md).

#### Usage

    OptimizerBatch$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstanceBatch](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md)).

#### Returns

[data.table::data.table](https://rdatatable.gitlab.io/data.table/reference/data.table.html).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerBatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
