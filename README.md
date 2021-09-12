
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

  - `%refactor%` is used to check that the output value is consistent
  - `%refactor2%` also checks that the refactored version runs faster

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
#> Error: The refactored expression returns a different value than the original one
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

Now let’s demonstrate `%refactor2%` by inverting the original and
refactored code, and using bigger data so execution time differences are
noticeable :

``` r
cars2 <- do.call(rbind, replicate(1000,cars, F))
fun3 <- function(data) {
  do.call(pmax, data)
} %refactor2% {
  apply(data, 1, max)
}
fun3(cars2)
#> Error: The refactored code ran slower than the original code
#>   `original time (s)`: 0.00
#> `refactored time (s)`: 0.09
```

## Caveats

We don’t control that side effects are the same on both sides, this
means the following for instance might be different in your refactored
code and you won’t be warned about it :

  - modified environments
  - written files
  - printed output
  - messages
  - warnings
  - errors

We might be able to support some of those though.

More importantly since both side are run, side effects will be run twice
and in some case this might change the behavior of the program, so use
cautiously.
