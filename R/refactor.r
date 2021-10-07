#' Refactor Code
#'
#' These operators are used to refactor code and differ in the difference of
#' behavior they allow between refactored and original code.
#'
#' *
#' Both original and refactored expressions are run. By default the function will fail if
#' the outputs are different. `%ignore_original%` and `%ignore_refactored%` do as
#' heir names suggest.
#'
#' Options can be set to alter the behavior of `%refactor%`:
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
#' `%refactor_*%` functions are variants that are not affected by options other than
#'  `refactor.waldo`:
#'
#' * `%refactor_chunk%` behaves like `%refactor%` with `options(refactor.value = FALSE, refactor.env = TRUE, refactor.time = FALSE)`,
#'   it's convenient to refactor chunks of code that modify the local environment.
#' * `%refactor_value%` behaves like `%refactor%` with `options(refactor.value = TRUE, refactor.env = FALSE, refactor.time = FALSE)`,
#'   it's convenient to refactor the body of a function that returns a useful value.
#' * `%refactor_chunk_and_value%` behaves like `%refactor%` with `options(refactor.value = TRUE, refactor.env = TRUE, refactor.time = FALSE)`,
#'   it's convenient to refactor the body of a function that returns a closure.
#' * `%refactor_chunk_efficiently%`, `%refactor_value_efficiently%` and `%refactor_chunk_and_value_efficiently%` are variants of the above
#'   which also check the improved execution speed of the refactored solution
#'
#'  2 additional functions are used to avoid akward commenting of code, when the original
#'  and refactored code have different behaviors.
#'
#'  * `%ignore_original%` and `%ignore_refactored%` are useful when original and
#'   refactored code give different results (possibly because one of them is wrong)
#'   and we want to keep both codes around without commenting.
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
    src_env = parent.frame())
}

#' @export
#' @rdname refactor
`%refactor_chunk%` <- function(original, refactored) {
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = FALSE,
    refactor.time = FALSE,
    refactor.env = TRUE,
    refactor.waldo = getOption("refactor.waldo"),
    src_env = parent.frame())
}

#' @export
#' @rdname refactor
`%refactor_value%` <- function(original, refactored) {
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = TRUE,
    refactor.time = FALSE,
    refactor.env = FALSE,
    refactor.waldo = getOption("refactor.waldo"),
    src_env = parent.frame())
}

#' @export
#' @rdname refactor
`%refactor_chunk_and_value%` <- function(original, refactored) {
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = TRUE,
    refactor.time = FALSE,
    refactor.env = TRUE,
    refactor.waldo = getOption("refactor.waldo"),
    src_env = parent.frame())
}

#' @export
#' @rdname refactor
`%refactor_chunk_efficiently%` <- function(original, refactored) {
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = FALSE,
    refactor.time = TRUE,
    refactor.env = TRUE,
    refactor.waldo = getOption("refactor.waldo"),
    src_env = parent.frame())
}

#' @export
#' @rdname refactor
`%refactor_value_efficiently%` <- function(original, refactored) {
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = TRUE,
    refactor.time = TRUE,
    refactor.env = FALSE,
    refactor.waldo = getOption("refactor.waldo"),
    src_env = parent.frame())
}

#' @export
#' @rdname refactor
`%refactor_chunk_and_value_efficiently%` <- function(original, refactored) {
  refactor_impl(
    original = substitute(original),
    refactored =  substitute(refactored),
    refactor.value = TRUE,
    refactor.time = TRUE,
    refactor.env = TRUE,
    refactor.waldo = getOption("refactor.waldo"),
    src_env = parent.frame())
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



