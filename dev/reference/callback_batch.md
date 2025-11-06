# Create Batch Optimization Callback

Function to create a
[CallbackBatch](https://bbotk.mlr-org.com/dev/reference/CallbackBatch.md).

Optimization callbacks can be called from different stages of
optimization process. The stages are prefixed with `on_*`.

    Start Optimization
         - on_optimization_begin
        Start Optimizer Batch
             - on_optimizer_before_eval
             - on_optimizer_after_eval
        End Optimizer Batch
         - on_result_begin
         - on_result_end
         - on_optimization_end
    End Optimization

See also the section on parameters for more information on the stages. A
optimization callback works with
[ContextBatch](https://bbotk.mlr-org.com/dev/reference/ContextBatch.md).

## Usage

``` r
callback_batch(
  id,
  label = NA_character_,
  man = NA_character_,
  on_optimization_begin = NULL,
  on_optimizer_before_eval = NULL,
  on_optimizer_after_eval = NULL,
  on_result_begin = NULL,
  on_result_end = NULL,
  on_result = NULL,
  on_optimization_end = NULL
)
```

## Arguments

- id:

  (`character(1)`)  
  Identifier for the new instance.

- label:

  (`character(1)`)  
  Label for the new instance.

- man:

  (`character(1)`)  
  String in the format `[pkg]::[topic]` pointing to a manual page for
  this object. The referenced help package can be opened via method
  `$help()`.

- on_optimization_begin:

  (`function()`)  
  Stage called at the beginning of the optimization. Called in
  `Optimizer$optimize()`. The functions must have two arguments named
  `callback` and `context`.

- on_optimizer_before_eval:

  (`function()`)  
  Stage called after the optimizer proposes points. Called in
  `OptimInstance$eval_batch()`. The functions must have two arguments
  named `callback` and `context`. The argument of `$eval_batch(xdt)` is
  available in `context`.

- on_optimizer_after_eval:

  (`function()`)  
  Stage called after points are evaluated. Called in
  `OptimInstance$eval_batch()`. The functions must have two arguments
  named `callback` and `context`. The new points and outcomes in
  `instance$archive` are available in `context`.

- on_result_begin:

  (`function()`)  
  Stage called before result are written to the instance. Called in
  `OptimInstance$assign_result()`. The functions must have two arguments
  named `callback` and `context`. The arguments of
  `$assign_result(xdt, y, extra)` are available in `context`.

- on_result_end:

  (`function()`)  
  Stage called after result are written to the instance. Called in
  `OptimInstance$assign_result()`. The functions must have two arguments
  named `callback` and `context`. The final result `instance$result` is
  available in `context`.

- on_result:

  (`function()`)  
  Deprecated. Use `on_result_end` instead. Stage called after result are
  written. Called in `OptimInstance$assign_result()`. The functions must
  have two arguments named `callback` and `context`.

- on_optimization_end:

  (`function()`)  
  Stage called at the end of the optimization. Called in
  `Optimizer$optimize()`. The functions must have two arguments named
  `callback` and `context`.

## Value

[CallbackBatch](https://bbotk.mlr-org.com/dev/reference/CallbackBatch.md)

## Details

A callback can write data to its state (`$state`), e.g. settings that
affect the callback itself. The
[ContextBatch](https://bbotk.mlr-org.com/dev/reference/ContextBatch.md)
allows to modify the instance, archive, optimizer and final result.

## Examples

``` r
# write archive to disk
callback_batch("bbotk.backup",
  on_optimization_end = function(callback, context) {
    saveRDS(context$instance$archive, "archive.rds")
  }
)
#> <CallbackBatch:bbotk.backup>
#> * Active Stages: on_optimization_end
```
