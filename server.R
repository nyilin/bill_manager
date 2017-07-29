# Dynamically append arbitrary number of inputs (Shiny) from 
# https://gist.github.com/ncarchedi/2ef57039c238ef074ee7
library(shiny)
library(DT)
source("functions.R")

shinyServer(function(input, output) {
  get_database <- eventReactive(input$update_view, {
    database <- load_database()
    if (!is.null(database)) {
      database[with(database, 
                    order(date_input, date_pay, row_id, decreasing = TRUE)), ]
    } else {
      database
    }
  })
  output$view_data <- DT::renderDataTable({
    DT::datatable(get_database(), rownames = FALSE)
  })
  
  observeEvent(input$add_entry_confirm, {
    entry <- form_entry(item_desc = input$item_desc, date_pay = input$date_pay, 
                        person_pay = input$person_pay, 
                        person_share = input$person_share, 
                        amount = input$amount)
    add_entry(entry)
    showNotification(
      "New entry added. Please click on 'view bills' for an updated view.", 
      type = "message"
    )
  })
  
  observeEvent(input$clear_balance_confirm, {
    amount_cleared <- as.numeric(input$amount_cleared)
    msg <- clear_balance(amount_cleared)
    showNotification(
      paste(msg, "Please click on 'view bills' for an updated view."), 
      type = "message"
    )
  })
  
  observeEvent(input$display_balance, {
    showNotification(display_balance(gl_to_pay_nyl = calculate()), 
                     type = "message")
  })
  
  observeEvent(input$delete_entry_confirm, {
    delete_entry(input$row_id)
    showNotification(
      paste("Entry with row id", input$row_id, "is deleted from database.", 
            "Please click on 'view bills' for an updated view."), 
      type = "message"
    )
  })
})
