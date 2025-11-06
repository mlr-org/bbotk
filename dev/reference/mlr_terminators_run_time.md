# Run Time Terminator

Class to terminate the optimization after the optimization process took
a number of seconds on the clock.

## Note

This terminator only works if `archive$start_time` is set. This is
usually done by the
[Optimizer](https://bbotk.mlr-org.com/dev/reference/Optimizer.md).

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md):

    mlr_terminators$get("run_time")
    trm("run_time")

## Parameters

- `secs`:

  `numeric(1)`  
  Maximum allowed time, in seconds, default is 100.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
-\> `TerminatorRunTime`

## Methods

### Public methods

- [`TerminatorRunTime$new()`](#method-TerminatorRunTime-new)

- [`TerminatorRunTime$is_terminated()`](#method-TerminatorRunTime-is_terminated)

- [`TerminatorRunTime$clone()`](#method-TerminatorRunTime-clone)

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

    TerminatorRunTime$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorRunTime$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorRunTime$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
trm("run_time", secs = 1800)
#> 
#> ── <TerminatorRunTime> - Run Time ──────────────────────────────────────────────
#> • Parameters: secs=1800
#> • Terminators:
```
