shorten_strings <- function(string_vec, limit) {
  new_vec <- vector('character', length(string_vec))
  for (i in seq_along(new_vec)) {
    item <- string_vec[[i]]
    size <- str_count(item)
    if (size <= limit) {
      new_vec[[i]] <- item
    } else {
      div_1 <- floor(size / 2)
      div_2 <- div_1 + 1
      first_half <- str_sub(item, start = 1, end = div_1)
      second_half <- str_sub(item, start = div_2, end = size)
      second_half <- str_replace(second_half, "\\s", "\n")
      new_vec[[i]] <- paste0(first_half, second_half)
    }
  }
  return(new_vec)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(shorten_strings, paste0(path, 'shorten_strings.rds'))
rm(shorten_strings, path)
