# Create Asynchronous Optimization Callback

Function to create a
[CallbackAsync](https://bbotk.mlr-org.com/dev/reference/CallbackAsync.md).

Optimization callbacks can be called from different stages of
optimization process. The stages are prefixed with `on_*`.

    Start Optimization
         - on_optimization_begin
        Start Worker
             - on_worker_begin
               Start Optimization on Worker
                 - on_optimizer_before_eval
                 - on_optimizer_after_eval
               End Optimization on Worker
             - on_worker_end
        End Worker
         - on_result_begin
         - on_result_end
         - on_optimization_end
    End Optimization

See also the section on parameters for more information on the stages. A
optimization callback works with
[ContextAsync](https://bbotk.mlr-org.com/dev/reference/ContextAsync.md).

## Usage

``` r
callback_async(
  id,
  label = NA_character_,
  man = NA_character_,
  on_optimization_begin = NULL,
  on_worker_begin = NULL,
  on_optimizer_before_eval = NULL,
  on_optimizer_after_eval = NULL,
  on_optimizer_queue_before_eval = NULL,
  on_optimizer_queue_after_eval = NULL,
  on_worker_end = NULL,
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
  Stage called at the beginning of the optimization in the main process.
  Called in `Optimizer$optimize()`. The functions must have two
  arguments named `callback` and `context`.

- on_worker_begin:

  (`function()`)  
  Stage called at the beginning of the optimization on the worker.
  Called in the worker loop. The functions must have two arguments named
  `callback` and `context`.

- on_optimizer_before_eval:

  (`function()`)  
  Stage called after the optimizer proposes points. Called in
  `OptimInstance$.eval_point()`. The functions must have two arguments
  named `callback` and `context`. The argument of
  `instance$.eval_point(xs)` and `xs_trafoed` and `extra` are available
  in the `context`. Or `xs` and `xs_trafoed` of `instance$.eval_queue()`
  are available in the `context`.

- on_optimizer_after_eval:

  (`function()`)  
  Stage called after points are evaluated. Called in
  `OptimInstance$.eval_point()`. The functions must have two arguments
  named `callback` and `context`. The outcome `y` is available in the
  `context`.

- on_optimizer_queue_before_eval:

  (`function()`)  
  Stage called before a point in the queue is evaluated. Called in
  `OptimInstance$.eval_queue()`. The functions must have two arguments
  named `callback` and `context`. The argument of
  `instance$.eval_queue(xs)` and `xs_trafoed` and `extra` are available
  in the `context`.

- on_optimizer_queue_after_eval:

  (`function()`)  
  Stage called after a point in the queue is evaluated. Called in
  `OptimInstance$.eval_queue()`. The functions must have two arguments
  named `callback` and `context`. The outcome `y` is available in the
  `context`.

- on_worker_end:

  (`function()`)  
  Stage called at the end of the optimization on the worker. Called in
  the worker loop. The functions must have two arguments named
  `callback` and `context`.

- on_result_begin:

  (`function()`)  
  Stage called before result are written. Called in
  `OptimInstance$assign_result()`. The functions must have two arguments
  named `callback` and `context`. The arguments of
  `$.assign_result(xdt, y, extra)` are available in the `context`.

- on_result_end:

  (`function()`)  
  Stage called after result are written. Called in
  `OptimInstance$assign_result()`. The functions must have two arguments
  named `callback` and `context`. The final result `instance$result` is
  available in the `context`.

- on_result:

  (`function()`)  
  Deprecated. Use `on_result_end` instead. Stage called after result are
  written. Called in `OptimInstance$assign_result()`. The functions must
  have two arguments named `callback` and `context`.

- on_optimization_end:

  (`function()`)  
  Stage called at the end of the optimization in the main process.
  Called in `Optimizer$optimize()`. The functions must have two
  arguments named `callback` and `context`.

## Value

[CallbackAsync](https://bbotk.mlr-org.com/dev/reference/CallbackAsync.md)

## Details

A callback can write data to its state (`$state`), e.g. settings that
affect the callback itself. The
[ContextAsync](https://bbotk.mlr-org.com/dev/reference/ContextAsync.md)
allows to modify the instance, archive, optimizer and final result.
