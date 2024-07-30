build_ids <- function (code, type, size, last_value = 0, invert = FALSE) {
  
  start <- last_value + 1
  end <- last_value + size
  
  if (invert) {
    ids <- paste0(code, "_", type, "_", end:start)
  } else {
    ids <- paste0(code, "_", type, "_", start:end)
  }
  ids
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(build_ids, paste0(path, 'build_ids.rds'))
rm(build_ids, path)
