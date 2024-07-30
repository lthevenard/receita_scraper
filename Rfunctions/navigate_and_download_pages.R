navigate_and_download_pages <- function(
  urls,
  time = c(8, 10),
  silent = FALSE,
  driver = remDr,
  szz = fun$szz,
  get_html = fun$get_html,
  which_list = fun$which_list,
  click = FALSE,
  click_time = c(2, 3),
  download_link_page = TRUE,
  click_method = c("webelements", "css"),
  click_css = NULL,
  click_webelements_positions = NULL,
  click_column_names = NULL
) {
  width <- length(urls)
  if (click) {
    if (!(click_method %in%  c("webelements", "css")) | is_empty(click_css) |  is_empty(click_column_names) | (click_method == "webelements" & is_empty(click_webelements_positions))) {
      warning("Inconsistent click method, ignoring clicks and downloading link-page only.\n")
      click <- FALSE
    } 
  }
  driver$closeall()
  driver$open(silent = TRUE)
  szz()
  
  if (!click) {
    list_of_pages <- vector('list', width)
    for (i in seq_along(urls)) {
      driver$navigate(urls[[i]])
      szz(time[1], time[2], ifelse(silent, "", paste("Downloading page", i, "of", width)))
      list_of_pages[[i]] <- get_html(driver)
    }
    return(list_of_pages)
  } else {
    if (download_link_page && click_method == "webelements") {
      click_webelements_positions <- c(0, click_webelements_positions)
    } else if (download_link_page) {
      click_css <- c("", click_css)
    }
    num_categories <- ifelse(click_method == "webelements",
                             length(click_webelements_positions),
                             length(click_css))
    
    list_of_pages <- vector('list', num_categories)
    for (j in seq_along(list_of_pages)) {
      list_of_pages[[j]] <- vector('list', width)
    }
    names(list_of_pages) <- click_column_names
    for (i in 1:width) {
      driver$navigate(urls[[i]])
      szz(time[1], time[2], ifelse(silent, "", paste("Downloading page", i, "of", width)))
      for (j in 1:num_categories) {
        if (download_link_page && j == 1) {
          list_of_pages[[j]][[i]] <- get_html(driver)
        } else if (click_method == "webelements") {
          element_position <- click_webelements_positions[[j]]
          szz()
          webElements <- driver$findElements(using = "css selector", click_css)
          szz()
          webElement <- webElements[[element_position]]
          szz()
          driver$mouseMoveToLocation(0, 0, webElement)
          szz()
          driver$click()
          szz(click_time[1], click_time[2], ifelse(silent, "", paste("Click:", click_column_names[[j]])))
          list_of_pages[[j]][[i]] <- get_html(driver)
        } else {
          element_css <- click_css[[j]]
          szz()
          webElement <- driver$findElement(using = "css selector", element_css)
          szz()
          driver$mouseMoveToLocation(0, 0, webElement)
          szz()
          driver$click()
          szz(click_time[1], click_time[2], ifelse(silent, "", paste("Click:", click_column_names[[j]])))
          list_of_pages[[j]][[i]] <- get_html(driver)
        }
      }
    }
    return(list_of_pages)
  }
}
path <- "/Users/lucasthevenard/Documents/prog/Rfunctions/"
saveRDS(navigate_and_download_pages, paste0(path, 'navigate_and_download_pages.rds'))
rm(navigate_and_download_pages, path)

