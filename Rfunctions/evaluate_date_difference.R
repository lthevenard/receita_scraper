evaluate_date_difference <- function(dates, FUN = mean, remove_NA = TRUE) {
  width <- length(dates)
  if (width < 2) {
    warning("Only 2 dates, returning NA.")
    return(NA)
  }
  dates <- dates %>%
    as.integer() %>%
    sort()
  
  time_diffs <- vector("integer", width - 1)
  
  for (i in 2:width) {
    time_diffs[i-1] <- dates[i] - dates[i-1]
  }
  
  FUN(time_diffs, na.rm = remove_NA)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(evaluate_date_difference, paste0(path, 'evaluate_date_difference.rds'))
rm(evaluate_date_difference, path)



