% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grConstruct.R
\name{grConstruct}
\alias{grConstruct}
\title{Construct Growth rate}
\usage{
grConstruct(data, origVar, newVarName = NA, type = c("geo", "ls", "ch"), n = 1)
}
\arguments{
\item{data}{The data frame containing the data}

\item{origVar}{The variable in which the growth is to be calculated}

\item{newVarName}{The name assigned to the new variable, if missing
then .SC/.SH/.GR will be appended depending on the type of
construction.}

\item{type}{The type of growth rate, can be least squares or
geometric}

\item{n}{The period for the growth rate to be calculated (Refer to
the lsgr or the geogr functions.)}
}
\value{
A data frame containing the computed growth rate.
}
\description{
A function for constructing growth rate variables.
}
\examples{
test.df2 = data.frame(FAOST_CODE = rep(c(1, 5000), each = 5),
                       Year = rep(1990:1994, 2),
                       a = rep(1:5, 2), b = rep(1:5, 2))
grConstruct(test.df2, origVar = "a", type = "geo", n = 1)
grConstruct(test.df2, origVar = "a", type = "geo", n = 3)
grConstruct(test.df2, origVar = "a", type = "geo", n = 5)
}
