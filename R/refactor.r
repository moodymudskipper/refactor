#' Refactor Code
#'
#' Both original and refactored expressions are run. By default the function will fail if
#' the outputs are different. `%ignore_original%` and `%ignore_refactored%` do as
#' heir names suggest.
#'
#' Options can be set to alter the behavior:
#'
#' * if `refactor.value` is `TRUE` (the default), the sameness of the outputs of
#'   `original` and `refactored` is tested
#' * if `refactor.env` is `TRUE` (default is `FALSE`), the sameness of the modifications
#'   to the local environment made by `original` and `refactored` is tested
#' * if `refactor.time` is `TRUE` (default is `FALSE`), the improved execution speed of
#'   the refactored solution is tested
#' * if `refactor.waldo` is `TRUE` (the default), the `waldo::compare` will be used
#'   to compare objects or environments in case of failure. 'waldo' is sometimes
#'   slow and if we set this option to `FALSE`, `dplyr::all_equal()` would be used instead.
#'
#'   `%ignore_original%` and `%ignore_refactored%` are useful when original and
#'   refactored code give different results (possibly because one of them is wrong)
#'   and we want to keep both codes around without tedious commening/uncommenting.
#' heir names suggest and are used to avoid tedious commenting/uncommenting
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
  refactor.waldo <- getOption("refactor.waldo")

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
         if(refactor.waldo)
           paste(waldo::compare(
           original_value, refactored_value, x_arg = "original", y_arg = "refactored"),
           collapse = "\n\n")
         else
           paste(all.equal(original_value, refactored_value), collapse = "\n\n"),
         call. = FALSE)
  }

  if(refactor.env && !identical(new_env1_as_list, new_env2_as_list)) {
    stop("The original and refactored expressions operate different changes to the local environment.\n\n",
         if(refactor.waldo)
         paste(waldo::compare(
           new_env1_as_list, new_env2_as_list, x_arg = "original", y_arg = "refactored"),
           collapse = "\n\n")
         else
           paste(all.equal(new_env1_as_list, new_env2_as_list), collapse = "\n\n"),
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
`%ignore_original%` <- function(original, refactored) {
  refactored <- substitute(refactored)
  eval.parent(refactored)
}

#' @export
#' @rdname refactor
`%ignore_refactored%` <- function(original, refactored) {
  refactored <- substitute(original)
  eval.parent(original)
}



