# `irace` package causes partial match warnings
# fix not on cran yet
# old_opts = options(
#   warnPartialMatchArgs = TRUE,
#   warnPartialMatchAttr = TRUE,
#   warnPartialMatchDollar = TRUE
# )

# https://github.com/HenrikBengtsson/Wishlist-for-R/issues/88
# old_opts = lapply(old_opts, function(x) if (is.null(x)) FALSE else x)

old_threshold = lg$threshold
lg$set_threshold("warn")
