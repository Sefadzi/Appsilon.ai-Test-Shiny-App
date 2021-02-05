
#' update select input dynamically
#'
#'
#'
#' @param id shiny id
#'
#' @return dynamicSelectInput
#' @export
dynamicSelectInput <- function(id, label, multiple = FALSE){

  ns <- shiny::NS(id)

  shiny::selectInput(ns("dynamic_select"), label,
                     choices = NULL, multiple = multiple, width = "100%")

}

#' Dynamical Update of a selectInput
#'
#' Shiny Module
#'
#' Use via \code{callModule(dynamicSelect, "name_select", the_data, "cyl")}
#'
#' @param input shiny input
#' @param output shiny output
#' @param session shiny session
#' @param the_data data.frame containing column of interest
#' @param column data column of interest
#' @param default_select The choices to select on load
#'
#' @seealso \link{dynamicSelectInput}
#'
#' @return the_data filtered to the choice
#' @export
dynamicSelect <- function(input, output, session, the_data, column, default_select = NULL){

  ns <- session$ns

  ## update input$dynamic_select
  observe({
    shiny::validate(
      shiny::need(the_data(),"Fetching data")
    )
    dt <- the_data()

    testthat::expect_is(dt, "data.frame")
    testthat::expect_is(column, "character")

    choice <- unique(dt[[column]])

    shiny::updateSelectInput(session, "dynamic_select",
                             choices = choice,
                             selected = default_select)

  })

  new_data <- reactive({
    shiny::validate(
      shiny::need(input$dynamic_select,"Select data"),
      shiny::need(the_data(), "Waiting for data")
    )

    sd <- the_data()
    selected <- input$dynamic_select

    ## will return sd even if column is NULL
    safeSubset(sd, column, selected)

  })

  return(new_data)

}
