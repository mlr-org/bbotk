# bbotk: Black-Box Optimization Toolkit

Features highly configurable search spaces via the 'paradox' package and
optimizes every user-defined objective function. The package includes
several optimization algorithms e.g. Random Search, Iterated Racing,
Bayesian Optimization (in 'mlr3mbo') and Hyperband (in 'mlr3hyperband').
bbotk is the base package of 'mlr3tuning', 'mlr3fselect' and
'miesmuschel'.

## Package Options

- `"bbotk.debug"`: If set to `TRUE`, asynchronous optimization is run in
  the main process.

- `"bbotk.tiny_logging"`: If set to `TRUE`, the logging is simplified to
  only show points and results. NA values are removed.

## See also

Useful links:

- <https://bbotk.mlr-org.com>

- <https://github.com/mlr-org/bbotk>

- Report bugs at <https://github.com/mlr-org/bbotk/issues>

## Author

**Maintainer**: Marc Becker <marcbecker@posteo.de>
([ORCID](https://orcid.org/0000-0002-8115-0400))

Authors:

- Jakob Richter <jakob1richter@gmail.com>
  ([ORCID](https://orcid.org/0000-0003-4481-5554))

- Michel Lang <michellang@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-9754-0393))

- Bernd Bischl <bernd_bischl@gmx.net>
  ([ORCID](https://orcid.org/0000-0001-6002-6980))

- Martin Binder <martin.binder@mail.com>

Other contributors:

- Olaf Mersmann <olafm@statistik.tu-dortmund.de> \[contributor\]
