is_infix <- function(x) {
  startsWith(x, "%") & endsWith(x, "%")
}

#' Find all uses of a package's functions
#'
#' This will show false positives, but guarantees that we don't miss any instance.
#'
#' @param pkg A string. The name of the target package
#' @param path A string. The path to a file or the folder to explore
#'   By default explores the working directory.
#' @param recursive A boolean. Passed to `list.files()` if `path` is a directory
#' @param exclude A character vector of function names to dismiss.
#'
#' @return Returns its input invisibly, called for side effects
#' @export
find_pkg_funs <- function(pkg, path = ".", recursive = TRUE, exclude = NULL
                          # , include_s3_generics = FALSE
                          ) {
  # fetch package functions and their origin
  imports <- getNamespaceImports(pkg)
  imports <- Map(function(fun, pkg) data.frame(fun, pkg), imports, names(imports))
  imports <- do.call(rbind, imports)
  row.names(imports) <- NULL
  exports <- data.frame(fun = getNamespaceExports(pkg))
  exports <- exports[!exports$fun %in% exclude, , drop = FALSE]
  pkg_funs <- merge(exports, imports, all.x = TRUE)

  # ns <- asNamespace(pkg)
  # s3_methods  <- Filter(function(x) isS3method(x, envir = ns), ls(ns))
  # s3_generics <- sub("^([^.]+)\\..*$", "\\1", s3_methods)
  # s3 <- data.frame(method = s3_methods, generic = s3_generics)
  # s3 <- subset(s3, !generic %in% ls(ns))


  # fetch parse data
  if(dir.exists(path)) {
    files <- list.files(path, full.names = TRUE, recursive = recursive, pattern = "\\.[rR]$")
  } else {
    if (!file.exists(path)) stop(sprintf("Invalid value for `path`, '%s' doesn't exist", path))
    files <- path
  }

  parse_data <- lapply(files, function(file) {
    data <- getParseData(parse(file))
    data <- data[! data$token %in% c("SYMBOL_SUB", "SYMBOL_PACKAGE"),]
    i_namespaced <- which(data$text %in% c("::", ":::")) + 1
    if(length(i_namespaced)) data <- data[-i_namespaced,]
    transform(data, file = file)
    })
  parse_data <- do.call(rbind, parse_data)
  parse_data <- parse_data[c("line1", "col1", "text", "file")]

  # merge datasets
  merged <- merge(parse_data, pkg_funs, by.x = "text", by.y = "fun")

  if(!nrow(merged)) {
    message(sprintf("No potential function calls from {%s} were found in the code", pkg))
    return(invisible(NULL))
  }

  markers <- data.frame(
    type = "info",
    file = merged$file,
    line = merged$line1,
    column = merged$col1,
    message = ifelse(
      is.na(merged$pkg),
      ifelse(
        is_infix(merged$text),
        sprintf("Found `%s`, do we want `library(%s, include.only = '%s')` ?", merged$text, pkg, merged$text),
        sprintf("Found `%s`, do we want `%s::%s` ?", merged$text, pkg, merged$text)
        ),
      ifelse(
        is_infix(merged$text),
        sprintf("Found `%s`, do we want `library(%s, include.only = '%s')` (or more directly `library(%s, include.only = '%s')`)?", merged$text, pkg, merged$text, merged$pkg, merged$text),
        sprintf("Found `%s`, do we want `%s::%s` (or more directly `%s::%s`) ?", merged$text, pkg, merged$text, merged$pkg, merged$text)
        )
      )
  )

  rstudioapi::sourceMarkers("Functions that might come from", markers)
  invisible(pkg)
}

