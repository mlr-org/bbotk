# Freeze Archive Callback

This
[CallbackAsync](https://bbotk.mlr-org.com/dev/reference/CallbackAsync.md)
freezes the
[ArchiveAsync](https://bbotk.mlr-org.com/dev/reference/ArchiveAsync.md)
to
[ArchiveAsyncFrozen](https://bbotk.mlr-org.com/dev/reference/ArchiveAsyncFrozen.md)
after the optimization has finished.

## Examples

``` r
clbk("bbotk.async_freeze_archive")
#> <CallbackAsync:bbotk.async_freeze_archive>: Archive Freeze Callback
#> * Active Stages: on_optimization_end
```
