self_writer <- function(head = FALSE) {
  
  if (head) {
    text <- paste0("# Pacotes ----\nlibrary(RSelenium)\nlibrary(tidyverse)\nlibrary(rvest)\nlibrary(lubridate)\nlibrary(googledrive)\nlibrary(readxl)\n\n",
                   "# WD ----\nsetwd(dirname(rstudioapi::getActiveDocumentContext()$path))\n\n# Funções ----\n")
  } else {
    text <- NULL
  }
  
  text <- paste0(
    text,
    "funs <- list.files('./func/geral', '.*\\\\.rds$', full.names = TRUE)", "\n",
    "names(funs) <- str_remove_all(funs, '.+/|\\\\.rds')", "\n\n"
  )
  
  funs <- list.files("./func/geral", ".*\\.rds$", full.names = TRUE)
  names(funs) <- str_remove_all(funs, ".+/|\\.rds")
  fun_names <- names(funs)
  
  call <- "fun <- list("
  buffer <- "            "
  middle <- " = readRDS(funs['"
  
  for (i in seq_along(fun_names)) {
    
    start <- ifelse(i == 1, call, buffer)
    
    end <- ifelse(i == length(fun_names), "']))\n\n", "']),\n")
    
    
    text <- paste0(text,
                   start, 
                   fun_names[i],
                   middle,
                   fun_names[i],
                   end)
  }
  text <- paste0(text, "\nrm(funs)")
  
  writeLines(text)
}

path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(self_writer, paste0(path, 'self_writer.rds'))
rm(self_writer, path)
