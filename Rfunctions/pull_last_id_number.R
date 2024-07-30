pull_last_id_number <- function(
  id_vector
) {
  id_vector %>%
    str_extract("\\d+$") %>%
    as.integer() %>%
    max()
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(pull_last_id_number, paste0(path, 'pull_last_id_number.rds'))
rm(pull_last_id_number, path)
