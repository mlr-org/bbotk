# Create Batch Optimization Callback

Specialized
[mlr3misc::Callback](https://mlr3misc.mlr-org.com/reference/Callback.html)
for batch optimization. Callbacks allow to customize the behavior of
processes in bbotk. The
[`callback_batch()`](https://bbotk.mlr-org.com/reference/callback_batch.md)
function creates a CallbackBatch. Predefined callbacks are stored in the
[dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
[mlr_callbacks](https://mlr3misc.mlr-org.com/reference/mlr_callbacks.html)
and can be retrieved with
[`clbk()`](https://mlr3misc.mlr-org.com/reference/clbk.html). For more
information on optimization callbacks see
[`callback_batch()`](https://bbotk.mlr-org.com/reference/callback_batch.md).

## See also

[`callback_batch()`](https://bbotk.mlr-org.com/reference/callback_batch.md)

## Super class

[`mlr3misc::Callback`](https://mlr3misc.mlr-org.com/reference/Callback.html)
-\> `CallbackBatch`

## Public fields

- `on_optimization_begin`:

  (`function()`)  
  Stage called at the beginning of the optimization. Called in
  `Optimizer$optimize()`.

- `on_optimizer_before_eval`:

  (`function()`)  
  Stage called after the optimizer proposes points. Called in
  `OptimInstance$eval_batch()`.

- `on_optimizer_after_eval`:

  (`function()`)  
  Stage called after points are evaluated. Called in
  `OptimInstance$eval_batch()`.

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
  Stage called at the end of the optimization. Called in
  `Optimizer$optimize()`.

## Methods

### Public methods

- [`CallbackBatch$clone()`](#method-CallbackBatch-clone)

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

    CallbackBatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

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
