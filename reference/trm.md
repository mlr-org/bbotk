# Syntactic Sugar Terminator Construction

This function complements
[mlr_terminators](https://bbotk.mlr-org.com/reference/mlr_terminators.md)
with functions in the spirit of `mlr_sugar` from
[mlr3](https://CRAN.R-project.org/package=mlr3).

## Usage

``` r
trm(.key, ...)

trms(.keys, ...)
```

## Arguments

- .key:

  (`character(1)`)  
  Key passed to the respective
  [dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  to retrieve the object.

- ...:

  (named [`list()`](https://rdrr.io/r/base/list.html))  
  Named arguments passed to the constructor, to be set as parameters in
  the
  [paradox::ParamSet](https://paradox.mlr-org.com/reference/ParamSet.html),
  or to be set as public field. See
  [`mlr3misc::dictionary_sugar_get()`](https://mlr3misc.mlr-org.com/reference/dictionary_sugar_get.html)
  for more details.

- .keys:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Keys passed to the respective
  [dictionary](https://mlr3misc.mlr-org.com/reference/Dictionary.html)
  to retrieve multiple objects.

## Value

- [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) for
  `trm()`.

- list of
  [Terminator](https://bbotk.mlr-org.com/reference/Terminator.md) for
  `trms()`.

## Examples

``` r
trm("evals", n_evals = 10)
#> 
#> ── <TerminatorEvals> - Number of Evaluation ────────────────────────────────────
#> • Parameters: n_evals=10, k=0
```
