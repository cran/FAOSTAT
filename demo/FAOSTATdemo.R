###########################################################################
## Title: Demo of the FAOSTAT package
## Updated: 2020-11-11
###########################################################################

# Install the package -----------------------------------------------------

if(!is.element("FAOSTAT", .packages(all.available = TRUE)))
  install_github(username = "mkao006", repo = "FAOSTATpackage", ref = "master", subdir = "FAOSTAT")
library(FAOSTAT)
help(package = "FAOSTAT")
vignette("FAOSTAT", package = "FAOSTAT")


# Create a folder to store the data
data_folder <- "data_raw"
dir.create(data_folder)

# Load information about all datasets into a data frame
fao_metadata <- FAOsearch()    

# Find information about datasets whose titles contain the word "crop" (illustrates the case insensitive search)
FAOsearch(dataset="crop", full = FALSE)

# Load crop production data
production_crops <- get_faostat_bulk(code = "QC", data_folder = data_folder)
# Show the structure of the data
str(crop_production)

# Cache the file i.e. save the data frame in the serialized RDS format for fast reuse later.
saveRDS(production_crops, "data_raw/production_crops_e_all_data.rds")
# Now you can load your local version of the data from the RDS file
production_crops <- readRDS("data_raw/production_crops_e_all_data.rds")


# Show the structure of the data frame
str(production_crops)

# Show the first and last year reported
min(production_crops$year)
max(production_crops$year)

# Later on you can read those RDS files as follows:
production_crops <- readRDS("data_raw/production_crops_e_all_data.rds")

