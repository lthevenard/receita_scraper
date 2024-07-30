recompose_url <- function(tibble) {
  
  url <- paste0(tibble$values[1], "?")
  
  for (i in 2:length(tibble$keys)) {
    
    if (i == 2) {
      next_param <- paste0(tibble$keys[i], "=", tibble$values[i])
      url <- paste0(url, next_param)
    } else {
      next_param <- paste0("&", tibble$keys[i], "=", tibble$values[i])
      url <- paste0(url, next_param)
    }
  }
  url
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(recompose_url, paste0(path, 'recompose_url.rds'))
rm(recompose_url, path)





