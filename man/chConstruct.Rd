\name{chConstruct}
\alias{chConstruct}
\title{Construct year to year change}
\usage{
  chConstruct(var, country = "FAOST_CODE", year = "Year",
    data, newVarName = NA, n = 1)
}
\arguments{
  \item{var}{The variable in which the year to year change
  is to be calculated}

  \item{country}{The column representing the index of
  country.}

  \item{year}{The column represing the index of year.}

  \item{data}{The data frame containing the data}

  \item{newVarName}{The name assigned to the new variable,
  if missing then .CH will be appended.}

  \item{n}{The period for the change rate to be
  calculated.}
}
\value{
  A data frame containing the computed year to year change
  rate.
}
\description{
  A function for constructing year to year change
}

