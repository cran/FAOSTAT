##' Access to FAO FAOSTAT API
##'
##' A wrapper function using getFAO() to obtain and process multiple
##' data set to obtain data.
##'
##' @param name The name to be given to the variable.
##' @param domainCode The domain code of the variable, see details.
##' @param elementCode The element code of the variable, see details.
##' @param itemCode The item code of the variable, see details.
##' @param query The object created if using the FAOsearch function
##' @param printURL Whether the url link for the data should be printed
##' @param productionDB Use the production data base
##'
##' @return A list containing the following elements
##' \describe{
##'     \item{data}{The country level data}
##'     \item{aggregates}{The aggregates provided by the FAO}
##'     \item{results}{The status of the download, whether success/failed}
##' }
##' @export
##' @seealso \code{\link{getWDI}}, \code{\link{getFAO}},
##' \code{\link{getWDItoSYB}}
##'
##' @examples
##' ## The default option is the arable land area
##' arlLand.df = getFAOtoSYB()

getFAOtoSYB = function(name, domainCode = "RL",
                       elementCode = 5110, itemCode = 6621, query,
                       printURL = FALSE, productionDB = FALSE){

    if(!missing(query)){
        domainCode = query$domainCode
        itemCode = query$itemCode
        elementCode = query$elementCode
        name  = query$name
    }

  if(missing(name))
      name = paste(domainCode, elementCode, itemCode, sep = "_")
  n = length(name)
  if(any(length(domainCode) != n, length(elementCode) != n,
         length(itemCode) != n))
    stop("length of inputs are not all the same, check the number of names")

  ## Try to improve this.
  faoData = data.frame(FAOST_CODE = as.integer(1),
                       Year = as.integer(format(Sys.time(), "%Y")),
                       stringsAsFactors = FALSE)
  ## faoData = data.frame(FAOST_CODE = integer(0),
  ##                      Year = integer(0),
  ##                      stringsAsFactors = FALSE)
  results = data.frame(Name = name, Success = logical(length(name)),
                       Reason = character(length(name)),
                       Time = as.POSIXct(rep(NA, length(name))),
                       stringsAsFactors = FALSE)
  printLab(paste("FAOSTAT Data Download (", n, " in Total)", sep = ""))

  i = 1
  retry = 1
  while(i <= n){
    if(retry > 50){
      cat("Download fail after 50 tries\n")
      results[i, "Success"] = FALSE
      results[i, "Reason"] = attr(tmp, "condition")$message
      i = i + 1
      retry = 1
    }
    if(retry == 1)
      cat(paste("(", i, "): Downloading variable ", name[i], " ... ", sep = ""))
    if(any(is.na(domainCode[i]), is.na(elementCode[i]), is.na(itemCode)[i])){
      cat("FAIL\n\t Error: One of Domain, Element or Item code is missing\n")
      results[i, "Success"] = FALSE
      results[i, "Reason"] = "One of Domain, Element or Item code is missing"
    } else {
      tmp = try(getFAO(name = name[i],
                       domainCode = domainCode[i],
                       elementCode = elementCode[i],
                       itemCode = itemCode[i], printURL = printURL,
                       productionDB = productionDB))
      if(!inherits(tmp, "try-error")){
        ## colnames(tmp)[3] = name[i]
        ## This was to account sometimes the download is successful, yet
        ## the data frame is empty
        if(NROW(tmp) != 0){
          cat("OK\n")
          results[i, "Success"] = TRUE
          results[i, "Reason"] = "Download Successful"
          results[i, "Time"] = Sys.time()
          faoData = merge(x = faoData, y = tmp, all = TRUE,
              by = c("FAOST_CODE", "Year"))
          i = i + 1
        } else {
          tmp = c("The specified query has no data, consult FAOSTAT")
          class(tmp) = "try-error"
          attr(tmp, "condition") =
            list(message = "The specified query has no data, consult FAOSTAT",
                 call = NULL)
          retry = retry + 1
        }
      }
    }
  }
  entity.df = arrange(with(faoData, faoData[FAOST_CODE %in%
    FAOcountryProfile[, "FAOST_CODE"], ]), FAOST_CODE, Year)
  region.df = arrange(with(faoData, faoData[!(FAOST_CODE %in%
    FAOcountryProfile[, "FAOST_CODE"]), ]), FAOST_CODE, Year)
  cat(paste("\n Number of variables successfully downloaded: ",
            sum(results$Success), " out of ", NROW(results), "\n\n", sep = ""))
  list(entity = entity.df, aggregates = region.df, results = results)
}
