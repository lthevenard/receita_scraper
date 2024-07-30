click_complex <- function(
  css,
  element_position,
  position_x = 0,
  position_y = 0,
  driver = remDr,
  szz = fun$szz
) {
  webElements <- driver$findElements(using = "css selector", css)
  szz()
  driver$mouseMoveToLocation(position_x, position_y, webElements[[element_position]])
  szz()
  driver$click()
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(click_complex, paste0(path, 'click_complex.rds'))
rm(click_complex, path)
