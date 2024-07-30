url_to_tibble <- function (url) {
  
  url <- str_split(url, "\\?")
  base_url <- unlist(url)[1]
  url_params <- unlist(url)[2]
  
  url_params <- str_split(url_params, "&")
  url_params <- unlist(url_params)
  
  keys <- "Base URL"
  values <- base_url
  
  for (param in url_params) {
    brake <- param %>%
      str_split("=") %>%
      unlist()
    keys <- c(keys, brake[1])
    values <- c(values, brake[2])
  }
  
  result <- vector('list', length(values))
  for (i in seq_along(values)) {
    result[[i]] <- values[[i]]
  }
  names(result) <- keys
  as_tibble(result)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(url_to_tibble, paste0(path, 'url_to_tibble.rds'))
rm(url_to_tibble, path)
