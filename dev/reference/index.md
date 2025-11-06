# Package index

## Package

- [`bbotk`](https://bbotk.mlr-org.com/dev/reference/bbotk-package.md)
  [`bbotk-package`](https://bbotk.mlr-org.com/dev/reference/bbotk-package.md)
  : bbotk: Black-Box Optimization Toolkit

## Objective

- [`Objective`](https://bbotk.mlr-org.com/dev/reference/Objective.md) :
  Objective Function with Domain and Codomain
- [`ObjectiveRFun`](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFun.md)
  : Objective interface with custom R function
- [`ObjectiveRFunDt`](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFunDt.md)
  : Objective interface for basic R functions.
- [`ObjectiveRFunMany`](https://bbotk.mlr-org.com/dev/reference/ObjectiveRFunMany.md)
  : Objective Interface with Custom R Function

## Terminator

- [`Terminator`](https://bbotk.mlr-org.com/dev/reference/Terminator.md)
  : Abstract Terminator Class
- [`mlr_terminators_clock_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_clock_time.md)
  [`TerminatorClockTime`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_clock_time.md)
  : Clock Time Terminator
- [`mlr_terminators_combo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md)
  [`TerminatorCombo`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_combo.md)
  : Combine Terminators
- [`mlr_terminators_evals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md)
  [`TerminatorEvals`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_evals.md)
  : Terminator that stops after a number of evaluations
- [`mlr_terminators_none`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md)
  [`TerminatorNone`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_none.md)
  : None Terminator
- [`mlr_terminators_perf_reached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md)
  [`TerminatorPerfReached`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_perf_reached.md)
  : Performance Level Terminator
- [`mlr_terminators_run_time`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_run_time.md)
  [`TerminatorRunTime`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_run_time.md)
  : Run Time Terminator
- [`mlr_terminators_stagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md)
  [`TerminatorStagnation`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation.md)
  : Terminator that stops when optimization does not improve
- [`mlr_terminators_stagnation_batch`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_batch.md)
  [`TerminatorStagnationBatch`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_batch.md)
  : Terminator that stops when optimization does not improve
- [`mlr_terminators_stagnation_hypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)
  [`TerminatorStagnationHypervolume`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators_stagnation_hypervolume.md)
  : Stagnation Hypervolume Terminator
- [`mlr_terminators`](https://bbotk.mlr-org.com/dev/reference/mlr_terminators.md)
  : Dictionary of Terminators
- [`trm()`](https://bbotk.mlr-org.com/dev/reference/trm.md)
  [`trms()`](https://bbotk.mlr-org.com/dev/reference/trm.md) : Syntactic
  Sugar Terminator Construction
- [`as_terminator()`](https://bbotk.mlr-org.com/dev/reference/as_terminator.md)
  [`as_terminators()`](https://bbotk.mlr-org.com/dev/reference/as_terminator.md)
  : Convert to a Terminator

## Optimization Instance

- [`OptimInstance`](https://bbotk.mlr-org.com/dev/reference/OptimInstance.md)
  : Optimization Instance
- [`OptimInstanceAsync`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsync.md)
  : Optimization Instance for Asynchronous Optimization
- [`OptimInstanceAsyncMultiCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncMultiCrit.md)
  : Multi Criteria Optimization Instance for Asynchronous Optimization
- [`OptimInstanceAsyncSingleCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceAsyncSingleCrit.md)
  : Single Criterion Optimization Instance for Asynchronous Optimization
- [`OptimInstanceBatch`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatch.md)
  : Optimization Instance for Batch Optimization
- [`OptimInstanceBatchMultiCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchMultiCrit.md)
  : Multi Criteria Optimization Instance for Batch Optimization
- [`OptimInstanceBatchSingleCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceBatchSingleCrit.md)
  : Single Criterion Optimization Instance for Batch Optimization
- [`OptimInstanceMultiCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceMultiCrit.md)
  : Multi Criteria Optimization Instance for Batch Optimization
- [`OptimInstanceSingleCrit`](https://bbotk.mlr-org.com/dev/reference/OptimInstanceSingleCrit.md)
  : Single Criterion Optimization Instance for Batch Optimization
- [`oi()`](https://bbotk.mlr-org.com/dev/reference/oi.md) : Syntactic
  Sugar for Optimization Instance Construction
- [`oi_async()`](https://bbotk.mlr-org.com/dev/reference/oi_async.md) :
  Syntactic Sugar for Asynchronous Optimization Instance Construction

## Optimizer

- [`Optimizer`](https://bbotk.mlr-org.com/dev/reference/Optimizer.md) :
  Optimizer
- [`OptimizerAsync`](https://bbotk.mlr-org.com/dev/reference/OptimizerAsync.md)
  : Asynchronous Optimizer
- [`OptimizerBatch`](https://bbotk.mlr-org.com/dev/reference/OptimizerBatch.md)
  : Batch Optimizer
- [`mlr_optimizers_async_design_points`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_async_design_points.md)
  [`OptimizerAsyncDesignPoints`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_async_design_points.md)
  : Asynchronous Optimization via Design Points
- [`mlr_optimizers_async_grid_search`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_async_grid_search.md)
  [`OptimizerAsyncGridSearch`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_async_grid_search.md)
  : Asynchronous Optimization via Grid Search
- [`mlr_optimizers_async_random_search`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_async_random_search.md)
  [`OptimizerAsyncRandomSearch`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_async_random_search.md)
  : Asynchronous Optimization via Random Search
- [`mlr_optimizers_chain`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_chain.md)
  [`OptimizerBatchChain`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_chain.md)
  : Run Optimizers Sequentially
- [`mlr_optimizers_cmaes`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_cmaes.md)
  [`OptimizerBatchCmaes`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_cmaes.md)
  : Optimization via Covariance Matrix Adaptation Evolution Strategy
- [`mlr_optimizers_design_points`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_design_points.md)
  [`OptimizerBatchDesignPoints`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_design_points.md)
  : Optimization via Design Points
- [`mlr_optimizers_focus_search`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_focus_search.md)
  [`OptimizerBatchFocusSearch`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_focus_search.md)
  : Optimization via Focus Search
- [`mlr_optimizers_gensa`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_gensa.md)
  [`OptimizerBatchGenSA`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_gensa.md)
  : Generalized Simulated Annealing
- [`mlr_optimizers_grid_search`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_grid_search.md)
  [`OptimizerBatchGridSearch`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_grid_search.md)
  : Optimization via Grid Search
- [`mlr_optimizers_irace`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_irace.md)
  [`OptimizerBatchIrace`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_irace.md)
  : Iterated Racing
- [`mlr_optimizers_local_search`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_local_search.md)
  [`OptimizerBatchLocalSearch`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_local_search.md)
  : Local Search
- [`mlr_optimizers_nloptr`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_nloptr.md)
  [`OptimizerBatchNLoptr`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_nloptr.md)
  : Non-linear Optimization
- [`mlr_optimizers_random_search`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_random_search.md)
  [`OptimizerBatchRandomSearch`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers_random_search.md)
  : Optimization via Random Search
- [`mlr_optimizers`](https://bbotk.mlr-org.com/dev/reference/mlr_optimizers.md)
  : Dictionary of Optimizer
- [`opt()`](https://bbotk.mlr-org.com/dev/reference/opt.md)
  [`opts()`](https://bbotk.mlr-org.com/dev/reference/opt.md) : Syntactic
  Sugar Optimizer Construction
- [`local_search()`](https://bbotk.mlr-org.com/dev/reference/local_search.md)
  : Local Search
- [`local_search_control()`](https://bbotk.mlr-org.com/dev/reference/local_search_control.md)
  : Local Search Control

## Archive

- [`Archive`](https://bbotk.mlr-org.com/dev/reference/Archive.md) : Data
  Storage
- [`ArchiveAsync`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
  : Rush Data Storage
- [`ArchiveAsyncFrozen`](https://bbotk.mlr-org.com/dev/reference/ArchiveAsyncFrozen.md)
  : Frozen Rush Data Storage
- [`ArchiveBatch`](https://bbotk.mlr-org.com/dev/reference/ArchiveBatch.md)
  : Data Table Storage
- [`Codomain`](https://bbotk.mlr-org.com/dev/reference/Codomain.md) :
  Codomain of Function

## Callbacks

- [`CallbackAsync`](https://bbotk.mlr-org.com/dev/reference/CallbackAsync.md)
  : Create Asynchronous Optimization Callback
- [`CallbackBatch`](https://bbotk.mlr-org.com/dev/reference/CallbackBatch.md)
  : Create Batch Optimization Callback
- [`callback_async()`](https://bbotk.mlr-org.com/dev/reference/callback_async.md)
  : Create Asynchronous Optimization Callback
- [`callback_batch()`](https://bbotk.mlr-org.com/dev/reference/callback_batch.md)
  : Create Batch Optimization Callback
- [`ContextAsync`](https://bbotk.mlr-org.com/dev/reference/ContextAsync.md)
  : Asynchronous Optimization Context
- [`ContextBatch`](https://bbotk.mlr-org.com/dev/reference/ContextBatch.md)
  : Batch Optimization Context
- [`bbotk.backup`](https://bbotk.mlr-org.com/dev/reference/bbotk.backup.md)
  : Backup Archive Callback
- [`bbotk.async_freeze_archive`](https://bbotk.mlr-org.com/dev/reference/bbotk.async_freeze_archive.md)
  : Freeze Archive Callback

## Misc

- [`is_dominated()`](https://bbotk.mlr-org.com/dev/reference/is_dominated.md)
  : Calculate which points are dominated
- [`Progressor`](https://bbotk.mlr-org.com/dev/reference/Progressor.md)
  : Progressor
- [`branin()`](https://bbotk.mlr-org.com/dev/reference/branin.md)
  [`branin_wu()`](https://bbotk.mlr-org.com/dev/reference/branin.md) :
  Branin Function
- [`bb_optimize()`](https://bbotk.mlr-org.com/dev/reference/bb_optimize.md)
  : Black-Box Optimization
- [`shrink_ps()`](https://bbotk.mlr-org.com/dev/reference/shrink_ps.md)
  : Shrink a ParamSet towards a point.
- [`bbotk_worker_loop()`](https://bbotk.mlr-org.com/dev/reference/bbotk_worker_loop.md)
  : Worker loop for Rush
- [`trafo_xs()`](https://bbotk.mlr-org.com/dev/reference/trafo_xs.md) :
  Calculate the transformed x-values
- [`terminated_error()`](https://bbotk.mlr-org.com/dev/reference/terminated_error.md)
  : Termination Error
