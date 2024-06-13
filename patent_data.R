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
# Issue: USPTO recorded date

# Data source: USPTO patents 2010-2023
# Assignee: US private firms
# Variables (i.e., columns in data frames; subject to change): 
# 1. Patent ID
# 2. Patent Submission Year (App Year)
# 3. Patent Grant Year
# 4. gvkey
#      concern: does not capture changes over time in ownership structure and
#      firm names, and the same company may have multiple codes over time
#      3a) gvkeyUO
#      3a) gvkeyFR
# 5. Company/organization assignee name
#      4a) Raw name
#      4b) Cleaned name

# To decide yet:

# 6. Private Subsidiary (binary variable)
# 7. Assignee Address
# 8. Link Year: Year for which the given (cleaned) firm name is mapped to the
# given gvkeyFR and (where applicable) given gvkeyUO
#      8a) cnLink_y1 (first year)
#      8b) cnLink_yn (last year)


# Load necessary packages
library(haven)
library(utils)
library(dplyr)
library(stringr)
library(tidyr)

#### #### #### #### ####

# Loading DISCERN data (data format: .dta)
# Time frame: 1980 - 2015
discern_database <- read_dta("output_files/DISCERN_patent_database_1980_2015_final1.dta")
discern_panel <- read_dta("output_files/DISCERN_Panel_Data_1980_2015.dta")
discern_SUB_name <- read_dta("output_files/DISCERN_SUB_name_list.dta")
discern_UO_name <- read_dta("output_files/DISCERN_UO_name_list.dta")

#### #### #### #### ####

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

# Filter patents with appYear from 2010 - 2020
f_statT1 <- subset(staticTranche1, appYear >= 2010 & appYear <= 2020)
f_statT2 <- subset(staticTranche2, appYear >= 2010 & appYear <= 2020)
f_statT3 <- subset(staticTranche3, appYear >= 2010 & appYear <= 2020)
f_statT4 <- subset(staticTranche4, appYear >= 2010 & appYear <= 2020)
f_statT5 <- subset(staticTranche5, appYear >= 2010 & appYear <= 2020)
f_statT6 <- subset(staticTranche6, appYear >= 2010 & appYear <= 2020)
f_statT7 <- subset(staticTranche7, appYear >= 2010 & appYear <= 2020)
f_statT8 <- subset(staticTranche8, appYear >= 2010 & appYear <= 2020)

# Combine the filtered datasets
f_statT_total <- rbind(f_statT1, f_statT2, f_statT3, f_statT4, 
                          f_statT5, f_statT6, f_statT7, f_statT8)
# 1,043,622 patents (observations) from submission period from 2010 to 2020

remove(f_statT1, f_statT2, f_statT3, f_statT4,f_statT5, f_statT6,
       f_statT7, f_statT8)

# Create patent data folder
data_folder_path <- "patent-data"
dir.create(data_folder_path)

# Define file path and save the combined dataset to new folder
data_folder_path <- file.path(data_folder_path, "f_statT_total")
write.csv(f_statT_total, data_folder_path, row.names = FALSE)

#### #### #### #### ####

# Compare DISCERN and compustat-patent data for the overlapping time period -->
# check and improve accuracy

# DISCERN data do not provide appYear, so we use Grant Year as the variable to
# frame the compared data
# Preliminary period: 2005-2015

f_discern <- subset(discern_database, publn_year >= 2005 & publn_year <= 2015)
# 661,577 observations

f_statT1_comp <- subset(staticTranche1, grantYear >= 2005 & grantYear <= 2015)
f_statT2_comp <- subset(staticTranche2, grantYear >= 2005 & grantYear <= 2015)
f_statT3_comp <- subset(staticTranche3, grantYear >= 2005 & grantYear <= 2015)
f_statT4_comp <- subset(staticTranche4, grantYear >= 2005 & grantYear <= 2015)
f_statT5_comp <- subset(staticTranche5, grantYear >= 2005 & grantYear <= 2015)
f_statT6_comp <- subset(staticTranche6, grantYear >= 2005 & grantYear <= 2015)
f_statT7_comp <- subset(staticTranche7, grantYear >= 2005 & grantYear <= 2015)
f_statT8_comp <- subset(staticTranche8, grantYear >= 2005 & grantYear <= 2015)

