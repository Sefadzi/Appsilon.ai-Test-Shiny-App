test_that("Data subsetting works well", {

  load("appData.RData")
  safeSubset <- function(df, column, subset){
    load("appData.RData")
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


  expect_type(safeSubset(s_df,"SHIPNAME","KAROLI"), "list")
  expect_equal(nrow(safeSubset(s_df,"SHIPNAME","KAROLI")), 1293)
})
