get_ip <- function() {
  read_html("https://api.ipify.org?format=json") %>%
    html_text(trim = TRUE) %>%
    jsonlite::fromJSON()
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(get_ip, paste0(path, 'get_ip.rds'))
rm(get_ip, path)


