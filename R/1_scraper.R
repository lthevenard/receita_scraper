library(RSelenium)
library(tidyverse)
library(scales)
library(rvest)
library(httr)
library(lubridate)

# Initial variables ----

base_url <- "http://normas.receita.fazenda.gov.br/sijut2consulta/consulta.action?facetsExistentes=&orgaosSelecionados=&tiposAtosSelecionados=&lblTiposAtosSelecionados=&ordemColuna=&ordemDirecao=&tipoConsulta=formulario&tipoAtoFacet=&siglaOrgaoFacet=&anoAtoFacet=&termoBusca=&numero_ato=&tipoData=2&dt_inicio=&dt_fim=&ano_ato=1999&optOrdem=Publicacao_DESC"

years <- 1988:2024

remDr <- remoteDriver(port = 4445L, browser = "chrome")

css <- list(
  tipo = ".linhaResultados td:nth-child(1)",
  num = ".linhaResultados td:nth-child(2)",
  orgao = ".linhaResultados td:nth-child(3)",
  data = ".linhaResultados td:nth-child(4)",
  ementa = ".linhaResultados td:nth-child(5)",
  regs = ".total-regs-encontrados",
  proxima_pag = "#tabelaAtos #btnProximaPagina2",
  titulo = ".tituloAto",
  pub = ".tituloPublicacao",
  texto = "#divTexto",
  assinatura = ".fecho",
  href_conteudo = "#divConteudo a",
  espaco_modificados = ".novos",
  espaco_modificaram = ".antigos",
  espaco_este_ato = ".atual",
  ato_nunca_alterado = ".ana",
  ato_nao_vigente = ".anv",
  ato_ja_alterado = ".aja"
)

# Functions ----

fun <- list.files('Rfunctions', '\\.rds$', full.names = TRUE) %>%
  lapply(readRDS)
names(fun) <- list.files('Rfunctions', '\\.rds$') %>%
  str_remove("\\.rds$")

extract_using_css <- function(page, css) {
  vector <- page %>%
    html_nodes(css) %>%
    html_text() %>%
    str_squish()
  return(vector)
}

test_css <- function(page, css) {
  test <- page %>%
    html_nodes(css) %>%
    html_text() %>%
    is_empty()
  return(test)
}

extract_links <- function(page, css) {
  vector <- page %>%
    html_nodes(css) %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    str_squish() %>%
    fun$invert_paste("http://normas.receita.fazenda.gov.br/sijut2consulta/")
  return(vector)
}

change_year <- function(year, url=base_url) {
  new_url <- base_url %>% 
    str_replace("ano_ato=\\d\\d\\d\\d", paste0("ano_ato=", year))
  return(new_url)
}

calc_page_results <- function(page) {
  regs <- extract_using_css(page, css$regs)
  items <- str_extract(regs, "\\d+") %>%
    as.numeric()
  pages <- ceiling(items / 100)
  results <- c(items, pages)
  return(results)
}

iterate_results <- function(year, tryagain = FALSE) {
  page <- fun$get_html(remDr)
  num_results <- calc_page_results(page)
  
  page_list <- list()
  
  page_list[[1]] <- list(
    year = year,
    results = num_results[[1]]
  )
  page_list[[2]] <- vector('list', num_results[[2]])
  page_list[[2]][[1]] <- page
  if (num_results[[2]] > 1) {
    for (j in 2:num_results[[2]]) {
      error <- try(fun$find_by_css_and_click(selector = css$proxima_pag))
      if (tryagain & typeof(error) == "character") {
        break()
      }
      fun$szz(8, 10, paste0("Downloading sub_page ", j))
      page_list[[2]][[j]] <- fun$get_html(remDr)
    }
  }
  return(page_list)
}

scrape_receita <- function(base_url, years) {
  page_list <- vector('list', length(years))
  for (i in seq_along(years)) {
    url <- change_year(years[[i]])
    remDr$navigate(url)
    fun$szz(8, 10, paste0("Accessing data from master page ", i, ", year: ", years[[i]], "\nDownloading sub_page 1"))
    page_list[[i]] <- iterate_results(years[[i]])
  }
  return(page_list)
}

extract_data <- function() {
  
  character_vector <- vector("character", num_pages)
  variables <- list(
    tipo = character_vector,
    num = character_vector,
    orgao = character_vector,
    data = character_vector,
    ementa = character_vector
  )
}

