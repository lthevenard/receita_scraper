analyze_url <- function (url) {
  
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
  
  tibble(keys, values)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(analyze_url, paste0(path, 'analyze_url.rds'))
rm(analyze_url, path)
