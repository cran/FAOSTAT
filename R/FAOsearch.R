#' Search FAOSTAT tables 
#' 
#' Get full list of datasets from the FAOSTAT database with the Code, Dataset Name and Topic.
#' 
#' @param code character code of the dataset, listed as DatasetCode
#' @param dataset character name of the dataset (or part of the name), listed as DatasetName in the output data frame
#' @param topic character topic from list
#' @param latest boolean sort list by latest updates
#' @param full boolean, TRUE returns the full table with all columns
#' @examples 
#' \dontrun{
#' # Find information about all datasets
#' fao_metadata <- FAOsearch()    
#' # Find information about the forestry dataset
#' FAOsearch(code="FO")
#' # Find information about datasets whose titles contain the word "Flows"
#' FAOsearch(dataset="Flows", full = FALSE)
#' }
#' @export
FAOsearch = function(code = NULL, dataset = NULL, topic = NULL, latest = FALSE, full = TRUE){
    # Download the latest metadata from Fenix Services (host of FAOSTAT data) 
    xml_url <- "https://fenixservices.fao.org/faostat/static/bulkdownloads/datasets_E.xml"
    # Temporary copy of the xml metadata file, valid for this R session
    xml_temp_file <- file.path(tempdir(), "datasets_E.xml")
    if (!file.exists(xml_temp_file)){
        print("Downloading information on datasets and links to individual bulk download files.")
        download.file(xml_url, xml_temp_file)
    }
    FAOxml <- XML::xmlParse(xml_temp_file)
    metadata <- XML::xmlToDataFrame(FAOxml, stringsAsFactors = FALSE)

    # Rename columns to lowercase
    names(metadata) <- tolower(gsub("\\.","_",names(metadata)))
    
    if(!is.null(code)){
        metadata <- metadata[code == metadata[,"datasetcode"],]}
    if(!is.null(dataset)){
        metadata <- metadata[grep(dataset, metadata[,"datasetname"], ignore.case = TRUE),]}
    if(!is.null(topic)){
        metadata <- metadata[grep(topic, metadata[,"topic"], ignore.case = TRUE),]}
    if(latest == TRUE){
        metadata <- metadata[order(metadata$DateUpdate, decreasing = TRUE),]}
    if(nrow(metadata) == 0L){
        stop("The metadata is empty for your query. Try loading FAOsearch() to see the full metadata.")
    }
    if(full == FALSE){
        return(metadata[,c("datasetcode", "datasetname", "dateupdate")])}
    if(full == TRUE){
        return(metadata)}
    else(return("Invalid query"))
}

