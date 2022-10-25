# bbotk 0.6.0.9000

* refactor: Double parameters were processed with only 4 decimal places in `OptimizerIrace`.
  From now on, double parameters represented with 15 decimal places.

# bbotk 0.6.0

* fix: `OptimizerIrace` did not work with parameters with multiple dependencies.
* feat: Add new callback that backups the archive to disk to `mlr_callbacks`.
* feat: Create custom callbacks with the `callback_optimization()` function.

# bbotk 0.5.4

* feat: Add `OptimizerFocusSearch` that performs a focusing random search.

# bbotk 0.5.3

* feat: `Optimizer` and `Terminator` objects have the field `$id` now.

# bbotk 0.5.2

* refactor: The `$print()` method of `OptimInstance` omits unnecessary columns now.
* fix: The `$clear()` method of `OptimInstance` raised an error.
* fix: The `$clear()` method of `Archive` missed to reset the `$start_time` field.
* feat: `Optimizer` and `Terminator` objects have the optional field `$label` now.
* feat: `as.data.table()` functions for objects of class `Dictionary` have been extended with additional columns.
* feat: Add a `as.data.table.DictionaryTerminator()` function.

# bbotk 0.5.1

* fix: The return of the `$.status()` method of `TerminatorRunTime` and `TerminatorClockTime` was not in a consistent unit.
  The return is in seconds from now on.
* fix: The number of evaluations was recorded as 0 in the log messages when the search space was empty.
* feat: Add a `as.data.table.DictionaryOptimizer()` function.
* feat: New `$help()` method which opens the manual page of an `Optimizer`.

# bbotk 0.5.0

* feat: Add `$nds_selection()` method to `Archive`.
* feat: New `Codomain` class that allows extra parameters.
* refactor: Objective values were automatically named.
  From now on, only unnamed returns of `ObjectiveRFun` are named.
* fix: `OptimInstance`, `Archive` and `Objective` objects  were not cloned properly.
* refactor: The fields `$param_classes`, `$properties` and `$packages` of `Optimizer` objects are read-only now.
* feat: The `branin()` function is exported now.

# bbotk 0.4.0

* feat: The search space and domain can now be empty.
* feat: The budget of `TerminatorEvals` can now be changed depending on the dimension of the search space with the parameter `k`.
* feat: Add `bb_optimize()` function.
* feat: Add `OptimizerIrace` which calls `irace::irace` from the `irace` package.

# bbotk 0.3.2

* refactor: Internal changes.

# bbotk 0.3.1

* feat: Add `$clear()` method to `OptimInstance` to reset the instance.
* refactor: Prettier `$print()` methods.
* feat: Assertions on overlapping and reserved names in domain and codomain.

# bbotk 0.3.0

* feat: The check of points and results can now be disables with the `check_values` flag in `OptimInstance`, `OptimInstanceSingleCrit`, `OptimInstanceMultiCrit`, `ObjectiveRFun` and `ObjectiveRFunDt`.
* refactor: The `data.table` within the `Archive` can now be accessed with `$data`.
* refactor: The `m` parameter of `Archive$best()` is renamed to `batch`.
* feat: New `ArchiveBest` class which only stores best scoring evaluation instead of all evaluations
* refactor: The runtime is reduced when `ObjectiveRFunDt` is used with a domain without trafo.
* fix: Add support for `ParamUty` in `OptimizerDesignPoints`.
* feat: The start points for `OptimizerCmaes` and `OptimizerNloptr` can now be randomly created or from center of the search space.
* feat: The `$optimize()` method supports progress bars via the package `progressr`.

# bbotk 0.2.2

* refactor: Remove dependency on orphaned package `bibtex`.
* feat: Add `OptimizerCmaes` which calls `adagio::pureCMAES` from the `adagio` package.

# bbotk 0.2.1

* refactor: Compact in-memory representation of R6 objects to save space when saving mlr3 objects via saveRDS(), serialize() etc.
* refactor: Warning and error messages when upstream package of `Optimizer` is not installed.

# bbotk 0.2

* First version of the Black-Box Optimization Toolkit