extract_table_data <- function(page_list) {
  norms <- list(
    year = vector('character', length(years)),
    total = vector('numeric', length(years)),
    year_table = vector('list', length(years))
  )
  for (i in seq_along(page_list)) {
    year_list <- page_list[[i]]
    norms$year[[i]] <- year_list[[1]]$year
    results <- year_list[[1]]$results
    norms$total[[i]] <- results
    pages <- year_list[[2]]
    year_table <- tibble()
    for (j in seq_along(pages)) {
      page <- pages[[j]]
      tipo <- page %>%
        extract_using_css(css$tipo)
      num <- page %>%
        extract_using_css(css$num)
      orgao <- page %>%
        extract_using_css(css$orgao)
      data <- page %>%
        extract_using_css(css$data)
      ementa <- page %>%
        extract_using_css(css$ementa)
      link <- page %>%
        extract_links(css$tipo)
      add_lines <- tibble(
        tipo = tipo,
        num = num,
        orgao = orgao,
        data = data,
        ementa = ementa,
        link = link
      )
      year_table <- bind_rows(
        year_table, add_lines
      )
    }
    norms$year_table[[i]] <- year_table
  }
  return(norms)
}

generate_relational_link <- function(link) {
  base_url <- "http://normas.receita.fazenda.gov.br/sijut2consulta/link.action?naoPublicado=&idAto=39251&visao=relacional"
  id_ato <- link %>%
    str_extract("Ato=\\d+")
  url <- base_url %>%
    str_replace("Ato=\\d+", id_ato)
  return(url)
}

empty_relational <- function(page) {
  page %>%
    html_nodes(".atual") %>%
    is_empty()
}

count_acts_by_css <- function(page, section_css) {
  page %>%
    html_nodes(section_css) %>%
    html_nodes("div") %>%
    html_attr("class") %>%
    .[!is.na(.)] %>%
    .[str_detect(., "^ato ")] %>%
    length()
}

classify_this_act <- function(page, act_css=css$espaco_este_ato) {
  page %>%
    html_nodes(act_css) %>%
    html_nodes("div") %>%
    html_attr("class") %>%
    .[!is.na(.)] %>%
    .[str_detect(., "^ato ")] %>%
    str_remove("^ato") %>%
    trimws() %>%
    paste(collapse="; ")
}

read_html_counting <- function(url, i) {
  cat("Downloading page nº", i, "...\n")
  read_html(url)
}

possibly_slowly_read_html_counting <- read_html_counting %>% 
  possibly(otherwise = NULL) %>% 
  slowly(rate = rate_delay(6))

insistently_read_html <- read_html_counting %>% 
  insistently(rate = rate_backoff(max_times = 10))

# Execution ----

remDr$open(silent=TRUE)

## General data ----

page_list <- vector('list', length(years))

for (i in seq_along(years)) {
  year <- years[[i]]
  if (!(year %in%  missing_years)) {
    next()
  }
  url <- change_year(year)
  remDr$navigate(url)
  fun$szz(10, 12, paste0("Accessing data from master page ", i, ", year: ", year, "\nDownloading sub_page 1"))
  page_list[[i]] <- try(iterate_results(year, tryagain = TRUE))
}

remDr$closeall()

table_data <- extract_table_data(page_list)

totais <- tibble(
  year = table_data$year,
  total = table_data$total
)

write_csv(totais, "data_output/totais.csv")

normas <- bind_rows(table_data$year_table)

normas <- normas %>%
  mutate(id = row_number(),
         idReceita = str_extract(link, "(?<=idAto=)\\d+")) %>%
  relocate(idReceita, .before = tipo) %>% 
  relocate(id, .before = idReceita)

write_csv(normas, "data_output/normas_receita.csv")
saveRDS(normas, "data_output/normas_receita.rds")

for (i in seq_along(page_list)) {
  year <- page_list[[i]][[1]]$year
  pages <- page_list[[i]][[2]]
  for (j in seq_along(pages)) {
    xml2::write_html(
      pages[[j]],
      paste0("./data_output/pages/norm_pages/", i, "_", year, "_", j, ".html")
    )
  }
}

## Internal Pages ----

normas_select <- normas %>%
  filter(str_detect(str_to_lower(tipo), "portaria|\\bnorma|resolução"))

internal_pages <- imap(
  normas_select$link,
  possibly_slowly_read_html_counting
)

while (sum(map_lgl(internal_pages, is.null)) > 0) {
  for (i in seq_along(internal_pages)) {
    if (is.null(internal_pages[[i]])) {
      internal_pages[[i]] <- insistently_read_html(normas_select$link[[i]], i)
    }
  }
}

scope <- nrow(normas_select)

normas_select <- normas_select %>%
  mutate(titulo = vector('character', scope),
         dou = vector('character', scope),
         assinatura = vector('character', scope),
         texto = vector('character', scope))

