DataFile <- "database.RData"
ArchiveFolder <- "archive"
if (!dir.exists(ArchiveFolder)) {
  dir.create(ArchiveFolder)
}
Today <- Sys.Date()

load_database <- function() {
  if (!file.exists(DataFile)) {
    database <- NULL
  } else {
    load(DataFile) # R object: database
  }
  database
}
form_entry <- function(item_desc = "", date_pay = Sys.Date(), 
                       person_pay, person_share = "both", amount = 0) {
  # Check item description
  if (item_desc %in% c("", " ")) {
    warning(simpleWarning(
      "You are not required but are advised to describe your purchase."
    ))
  }
  # Check date of purchase
  if (class(date_pay) != "Date") {
    date_pay <- as.Date(date_pay)
  }
  if (is.na(date_pay)) {
    stop(simpleError(
      "Please specify correct date of purchase. Default is current date."
    ))
  } else {
    if (date_pay > Today) {
      stop(simpleError("Please specify a reasonable date of purchase."))
    }
  }
  # Check the person who paid and people to share the expense. If the amount 
  # should only be born by one person, `person_share` should be that person.
  person_pay <- match.arg(arg = person_pay, 
                          choices = c("Ginny Li", "Ning Yilin"))
  person_share <- match.arg(arg = person_share, 
                            choices = c("both", "Ginny Li", "Ning Yilin"))
  # Decide status based on person_pay and person_share: if they are the same, 
  # this entry is simply for bill keeping and does not need to be included in 
  # caculation.
  if (person_pay == person_share) {
    status <- "ignore"
  } else {
    status <- "due"
  }
  # Check amount
  amount <- as.numeric(amount)
  if (is.na(amount)) {
    stop(simpleError("Please specify valid amount of purchase."))
  }
  if (amount <= 0) {
    stop(simpleError("Please specify valid amount of purchase."))
  }
  # Return new entry
  data.frame(item_desc = item_desc, date_pay = date_pay, 
             person_pay = person_pay, person_share = person_share, 
             amount = amount, date_input = Today, status = status, 
             stringsAsFactors = FALSE)
}
check_entry <- function(entry) {
  # Load database
  database <- load_database()
  # Check if similar entry already exists
  dup <- NULL
  if (!is.null(database)) {
    rows <- which(database$date_pay == entry$date_pay & 
                    database$amount == entry$amount & 
                    database$person_pay == entry$person_pay & 
                    database$person_share == entry$person_share)
    if (length(rows) > 0) {
      dup <- database[rows, ]
    }
  }
  list(entry = entry, duplicates = dup)
}
add_entry <- function(entry) {
  database <- load_database()
  save(
    database, 
    file = file.path(ArchiveFolder, paste0("database", Sys.Date(), ".RData"))
  )
  # Compile new entry
  if (is.null(database)) {
    entry <- cbind(row_id = 1, entry)
  } else {
    entry <- cbind(row_id = max(database$row_id) + 1, entry)
  }
  database <- rbind(database, entry)
  save(database, file = DataFile)
}
calculate_entry <- function(entry) {
  if (entry$status != "due") {
    return(0)
  }
  if (entry$person_share == "both") {
    if (entry$person_pay == "Ning Yilin") {
      entry$amount / 2
    } else {
      -entry$amount / 2
    }
  } else if (entry$person_share == "Ning Yilin") {
    -entry$amount
  } else {
    entry$amount
  }
}
calculate <- function() {
  # Check whether there exist any records
  if (!file.exists(DataFile)) {
    stop(simpleError("There is no record yet.\n"))
  }
  load(DataFile)
  # Check whether there is any outstanding balance
  if (!any(database$status == "due")) {
    message(simpleMessage("There is no outstanding balance. We are good.\n"))
    return(0)
  }
  # Compute outstanding balance
  sum(sapply(which(database$status == "due"), function(i) {
    calculate_entry(entry = database[i, ])
  }))
}
display_balance <- function(gl_to_pay_nyl) {
  if (gl_to_pay_nyl > 0) {
    sprintf(
      "Ginny Li should pay Ning Yilin S$ %.2f.", gl_to_pay_nyl
    )
  } else if (gl_to_pay_nyl < 0) {
    sprintf(
      "Ning Yilin should pay Ginny Li S$ %.2f.", -gl_to_pay_nyl
    )
  } else {
    "There is no outstanding balance. We are good."
  }
}
clear_balance <- function(amount_cleared = "All cleared") {
  # Check whether there exist any records
  database <- load_database()
  save(
    database, 
    file = file.path(ArchiveFolder, paste0("database", Sys.Date(), ".RData"))
  )
  # Check whether there is any outstanding balance
  if (!any(database$status == "due")) {
    return("There is no outstanding balance to clear.")
  }
  # Update database to clear outstanding balance
  rows <- which(database$status == "due")
  # cat(length(rows), "items cleared:\n")
  # for (i in rows) {
  #   print(database[i, ])
  # }
  database$status[rows] <- "cleared"
  save(database, file = DataFile)
  # Check whether there is any left_over
  gl_to_pay_nyl <- calculate()
  if (amount_cleared == "All cleared") {
    amount_cleared <- gl_to_pay_nyl
  } else {
    if (amount_cleared < abs(gl_to_pay_nyl)) {
      if (gl_to_pay_nyl < 0) {
        entry <- form_entry(item_desc = "Yet to be cleared", date_pay = Today, 
                            person_pay = "Ginny Li", person_share = "Ning Yilin", 
                            amount = abs(gl_to_pay_nyl) - amount_cleared)
      } 
      if (gl_to_pay_nyl > 0) {
        entry <- form_entry(item_desc = "Yet to be cleared", date_pay = Today, 
                            person_pay = "Ning Yilin", person_share = "Ginny Li", 
                            amount = gl_to_pay_nyl - amount_cleared)
      } 
      add_entry(entry)
    }
  }
  sprintf("Outstanding balance of %.2f is cleared.", amount_cleared)
}
delete_entry <- function(row_id) {
  database <- load_database()
  database <- database[!(database$row_id %in% row_id), ]
  save(database, file = "database.RData")
}
