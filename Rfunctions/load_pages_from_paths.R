load_pages_from_paths <- function(path_list) {
  list_of_pages <- vector('list', length(path_list))
  names(list_of_pages) <- path_list
  for (i in seq_along(path_list)) {
    list_of_pages[[i]] <- read_html(path_list[[i]])
  }
  return(list_of_pages)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(load_pages_from_paths, paste0(path, 'load_pages_from_paths.rds'))
rm(load_pages_from_paths, path)
