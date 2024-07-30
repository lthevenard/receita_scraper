exclude_nas <- function(vec) {
  vec[!is.na(vec)]
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(exclude_nas, paste0(path, 'exclude_nas.rds'))
rm(exclude_nas, path)
