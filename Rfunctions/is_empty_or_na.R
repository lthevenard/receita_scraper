is_empty_or_na <- function (x) {
  
  if (is_empty(x)) {
    answer <- TRUE
  } else if (is.na(x)) {
    answer <- TRUE
  } else {
    answer <- FALSE
  }
  answer
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(is_empty_or_na, paste0(path, 'is_empty_or_na.rds'))
rm(is_empty_or_na, path)