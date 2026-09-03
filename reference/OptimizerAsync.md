# Asynchronous Optimizer

The OptimizerAsync implements the asynchronous optimization algorithm.
The optimization is performed asynchronously on a set of workers.

## Details

OptimizerAsync is the abstract base class for all asynchronous
optimizers. It provides the basic structure for asynchronous
optimization algorithms. The public method `$optimize()` is the main
entry point for the optimization and runs in the main process. The
method starts the optimization process by starting the workers and
pushing the necessary objects to the workers. Optionally, a set of
points can be created, e.g. an initial design, and pushed to the
workers. The private method `$.optimize()` is the actual optimization
algorithm that runs on the workers. Usually, the method proposes new
points, evaluates them, and updates the archive.

## Optimization

The
[`rush::rush_plan()`](https://rush.mlr-org.com/reference/rush_plan.html)
function defines the number of workers and their type. There are three
types of workers:

- "mirai": Workers are started with
  [mirai](https://CRAN.R-project.org/package=mirai) on local or remote
  machines. See `$start_workers()` in
  [Rush](https://rush.mlr-org.com/reference/Rush.html) for more details.
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html)
  must be created before starting the optimization.

- "processx": Workers are started as local processes with
  [processx](https://CRAN.R-project.org/package=processx). See
  `$start_local_workers()` in
  [Rush](https://rush.mlr-org.com/reference/Rush.html) for more details.

- "script": Workers are started by the user with a custom script. See
  `$create_worker_script()` in
  [Rush](https://rush.mlr-org.com/reference/Rush.html) for more details.

The workers are started when the `$optimize()` method is called. The
main process waits until at least one worker is running. The
optimization starts directly after the workers are running. The main
process prints the evaluation results and other log messages from the
workers. The optimization is terminated when the terminator criterion is
satisfied. The result is assigned to the
[OptimInstanceAsync](https://bbotk.mlr-org.com/reference/OptimInstanceAsync.md)
field. The main loop periodically checks the status of the workers. If
all workers crash the optimization is terminated.

## Compute Profiles

Workers can be distributed over the [compute
profiles](https://mirai.r-lib.org/articles/mirai.html#scoped-profiles)
of [mirai](https://CRAN.R-project.org/package=mirai), e.g. one profile
for CPU daemons and one profile for GPU daemons. The profiles are set
with the `profiles` argument of
[`rush::rush_plan()`](https://rush.mlr-org.com/reference/rush_plan.html)
and the daemons of each profile must be created beforehand.

    mirai::daemons(2, .compute = "cpu")
    mirai::daemons(2, .compute = "gpu")
    rush::rush_plan(profiles = c(cpu = 2, gpu = 2), worker_type = "mirai")

Compute profiles are only supported by the `"mirai"` worker type. The
profile a worker runs on is available as `instance$rush$profile` in the
private `$.optimize()` method and in the callbacks, so that an optimizer
can behave differently depending on the hardware it runs on.

Each compute profile has its own queue. Points pushed with
`instance$archive$push_points(xss, profile = "gpu")` are only evaluated
by the workers of the `"gpu"` profile, whereas points pushed without a
profile are added to the shared queue and are evaluated by any worker. A
worker takes points from the queue of its profile first and falls back
to the shared queue. The `instance$archive$n_queued_per_profile` field
shows the number of points queued for each profile.

## Debug Mode

The debug mode runs the optimization loop in the main process. This is
useful for debugging the optimization algorithm. The debug mode is
enabled by setting `options(bbotk.debug = TRUE)`.

## Tiny Logging

The tiny logging mode is enabled by setting the option
`bbotk.tiny_logging` to `TRUE`. In the tiny logging mode, the evaluated
points are printed in a compact format and the currently best performing
point is shown. Deactivated depending parameters are not printed.

## See also

[OptimizerAsyncDesignPoints](https://bbotk.mlr-org.com/reference/mlr_optimizers_async_design_points.md),
[OptimizerAsyncGridSearch](https://bbotk.mlr-org.com/reference/mlr_optimizers_async_grid_search.md),
[OptimizerAsyncRandomSearch](https://bbotk.mlr-org.com/reference/mlr_optimizers_async_random_search.md)

## Super class

[`Optimizer`](https://bbotk.mlr-org.com/reference/Optimizer.md) -\>
`OptimizerAsync`

## Methods

### Public methods

- [`OptimizerAsync$optimize()`](#method-OptimizerAsync-optimize)

- [`OptimizerAsync$clone()`](#method-OptimizerAsync-clone)

Inherited methods

- [`Optimizer$format()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-format)
- [`Optimizer$help()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-help)
- [`Optimizer$initialize()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-initialize)
- [`Optimizer$print()`](https://bbotk.mlr-org.com/reference/Optimizer.html#method-print)

------------------------------------------------------------------------

### `OptimizerAsync$optimize()`

Performs the optimization on a
[OptimInstanceAsyncSingleCrit](https://bbotk.mlr-org.com/reference/OptimInstanceAsyncSingleCrit.md)
or
[OptimInstanceAsyncMultiCrit](https://bbotk.mlr-org.com/reference/OptimInstanceAsyncMultiCrit.md)
until termination. The single evaluations will be written into the
[ArchiveAsync](https://bbotk.mlr-org.com/reference/ArchiveAsync.md). The
result will be written into the instance object.

#### Usage

    OptimizerAsync$optimize(inst)

#### Arguments

- `inst`:

  ([OptimInstanceAsyncSingleCrit](https://bbotk.mlr-org.com/reference/OptimInstanceAsyncSingleCrit.md)
  \|
  [OptimInstanceAsyncMultiCrit](https://bbotk.mlr-org.com/reference/OptimInstanceAsyncMultiCrit.md)).

#### Returns

[`data.table::data.table()`](https://rdrr.io/pkg/data.table/man/data.table.html)

------------------------------------------------------------------------

### `OptimizerAsync$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptimizerAsync$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
