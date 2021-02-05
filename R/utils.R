
#load module
#' Safe subset
#'
#' @param df the dataframe
#' @param column a name of column to subset
#' @param subset entries in column to subset to
#'
#' If column not in dataframe, returns back the dataframe
safeSubset <- function(df, column, subset){

  testthat::expect_type(df, "list")
  testthat::expect_type(column, "character")
  testthat::expect_equal(length(column), 1)

  if(!is.null(subset)){
    testthat::expect_type(subset, "character")
  } else {
    message("Subset is NULL, returning original")
    out <- df
  }

  message(" # subsetting # original rows: ",nrow(df) ," column:", column, " by ", paste(subset, collapse = ", "))

  col <- df[[column]]

  if(!is.null(col)){
    out <- df[col %in% subset,]
    message("Subset rows: ", nrow(out))
  } else {
    message("Column not found:", column)
    out <- df
  }

  out

}
