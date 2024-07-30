build_archive_names <- function(
  type,
  capture_date
) {
  paste0(
    type, "_", capture_date %>%
      str_replace_all("-", "_")
  )
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(build_archive_names, paste0(path, 'build_archive_names.rds'))
rm(build_archive_names, path)
