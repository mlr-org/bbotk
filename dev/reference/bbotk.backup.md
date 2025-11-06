# Backup Archive Callback

This
[CallbackBatch](https://bbotk.mlr-org.com/dev/reference/CallbackBatch.md)
writes the [Archive](https://bbotk.mlr-org.com/dev/reference/Archive.md)
after each batch to disk.

## Examples

``` r
clbk("bbotk.backup", path = "backup.rds")
#> <CallbackBatch:bbotk.backup>: Backup Archive Callback
#> * Active Stages: on_optimizer_after_eval, on_optimization_begin
```
