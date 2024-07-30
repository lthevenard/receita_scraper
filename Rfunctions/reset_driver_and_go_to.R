reset_driver_and_go_to <- function(
  url,
  driver = remDr,
  szz = fun$szz
) {
  driver$closeall()
  cat("Opening driver...\n")
  driver$open(silent = TRUE)
  szz()
  driver$navigate(url)
  szz(9, 12, "Waiting for base page...")
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(reset_driver_and_go_to, paste0(path, 'reset_driver_and_go_to.rds'))
rm(reset_driver_and_go_to, path)
