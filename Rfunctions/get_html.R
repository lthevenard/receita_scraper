get_html <- function(remDr) {
  remDr$getPageSource() %>%
    .[[1]] %>%
    read_html()
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(get_html, paste0(path, 'get_html.rds'))
rm(get_html, path)


