szz <- function (from = 0.5, to = 1, message = "") {
  tictoc <- runif(1, from, to)
  if (message[1] != "") {
    round_tictoc <- round(tictoc, 1)
    paste0(paste(message, collapse = " "), " [zzz... ", round_tictoc, "s]\n") %>%
      cat()
  }
  Sys.sleep(tictoc)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(szz, paste0(path, 'szz.rds'))
rm(szz, path)
