#' Refactor Code
#'
#' Both original and refactored expressions are run. By default the function will fail if
#' the outputs are different.
#'
#' Options can be set to alter the behavior:
#'
#' * if `refactor.value` is `TRUE` (the default), the sameness of the outputs of
#'   `original` and `refactored` is tested
#' * if `refactor.env` is `TRUE` (default is `FALSE`), the sameness of the modifications
#'   to the local environment made by `original` and `refactored` is tested
#' * if `refactor.time` is `TRUE` (default is `FALSE`), the improved execution speed of
#'   the refactored solution is tested
#'
#' @param original original expression
#' @param refactored refactored expression
#' @name refactor
#' @export
`%refactor%` <- function(original, refactored) {
  ## fetch options
  refactor.value <- getOption("refactor.value")
  refactor.time <- getOption("refactor.time")
  refactor.env <- getOption("refactor.env")

  ## capture expressions and env
  original          <- substitute(original)
  refactored        <- substitute(refactored)
  pf <- parent.frame()

  ## record env before modifications
  original_env_as_list      <- as.list(pf)
  original_var_nms  <- names(original_env_as_list)


  if(refactor.time) {
    original_time     <- system.time(original_value   <- eval.parent(original))[["elapsed"]]
  } else {
    original_value   <- eval.parent(original)
  }

  ## record env after modifications made by original code
  new_env1_as_list   <- as.list(pf)
  new_var_nms       <- names(new_env1_as_list)

  ## reinitiate env
  rm(list=setdiff(new_var_nms, original_var_nms), envir = pf)
  for (var_nm in intersect(new_var_nms, original_var_nms)) {
    pf[[var_nm]] <- original_env_as_list[[var_nm]]
  }

  if(refactor.time) {
    refactored_time   <- system.time(refactored_value <- eval.parent(refactored))[["elapsed"]]
  } else {
    refactored_value <- eval.parent(refactored)
  }

  ## record env after modifications made by refactored code
  new_env2_as_list   <- as.list(pf)

  if(refactor.value && !identical(original_value, refactored_value)) {
    stop("The refactored expression returns a different value than the original one.\n\n",
         paste(waldo::compare(
           original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
           collapse = "\n\n"),
         call. = FALSE)
  }

  if(refactor.env && !identical(new_env1_as_list, new_env2_as_list)) {
    stop("The original and refactored expressions operate different changes to the local environment.\n\n",
         paste(waldo::compare(
           new_env1_as_list, new_env2_as_list, x_arg = "original", y_arg = "refactored"),
           collapse = "\n\n"),
         call. = FALSE)
  }

  if(refactor.time && refactored_time > original_time) {
    stop("The refactored code ran slower than the original code.\n",
         paste(waldo::compare(
           original_time, refactored_time, x_arg = "original time (s)", y_arg = "refactored time (s)"),
           collapse = "\n\n"),
         call. = FALSE)
  }
  return(original_value)
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
      stop("The refactored code ran slower than the original code.\n",
           paste(waldo::compare(
             original_time, refactored_time, x_arg = "original time (s)", y_arg = "refactored time (s)"),
             collapse = "\n\n"),
           call. = FALSE)
    }
    return(refactored_value)
  }
  stop("The refactored expression returns a different value than the original one.\n",
       paste(waldo::compare(
         original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
         collapse = "\n\n"),
       call. = FALSE)
}



