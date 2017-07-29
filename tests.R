input1 <- form_input(item_desc = "GNC", date_pay = "2017-07-16", 
                     person_pay = "Ning Yilin", person_share = "Ning Yilin", 
                     amount = 189.34)
input_ls <- check_input(input1)
add_input(input_ls$input1)
calculate_input(input1)
input1 <- form_input(item_desc = "GNC", date_pay = "2017-07-16", 
                     person_pay = "Ning Yilin", person_share = "Ning Yilin", 
                     amount = 189.34)
balance <- calculate()
display_balance(balance)

input2 <- form_input(item_desc = "Bing", date_pay = "2017-07-16", 
                     person_pay = "Ning Yilin", person_share = "both", 
                     amount = 12.9)
input3 <- form_input(item_desc = "Fairprice grocery", date_pay = "2017-07-16",
                     person_pay = "Ning Yilin", person_share = "both", 
                     amount = 135)
add_input(input2)
add_input(input3)
calculate()
clear_balance()