f_statT_compare <- rbind(f_statT1_comp, f_statT2_comp, f_statT3_comp,
                         f_statT4_comp, f_statT5_comp, f_statT6_comp,
                         f_statT7_comp, f_statT8_comp)
# 1,126,479 observations

remove(f_statT1_comp, f_statT2_comp, f_statT3_comp, f_statT4_comp,
       f_statT5_comp, f_statT6_comp, f_statT7_comp, f_statT8_comp)

remove(staticTranche1, staticTranche2, staticTranche3, staticTranche4,
       staticTranche5, staticTranche6, staticTranche7, staticTranche8)

# remove(f_statT1, f_statT2, f_statT3, f_statT4, f_statT5, f_statT6,
#        f_statT7, f_statT8)

# Convert the relevant columns to character to ensure matching works correctly
f_discern$publn_nr <- as.character(f_discern$publn_nr)
f_statT_compare$patent_id <- as.character(f_statT_compare$patent_id)

# Check if publn_nr from f_discern exists in patent_id from f_statT_compare
common_patents_discern <- f_discern$publn_nr %in% f_statT_compare$patent_id

# Create a new column in f_discern to indicate if the patent is in f_statT_compare
f_discern$in_f_statT_compare <- common_patents_discern

# Check if patent_id from f_statT_compare exists in publn_nr from f_discern
common_patents_statT_compare <- f_statT_compare$patent_id %in% f_discern$publn_nr

# Create a new column in f_statT_compare to indicate if the patent is in f_discern
f_statT_compare$in_f_discern <- common_patents_statT_compare

# Count the number of TRUE and FALSE values in both datasets
true_count_discern <- sum(f_discern$in_f_statT_compare)
false_count_discern <- sum(!f_discern$in_f_statT_compare)
true_count_statT_compare <- sum(f_statT_compare$in_f_discern)
false_count_statT_compare <- sum(!f_statT_compare$in_f_discern)

# 577,283 out of 661,577 patents in DISCERN are present in compustat-patent
# 577,180 out of 1,126,479 patents in c-p are present in DISCERN

# potential factors that accounts for differences:
#   static vs dynamic



#### #### #### #### ####

# Load USPTO raw data

uspto_assignee <- read.csv("USPTO/assignee.csv")
# reel frame id, assignee name, assignee address
# 10,930,678
# needs to be linked to date & unique ID, patent

uspto_assignment <- read.csv("USPTO/assignment.csv")
# record date, rf id, file id
# 10,531,897

uspto_doc_id <- read.csv("USPTO/documentid.csv")
# 11,688,561 observations

# Change variable type to date; filter to desired time period
uspto_doc_id$appno_date <- as.Date(uspto_doc_id$appno_date, format = "%Y-%m-%d")
typeof(uspto_doc_id$appno_date)
uspto_doc_id <- uspto_doc_id |>
  filter(appno_date >= as.Date("2010-01-01") & appno_date <= as.Date("2024-12-31"))
# 2,686,775 observations

# Remove unnecessary variables
uspto_doc_id <- uspto_doc_id |>
  select(-pgpub_doc_num, -pgpub_date, -pgpub_country)

# Filter uspto_assignee and uspto_assignment to keep only rows with rf_id present in uspto_doc_id
uspto_assignee <- uspto_assignee |>
  semi_join(uspto_doc_id, by = "rf_id")
# 2,276,430 observations
uspto_assignment <- uspto_assignment |>
  semi_join(uspto_doc_id, by = "rf_id")
# 2,191,638 observations

####

