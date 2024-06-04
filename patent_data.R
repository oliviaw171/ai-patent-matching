# This file loads past data on patent (we aim for cleaning and analyzing data
# from 2010-2021, but we are including pre-2010 data as well in the first stage)

# Load necessary packages
library(haven)

# Loading DISCERN data (data format: .dta)
discern_database <- read_dta("output_files/DISCERN_patent_database_1980_2015_final1.dta")
discern_panel <- read_dta("output_files/DISCERN_Panel_Data_1980_2015.dta")
discern_SUB_name <- read_dta("output_files/DISCERN_SUB_name_list.dta")
discern_UO_name <- read_dta("output_files/DISCERN_UO_name_list.dta")

