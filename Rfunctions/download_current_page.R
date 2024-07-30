download_current_page <- function(driver = remDr) {
  driver$getPageSource() %>%
    .[[1]] %>%
    read_html()
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(download_current_page, paste0(path, 'download_current_page.rds'))
rm(download_current_page, path)
