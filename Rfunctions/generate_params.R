# Generate parameters from a data frame created with analyze_url
generate_params <- function(url_df) {
  query_params <- url_df$values[url_df$keys != "Base URL"]
  names(query_params) <- url_df$keys[url_df$keys != "Base URL"]
  query_params <- as.list(query_params)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(generate_params, paste0(path, 'generate_params.rds'))
rm(generate_params, path)