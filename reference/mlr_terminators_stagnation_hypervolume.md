# Stagnation Hypervolume Terminator

Class to terminate the optimization after the hypervolume stagnates,
i.e. does not improve more than `threshold` over the last `iters`
iterations.

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/reference/trm.md):

    mlr_terminators$get("stagnation_hypervolume")
    trm("stagnation_hypervolume")

## Parameters

- `iters`:

  `integer(1)`  
  Number of iterations to evaluate the performance improvement on,
  default is 10.

- `threshold`:

  `numeric(1)`  
  If the improvement is less than `threshold`, optimization is stopped,
  default is `0`.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md),
[`mlr_terminators_evals`](https://bbotk.mlr-org.com/reference/mlr_terminators_evals.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_batch.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md)
-\> `TerminatorStagnationHypervolume`

## Methods

### Public methods

- [`TerminatorStagnationHypervolume$new()`](#method-TerminatorStagnationHypervolume-new)

- [`TerminatorStagnationHypervolume$is_terminated()`](#method-TerminatorStagnationHypervolume-is_terminated)

- [`TerminatorStagnationHypervolume$clone()`](#method-TerminatorStagnationHypervolume-clone)

Inherited methods

- [`bbotk::Terminator$format()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-format)
- [`bbotk::Terminator$print()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-print)
- [`bbotk::Terminator$remaining_time()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-remaining_time)
- [`bbotk::Terminator$status()`](https://bbotk.mlr-org.com/reference/Terminator.html#method-status)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    TerminatorStagnationHypervolume$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` if the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorStagnationHypervolume$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorStagnationHypervolume$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
TerminatorStagnation$new()
#> 
#> ── <TerminatorStagnation> - Stagnation ─────────────────────────────────────────
#> • Parameters: iters=10, threshold=0
#> • Terminators:
trm("stagnation", iters = 5, threshold = 1e-5)
#> 
#> ── <TerminatorStagnation> - Stagnation ─────────────────────────────────────────
#> • Parameters: iters=5, threshold=1e-05
#> • Terminators:
```
