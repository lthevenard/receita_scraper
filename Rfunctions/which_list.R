which_list <- function(search, list_to_search) {
  search_result <- NULL
  for (i in seq_along(list_to_search)) {
    if (search %in%  list_to_search[[i]]) {
      search_result <- i
    }
  }
  if (is.null(search_result)) {
    warning("Item not found. Returning NULL")
  }
  search_result
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(which_list, paste0(path, 'which_list.rds'))
rm(which_list, path)
