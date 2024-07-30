load_page_list <- function(path) {
  if (!dir.exists(path)) {
    cat("\nPATH DOES NOT EXIST\n")
    return(NULL)
  }
  if (str_detect(path, "/$")) {
    path <- str_remove(path, "/$")
  }
  files <- list.files(path, '\\.html$', full.names = TRUE)
  files <- sort(files)
  list_of_pages <- lapply(files, read_html)
  names(list_of_pages) <- files
  return(list_of_pages)
}

path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(load_page_list, paste0(path, 'load_page_list.rds'))
rm(load_page_list, path)
