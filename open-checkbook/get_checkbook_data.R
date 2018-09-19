library(tidyverse)

ledger <- read_csv("http://checkbook.atlantaga.gov/api/ledger.csv", 
                   col_types = cols(
                     fiscal_year = col_integer(),
                     fiscal_period = col_integer(),
                     check_date = col_datetime(format = ""),
                     fund_type = col_character(),
                     fund = col_character(),
                     department = col_character(),
                     division = col_character(),
                     account = col_character(),
                     expense_category = col_character(),
                     project = col_character(),
                     invoice_description = col_character(),
                     amount = col_double(),
                     vendor_name = col_character(),
                     vendor_id = col_character(),
                     payment_id = col_integer(),
                     payment_method = col_character(),
                     payment_status = col_character(),
                     payment_check_num = col_double()
                   ))
vendor <- read_csv("http://checkbook.atlantaga.gov/api/vendor.csv",
                   col_types = cols(
                     vendor_name = col_character(),
                     vendor_id = col_character(),
                     vendor_description = col_character(),
                     vendor_address1 = col_character(),
                     vendor_address2 = col_character(),
                     vendor_city = col_character(),
                     vendor_zip = col_character(),
                     minority_group = col_character(),
                     women_owned_flag = col_character(),
                     small_business_flag = col_character(),
                     geocoded_column = col_character()
                   )
)
