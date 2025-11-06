# None Terminator

Mainly useful for optimization algorithms where the stopping is
inherently controlled by the algorithm itself (e.g.
[OptimizerBatchGridSearch](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_grid_search.md)).

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md):

    mlr_terminators$get("none")
    trm("none")

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
-\> `TerminatorNone`

## Methods

### Public methods

- [`TerminatorNone$new()`](#method-TerminatorNone-new)

- [`TerminatorNone$is_terminated()`](#method-TerminatorNone-is_terminated)

- [`TerminatorNone$clone()`](#method-TerminatorNone-clone)

Inherited methods

- [`bbotk::Terminator$format()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-format)
- [`bbotk::Terminator$print()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-print)
- [`bbotk::Terminator$remaining_time()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-remaining_time)
- [`bbotk::Terminator$status()`](https://bbotk.mlr-org.com/dev/reference/Terminator.html#method-status)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    TerminatorNone$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorNone$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorNone$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
