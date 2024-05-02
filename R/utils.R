#' Change case of column names
#'
#' Columns from FAOSTAT frequently have parentheses and other non-alphanumeric
#' characters. This suite of functions seeks to give control over these names
#' for easier data analysis
#'
#' @md
#'
#' @param old_names character. Vector of the names to be changed
#' @param new_case character. Choice of new names:
#' * make_names - (default) use the [make.names] function in R to sanitise names
#' * unsanitised/unsanitized - Return names as they are
#' * snake_case - Names are converted to lowercase and separators are replaced with underscores
#' @param ... extra arguments to pass to sanitisation function (only works for [make.names])
#'
#' @export

change_case <- function(old_names, new_case = c("make.names", "unsanitised", "unsanitized", "snake_case"), ...){
  
  new_case <- match.arg(new_case)
  if (new_case == "unsanitized") new_case <- "unsanitised"
  
  switch(new_case,
         unsanitised = old_names,
         make.names = make.names(old_names, ...),
         snake_case = to_snake(old_names, ...)
         )
}

to_snake <- function(old_names){
  
  gsub("[^[:alnum:]]", "_", tolower(old_names))

}
