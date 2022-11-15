library(roxygen2)

roxy_tag_parse.roxy_tag_cparam = function(x) {
  tag_name_description(x)
}

roxy_tag_rd.roxy_tag_cparam <- function(x, base_path, env) {
  value <- setNames(x$val$description, x$val$name)
  rd_section(x$tag, value)
}

#' @export
format.rd_section_cparam <- function(x, ...) {
  browser()
  names = names(x$value)
  items = x$value
  comment =
  paste0(
    "\\section{Control Parameters}{\n",
    "\\describe{\n",
    paste0("\\item{", names, "}{", items, "}\n", collapse = ""),
    "}\n",
    "}\n"
  )
}
