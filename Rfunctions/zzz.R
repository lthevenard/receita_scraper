zzz <- function (from = 5, to = 10) {
  tictoc <- runif(1, from, to)
  round_tictoc <- round(tictoc, 1)
  paste0("\n\n[zzz...] Sleeping for ", round_tictoc, " secs") %>%
    cat()
  Sys.sleep(tictoc)
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(zzz, paste0(path, 'zzz.rds'))
rm(zzz, path)
