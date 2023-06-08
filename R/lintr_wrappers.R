#' Use lintr template
#'
#' This opens up an untitled script in RStudio containing calls to `lintr::lint()`
#' or `lintr::lint_dir()` with various linters, sorted by category and rough
#' order of importance.
#'
#' @param path Path to a R script or a directory. By default `use_lint_template_on_file()`
#'   considers the active document and `use_lint_template_on_dir()` considers the
#'   project folder as returned by `here::here()`
#'
#' @return Returns `NULL` invisibly. Called for side effects.
#' @export
use_lintr_template_on_file <- function(path = NULL) {
  if (is.null(path)) path <- rstudioapi::documentPath(rstudioapi::documentId(FALSE))
  template_path <- system.file("lint_file_template.R", package = "refactor")
  lines <- readLines(template_path)
  lines[[3]] <- sprintf('path <- "%s"', path)
  rstudioapi::documentNew(lines)
  invisible(NULL)
}

#' @rdname use_lintr_template_on_file
#' @export
use_lintr_template_on_dir <- function(path = NULL) {
  if (is.null(path)) path <- here::here()
  template_path <- system.file("lint_dir_template.R", package = "refactor")
  lines <- readLines(template_path)
  lines[[3]] <- sprintf('linted_dir <- "%s"', path)
  rstudioapi::documentNew(lines)
  invisible(NULL)
}
