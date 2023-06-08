#' Identify hybrid scripts
#'
#' Identify scripts who contain both function definitions and other object definitions.
#'
#' @param path A string. The path to a file or the folder to explore
#'   By default explores the working directory.
#' @param recursive A boolean. Passed to `list.files()` if `path` is a directory
#'
#' @return Returns the path invisibly, called for side effects.
#' @export
identify_hybrid_scripts <- function(path = ".", recursive = TRUE) {
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

  is_function_call <- function(x) {
    is.call(x) &&
      list(x[[1]]) %in% c(quote(`<-`), quote(`=`)) &&
      is.call(x[[3]]) &&
      identical(x[[c(3, 1)]], quote(`function`))
  }

  get_file_markers <- function(file) {
    code <- parse(file)
    calls_are_fun_defs <- sapply(as.list(code), is_function_call)

    if(all(calls_are_fun_defs) || all(!calls_are_fun_defs)) {
      return(NULL)
    }

    data <- getParseData(code)
    level1 <- data$id[data$parent == 0]
    level2 <- data$id[data$parent %in% level1]
    lines <- unique(data[data$id %in% level2, "line1"])
    if(calls_are_fun_defs[[1]]) {
      msg <- "The script starts with a function definition but contains other object definitions"
      line <- lines[which(!calls_are_fun_defs)[[1]]]
    } else {
      msg <- "The script starts with a non function object definition but contains functions"
      line <- lines[which(calls_are_fun_defs)[[1]]]
    }
    markers <- data.frame(
      type = "info",
      file = file,
      line = line,
      column = 1,
      message = msg
    )
    markers
  }

  markers <- lapply(all_scripts, get_file_markers)
  markers <- do.call(rbind, markers)
  if(is.null(markers)) {
    message("All scripts contain either only function definitions or no function definition")
    return(invisible(path))
  }
  rstudioapi::sourceMarkers("Hybrid scripts", markers)
  invisible(path)
}
