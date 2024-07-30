construir_ids <- function (codigo, tipo, comeco, tamanho, inverter = FALSE) {
  
  fim <- comeco + tamanho - 1
  
  if (inverter) {
    saida <- paste0(codigo, "_", tipo, "_", fim:comeco)
  } else {
    saida <- paste0(codigo, "_", tipo, "_", comeco:fim)
  }
  saida
}
saveRDS(construir_ids, "./func/geral/construir_ids.rds")
rm(construir_ids)
