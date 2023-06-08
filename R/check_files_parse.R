#' Check that files parse correctly
#'
#' This identifies files that contain non syntactic code, including files that
#' have an R extension despite not being an R script.
#'
#' @param path A string. The path to a file or the folder to explore
#'   By default explores the working directory.
#' @param recursive A boolean. Passed to `list.files()` if `path` is a directory
#'
#' @return Returns the path invisibly, called for side effects.
#' @export
check_files_parse <- function(path = ".", recursive = TRUE) {
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

  errors <- sapply(all_scripts, function(file) {
    error <- tryCatch(parse(file), error = function(e) e$message)
    if (!is.character(error)) error <- ""
    if (startsWith(error, "invalid multibyte character in parse")) {
      is_rdata <- !inherits(try(load(file, envir = new.env())), "try-error")
      if(is_rdata) return("`.RData` file stored as `.R`")
      is_rds <- !inherits(try(readRDS(file)), "try-error")
      if(is_rdata) return("`.RDS` file stored as `.R`")
    }
    error
  })
  errors <- errors[errors != ""]
  if(!length(errors)) {
    message("All R scripts contain syntactic codes")
    return(invisible(path))
  }
  markers <- data.frame(
    type = "error",
    file = names(errors),
    message = errors,
    line= ifelse(
      endsWith(errors, "^"),
      as.numeric(sub("^.*\n(\\d+): +.+\n +\\^$", "\\1", errors)),
      1),
    column=1
  )

  rstudioapi::sourceMarkers("Check that files parse", markers)
  invisible(path)
}
