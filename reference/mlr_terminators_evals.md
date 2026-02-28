# Terminator that stops after a number of evaluations

Class to terminate the optimization depending on the number of
evaluations. An evaluation is defined by one resampling of a parameter
value. The total number of evaluations \\B\\ is defined as

\$\$ B = \mathtt{n\\evals} + \mathtt{k} \* D \$\$ where \\D\\ is the
dimension of the search space.

## Dictionary

This [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) can
be instantiated via the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_terminators](https://bbotk.mlr-org.com/reference/mlr_terminators.md)
or with the associated sugar function
[`trm()`](https://bbotk.mlr-org.com/reference/trm.md):

    mlr_terminators$get("evals")
    trm("evals")

## Parameters

- `n_evals`:

  `integer(1)`  
  See formula above. Default is 100.

- `k`:

  `integer(1)`  
  See formula above. Default is 0.

## See also

Other Terminator:
[`Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md),
[`mlr_terminators`](https://bbotk.mlr-org.com/reference/mlr_terminators.md),
[`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_clock_time.md),
[`mlr_terminators_combo`](https://bbotk.mlr-org.com/reference/mlr_terminators_combo.md),
[`mlr_terminators_none`](https://bbotk.mlr-org.com/reference/mlr_terminators_none.md),
[`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/reference/mlr_terminators_perf_reached.md),
[`mlr_terminators_run_time`](https://bbotk.mlr-org.com/reference/mlr_terminators_run_time.md),
[`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation.md),
[`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_batch.md),
[`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/reference/mlr_terminators_stagnation_hypervolume.md)

## Super class

[`bbotk::Terminator`](https://bbotk.mlr-org.com/reference/Terminator.md)
-\> `TerminatorEvals`

## Methods

### Public methods

- [`TerminatorEvals$new()`](#method-TerminatorEvals-new)

- [`TerminatorEvals$is_terminated()`](#method-TerminatorEvals-is_terminated)

- [`TerminatorEvals$clone()`](#method-TerminatorEvals-clone)

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

    TerminatorEvals$new()

------------------------------------------------------------------------

### Method `is_terminated()`

Is `TRUE` iff the termination criterion is positive, and `FALSE`
otherwise.

#### Usage

    TerminatorEvals$is_terminated(archive)

#### Arguments

- `archive`:

  ([Archive](https://bbotk.mlr-org.com/reference/Archive.md)).

#### Returns

`logical(1)`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    TerminatorEvals$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
TerminatorEvals$new()
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=100, k=0

# 5 evaluations in total
trm("evals", n_evals = 5)
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=5, k=0

# 3 * [dimension of search space] evaluations in total
trm("evals", n_evals = 0, k = 3)
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=0, k=3

# (3 * [dimension of search space] + 1) evaluations in total
trm("evals", n_evals = 1, k = 3)
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=1, k=3
```
