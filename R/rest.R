#' Register for a FAOSTAT account and login to get an access token
#'
#' Authenticates with the FAOSTAT API and stores the access token for the
#' current session. Credentials are resolved in this order:
#' \enumerate{
#'   \item Arguments passed directly to the function.
#'   \item The \code{FAOSTAT_USER} and \code{FAOSTAT_PASSWORD} environment
#'     variables (set them in \file{~/.Renviron} to avoid storing credentials
#'     in scripts).
#'   \item An interactive prompt (email via \code{readline()}, password via
#'     \code{rstudioapi::askForPassword()} when available, otherwise
#'     \code{readline()}).
#' }
#' API calls (\code{get_faostat_bulk()} etc.) trigger \code{faostat_login()}
#' automatically when no token is present, so explicit calls are optional.
#'
#' @param username character. Your FAOSTAT account email. Defaults to the
#'   \code{FAOSTAT_USER} environment variable, then an interactive prompt.
#' @param password character. Your FAOSTAT account password. Defaults to the
#'   \code{FAOSTAT_PASSWORD} environment variable, then an interactive prompt.
#' @param base_url character. Base URL for FAOSTAT authentication.
#'
#' @examples
#' \dontrun{
#' # Simplest usage — prompts for credentials interactively if not set:
#' crop_production <- get_faostat_bulk(code = "QCL", data_folder = "data_raw")
#'
#' # Silent usage — set in ~/.Renviron (run usethis::edit_r_environ() to open it):
#' # FAOSTAT_USER=your@email.com
#' # FAOSTAT_PASSWORD=yourpassword
#' crop_production <- get_faostat_bulk(code = "QCL", data_folder = "data_raw")
#' }
#' @export
faostat_login <- function(username = Sys.getenv("FAOSTAT_USER"),
                          password = Sys.getenv("FAOSTAT_PASSWORD"),
                          base_url = "https://faostatservices.fao.org/api/v1"){
  if (nchar(username) == 0) {
    message("Please login to the FAOSTAT API")
    username <- readline("FAOSTAT email: ")
  }
  if (nchar(password) == 0) {
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
      password <- rstudioapi::askForPassword("FAOSTAT password")
    } else {
      password <- readline("FAOSTAT password: ")
    }
  }

  auth_url <- paste0(base_url, "/auth/login")

  # The API documentation says:
  # HTTP Method: POST
  # Content-Type: application/x-www-form-urlencoded
  # Request Parameters (Body): username, password

  resp <- httr::POST(auth_url,
                     body = list(username = username, password = password),
                     encode = "form")

  if (httr::http_error(resp)) {
    stop("Login failed. Check your username and password.")
  }

  auth_data <- httr::content(resp)

  # The response structure is nested: {"AuthenticationResult": {"AccessToken": "...", ...}}
  auth_result <- auth_data$AuthenticationResult

  if (!is.null(auth_result) && !is.null(auth_result$AccessToken)) {
    .FAOSTATenv$access_token <- auth_result$AccessToken
    if (!is.null(auth_result$RefreshToken)) {
      .FAOSTATenv$refresh_token <- auth_result$RefreshToken
    }
    message("Successfully logged in to FAOSTAT.")
  } else {
    stop("Could not retrieve access token from response. Structure might have changed.")
  }

  invisible(auth_data)
}

#' REST functions to connect to FAO
#' 
#' @param endpoint character. Endpoint for FAO API
#' @param params list of query parameters
#' @param language character. One of the UN languages supported by FAOSTAT
#' @param base_url character. Base URL for FAOSTAT API
#' 
#' @keywords internal
#' 

get_fao <- function(endpoint, params = list(), language = c("en", "fr", "es", "NA"), base_url = "https://faostatservices.fao.org/api/v1"){

  language = match.arg(language, several.ok = FALSE)

  if (!exists("access_token", envir = .FAOSTATenv)) {
    faostat_login()
  }
  config <- add_headers(Authorization = paste("Bearer", .FAOSTATenv$access_token))
  
  resp <- GET(paste(base_url, language, endpoint, sep = "/"), query = params, config)
  
  if (http_error(resp)) {
    if (status_code(resp) == 404) {
      stop("Error 404 - resource not found. Is something wrong with the URL?")
    }
    stop("Request failed")
  }
  
  return(resp)
  
}