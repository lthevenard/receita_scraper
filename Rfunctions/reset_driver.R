reset_driver <- function(
  driver = remDr,
  szz = fun$szz
) {
  driver$closeall()
  szz()
  driver$open(silent = TRUE)
  szz()
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(reset_driver, paste0(path, 'reset_driver.rds'))
rm(reset_driver, path)
