#' @title Download bulk data from the faostat website
#' http://www.fao.org/faostat/en/#data
#'
#' @description 
#' \itemize{
#'  \item{}{\code{get_faostat_bulk()} loads the given data set code and returns a data frame.}
#'  \item{}{\code{download_faostat_bulk()} loads data from the given url and saves it to a compressed zip file.}
#'  \item{}{\code{read_faostat_bulk()} Reads the compressed .csv .zip file into a data frame.
#'  More precisely it unzips the archive. 
#'  Reads the main csv file within the archive.
#'  The main file has the same name as the name of the archive. 
#'  Note: the zip archive might also contain metadata files about Flags and Symboles.}
#' }
#' In general you should load the data with the function \code{get_faostat_bulk()} and a dataset code.
#' The other functions are lower level functions that you can use as an alternative. 
#' You can also explore the datasets and find their download URLs
#' on the FAOSTAT website. Explore the website to find out the data you are interested in
#' \url{http://www.fao.org/faostat/en/#data}
#' Copy a "bulk download" url, 
#' for example they are located in the right menu on the "crops" page
#' \url{http://www.fao.org/faostat/en/#data/QC}
#' Note that faostat bulk files with names ending with "normalized" are in long format 
#' with a year column instead of one column for each year.
#' The long format is preferable for data analysis and this is the format 
#' returned by the  \code{get_faostat_bulk()} function. 
#' @author Paul Rougieux
#' @param url_bulk character url of the faostat bulk zip file to download
#' @param data_folder character path of the local folder where to download the data
#' @examples 
#' \dontrun{
#'
#' # Create a folder to store the data
#' data_folder <- "data_raw"
#' dir.create(data_folder)
#' 
#' # Load crop production data
#' production_crops <- get_faostat_bulk(code = "QC", data_folder = data_folder)
#' 
#' # Cache the file i.e. save the data frame in the serialized RDS format for faster load time later.
#' saveRDS(production_crops, "data_raw/production_crops_e_all_data.rds")
#' # Now you can load your local version of the data from the RDS file
#' production_crops <- readRDS("data_raw/production_crops_e_all_data.rds")
#'
#'
#' # Use the lower level functions to download zip files, 
#' # then read the zip files in separate function calls.
#' # In this example, to avoid a warning about "examples lines wider than 100 characters"
#' # the url is split in two parts: a common part 'url_bulk_site' and a .zip file name part.
#' # In practice you can enter the full url directly as the `url_bulk`  argument.
#' # Notice also that I have choosen to load global data in long format (normalized).
#' url_bulk_site <- "http://fenixservices.fao.org/faostat/static/bulkdownloads"
#' url_crops <- file.path(url_bulk_site, "production_crops_E_All_Data_(Normalized).zip")
#' url_forestry <- file.path(url_bulk_site, "Forestry_E_All_Data_(Normalized).zip")
#' # Download the files
#' download_faostat_bulk(url_bulk = url_forestry, data_folder = data_folder)
#' download_faostat_bulk(url_bulk = url_crops, data_folder = data_folder)
#' 
#' # Read the files and assign them to data frames 
#' production_crops <- read_faostat_bulk("data_raw/production_crops_E_All_Data_(Normalized).zip")
#' forestry <- read_faostat_bulk("data_raw/Forestry_E_All_Data_(Normalized).zip")
#'  
#' # Save the data frame in the serialized RDS format for fast reuse later.
#' saveRDS(production_crops, "data_raw/production_crops_e_all_data.rds")
#' saveRDS(forestry,"data_raw/forestry_e_all_data.rds")
#' }
#' @export
download_faostat_bulk <- function(url_bulk, data_folder){
    file_name <- basename(url_bulk)
    download.file(url_bulk, file.path(data_folder, file_name))
}

#' @rdname download_faostat_bulk
#' @param zip_file_name character name of the zip file to read
#' @return data frame of FAOSTAT data 
#' @export
read_faostat_bulk <- function(zip_file_name){
    # The main csv file shares the name of the archive
    csv_file_name <- gsub(".zip$",".csv", basename(zip_file_name))
    # Read the csv file within the zip file
    df <- read.csv(unz(zip_file_name, csv_file_name), stringsAsFactors = FALSE)
    # Rename columns to lowercase
    names(df) <- tolower(gsub("\\.","_",names(df)))
    return(df)
}

#' @rdname download_faostat_bulk
#' @param code character dataset code
#' @return data frame of FAOSTAT data 
#' @export
get_faostat_bulk <- function(code, data_folder){
    # Load information about the given dataset code 
    metadata <- FAOsearch(code = code)
    # Use the result of the search to download the data and assign it to a data frame 
    download_faostat_bulk(url_bulk = metadata$filelocation, data_folder = data_folder)
    output <- read_faostat_bulk(file.path(data_folder, basename(metadata$filelocation)))
    return(output)
}

