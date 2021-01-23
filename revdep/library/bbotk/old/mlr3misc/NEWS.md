# mlr3misc 0.7.0

* Make more map functions work nicely with data frames and data tables.
* `formulate()` now supports multiple LHS terms.
* Added `format_bib()` and `cite_bib()` helpers for working with bibentires and
  roxygen2.

# mlr3misc 0.6.0

* New argument `.timeout` for `invoke()`.
* New argument `.timeout` for `encapsulate()`.
* Removed `cite_bib()` and Rd macro `\cite{}` and removed orphaned package
  `bibtex` from suggests.
* New argument `quietly` for `require_namespaces()`.
* New function `crate()` to cleanly separate a function from its environment.
* New function `register_namespace_callback()`.

# mlr3misc 0.5.0

* Added `compose()` function for function composition.
* Added method `leanify_package()` that shrinks the size of serialized R6
  objects.

# mlr3misc 0.4.0

* Added helper functions to assist in generating Rd documentation for 'mlr3'
  objects.

# mlr3misc 0.3.0

* Introduced a placeholder for column name prefixes in `unnest()`.

# mlr3misc 0.2.0

* Fixed an issue with `rcbind()` for columns of `x` named `y` (#42).
* Fixed broken `on.exit()` in `invoke()` if both a seed and a list of options
  were provided.

# mlr3misc 0.1.8

* New function `check_packages_installed()`.
* New function `open_help()`.

# mlr3misc 0.1.7

* `map_dtr()`, `imap_dtr()` and `pmap_dtr()` now pass `.idcol` down to argument
  `idcol` of `data.table::rbindlist()`.
* `cite_bib()` can now handle packages with multiple citation entries.
* Added argument `wrap` to `catf()`, `messagef()`, `warningf()` and `stopf()` to
  wrap the respective messages to a customizable width.
* Added `with_package()` helper, similar to the one in package `withr`.

# mlr3misc 0.1.6

* `cite_bib()` or Rd macro `\cite{}` can now return the citation information of
  the package if key is set to `"pkg::citation"`.
* Updated dictionary helpers.

# mlr3misc 0.1.5

* Fixed error in C code discovered by UBSAN checks on CRAN.
* Added `dictionary_sugar_mget()`.
* Renamed `dictionary_sugar()` to `dictionary_sugar_get()`.
* Added function `cite_bib()` and Rd macro `\cite{}` to insert entries from
  bibtex files into roxygen documentation.
* `unnest()` now creates list columns for non atomic list elements.

# mlr3misc 0.1.4

* Added argument `na_rm` to `which_max()` and `which_min()`.
* Fixed a bug in `as_short_string()` for empty atomic vectors.

# mlr3misc 0.1.3

* New function `detect()`.
* New function `dictionary_sugar()`.
* It is now asserted that the return value of `Dictionary$get()` is an R6 object.
* Fix some assertions in `Dictionary`

# mlr3misc 0.1.2

* New function `named_vector()`.
* New function `keep_in_bounds()`.
* New function `set_col_names()`.
* New function `distinct_values()`.
* Added argument `.key` to `rowwise_table()`.
* Additional arguments passed to `Dictionary$get()` and `Dictionary$mget()`
  must now be named.

# mlr3misc 0.1.1

* New function `encapsulate()` to call functions while recording a log.
* `invoke()`: New arguments `.opts` and `.seed` to temporarily set options or
  random seeds, respectively.
* Fixed warnings about partial argument matching.

# mlr3misc 0.1.0

* Initial release.
