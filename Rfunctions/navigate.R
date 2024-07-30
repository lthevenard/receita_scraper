navigate <- function(
  link,
  message,
  from,
  to,
  szz = fun$szz,
  driver = remDr
) {
  driver$navigate(link)
  szz(from, to, message)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(navigate, paste0(path, 'navigate.rds'))
rm(navigate, path)
