% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fetch_namespace_names.R
\name{fetch_namespace_names}
\alias{fetch_namespace_names}
\title{Fetch namespace names}
\usage{
fetch_namespace_names(path = ".", recursive = TRUE)
}
\arguments{
\item{path}{A string. The path to a file or the folder to explore
By default explores the working directory.}

\item{recursive}{A boolean. Passed to \code{list.files()} if \code{path} is a directory}
}
\value{
A character vector of package names
}
\description{
Scans the code and finds all namespaced call of the form \code{pkg::fun} and returns
a vector of unique package names.
}
