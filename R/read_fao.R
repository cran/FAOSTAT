#' Access FAOSTAT API
#'
#' Uses the same functionality as the web interface to pull data from the
#' FAOSTAT API. Contains most of its parameters. Currently only works for
#' datasets that have area, item, element and year. Values for Chinese countries
#' are not yet deduplicated.
#'
#' @param area_codes character. FAOSTAT area codes
#' @param element_codes character. FAOSTAT element codes
#' @param item_codes character. FAOSTAT item codes
#' @param year_codes character. Vector of desired years
#' @param area_format character. Desired area code type in output (input still
#'   needs to use FAOSTAT codes)
#' @param item_format character. Item code
#' @param dataset character. FAO dataset desired, e.g. RL, FBS
#' @param metadata_cols character. Metadata columns to include in output
#' @param clean_format character/function. Whether to clean columns. Either one
#'   of the formats described in [change_case] or a formatting function
#' @param include_na logical. Whether to include NAs for combinations of
#'   dimensions with no data
#' @param language character. 2 letter language code for output labels
#'
#' @return data.frame in long format (wide not yet supported). Contains
#'   attributes for the URL and parameters used.
#'
#' @examples
#' 
#' \dontrun{
#'
#' # Get data for Cropland (6620) Area (5110) in Antigua and Barbuda (8) in 2017
#' df = read_fao(area_codes = "8", element_codes = "5110", item_codes = "6620", 
#' year_codes = "2017")
#' # Load cropland area for a range of year
#' df = read_fao(area_codes = "106", element_codes = "5110", item_codes = "6620", 
#' year_codes = 2010:2020)
#'
#' # Find which country codes are available
#' metadata_area <- read_dimension_metadata("RL", "area")
#' # Find which items are available
#' metadata_item <- read_dimension_metadata("RL", "item")
#' # Find which elements are available
#' metadata_element <- read_dimension_metadata("RL", "element")
#' 
#'}
#'
#' @export

read_fao <- function(area_codes, element_codes, item_codes, year_codes, 
                   area_format = c("M49", "FAO", "ISO2", "ISO3"),
                   item_format = c("CPC", "FAO"),
                   dataset = "RL", 
                   metadata_cols = c("codes", "units", "flags", "notes"),
                   clean_format = c("make.names", "unsanitised", "unsanitized", "snake_case"),
                   include_na = FALSE,
                   language = c("en", "fr", "es")){
  
  if (deparse(match.call()[[1]]) == "getFAO") {
    .Deprecated("read_fao", msg = "getFAO has deprecated been replaced by read_fao as the old API doesn't work anymore. 
                read_fao was called instead")
  }
  
  coll <- function(string){
    paste0(string, collapse = ",")
  }
  
  #Prepare clean formatter for cleaning output column names
  if (!is.function(clean_format)){
    clean_formatter = function(o) {change_case(o, new_case = match.arg(NULL, clean_format))}
  } else {
      clean_formatter = clean_format
    }
  
  language = match.arg(language, several.ok = FALSE)
  area_format = match.arg(area_format, several.ok = FALSE)
  item_format = match.arg(item_format, several.ok = FALSE)
  
  area_coll     = coll(area_codes)
  item_coll     = coll(item_codes)
  element_coll  = coll(element_codes)
  year_coll     = coll(year_codes)
  
  params <- list(
    area = area_coll, #These are FAO codes even if displayed in M49
    area_cs = area_format,
    element = element_coll,
    item = item_coll, #I think these are FAO codes too, but they _happen_ to match for CPC
    item_cs = item_format,
    year = year_coll,
    show_codes = "codes" %in% metadata_cols,
    show_unit = "units" %in% metadata_cols,
    show_flags = "flags" %in% metadata_cols,
    show_notes = "notes" %in% metadata_cols,
    null_values = include_na,
    # pivot = FALSE,
    # no_records = return_n_records_only,  # Used to only return the number of records
    # page_number = 1,   # For pagination
    # page_size = 100,   # Number of records for pagination
    datasource = "DB4",
    output_type = "csv" #objects returns a json object
    #latest_year = 1 # Will give the latest year available
  )
  
  #Call to check for no records then get data
  
  final_endpoint <- paste0("/data/", dataset)
  
  resp <- get_fao(final_endpoint, language = language, params = params)
  
  resp_content <- content(resp, type = "text", encoding = "UTF-8")
  
  ret <- fread(text = resp_content)
  
  setnames(ret, new = clean_formatter)
  ret <- as.data.frame(ret)
  
  #TODO Add China replacement function 
  attr(ret, "url") <- resp$url
  attr(ret, "params") <- params
  
  return(ret[])
}

#' @rdname read_fao
#' @export
#' 

getFAO <- read_fao
