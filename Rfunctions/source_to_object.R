source_to_object <- function (r_path) {
  
  obj_name <- r_path %>%
    str_extract("/[^/]+\\.[Rr]$") %>%
    str_remove_all("^/|\\.[Rr]$")
  
  temp_e <- new.env()
  
  source(r_path, local = temp_e)
  
  temp_e[[obj_name]]
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(source_to_object, paste0(path, 'source_to_object.rds'))
rm(source_to_object, path)
