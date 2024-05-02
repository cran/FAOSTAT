#' Examine dimensions of a dataset
#'
#' Lists the dimensions of a dataset including ids and labels. These can be used
#' to query dataset dimension names and the codes therein. They can also be used
#' to access groups, flags, units and the glossary
#'
#' @param dataset_code character. Dataset as obtained from the code column of
#'   \link{search_dataset}
#' @param dimension_code character. Dimensions as obtained from \code{read_dataset_dimensions}
#' 
#' @export

read_dataset_dimension <- function(dataset_code){
  
  response <- get_fao(sprintf("/definitions/domain/%s", dataset_code))
  content <- content(response)
  
  data <- as.data.frame(rbindlist(lapply(content$data, as.data.table)))
    
  attr(data, "metadata") <- content$metadata
  
  return(data)
}

#' @rdname read_dataset_dimension
#' @export

read_dimension_metadata <- function(dataset_code, dimension_code){
  
  response <- get_fao(sprintf("/definitions/domain/%s/%s", dataset_code, dimension_code))
  content <- content(response)
  
  data <- as.data.frame(rbindlist(lapply(content$data, as.data.table)))
  
  attr(data, "metadata") <- content$metadata
  
  return(data)
}
