
library(shiny)
library(DT)
library(googlesheets)
library(rsconnect)
library(dplyr)

fields <- c("line1", "line2", "line3","author")
fields2 <- c("haiku", "author")

shinyServer(function(input, output, session) {

  output$line1_text <- renderText({
    return(input$line1)
  })
  output$line2_text <- renderText({
    return(input$line2)
  })
  output$line3_text <- renderText({
    return(input$line3)
  })
  
  # Whenever a field is filled, aggregate all form data
  formData <- reactive({
    data <- sapply(fields, function(x) input[[x]])
    data
  })
  
  table <- "poems"
  table2 <- "poems2"
  
  saveData <- function(data) {
    sheet <- gs_title(table)
    gs_add_row(sheet, ws = "Sheet1", input = data)
  }
  
  loadData <- function() {
    sheet <- gs_title(table)
    gs_read_csv(sheet)
  }
  
  loadData2 <- function() {
    sheet2 <- gs_title(table2)
    gs_read_csv(sheet2, ws = "Sheet1", col_names = TRUE)
  }
  
  data2<- reactiveValues()
  data2$df <- data.frame(Haiku = numeric(0), Author = numeric(0))
  
  newHaiku <- observe({
    if(input$submit > 0) {
      newLine1 <- isolate(c(input$line1," "))
      newLine2 <- isolate(c(input$line2," "))
      newLine3 <- isolate(c(input$line3,input$author))
      space <- isolate(c(" "," "))
      
      isolate(data2$df[1,] <- c(input$line1," "))
      isolate(data2$df[2,] <- c(input$line2," "))
      isolate(data2$df[3,] <- c(input$line3,input$author))
      isolate(data2$df[4,] <- c(" "," "))
      isolate(sheet2 <- gs_title(table2))
      isolate(old_data <- gs_read_csv(sheet2, ws="Sheet1"))
      isolate(all_data <- bind_rows(data2$df, old_data))
      isolate(gs_edit_cells(sheet2, ws = "Sheet1", input = all_data, anchor = "A1", col_names = TRUE))
    }
    
  })
  
  # When the Submit button is clicked, save the form data
  observeEvent(input$submit, {
    saveData(formData())
    updateTextInput(session, "line1", value = " ")
    updateTextInput(session, "line2", value = " ")
    updateTextInput(session, "line3", value = " ")
    updateTextInput(session, "author", value = " ")
  })
  
  # Show the previous haikus
  # (update with current haiku when Submit is clicked)
  output$haikus <- DT::renderDataTable({
    input$submit
    loadData()
  }) 
  
  output$haikus2 <- renderTable({
    input$submit
    loadData2()
  }, na = " ", colnames = FALSE)
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("haikus-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(loadData(), file, row.names = FALSE)
    },
    contentType = "text/csv"
  )


})
