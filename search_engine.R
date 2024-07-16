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

bing_web_search_sdk_list <- function(search_word_list, c = 50) {
  list_name_url <- list()
  list_raw <- list()
  list_urls <- list()
  
  for (search_word in search_word_list) {
    # Sanity check to avoid any potential issue
    if (nchar(search_word) == 0) {
      stop(Empty_Search_Word_Err)
    }
    
    # Bing Web Search API request
    url <- paste0("https://api.cognitive.microsoft.com/bing/v7.0/search?q=", URLencode(search_word), "&count=", c)
    response <- GET(url, add_headers(`Ocp-Apim-Subscription-Key` = subscription_key))
    
    if (status_code(response) != 200) {
      stop("Bing API request failed")
    }
    
    web_data_raw <- content(response, "parsed", "application/json")
    raw <- toJSON(web_data_raw)
    list_raw <- append(list_raw, raw)
    
    name_url <- list()
    urls <- list()
    if (!is.null(web_data_raw$webPages$value)) {
      for (item in web_data_raw$webPages$value) {
        name_url <- append(name_url, list(c(item$name, item$url)))
        urls <- append(urls, item$url)
      }
    }
    
    list_name_url <- append(list_name_url, list(name_url))
    list_urls <- append(list_urls, list(urls))
  }
  
  return(list(list_name_url = list_name_url, list_raw = list_raw, list_urls = list_urls))
}



