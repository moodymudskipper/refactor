.onLoad <- function(libname, pkgname) {
  op <- options()
  op.refactor <- list(
    refactor.value = TRUE,
    refactor.env = FALSE,
    refactor.time = FALSE
  )
  toset <- !(names(op.refactor ) %in% names(op))
  if(any(toset)) options(op.refactor[toset])

  invisible(NULL)
}
