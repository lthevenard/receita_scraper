click <- function(
  css,
  position_x = 0,
  position_y = 0,
  driver = remDr,
  szz = fun$szz
) {
  webElement <- driver$findElement(using = "css selector", css)
  szz()
  driver$mouseMoveToLocation(position_x, position_y, webElement)
  szz()
  driver$click()
}

path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(click, paste0(path, 'click.rds'))
rm(click, path)
