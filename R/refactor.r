#' Refactor Code
#'
#' Both original and refactored expressions are run. The function will fail if
#' the outputs are different. `%refactor2%` will also fail if the refactored
#' expression runs slower.
#'
#' @param original original expression
#' @param refactored refactored expression
#' @name refactor
#' @export
#' @examples
#' {
#' apply(cars, 1, max)
#' } %refactor% {
#'   do.call(pmax, cars)
#' }
`%refactor%` <- function(original, refactored) {
  original          <- substitute(original)
  refactored        <- substitute(refactored)
  original_value    <- eval.parent(original)
  refactored_value <- eval.parent(refactored)
  if(identical(original_value, refactored_value)) {
    return(refactored_value)
  }
  stop("The refactored expression returns a different from the original one\n",
       waldo::compare(
         original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
       call. = FALSE)
}

#' @export
#' @rdname refactor
`%refactor2%` <- function(original, refactored) {
  original          <- substitute(original)
  refactored        <- substitute(refactored)
  original_time     <- system.time(original_value   <- eval.parent(original))[["elapsed"]]
  refactored_time   <- system.time(refactored_value <- eval.parent(refactored))[["elapsed"]]
  if(identical(original_value, refactored_value)) {
    if(refactored_time > original_time) {
      stop("The refactored code ran slower than the original code\n",
           waldo::compare(
             original_time, refactored_time, x_arg = "original time (s)", y_arg = "refactored time (s)"),
           call. = FALSE)
    }
    return(refactored_value)
  }
  stop("The refactored expression returns a different from the original one\n",
       waldo::compare(
         original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
       call. = FALSE)
}
