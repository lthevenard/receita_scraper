save_page_list <- function(page_list, path) {
  if (!dir.exists(path)) {
    dir.create(path)
  }
  if (str_detect(path, "/$")) {
    path <- str_remove(path, "/$")
  }
  for (i in seq_along(page_list)) {
    file_name <- paste0(i, ".html")
    full_path <- paste0(path, "/", file_name)
    write_html(page_list[[i]], full_path)
  }
}

path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(save_page_list, paste0(path, 'save_page_list.rds'))
rm(save_page_list, path)
