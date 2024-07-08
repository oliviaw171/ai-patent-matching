# Web search engine approach

# Loading necessary Libraries
library(RSQLite)
library(httr)
library(jsonlite)

# SQLite
conn <- dbConnect(SQLite(), dbname = "my_database.sqlite")

# Bing API
subscription_key <- ""  # insert your Bing key here
stopifnot(nchar(subscription_key) > 0)
client_id <- ""

Empty_Search_Word_Err <- "Empty Search Word"

# Function to call Bing API
search_bing <- function(query) {
  if (nchar(query) == 0) {
    stop(Empty_Search_Word_Err)
  }
  
  url <- paste0("https://api.cognitive.microsoft.com/bing/v7.0/search?q=", URLencode(query))
  response <- GET(url, add_headers(`Ocp-Apim-Subscription-Key` = subscription_key))
  
  if (status_code(response) != 200) {
    stop("Bing API request failed")
  }
  
  content(response, "parsed", "application/json")
}

###### ###### ###### ###### ###### ###### ###### ###### 


