# Create Asynchronous Optimization Callback

Specialized
[mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html)
for asynchronous optimization. Callbacks allow to customize the behavior
of processes in bbotk. The
[`callback_async()`](https://bbotk.mlr-org.com/reference/callback_async.md)
function creates a CallbackAsync. Predefined callbacks are stored in the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_callbacks](https://mlr3misc.mlr-org.com/reference/mlr_callbacks.html)
and can be retrieved with
[`clbk()`](https://mlr3misc.mlr-org.com/reference/clbk.html). For more
information on optimization callbacks see
[`callback_async()`](https://bbotk.mlr-org.com/reference/callback_async.md).

## See also

[`callback_async()`](https://bbotk.mlr-org.com/reference/callback_async.md)

## Super class

[`mlr3misc::Callback`](https://mlr3misc.mlr-org.com/reference/Callback.html)
-\> `CallbackAsync`

## Public fields

- `on_optimization_begin`:

  (`function()`)  
  Stage called at the beginning of the optimization in the main process.
  Called in `Optimizer$optimize()`.

- `on_worker_begin`:

  (`function()`)  
  Stage called at the beginning of the optimization on the worker.
  Called in the worker loop.

- `on_optimizer_before_eval`:

  (`function()`)  
  Stage called after the optimizer proposes points. Called in
  `OptimInstance$.eval_point()`.

- `on_optimizer_after_eval`:

  (`function()`)  
  Stage called after points are evaluated. Called in
  `OptimInstance$.eval_point()`.

- `on_optimizer_queue_before_eval`:

  (`function()`)  
  Stage called after the optimizer proposes points. Called in
  `OptimInstance$.eval_queue()`.

- `on_optimizer_queue_after_eval`:

  (`function()`)  
  Stage called after points are evaluated. Called in
  `OptimInstance$.eval_queue()`.

- `on_worker_end`:

  (`function()`)  
  Stage called at the end of the optimization on the worker. Called in
  the worker loop.

- `on_result_begin`:

  (`function()`)  
  Stage called before the results are written. Called in
  `OptimInstance$assign_result()`.

- `on_result_end`:

  (`function()`)  
  Stage called after the results are written. Called in
  `OptimInstance$assign_result()`.

- `on_optimization_end`:

  (`function()`)  
  Stage called at the end of the optimization in the main process.
  Called in `Optimizer$optimize()`.

## Methods

### Public methods

- [`CallbackAsync$clone()`](#method-CallbackAsync-clone)

Inherited methods

- [`mlr3misc::Callback$call()`](https://mlr3misc.mlr-org.com/reference/Callback.html#method-call)
- [`mlr3misc::Callback$format()`](https://mlr3misc.mlr-org.com/reference/Callback.html#method-format)
- [`mlr3misc::Callback$help()`](https://mlr3misc.mlr-org.com/reference/Callback.html#method-help)
- [`mlr3misc::Callback$initialize()`](https://mlr3misc.mlr-org.com/reference/Callback.html#method-initialize)
- [`mlr3misc::Callback$print()`](https://mlr3misc.mlr-org.com/reference/Callback.html#method-print)

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    CallbackAsync$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
