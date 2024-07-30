invert_paste <- function(b, a, sep = "") {
  paste(a, b, sep = sep)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(invert_paste, paste0(path, 'invert_paste.rds'))
rm(invert_paste, path)
