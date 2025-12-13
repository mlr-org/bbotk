# Clock Time Terminator

Class to terminate the optimization after a fixed time point has been
reached (as reported by
[`Sys.time()`](https://rdrr.io/r/base/Sys.time.html)).

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
can be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md):

    mlr_terminators$get("clock_time")
    trm("clock_time")

## Parameters

- `stop_time`:

  `POSIXct(1)`  
  Terminator stops after this point in time.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
-\> `TerminatorClockTime`

## Methods

### Public methods

- [`TerminatorClockTime$new()`](#method-TerminatorClockTime-new)

- [`TerminatorClockTime$is_terminated()`](#method-TerminatorClockTime-is_terminated)

- [`TerminatorClockTime$clone()`](#method-TerminatorClockTime-clone)

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

    TerminatorClockTime$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorClockTime$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorClockTime$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
stop_time = as.POSIXct("2030-01-01 00:00:00")
trm("clock_time", stop_time = stop_time)
#> 
#> ── <TerminatorClockTime> - Clock Time ──────────────────────────────────────────
#> • Parameters: stop_time=<POSIXct>
```