# Standardize the assignee names
standardize_name <- function(name) {
  # Convert to lowercase
  name <- tolower(name)
  
  # Remove punctuation and special characters
  name <- gsub("[[:punct:]]", "", name)
  
  # Remove common company suffixes
  name <- gsub("\\b(co|ltd|corp|inc)\\b", "", name, ignore.case = TRUE)
  
  # Trim leading and trailing whitespace
  name <- trimws(name)
  
  return(name)
}

# Apply the standardization function to the ee_name column
uspto_assignee$ee_name <- standardize_name(uspto_assignee$ee_name)

# Add a binary column indicating duplicate entries in ee_name
uspto_assignee$has_duplicate <- duplicated(uspto_assignee$ee_name) | duplicated(uspto_assignee$ee_name, fromLast = TRUE)

# Count the number of entries with duplicates
sum(uspto_assignee$has_duplicate)

# 2,139,990 before standardizing names, 2,158,107 after standardizing names

####

# Identify duplicate observations
duplicate_uspto_pat <- duplicated(uspto_assignee$ee_name) | duplicated(uspto_assignee$ee_name, fromLast = TRUE)

uspto_cb_assignee <- uspto_assignee %>%
  group_by(ee_name, ee_address_1, ee_address_2, ee_city, ee_state, ee_postcode, ee_country) %>%
  summarise(rf_id_combined = if_else(all(has_duplicate), paste(rf_id, collapse = ", "), as.character(rf_id[1])))

# Save edited datasets locally (then push to github)
dir.create("uspto-clean")

write.csv(uspto_doc_id, file = "uspto-clean/uspto_doc_id_cleaned.csv", row.names = FALSE)
write.csv(uspto_assignee, file = "uspto-clean/uspto_assignee_cleaned.csv", row.names = FALSE)
write.csv(uspto_assignment, file = "uspto-clean/uspto_assignment_cleaned.csv", row.names = FALSE)
write.csv(uspto_cb_assignee, file = "uspto-clean/uspto_cb_assignee_cleaned.csv", row.names = FALSE)

# Figure out solution to uploading more large files
# Link between patent id, reel frame id, file id

####

# Combine address-related columns into a single variable
uspto_cb_assignee <- tidyr::unite(uspto_cb_assignee, 
            col = "ee_address", 
            ee_address_1, ee_address_2, ee_city, ee_state, ee_postcode, ee_country, 
            sep = ", ", 
            remove = FALSE)

# Clean and standardize the ee_address variable by removing punctuation
uspto_cb_assignee$ee_address <- gsub("[[:punct:]]", "", uspto_cb_assignee$ee_address)

# Remove extra spaces from ee_address
uspto_cb_assignee$ee_address <- gsub("\\s+", " ", uspto_cb_assignee$ee_address)

# Remove unnecessary columns from the dataframe
uspto_cb_assignee <- subset(uspto_cb_assignee, select = -c(ee_address_1, ee_address_2, ee_city, ee_state, ee_postcode, ee_country))

# Loop through each row and compare with the previous row (speed too slow)
# for (i in 2:nrow(uspto_cb_assignee)) {
#  if (uspto_cb_assignee[i, "ee_name"] == uspto_cb_assignee[i - 1, "ee_name"] &&
#      uspto_cb_assignee[i, "ee_address"] == uspto_cb_assignee[i - 1, "ee_address"]) {
#    # Combine the rf_id_combined values into one string
#    uspto_cb_assignee[i, "rf_id_combined"] <- paste(uspto_cb_assignee[i - 1, "rf_id_combined"], uspto_cb_assignee[i, "rf_id_combined"], sep = ", ")
#    # Remove the previous row
#    uspto_cb_assignee <- uspto_cb_assignee[-(i - 1), ]
#    # Decrement the loop index to adjust for the removed row
#    i <- i - 1
#  }
# }

# Group rows by ee_name and ee_address, then combine rf_id_combined values
uspto_cb_assignee <- uspto_cb_assignee %>%
  group_by(ee_name, ee_address) %>%
  summarize(rf_id_combined = toString(rf_id_combined)) %>%
  ungroup()
