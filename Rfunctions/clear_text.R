clear_text <- function(
  text,
  remove_punctuation = FALSE,
  remove_parentheses = FALSE
) {
  text <- text %>%
    str_to_lower() %>%
    stringi::stri_trans_nfd() %>%
    str_remove_all("[\u0300-\u036f]") %>%
    str_trim()
  
  if (remove_punctuation) {
    text <- text %>%
      str_remove_all("[^\\w\\s]") %>%
      str_trim()
  }
  if (remove_parentheses) {
    text <- text %>%
      str_remove_all("\\(|\\)|\\[|\\]|\\{|\\}") %>%
      str_trim()
  }
  text
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(clear_text, paste0(path, 'clear_text.rds'))
rm(clear_text, path)
