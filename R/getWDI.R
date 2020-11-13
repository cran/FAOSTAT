#' Access to World Bank WDI API
#' 
#' @description A function to extract data from the World Bank API
#'
#' Please refer to \url{https://data.worldbank.org/} for any
#' difference between the country code system. Further details on World
#' Bank classification and methodology are available on that website. 
#' 
#' @param indicator The World Bank official indicator name.
#' @param name The new name to be used in the column.
#' @param startDate The start date for the data to begin
#' @param endDate The end date.
#' @param printURL Whether the url link for the data should be printed
#' @param outputFormat The format of the data, can be 'long' or 'wide'.
#' @return A data frame containing the desired World Bank Indicator
#' 
#' @details 
#' Sometime after 2016, there was a change in the api according to 
#' \url{https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api-documentation}
#' "Version 2 (V2) of the Indicators API has been released and replaces V1 of the API. 
#' V1 API calls will no longer be supported. To use the V2 API, you must place v2 in the call. 
#' For example: \url{http://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL}.
#' 
#' Original (2011) source by Markus Gesmann:
#' \url{http://lamages.blogspot.it/2011/09/setting-initial-view-of-motion-chart-in.html}
#' Also available at 
#' \url{https://www.magesblog.com/post/2011-09-25-accessing-and-plotting-world-bank-data/}
#'
#' @seealso \code{\link{getFAO}}, \code{\link{getWDItoSYB}},
#' \code{\link{getFAOtoSYB}} 
#' and the wbstats package \url{https://cran.r-project.org/package=wbstats} for an implementation with many more features.
#' @examples
#' ## pop.df = getWDI()
#' @export
getWDI = function(indicator = "SP.POP.TOTL", name = NULL,
                  startDate = 1960, endDate = format(Sys.Date(), "%Y"),
                  printURL = FALSE, outputFormat = "wide"){
    if(is.null(name))
        name = indicator
    url = paste("http://api.worldbank.org/v2/countries/all/indicators/", indicator,
                "?date=", startDate, ":", endDate,
                "&format=json&per_page=30000", sep = "")
    if(printURL)
        print(url)
    wbData = fromJSON(url)[[2]]
    wbData = data.frame(Country = sapply(wbData,
                                         function(x) x[["country"]]["value"]),
                        ISO2_WB_CODE= sapply(wbData,
                                             function(x) x[["country"]]["id"]),
                        Year = as.integer(sapply(wbData, "[[", "date")),
                        Value = as.numeric(sapply(wbData, function(x)
                            ifelse(is.null(x[["value"]]), NA, x[["value"]]))),
                        stringsAsFactors = FALSE)
    if(outputFormat == "long"){
        wbData$name = name
    } else if(outputFormat == "wide"){
        names(wbData)[4] = name
    }
    return(wbData)
}

# TODO (Michael): Investigate why sometimes ISO2 is used and
#                 sometiems ISO3 is used.
