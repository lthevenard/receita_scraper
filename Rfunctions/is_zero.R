is_zero <- function(x, character = FALSE) {
  if (character) {
    x = as.numeric(x)
  }
  x == 0
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(is_zero, paste0(path, 'is_zero.rds'))
rm(is_zero, path)
