##' Access to FAO FAOSTAT API
##'
##' A function to access FAOSTAT data through the FAOSTAT API
##'
##' Need to account for multiple itemCode, currently only support one
##' single variable.
##'
##' Add date range in to argument
##' @param name The name to be given to the variable.
##' @param domainCode The domain of the data
##' @param elementCode The code of the element
##' @param itemCode The code of the specific item
##' @param query The object created if using the FAOsearch function
##' @param printURL Whether the url link for the data should be printed
##' @param productionDB Access to the production database, defaulted to public
##' @return Outputs a data frame containing the specified data
##' @export
##'
##' @seealso \code{\link{getWDI}}, \code{\link{getWDItoSYB}},
##' \code{\link{getFAOtoSYB}}, \code{\link{FAOsearch}}
##'
##' @examples
##' getFAO()

## NOTE(Michael): Maybe change input from csv to json.

getFAO = function(name = "arableLand", domainCode = "RL", elementCode = 5110,
                  itemCode = 6621, query, printURL = FALSE, productionDB = FALSE){
    if(!missing(query)){
        if(NROW(query) > 1)
            stop("Use 'getFAOtoSYB' for batch download")
        domainCode = query$domainCode
        itemCode = query$itemCode
        elementCode = query$elementCode
        name  = query$name
    }

    if(productionDB){
        base = "http://ldvapp07.fao.org:8030/wds/api?"
        database = "db=faostatprod&"
        selection = "select=D.AreaCode[FAOST_CODE],D.Year[Year],D.Value[Value],&from=data[D],element[E]&"
        condition = paste("where=D.elementcode(", elementCode, "),D.itemcode(",
        itemCode, "),D.domaincode('", domainCode, "')", sep = "")
        join = ",JOIN(D.elementcode:E.elementcode)&orderby=E.elementnamee,D.year"
    } else {
        base = "http://fenixapps.fao.org/wds/api?"
        database = "db=faostat&"
        selection = "select=A.AreaCode[FAOST_CODE],D.year[Year],D.value[Value],&from=data[D],element[E],item[I],area[A]&"
        condition = paste("where=D.elementcode(", elementCode, "),D.itemcode(",
        itemCode, "),D.domaincode('", domainCode, "')", sep = "")
        join = ",JOIN(D.elementcode:E.elementcode),JOIN(D.itemcode:I.itemcode),JOIN(D.areacode:A.areacode)&orderby=E.elementnamee,D.year"
    }

    out = "out=csv&"
    url = paste(base, out, database, selection, condition, join, sep = "")
    if(printURL) print(url)

    dat = read.csv(file = url, stringsAsFactors = FALSE)
    ## while(inherits(dat, "try-error")){
    ##   dat = try(read.csv(url, stringsAsFactors = FALSE))
    ## }
    dat$FAOST_CODE = as.integer(dat$FAOST_CODE)
    dat$Year = as.integer(dat$Year)
    colnames(dat)[colnames(dat) == "Value"] = name
    arrange(df = dat, FAOST_CODE, Year)
}
