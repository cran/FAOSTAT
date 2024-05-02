##' A function to translate between different country coding systems
##'
##' The function translate any country code scheme to another if both are in the
##' are among the types present in the FAO API. If you require other codes or
##' conversion of country names to codes, consider the `countrycodes` package.
##'
##' @md
##'
##' @param data The data frame
##' @param from The name of the old coding system
##' @param to The name of the new coding system
##' @param oldCode The column name of the old country coding scheme
##' @param reset_cache logical. Whether to pull data from FAOSTAT directly
##'   instead of caching
##' @export
##' 

translate_countrycodes = function (data, from = c("FAO", "M49", "ISO2", "ISO3"), to=c("M49", "FAO", "ISO2", "ISO3", "name"), oldCode, reset_cache = FALSE){
    
    if (deparse(match.call()[[1]]) == "translateCountryCode") {
        .Deprecated("search_fao", msg = "translateCountryCode has deprecated been replaced by translate_countrycode as the old API doesn't work anymore. 
                translate_countrycodes was called instead")
    }
    
    
    from <- match.arg(from)
    to <- match.arg(to)
    
    switch_list = list("FAO"  = "Country Code", 
                       "M49"  = "M49 Code",
                       "ISO2" = "ISO2 Code",
                       "ISO3" = "ISO3 Code",
                       "name" = "Country")
    
    from_name = do.call(switch, c(list(from), switch_list))
    to_name = do.call(switch, c(list(to), switch_list))
    
    int2txt <- function(int, wid = 3){
        
        ifelse(is.na(int), NA_character_, 
        sprintf(paste0("%0", wid, "d", collapse = ""), as.integer(int)))
    }
    
    
    fao_countries <- copy(cache_data("country_codes", 
                                fread(text = content(get_fao("/definitions/types/areagroup", params = list(output_type = "csv")),
                                        type = "text", encoding = "UTF-8"),
                                      colClasses = "character"),
                                reset = reset_cache
                                ))
    
    # Remove country groups
    fao_countries[,`:=`("Country Group Code" = NULL, "Country Group" = NULL)]
    fao_countries = unique(fao_countries)
    
    conversion_table = fao_countries[,c(from_name, to_name), with = FALSE]
    setnames(conversion_table, c("from", "to"))
    
    if(from == "FAO"){
        conversion_table[, from := int2txt(from)]
    } else {
        conversion_table[, from := as.character(from)]
    }
    
    setkeyv(conversion_table, "from")
    
    to_convert <- data.table(from = int2txt(data[[oldCode]]))
    setkeyv(to_convert, "from")
    
    # Convert codes to text
    converted_codes = conversion_table[to_convert, on = "from"][["to"]]
    
    new_data = data
    new_data[[oldCode]] = converted_codes
    
    return(new_data)
}

#' @rdname translate_countrycodes
#' @export
#' 

translateCountryCode <- translate_countrycodes


