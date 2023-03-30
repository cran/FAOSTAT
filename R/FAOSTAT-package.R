##' A complementary package to the FAOSTAT database and the
##' Statistical Yearbook of the Food and Agricultural Organization of
##' the United Nations.
##'
##'
##' @name FAOSTAT-package
##' @docType package
##' @title A complementary package to the FAOSTAT database and the
##' Statistical Yearbook of the Food and Agricultural Organization of
##' the United Nations.
##' @author Michael. C. J. Kao \email{michael.kao@@fao.org}
##' @keywords package
##' @import RJSONIO
##' @import plyr
##' @import data.table
##' @import MASS
##' @import classInt
##' @import labeling
##' @import httr
##'

.FAOSTATenv <- new.env()
# Remove CHECK note due to non-standard evaluation in data.table
utils::globalVariables(c("code", "label", "date_update"))
