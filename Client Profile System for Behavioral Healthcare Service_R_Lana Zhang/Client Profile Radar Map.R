library(dplyr)
library(shiny)
library(fmsb)  # radar chart

# Data Preparation
score_vars <- names(normalized_weight)
prepare_radar_data <- function(client_row) {
  var_max <- apply(data_client[, score_vars], 2, max)
  var_min <- apply(data_client[, score_vars], 2, min)
  
  max_min <- rbind(var_max, var_min)
  client_scores <- client_row[score_vars]
  radar_data <- rbind(max_min, client_scores)
  rownames(radar_data) <- c("max", "min", as.character(client_row$Client_Name))
  
  return(radar_data)
}
recommend_strategy <- function(priority_level) {
  switch(priority_level,
         "High" = "✅ High Priority: Assign immediate staff outreach within 24 hours. Offer flexible scheduling and check transportation support.",
         "Medium" = "🟡 Medium Priority: Follow-up within 3 days. Monitor responsiveness and engagement history.",
         "Low" = "🔵 Low Priority: Use SMS or email reminders weekly. Monitor but no urgent contact needed.",
         "No Info"
  )
}

# UI
ui <- fluidPage(
  titlePanel("Client Profile Radar Map"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("client", "Select a Client", choices = data_client$Client_Name)
    ),
    
    mainPanel(
      width = 8,
      plotOutput("radarPlot"),
      br(),
      h4("Priority Level:"),
      verbatimTextOutput("priorityText"),
      h4("Recommended Outreach Strategy:"),
      verbatimTextOutput("strategyText")
    )
  )
)

# Server
server <- function(input, output) {
  selected_client <- reactive({
    req(input$client)
    filter(data_client, Client_Name == input$client)
  })
  
  output$radarPlot <- renderPlot({
    radar_data <- prepare_radar_data(selected_client())
    radarchart(radar_data, axistype = 1, 
               pcol = "#2C3E50",  # Polygon border color
               pfcol = rgb(0.2, 0.5, 0.7, 0.4), plwd = 2,
               cglcol = "grey", cglty = 1, axislabcol = "grey", cglwd = 0.8,
               vlcex = 0., title = paste("Radar Map: ", input$client), cex.main = 1.4)
  }, height = 500)
  
  output$priorityText <- renderText({
    paste(selected_client()$Group)
  })
  
  output$strategyText <- renderText({
    recommend_strategy(as.character(selected_client()$Group))
  })
}

# Run App
shinyApp(ui = ui, server = server)