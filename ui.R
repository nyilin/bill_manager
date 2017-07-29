# Dynamically append arbitrary number of inputs (Shiny) from 
# https://gist.github.com/ncarchedi/2ef57039c238ef074ee7
library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Bill manager"),
  
  # Sidebar with a slider input for number of bins
  sidebarPanel(
    actionButton("update_view", label = "View bills"), 
    actionButton("display_balance", label = "Show outstanding balance"), 
    hr(), 
    actionButton("clear_balance", label = "Clear outstanding balance"), 
    conditionalPanel(
      "input.clear_balance == 1", 
      textInput("amount_cleared", 
                label = "Amount of outstanding balance cleared:", 
                value = "All cleared"), 
      actionButton("clear_balance_confirm", label = "Confirm amount cleared")
    ), 
    hr(), 
    actionButton("add_entry", label = "Add new entry"), 
    conditionalPanel(
      "input.add_entry == 1", 
      textInput("item_desc", label = "Item description:", value = ""), 
      dateInput("date_pay", label = "Date of payment:", value = Sys.Date()), 
      selectInput("person_pay", label = "Who paid", 
                  choices = c("Ning Yilin", "Ginny Li")), 
      selectInput("person_share", label = "Who should bear the cost", 
                  choices = c("both", "Ning Yilin", "Ginny Li")), 
      numericInput("amount", label = "Payment amount:", value = 0, min = 0), 
      actionButton("add_entry_confirm", label = "Confirm to add entry")
    ),
    hr(), 
    actionButton("delete_entry", label = "Delete entry"), 
    conditionalPanel(
      "input.delete_entry == 1", 
      p("Please use this function with caution."), 
      numericInput("row_id", label = "Row id of entry to delete:", 
                   value = 1, min = 1), 
      actionButton("delete_entry_confirm", label = "Confirm to delete entry")
    )
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    DT::dataTableOutput("view_data"), 
    textOutput("balance")
  )
))
