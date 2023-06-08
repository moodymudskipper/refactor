#' Fetch namespace names
#'
#' Scans the code and finds all namespaced call of the form `pkg::fun` and returns
#' a vector of unique package names.
#'
#' @param path A string. The path to a file or the folder to explore
#'   By default explores the working directory.
#' @param recursive A boolean. Passed to `list.files()` if `path` is a directory
#'
#' @return A character vector of package names
#' @export
fetch_namespace_names <- function(path = ".", recursive = TRUE) {
  if (dir.exists(path)) {
    all_scripts <- list.files(
      path,
      pattern = "\\.[rR]$",
      full.names = TRUE,
      recursive = recursive
    )
  } else {
    if (!file.exists(path)) {
      stop("wrong file")
    }
    all_scripts <- path
  }

  code <- sapply(all_scripts, parse)
  namespaces <- list()
  collect_namespaced_calls <- function(call) {
    if(!is.call(call) && !is.expression(call)) {
      return()
    }
    if(rlang::is_call(call, "::")) {
      namespaces <<- c(namespaces, call[[2]])
      return()
    }
    lapply(as.list(call), collect_namespaced_calls)
    invisible()
  }
  lapply(code, collect_namespaced_calls)
  sort(as.character(unique(namespaces)))
}

#' Use namespace check
#'
#' Wrapper around `fetch_namespace_names()` that opens a new RStudio source editot
#'   tab with code to be pasted at the top of the main script to enumerate required
#'   packages and test if they are installed.
#'
#' @return Returns `NULL` invisibly, called for side effects.
#' @export
use_namespace_check <- function() {
  pkgs <- fetch_namespace_names()
  #pkgs <- capture.output(dput(pkgs))
  #pkgs <- paste(pkgs, collapse = "\n")
  code <- sprintf("requireNamespace(\"%s\")", pkgs)
  rstudioapi::documentNew(code, "r")
  invisible(NULL)
}

