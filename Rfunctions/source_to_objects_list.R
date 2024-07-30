source_to_objects_list <- function (r_path) {
  
  temp_e <- new.env()
  
  source(r_path, local = temp_e)
  
  as.list(temp_e)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(source_to_objects_list, paste0(path, 'source_to_objects_list.rds'))
rm(source_to_objects_list, path)
