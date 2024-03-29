% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/refactor.r
\name{refactor}
\alias{refactor}
\alias{\%refactor\%}
\alias{\%refactor_chunk\%}
\alias{\%refactor_value\%}
\alias{\%refactor_chunk_and_value\%}
\alias{\%refactor_chunk_efficiently\%}
\alias{\%refactor_value_efficiently\%}
\alias{\%refactor_chunk_and_value_efficiently\%}
\alias{\%ignore_original\%}
\alias{\%ignore_refactored\%}
\title{Refactor Code}
\usage{
original \%refactor\% refactored

original \%refactor_chunk\% refactored

original \%refactor_value\% refactored

original \%refactor_chunk_and_value\% refactored

original \%refactor_chunk_efficiently\% refactored

original \%refactor_value_efficiently\% refactored

original \%refactor_chunk_and_value_efficiently\% refactored

original \%ignore_original\% refactored

original \%ignore_refactored\% refactored
}
\arguments{
\item{original}{original expression}

\item{refactored}{refactored expression}
}
\description{
These operators are used to refactor code and differ in the difference of
behavior they allow between refactored and original code.
}
\details{
\itemize{
\item 
}

Both original and refactored expressions are run. By default the function will fail if
the outputs are different. \verb{\%ignore_original\%} and \verb{\%ignore_refactored\%} do as
heir names suggest.

Options can be set to alter the behavior of \verb{\%refactor\%}:
\itemize{
\item if \code{refactor.value} is \code{TRUE} (the default), the sameness of the outputs of
\code{original} and \code{refactored} is tested
\item if \code{refactor.env} is \code{TRUE} (default is \code{FALSE}), the sameness of the modifications
to the local environment made by \code{original} and \code{refactored} is tested
\item if \code{refactor.time} is \code{TRUE} (default is \code{FALSE}), the improved execution speed of
the refactored solution is tested
\item if \code{refactor.waldo} is \code{TRUE} (the default), the \code{waldo::compare} will be used
to compare objects or environments in case of failure. 'waldo' is sometimes
slow and if we set this option to \code{FALSE}, \code{dplyr::all_equal()} would be used instead.
}

\verb{\%refactor_*\%} functions are variants that are not affected by options other than
\code{refactor.waldo}:
\itemize{
\item \verb{\%refactor_chunk\%} behaves like \verb{\%refactor\%} with \code{options(refactor.value = FALSE, refactor.env = TRUE, refactor.time = FALSE)},
it's convenient to refactor chunks of code that modify the local environment.
\item \verb{\%refactor_value\%} behaves like \verb{\%refactor\%} with \code{options(refactor.value = TRUE, refactor.env = FALSE, refactor.time = FALSE)},
it's convenient to refactor the body of a function that returns a useful value.
\item \verb{\%refactor_chunk_and_value\%} behaves like \verb{\%refactor\%} with \code{options(refactor.value = TRUE, refactor.env = TRUE, refactor.time = FALSE)},
it's convenient to refactor the body of a function that returns a closure.
\item \verb{\%refactor_chunk_efficiently\%}, \verb{\%refactor_value_efficiently\%} and \verb{\%refactor_chunk_and_value_efficiently\%} are variants of the above
which also check the improved execution speed of the refactored solution
}

2 additional functions are used to avoid akward commenting of code, when the original
and refactored code have different behaviors.
\itemize{
\item \verb{\%ignore_original\%} and \verb{\%ignore_refactored\%} are useful when original and
refactored code give different results (possibly because one of them is wrong)
and we want to keep both codes around without commenting.
}
}
