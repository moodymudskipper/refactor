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
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = getOption("refactor.value"),
    refactor.time = getOption("refactor.time"),
    refactor.env = getOption("refactor.env"),
    refactor.waldo = getOption("refactor.waldo"),
    pf = parent.frame())
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



