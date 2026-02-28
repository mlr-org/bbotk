# Reflections for bbotk

Environment which stores various information to allow objects to examine
and introspect their structure and properties (c.f.
[Reflections](https://en.wikipedia.org/wiki/Reflective_programming)).

This environment be modified by third-party packages.

The following objects are set by
[bbotk](https://CRAN.R-project.org/package=bbotk):

- `optimizer_properties`
  ([`character()`](https://rdrr.io/r/base/character.html))  
  Properties of an optimizer, e.g. "dependencies".

- `objective_properties`
  ([`character()`](https://rdrr.io/r/base/character.html))  
  Properties of an objective, e.g. "noisy".

## Usage

``` r
bbotk_reflections
```

## Format

[environment](https://rdrr.io/r/base/environment.html).

## Examples

``` r
ls.str(bbotk_reflections)
#> objective_properties :  chr [1:4] "noisy" "single-crit" "multi-crit" "deterministic"
#> optimizer_properties :  chr [1:4] "dependencies" "single-crit" "multi-crit" "async"
#> terminator_properties :  chr [1:2] "single-crit" "multi-crit"
```
