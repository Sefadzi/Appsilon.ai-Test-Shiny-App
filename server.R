
function(session, input, output) {

  the_data <- reactive({
    s_df
  })

  vesselType_filter <- shiny::callModule(dynamicSelect, "vesselTypeSelect", the_data, "ship_type", default_select = "Cargo")
  ## cyl_filter is then filtered by disp
  vessel_filter <- shiny::callModule(dynamicSelect, "vesselSelect", vesselType_filter, "SHIPNAME", default_select = NULL)



  output$map <- renderLeaflet({
    df_ <- vessel_filter()

    leaflet() %>%
      setView(lng = 54.3520, lat = 18.6466, zoom = 12)%>%addTiles()
  })




  observe({

    df_ = vessel_filter()

    if(nrow(df_) >= 1) {
      df <- df_ %>%
        group_by(SHIPNAME) %>%
        mutate(l_LAT = lag(LAT), l_LONG = lag(LON)) %>%
        mutate(distance = diag(distm(cbind(l_LONG, l_LAT), cbind(LON, LAT),
                                     fun = distHaversine)),
               timespan = difftime(DATETIME, lag(DATETIME), units = "secs")) %>%
        slice_max(distance) %>%
        slice_max(DATETIME) %>%
        ungroup()

      leafletProxy("map") %>%
        clearMarkers()%>%
        clearPopups()%>%
        setView(lng = as.numeric(df$l_LONG), lat = as.numeric(df$l_LAT), zoom = 10)%>%
        addCircleMarkers(lng = as.numeric(df$LON),
                         lat = as.numeric(df$LAT))%>%
        addCircleMarkers(lng = as.numeric(df$l_LONG),
                         lat = as.numeric(df$l_LAT))%>%
        addPopups(lng = as.numeric(df$l_LONG),
                  lat = as.numeric(df$l_LAT),
                  popup = paste0(
                    "OBSERVED POINT WITH MAX DISTANCE",br(),
                    "Vessel: ", df$SHIPNAME, " ",br(),
                    "Distance (m): ", round(df$distance,2), " ",br(),
                    "Vessel Speed: ", df$SPEED
                  ))


    }


  })





  output$d3 <- renderD3({
    the_data() %>%
      mutate(label = !!sym(input$var)) %>%
      group_by(label) %>%
      #tally() %>%
      summarise(n = length(unique(SHIPNAME)))%>%
      arrange(desc(n)) %>%
      mutate(
        y = n,
        ylabel = prettyNum(n, big.mark = ","),
        fill = ifelse(label != input$val, "#E69F00", "red"),
        mouseover = "#0072B2"
      ) %>%
      r2d3(r2d3_file)
  })

  observeEvent(input$bar_clicked, {
    updateTextInput(session, "val", value = input$bar_clicked)
  })

  output$table <- renderDataTable({
    the_data() %>%
      filter(!!sym(input$var) == input$val) %>%
      datatable(fillContainer = TRUE)
  })

  output$columnplot <- renderHighchart({
    df <- the_data()

    avpd <- df %>%
      group_by(date, port)%>%
      summarize(n = length(unique(SHIPNAME)))%>%
      hchart(., type = "column",
             hcaes(x = date,
                   y = n,
                   group = port)) %>%
      hc_yAxis(opposite = FALSE,
               labels = list(format = "{value}")) %>%
      hc_title(text = "DAILY PORT VISITS") %>%
      hc_tooltip(pointFormat = '{point.x: %Y-%m-%d}


                            {point.y:.2f} ')
  })


  avg_sd <- reactive({
    spd[spd$SHIPNAME == input$selectedVessel,]
  })

  output$speedometer <- renderHighchart({

    df <- avg_sd()

    highchart() %>%
      hc_chart(type = "solidgauge") %>%
      hc_pane(
        startAngle = -90,
        endAngle = 90,
        background = list(
          outerRadius = '100%',
          innerRadius = '60%',
          shape = "arc"
        )
      ) %>%
      hc_tooltip(enabled = FALSE) %>%
      hc_yAxis(
        stops = list_parse2(col_stops),
        lineWidth = 0,
        minorTickWidth = 0,
        tickAmount = 2,
        min = min(spd$avg),
        max = max(spd$avg),
        labels = list(y = 26, style = list(fontSize = "20px"))
      ) %>%
      hc_title(text = "AVERAGE VESSEL SPEED (KNOTS)")%>%
      hc_add_series(
        data = as.numeric(df[,2]),
        dataLabels = list(
          y = -50,
          borderWidth = 0,
          useHTML = TRUE,
          style = list(fontSize = "20px")
        )
      ) %>%
      hc_size(height = 350)

  })

}


