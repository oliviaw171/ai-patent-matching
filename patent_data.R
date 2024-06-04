# This file loads past data on patent (we aim for cleaning and analyzing data
# from 2010-2021, but we are including pre-2010 data as well in the first stage)

# Goal: take all patents applications filed at the US Patent and Trademark
# Office (USPTO) from 2010 to 2023 and match them to private firms

# Data source: USPTO patents 2010-2023
# Assignee: US private firms

# Load necessary packages
library(haven)
library(utils)

# Loading DISCERN data (data format: .dta)
discern_database <- read_dta("output_files/DISCERN_patent_database_1980_2015_final1.dta")
discern_panel <- read_dta("output_files/DISCERN_Panel_Data_1980_2015.dta")
discern_SUB_name <- read_dta("output_files/DISCERN_SUB_name_list.dta")
discern_UO_name <- read_dta("output_files/DISCERN_UO_name_list.dta")

# Loading compustat-patent data (data format: .csv)
staticTranche1 <- read.csv("compustat-patent/staticTranche1.csv")
staticTranche2 <- read.csv("compustat-patent/staticTranche2.csv")
staticTranche3 <- read.csv("compustat-patent/staticTranche3.csv")
staticTranche4 <- read.csv("compustat-patent/staticTranche4.csv")
staticTranche5 <- read.csv("compustat-patent/staticTranche5.csv")
staticTranche6 <- read.csv("compustat-patent/staticTranche6.csv")
staticTranche7 <- read.csv("compustat-patent/staticTranche7.csv")
staticTranche8 <- read.csv("compustat-patent/staticTranche8.csv")

