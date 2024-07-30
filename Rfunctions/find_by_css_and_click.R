find_by_css_and_click <- function(
  selector,
  index = 0,
  driver = remDr,
  szz = fun$szz) {
  if (index == 0) {
    webElement <- driver$findElement(using = "css selector", selector)
    driver$mouseMoveToLocation(0, 0, webElement)
    driver$click()
    szz(0.5, 1)
  } else {
    wes <- driver$findElements(using = "css selector", selector)
    driver$mouseMoveToLocation(0, 0, wes[[index]])
    driver$click()
    szz(0.5, 1)
  }
  
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(find_by_css_and_click, paste0(path, 'find_by_css_and_click.rds'))
rm(find_by_css_and_click, path)
