sys_time <- function () {
  paste(
    Sys.Date(),
    as.integer(Sys.time()),
    sep = "_"
  )
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(sys_time, paste0(path, 'sys_time.rds'))
rm(sys_time, path)