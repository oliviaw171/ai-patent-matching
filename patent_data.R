# This file loads past data on patent (we aim for cleaning and analyzing data
# from 2010-2021, but we are including pre-2010 data as well in the first stage)

# Goal: take all patents applications filed at the US Patent and Trademark
# Office (USPTO) from 2010 to 2023 and match them to private firms

# Assumption (to check): assignee should be a private firm, not an individual
# Static or dynamic?
# Which year to use? Grant, application, link
# App Year usage argument:
#   A) Innovation Timeline: 
# The application year reflects when the innovation was conceived and formally
# submitted, which is closely tied to the firm's innovative activities and the
# timing of AI adoption
#   B) Consistency with Independent Variables: 
# Main independent variable, AI adoption, is likely tied to specific
# periods

# Data source: USPTO patents 2010-2023
# Assignee: US private firms
# Variables (i.e., columns in data frames; subject to change): 
# 1. Patent ID
# 2. Patent Grant Year
# 3. gvkey
#      concern: does not capture changes over time in ownership structure and
#      firm names, and the same company may have multiple codes over time
#      3a) gvkeyUO
#      3a) gvkeyFR
# 4. Company/organization assignee name
#      4a) Raw name
#      4b) Cleaned name

# To decide yet:

# 5. Private Subsidiary (binary variable)
# 6. Assignee Address
# 7. Patent Submission Year (App Year)
# 8. Link Year: Year for which the given (cleaned) firm name is mapped to the
# given gvkeyFR and (where applicable) given gvkeyUO
#      8a) cnLink_y1 (first year)
#      8b) cnLink_yn (last year)


# Load necessary packages
library(haven)
library(utils)

# Loading DISCERN data (data format: .dta)
discern_database <- read_dta("output_files/DISCERN_patent_database_1980_2015_final1.dta")
discern_panel <- read_dta("output_files/DISCERN_Panel_Data_1980_2015.dta")
discern_SUB_name <- read_dta("output_files/DISCERN_SUB_name_list.dta")
discern_UO_name <- read_dta("output_files/DISCERN_UO_name_list.dta")

# Loading compustat-patent data (data format: .csv)
# Time frame: 1926 - 2020
# p.s. Direction of retrieving raw datasets can be found in `orig` folder
staticTranche1 <- read.csv("compustat-patent/staticTranche1.csv")
staticTranche2 <- read.csv("compustat-patent/staticTranche2.csv")
staticTranche3 <- read.csv("compustat-patent/staticTranche3.csv")
staticTranche4 <- read.csv("compustat-patent/staticTranche4.csv")
staticTranche5 <- read.csv("compustat-patent/staticTranche5.csv")
staticTranche6 <- read.csv("compustat-patent/staticTranche6.csv")
staticTranche7 <- read.csv("compustat-patent/staticTranche7.csv")
staticTranche8 <- read.csv("compustat-patent/staticTranche8.csv")

