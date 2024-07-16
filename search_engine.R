# Web search engine approach

# Loading necessary Libraries
library(RSQLite)
library(httr)
library(jsonlite)

# SQLite
### May not need
conn <- dbConnect(SQLite(), dbname = "my_database.sqlite")

# Define Azure Cognitive Services API access function
bing_web_search_sdk_list <- function(search_word_list, c = 50) {
  list_name_url <- list()
  list_raw <- list()
  list_urls <- list()
  
  for (search_word in search_word_list) {
    # sanity check to avoid any potential issue
    if (nchar(search_word) == 0) {
      stop("Empty Search Word")
    }
    
    # Perform web search
    endpoint <- "https://api.cognitive.microsoft.com/bing/v7.0/search"
    headers <- c(`Ocp-Apim-Subscription-Key` = subscription_key)
    query_params <- list(q = search_word, count = c)
    response <- GET(url = endpoint, query = query_params, add_headers(.headers=headers))
    raw_data <- content(response, as = "text")
    list_raw <- c(list_raw, raw_data)
    
    # Extract name-url pairs and URLs
    parsed_data <- fromJSON(raw_data)
    name_url <- sapply(parsed_data$webPages$value, function(x) list(x$name, x$url))
    urls <- parsed_data$webPages$value$url
    
    list_name_url <- c(list_name_url, toString(name_url))
    list_urls <- c(list_urls, toString(urls))
  }
  
  return(list(list_name_url, list_raw, list_urls))
}

# Function to log time used
log_time_used <- function(t1, task, log_file, mode = 'a') {
  t2 <- Sys.time()
  t <- as.numeric(difftime(t2, t1, units = "secs"))
  message <- paste(task, "takes", t, "s.")
  
  if (file.exists(log_file)) {
    writeLines(paste(message, "\n"), log_file, append = TRUE)
  } else {
    writeLines(paste(message, "\n"), stdout())
  }
  
  return(Sys.time())
}

# Main execution flow
t_start <- Sys.time()
t1 <- Sys.time()

# Load names from pickle file (assuming it's in RDS format)
list_name <- readRDS("sdc_compustat_patentsview_name.rds")

# Take task number from command line argument
task_num <- as.integer(commandArgs(trailingOnly = TRUE)[1])

logfile <- paste0("search_task", task_num, ".log")
task_size <- 5000
task_start <- (task_num - 1) * task_size + 1
task_end <- min(task_num * task_size, length(list_name))
list_task <- list_name[task_start:task_end]

df <- data.frame(newname = unlist(list_task))

# Create SQLite database and store initial data
db <- paste0("search_task", task_num, ".db")
con <- dbConnect(SQLite(), dbname = db)
table_name <- paste0("newname_task", task_num)
dbWriteTable(conn = con, name = table_name, value = df, overwrite = TRUE)

# Function to show tables in SQLite database
show_tables <- function() {
  tables <- dbListTables(con)
  return(tables)
}

# Function to drop tables from SQLite database
drop_tables <- function(table_name) {
  dbRemoveTable(con, name = table_name)
  tables <- dbListTables(con)
  return(tables)
}

# Drop result table if exists
result_table <- paste0("search_result_task", task_num)
if (result_table %in% show_tables()) {
  drop_tables(result_table)
} else {
  cat("no result table in db yet\n")
}

t1 <- log_time_used(t1, "getting ready", log_file = logfile, mode = 'w+')

# Function for batch search and save to SQLite
batch_search_new <- function(n, s, c = 50) {
  t1 <- Sys.time()
  begin <- (n - 1) * s + 1
  end <- min(n * s, nrow(df))
  name_list <- df$newname[begin:end]
  search_results <- bing_web_search_sdk_list(name_list, c)
  
  # Create DataFrame for results
  df_result <- data.frame(newname = name_list,
                          name_url = search_results[[1]],
                          raw = search_results[[2]],
                          urls = search_results[[3]])
  
  sql_name <- paste0("sdc_search_result_task", task_num)
  dbWriteTable(conn = con, name = sql_name, value = df_result, append = TRUE)
  
  t1 <- log_time_used(t1, paste("query + save", s, "searches to sql"), log_file = logfile)
}

# Perform batch searches in rounds
batch_size <- 1000
batch_round <- ceiling(nrow(df) / batch_size)

for (batch_num in 1:batch_round) {
  batch_search_new(batch_num, batch_size)
  if (logfile == '') {
    cat(paste("processed batch No.", batch_num, "\n"))
  } else {
    cat(paste("processed batch No.", batch_num, "\n"), file = logfile, append = TRUE)
  }
}

t1 <- log_time_used(t_start, paste(batch_round, "rounds done"), log_file = logfile)

# Validation code to read from SQLite database
sql <- paste0("SELECT * FROM sdc_search_result_task", task_num, " LIMIT 100;")
df_temp <- dbGetQuery(con, sql)
print(head(df_temp))
