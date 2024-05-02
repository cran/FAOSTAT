#' Search FAOSTAT dataset_codes, datasets, elements, indicators, and items
#'
#' Get full list of datasets from the FAOSTAT database with the Code, dataset
#' name and updates.
#'
#' @param dataset_code character. Code of desired datasets, listed as `code` in
#'   output.
#' @param dataset_label character. Name of the datasets, listed as `label` in the output
#'   data frame. Can take regular expressions.
#' @param latest logical. Sort list by latest updates
#' @param reset_cache logical. By default, data is saved after a first run and
#'   reused. Setting this to true causes the function to pull data from FAO
#'   again
#' @examples
#' \dontrun{
#' # Find information about all datasets
#' fao_metadata <- search_dataset()
#' # Find information about forestry datasets
#' search_dataset(dataset_code="FO")
#' # Find information about datasets whose titles contain the word "Flows"
#' search_dataset(dataset_label="Flows")
#' }
#'
#' @return A data.frame with the columns: code, label, date_update, note_update,
#'   release_current, state_current, year_current, release_next, state_next,
#'   year_next
#' @export

 search_dataset <- function(dataset_code, dataset_label, latest = TRUE, reset_cache = FALSE){
    
    if (deparse(match.call()[[1]]) == "FAOsearch") {
        .Deprecated("search_fao", msg = "FAOsearch has deprecated been replaced by search_dataset as the old API doesn't work anymore. 
                search_dataset was called instead")
    }
    
     if(missing(dataset_code)) dataset_code <- NULL
     if(missing(dataset_label)) dataset <- NULL
     
     # You could in theory allow multiple, but I don't think that's expected usage
     if(length(dataset) > 1){
         warning("More than 1 values was supplied to dataset, only the first will be used")
         dataset <- dataset[1]
     }
     
    search_data <- cache_data("search_dataset", get_fao("/domains"), reset = reset_cache)
    
    data <- rbindlist(content(search_data)[["data"]], fill = TRUE)
    metadata <- content(search_data)[["metadata"]]
    
    # Ensure that column names come from the current environment and not from
    # within the table
    function_env <- environment()
    
    if(!is.null(dataset_code)){
        data <- data[code %chin% get("dataset_code", envir = function_env),]
    }
    if(!is.null(dataset)){
        data <- data[grepl(get("dataset", envir = function_env), label),]
    }
        
    if(latest){
        data <- data[order(date_update)]
    }
    
    data <- as.data.frame(data)
    
    attr(data, "query_metadata") <- metadata
    
    return(data)
 }
 
 #' @rdname search_dataset
 #' @export
 #' 

FAOsearch <- search_dataset
