#' Cache files read in by the API
#'
#' @rdname cache
#' @param name character. Key to which data is bound
#' @param environment environment. .FAOSTATenv by default
#' @param data object. Data to be cached
#' @param reset logical. Should the cache be replaced with new data?
#' @keywords internal
cache_data <- function(name, data, reset = FALSE, environment = .FAOSTATenv) {
    if (check_cache(name, environment = environment) && !reset) {
      cached <- cache_retrieve(name, environment = environment)
      return(cached)
    }
    
    assign(name, data, envir = environment)
    
    return(data)
  }

check_cache <- function(name, environment = .FAOSTATenv) {
  !is.null(environment[[name]])
}

cache_retrieve <- function(name, environment = .FAOSTATenv) {
  get(name, envir = environment)
}

cache_delete <- function(name, environment = .FAOSTATenv){
  rm(list = name, envir = environment)
}

