# Changelog

## bbotk (development version)

## bbotk 1.9.0

- feat: Allow `"learn"` tag (direction=0) alongside minimize/maximize in
  `Codomain`.
- feat: Add new base class `EvalInstance` from which `OptimInstance` now
  inherits. `EvalInstance` keeps information about a process that
  evaluates an `Objective` while not necessarily optimizing it.
- feat: Exporting formerly internal
  [`choose_search_space()`](https://bbotk.mlr-org.com/dev/reference/choose_search_space.md)
  function.
- feat: Use `mlr3misc` error classes for errors and warnings.
- compatibility: Compatible with `rush` 1.0.0.
- fix: Terminator print method works correctly now.

## bbotk 1.8.1

CRAN release: 2025-11-26

- fix: Any Conditions work with `OptimizerLocalSearch` now.

## bbotk 1.8.0

CRAN release: 2025-11-06

- feat: Add `on_optimizer_queue_before_eval` and
  `on_optimizer_queue_after_eval` stages to `CallbackAsync` and
  `CallbackBatch`.
- fix: Start phase of `rush` worker.

## bbotk 1.7.1

CRAN release: 2025-10-24

fix: Imbalanced protection and casting in C code. fix: Load required
packages in worker loop.

## bbotk 1.7.0

CRAN release: 2025-10-10

- BREAKING CHANGE: Replace `OptimizerBatchLocalSearch` with a faster C
  implementation.
- feat: Add `par` parameter to `OptimizerGenSA`.
- BREAKING CHANGE: Replace `start` parameter from `OptimizerNloptr` with
  `x0` parameter.
- feat: Expose internal termination criteria of `Optimizer`s.
- feat: Store required packages in `Objective$packages`.
- feat: Fail queued and running points when optimization is terminated.
- fix: Pass `n_workers` to `rush`.
- feat: Kill `rush` worker after optimization.
- feat: Add tiny logging mode.

## bbotk 1.6.0

CRAN release: 2025-06-03

- BREAKING CHANGE: The mlr3 ecosystem has a base logger now which is
  named `mlr3`. The `mlr3/bbotk` logger is a child of the `mlr3` logger
  and is used for logging messages from the `bbotk` and `mlr3tuning`
  package.
- feat: Classes are now printed with the `cli` package.
- fix: Prevent switching of `xss` and `constants`.
- fix: Add saveguard on `OptimizerNloptr` bounds.
- feat: Allow numerical gradient approximation in `OptimizerNloptr`.

## bbotk 1.5.0

CRAN release: 2024-12-17

- compatibility: irace 4.1.0
- compatibility: rush 0.2.0
- refactor: Replace `Codomain$maximization_to_minimization` with
  `$direction` field.
- feat: Save `ArchiveAsync` to a `data.table` with `ArchiveAsyncFrozen`.

## bbotk 1.4.1

CRAN release: 2024-11-27

- compatibility: irace 4.0.0

## bbotk 1.4.0

CRAN release: 2024-11-26

- feat: Add `OptimizerBatchChain` that runs multiple optimizers
  sequentially.
- refactor: Only pass `extra` to `$assign_result()`.

## bbotk 1.3.0

CRAN release: 2024-11-07

- feat: Add new stage `on_result_begin` to `CallbackAsyncTuning` and
  `CallbackBatchTuning`.
- refactor: Rename stage `on_result` to `on_result_end` in
  `CallbackAsyncTuning` and `CallbackBatchTuning`.
- docs: Extend the `CallbackAsyncTuning` and `CallbackBatchTuning`
  documentation.

## bbotk 1.2.0

CRAN release: 2024-10-25

- feat: `ContextBatch` and `ContextAsync` have a `result_extra` field
  now to access additional results passed to the instance.
- refactor: Additional information are passed with `extra` to
  `OptimInstance$assign_result()`.

## bbotk 1.1.1

CRAN release: 2024-10-15

- feat: The optimizers passes additional information to
  `OptimInstance$assign_result()` method.

## bbotk 1.1.0

CRAN release: 2024-09-09

- docs: Move vignette to mlr3book.
- feat: Add hypervolume stagnation terminator
  `trm("stagnation_hypervolume")`.
- feat Add local search optimizer `opt("local_search")`.
- refactor: Remove unused fields from callbacks.
- fix: Add `"on_optimization_end_batch"` stage to `CallbackBatch`.

## bbotk 1.0.1

CRAN release: 2024-07-24

- refactor: extra columns in results.

## bbotk 1.0.0

CRAN release: 2024-06-28

- feat: Introduce asynchronous optimization with the `OptimizerAsync`
  and `OptimInstanceAsync` classes.
- BREAKING CHANGE: The `Optimizer` class is `OptimizerBatch` now.
- BREAKING CHANGE: The `OptimInstance` class and subclasses are
  `OptimInstanceBatch*` now.
- BREAKING CHANGE: The `CallbackOptimization` class is `CallbackBatch`
  now.
- BREAKING CHANGE: The `ContextOptimization` class is `ContextBatch`
  now.
- BREAKING CHANGE: Remove `ArchiveBest` class and `keep_evals` parameter
  from `OptimInstance`.

## bbotk 0.8.0

CRAN release: 2024-02-29

- fix: `OptimizerIrace` failed with logical parameters and dependencies.
- refactor: Optimize the runtime of `archive$best()` method and add ties
  method.
- compatibility: Work with new paradox version 1.0.0

## bbotk 0.7.3

CRAN release: 2023-11-13

- fix: `OptimInstance$print()` errored when the search space was empty.

## bbotk 0.7.2

CRAN release: 2022-12-08

- fix: Standalone `Tuner` and `FSelector` were rejected by
  `ContextBatch`.

## bbotk 0.7.1

CRAN release: 2022-11-30

- feat: Data unrelated to a specific point evaluation can be written to
  `Archive$data_extra`.

## bbotk 0.7.0

CRAN release: 2022-11-05

- fix: `Terminator$format(with_params = TRUE)` printed an empty list
  when no parameter was set.
- refactor: `OptimizerIrace` automatically added the `instances`
  parameter to `Objective$constants`. From now on, the `instances`
  parameter can be also set manually.
- BREAKING CHANGE: `branin(xs)` is now `branin(x1, x2, noise)` and
  `branin_wu(x1, x2, fidelity)`.
- feat: Add `ObjectiveRFunMany` that can evaluate a list of
  configurations with a user supplied function.
- fix: If all configurations were missing a parameter,
  `ObjectiveRFunDt$eval_many()` did not create a column with `NA` for
  the missing parameter.
- refactor: The default of `digits` in `OptimizerIrace` is 15 now to
  avoid rounding errors.
- refactor: The bounds of double parameters were processed with only 4
  decimal places in `OptimizerIrace`. By default, the bounds of double
  parameters are represented with 15 decimal places now. The `digits`
  parameter of `OptimizerIrace` also changes number of decimal places of
  the bounds now.

## bbotk 0.6.0

CRAN release: 2022-10-25

- fix: `OptimizerIrace` did not work with parameters with multiple
  dependencies.
- feat: Add new callback that backups the archive to disk to
  `mlr_callbacks`.
- feat: Create custom callbacks with the
  [`callback_batch()`](https://bbotk.mlr-org.com/dev/reference/callback_batch.md)
  function.

## bbotk 0.5.4

CRAN release: 2022-08-25

- feat: Add `OptimizerFocusSearch` that performs a focusing random
  search.

## bbotk 0.5.3

CRAN release: 2022-05-04

- feat: `Optimizer` and `Terminator` objects have the field `$id` now.

## bbotk 0.5.2

CRAN release: 2022-04-04

- refactor: The `$print()` method of `OptimInstance` omits unnecessary
  columns now.
- fix: The `$clear()` method of `OptimInstance` raised an error.
- fix: The `$clear()` method of `Archive` missed to reset the
  `$start_time` field.
- feat: `Optimizer` and `Terminator` objects have the optional field
  `$label` now.
- feat:
  [`as.data.table()`](https://rdrr.io/pkg/data.table/man/as.data.table.html)
  functions for objects of class `Dictionary` have been extended with
  additional columns.
- feat: Add a `as.data.table.DictionaryTerminator()` function.

## bbotk 0.5.1

CRAN release: 2022-02-25

- fix: The return of the `$.status()` method of `TerminatorRunTime` and
  `TerminatorClockTime` was not in a consistent unit. The return is in
  seconds from now on.
- fix: The number of evaluations was recorded as 0 in the log messages
  when the search space was empty.
- feat: Add a `as.data.table.DictionaryOptimizer()` function.
- feat: New `$help()` method which opens the manual page of an
  `Optimizer`.

## bbotk 0.5.0

CRAN release: 2022-01-19

- feat: Add `$nds_selection()` method to `Archive`.
- feat: New `Codomain` class that allows extra parameters.
- refactor: Objective values were automatically named. From now on, only
  unnamed returns of `ObjectiveRFun` are named.
- fix: `OptimInstance`, `Archive` and `Objective` objects were not
  cloned properly.
- refactor: The fields `$param_classes`, `$properties` and `$packages`
  of `Optimizer` objects are read-only now.
- feat: The
  [`branin()`](https://bbotk.mlr-org.com/dev/reference/branin.md)
  function is exported now.

## bbotk 0.4.0

CRAN release: 2021-09-13

- feat: The search space and domain can now be empty.
- feat: The budget of `TerminatorEvals` can now be changed depending on
  the dimension of the search space with the parameter `k`.
- feat: Add
  [`bb_optimize()`](https://bbotk.mlr-org.com/dev/reference/bb_optimize.md)
  function.
- feat: Add `OptimizerIrace` which calls
  [`irace::irace`](https://mlopez-ibanez.github.io/irace/reference/irace.html)
  from the `irace` package.

## bbotk 0.3.2

CRAN release: 2021-03-18

- refactor: Internal changes.

## bbotk 0.3.1

CRAN release: 2021-03-12

- feat: Add `$clear()` method to `OptimInstance` to reset the instance.
- refactor: Prettier `$print()` methods.
- feat: Assertions on overlapping and reserved names in domain and
  codomain.

## bbotk 0.3.0

CRAN release: 2021-01-23

- feat: The check of points and results can now be disables with the
  `check_values` flag in `OptimInstance`, `OptimInstanceSingleCrit`,
  `OptimInstanceMultiCrit`, `ObjectiveRFun` and `ObjectiveRFunDt`.
- refactor: The `data.table` within the `Archive` can now be accessed
  with `$data`.
- refactor: The `m` parameter of `Archive$best()` is renamed to `batch`.
- feat: New `ArchiveBest` class which only stores best scoring
  evaluation instead of all evaluations
- refactor: The runtime is reduced when `ObjectiveRFunDt` is used with a
  domain without trafo.
- fix: Add support for `ParamUty` in `OptimizerDesignPoints`.
- feat: The start points for `OptimizerCmaes` and `OptimizerNloptr` can
  now be randomly created or from center of the search space.
- feat: The `$optimize()` method supports progress bars via the package
  `progressr`.

## bbotk 0.2.2

CRAN release: 2020-10-08

- refactor: Remove dependency on orphaned package `bibtex`.
- feat: Add `OptimizerCmaes` which calls
  [`adagio::pureCMAES`](https://rdrr.io/pkg/adagio/man/cmaes.html) from
  the `adagio` package.

## bbotk 0.2.1

CRAN release: 2020-09-05

- refactor: Compact in-memory representation of R6 objects to save space
  when saving mlr3 objects via saveRDS(), serialize() etc.
- refactor: Warning and error messages when upstream package of
  `Optimizer` is not installed.

## bbotk 0.2

- First version of the Black-Box Optimization Toolkit
