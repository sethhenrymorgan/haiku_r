
library(shiny)
library(DT)
library(googlesheets)
library(rsconnect)
library(shinythemes)

fields <- c("line1", "line2", "line3","author")
fields2 <- c("haiku", "author")

shinyUI(fluidPage(theme = shinytheme("journal"),

  titlePanel('Haiku_R 1.0'),
  
  sidebarLayout(
  
  sidebarPanel('Write',
           textInput("line1", label = "Write your haiku here:", ""),
           textInput("line2", label = NULL),
           textInput("line3", label = NULL),
           textInput("author", label = "Author"),
           actionButton("submit", "Submit"),
           textOutput("line1_text"),
           textOutput("line2_text"),
           textOutput("line3_text")
  ),
  
  mainPanel(
    tabsetPanel(
      tabPanel('View', 
           uiOutput("haikus2"),
           tags$style (type="text/css", "#haikus2 td:last-child {font-style:italic;}")
            ),
      tabPanel('Data', DT::dataTableOutput("haikus"))
    )
  )
  )
))