for (i in seq_along(internal_pages)) {
  print(i)
  page <- internal_pages[[i]]
  if (test_css(page, css$titulo)) {
    normas_select$titulo[[i]] <- NA
  } else {
    normas_select$titulo[[i]] <- page %>%
      extract_using_css(css$titulo) %>%
      paste(collapse = "\n")
  }
  if (test_css(page, css$pub)) {
    normas_select$dou[[i]] <- NA
  } else {
    normas_select$dou[[i]] <- page %>%
      extract_using_css(css$pub) %>%
      paste(collapse = "\n")
  }
  if (test_css(page, css$assinatura)) {
    normas_select$assinatura[[i]] <- NA
  } else {
    normas_select$assinatura[[i]] <- page %>%
      extract_using_css(css$assinatura) %>%
      paste(collapse = "\n")
  }
  if (test_css(page, css$texto)) {
    normas_select$texto[[i]] <- NA
  } else {
    normas_select$texto[[i]] <- page %>%
      extract_using_css(css$texto)%>%
      paste(collapse = "\n")
  }
}

glimpse(normas_select)

saveRDS(normas_select, "data_output/select_database.rds")

## Relational pages ----

tem_relacional <- vector('logical', length(internal_pages))

for (i in seq_along(internal_pages)) {
  page <- internal_pages[[i]]
  tem_relacional[[i]] <- page %>%
    html_nodes(css$href_conteudo) %>%
    html_text() %>%
    paste(collapse="\n") %>%
    str_squish() %>%
    str_detect("[Rr]elacional")
}

normas_select <- normas_select %>% 
  mutate(tem_relacional = tem_relacional,
         link_relacional = map_chr(link, generate_relational_link))

saveRDS(normas_select, "data_output/select_database.rds")

normas_select_relacional <- normas_select %>% 
  filter(tem_relacional) %>% 
  select(id, idReceita, link_relacional)

relacional_pages <- imap(
  normas_select_relacional$link_relacional,
  possibly_slowly_read_html_counting
)

while (sum(map_lgl(relacional_pages, is.null)) > 0) {
  for (i in seq_along(relacional_pages)) {
    if (is.null(relacional_pages[[i]])) {
      relacional_pages[[i]] <- insistently_read_html(
        normas_select_relacional$link_relacional[[i]],
        i
      )
    }
  }
}

normas_select_relacional <- normas_select_relacional %>% 
  mutate(page_relacional = relacional_pages,
         relational_table = vector("list", nrow(normas_select_relacional)))

for (i in seq_along(normas_select_relacional$page_relacional)) {
  id <- normas_select_relacional$id[[i]]
  page <- relacional_pages[[i]]
  modificaram <- count_acts_by_css(page, css$espaco_modificaram)
  modificados <- count_acts_by_css(page, css$espaco_modificados)
  classificacao <- classify_this_act(page)
  normas_select_relacional$relational_table[[i]] <- tibble(
    id = id,
    modificaram = modificaram,
    modificados = modificados,
    classificacao = classificacao
  )
}

relacional_df <- bind_rows(normas_select_relacional$relational_table)

alter_date_tibble <- vector('list', length(relacional_pages))

for (i in seq_along(normas_select_relacional$page_relacional)) {
  id <- normas_select_relacional$id[[i]]
  page <- relacional_pages[[i]]
  alter_date <- page %>%
    html_nodes(css$espaco_modificaram) %>%
    html_text() %>%
    str_squish() %>%
    paste(collapse = " ") %>%
    str_extract("\\d{2}/\\d{2}/\\d{4}")
  alter_date_tibble[[i]] <- tibble(
    id = id,
    alter_date = alter_date
  )
}

alter_date_tibble <- bind_rows(alter_date_tibble)

relacional_df <- relacional_df %>%
  left_join(alter_date_tibble, by="id")

saveRDS(relacional_df, "data_output/relacional_df.rds")


# Save final results ----

for (i in seq_along(internal_pages)) {
  id <- normas_select$id[[i]]
  idReceita <- normas_select$idReceita[[i]]
  page <- internal_pages[[i]]
  xml2::write_html(
    page,
    paste0("./data_output/pages/internal_pages/id-", id, "_idReceita-", idReceita, ".html")
  )
}


for (i in seq_along(normas_select_relacional$page_relacional)) {
  id <- normas_select_relacional$id[[i]]
  idReceita <- normas_select_relacional$idReceita[[i]]
  page <- normas_select_relacional$page_relacional[[i]]
  xml2::write_html(
    page,
    paste0("./data_output/pages/relacional_pages/id-", id, "_idReceita-", idReceita, ".html")
  )
}

normas_select_complete <- normas_select %>% 
  left_join(relacional_df, by = "id")

saveRDS(normas_select_complete, "data_output/select_database_complete.rds")