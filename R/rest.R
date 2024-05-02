#' REST functions to connect to FAO
#' 
#' @param endpoint character. Endpoint for FAO API
#' @param params list of query parameters
#' @param language character. One of the UN languages supported by FAOSTAT
#' @param base_url character. Base URL for FAOSTAT API
#' 
#' @keywords internal
#' 

get_fao <- function(endpoint, params = list(), language = c("en", "fr", "es"), base_url = "https://fenixservices.fao.org/faostat/api/v1"){
  
  language = match.arg(language, several.ok = FALSE)
  
  resp <- GET(paste(base_url, language, endpoint, sep = "/"), query = params)
  
  if (http_error(resp)) {
    if (status_code(resp) == 404) {
      stop("Error 404 - resource not found. Is something wrong with the URL?")
    }
    stop("Request failed")
  }
  
  return(resp)
  
}