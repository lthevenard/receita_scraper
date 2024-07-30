patternize <- function (x) {
  
  x %>%
    str_replace_all("\\.", "\\\\.") %>%
    str_replace_all("\\*", "\\\\*") %>%
    str_replace_all("\\?", "\\\\?") %>%
    str_replace_all("\\(", "\\\\(") %>%
    str_replace_all("\\)", "\\\\)") %>%
    str_replace_all("\\[", "\\\\[") %>%
    str_replace_all("\\]", "\\\\]") %>%
    str_replace_all("\\$", "\\\\$") %>%
    str_replace_all("\\|", "\\\\|") %>%
    str_replace_all("\\{", "\\\\{") %>%
    str_replace_all("\\}", "\\\\}")
}

path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(patternize, paste0(path, 'patternize.rds'))
rm(patternize, path)

