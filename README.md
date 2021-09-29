
<!-- README.md is generated from README.Rmd. Please edit that file -->

# refactor

Refactoring code can be a bit scary, what if we mess something up and
end up with a different output or slower code?

Hopefully no more\! {refactor} lets you run both the original and
refactored version of your code and checks whether the output is the
same and if it runs as fast. Then when you’re comfortable with your work
you can remove the original version.

## Installation

Install with:

``` r
remotes::install_github("moodymudskipper/refactor")
```

## Examples

``` r
library(refactor)
```

`%refactor%` by default checks that the output value is consistent
between the original and refactored expressions.

They’ll often be used on the body of a function but can be used on any
expression.

Here I intend to correct an inefficient use of the `apply()` function,
but used `pmax` incorrectly:

``` r
fun1 <- function(data) {
  apply(data, 1, max)
} %refactor% {
  pmax(data)
}
fun1(cars)
#> Error: The refactored expression returns a different value than the original one.
#> 
#> `original` is a double vector (4, 10, 7, 22, 16, ...)
#> `refactored` is an S3 object of class <data.frame>, a list
```

Now using it correctly:

``` r
fun2 <- function(data) {
  apply(data, 1, max)
} %refactor% {
  do.call(pmax, data)
}
fun2(cars)
#>  [1]   4  10   7  22  16  10  18  26  34  17  28  14  20  24  28  26  34  34  46
#> [20]  26  36  60  80  20  26  54  32  40  32  40  50  42  56  76  84  36  46  68
#> [39]  32  48  52  56  64  66  54  70  92  93 120  85
```

We can use the option `refactor.env` to test that the local environment
isn’t changed in different ways by the original and refactored
expression.

``` r
options("refactor.env" = TRUE)
{
  # original code
  data <- cars
  i <- 1
  apply(data, i, max)
} %refactor% {
  # refactored code
  do.call(pmax, cars)
}
#> Error: The original and refactored expressions operate different changes to the local environment.
#> 
#> `original` is length 4
#> `refactored` is length 2
#> 
#> `names(original)`:   "i" "data" "fun1" "fun2"
#> `names(refactored)`:            "fun1" "fun2"
#> 
#> `original$i` is a double vector (1)
#> `refactored$i` is absent
#> 
#> `original$data` is an S3 object of class <data.frame>, a list
#> `refactored$data` is absent
```

We can use the option `refactor.time` to test that the refactored
solution is faster.

``` r
# use bigger data so execution time differences are noticeable
cars2 <- do.call(rbind, replicate(1000,cars, F))

options("refactor.time" = TRUE)
fun3 <- function(data) {
  do.call(pmax, data)
} %refactor% {
  apply(data, 1, max)
}
fun3(cars2)
#> Error: The refactored code ran slower than the original code.
#>   `original time (s)`: 0.00
#> `refactored time (s)`: 0.08
```

## Caveats

We don’t control that side effects are the same on both sides, with the
exception of modifications to the local environment. This means the
following for instance might be different in your refactored code and
you won’t be warned about it :

  - modified environments (other than local)
  - written files
  - printed output
  - messages
  - warnings
  - errors

We might be able to support some of those though.

More importantly since both side are run, side effects will be run twice
and in some case this might change the behavior of the program, so use
cautiously.
