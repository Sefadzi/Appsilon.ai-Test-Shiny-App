

semanticPage(
  grid(
    grid_template = grid_template(
      default = list(
        areas = rbind(
          c("title","dropdown1","dropdown2"),
          c("info","map","map"),
          #c("info","map","map"),
          c("info","viz1","viz2")
        ),
        cols_width = c("450px","1fr","1fr"),
        rows_height = c("40px","1fr","1fr")
      )
    ),
    container_style = "
    grid-gap: 10px;
    max-height: 1600px;",
    area_styles = list(title = "margin: 10px;",
                       info = "margin: 10px;",
                       dropdown1 = "margin: 10px;",
                       dropdown2 = "margin: 10px;",
                       map = "margin: 10px;",
                       viz1 = "margin: 10px;",
                       viz2 = "margin: 10px;"
    ),
    title = h2(class = "ui header", icon("ship"),
               style = "background: #ffb533; padding: 5px;border-radius: 5px;",
               "AIS Data Analytics"),
    info = div(class = "content",
               style = "border: 2px solid #eeeeee; border-radius: 5px;background: #ffffff;box-shadow: 10px 10px 4px #888888;max-height: 100%;padding:10px;",
               h3("NUMBER OF VESSELS PER SELECTED CATEGORY"),
               selectInput("var", "Select a variable",
                           c("SHIP TYPE"="ship_type", "PORT"="port"),
                           selected = "ship_type"),
               d3Output("d3"),
               DT::dataTableOutput("table"),
               textInput("val", "Value"),
               br()
    ),
    dropdown1 = div(style = "display: block;padding-top:10px;position:relative;z-index:100000;",
                    dynamicSelectInput("vesselTypeSelect", "Select a Vessel Type", multiple = FALSE)),
    dropdown2 = div(style = "display: block;padding-top:10px;position:relative;z-index:100000;",
                    dynamicSelectInput("vesselSelect", "Choose a Vessel", multiple = FALSE)),
    map = div(class = "content",
              style = "border: 2px solid #eeeeee; border-radius: 5px;box-shadow: 10px 10px 8px #888888;padding:5px;background: #ffffff;margin-top:30px;",
              leafletOutput("map")
    ),

    viz1 = div(
               style = "border: 2px solid #eeeeee;background: #ffffff;box-shadow: 10px 10px 8px #888888;padding: 10px; max-height: 400px;",
               selectInput("selectedVessel",label = "Select a Vessel",choices = speedChoices, selected = speedChoices[1]),
               highchartOutput("speedometer")),
    # highchartOutput("polar")),
    viz2 = div(class = "content",
               style="background: #ffffff;border-radius: 5px;box-shadow: 10px 10px 8px #888888;display:block;border: 2px solid #eeeeee;padding-right:10px;",
               highchartOutput("columnplot")
    )
  )

)
