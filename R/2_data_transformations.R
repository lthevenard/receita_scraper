library(tidyverse)
library(lubridate)

# Data Input ----

normas_select <- readRDS("data_output/select_database.rds")
relacional_df <- readRDS("data_output/relacional_df.rds")

# Functions ----

match_regex_cases <- function(texts, regex, name, lower_case = TRUE) {
  results <- NULL
  is_match <- vector('numeric', length(texts))
  for (i in seq_along(texts)) {
    if (is.na(texts[[i]])) {
      next()
    }
    if (lower_case) {
      text <- str_to_lower(texts[[i]])
    } else {
      text <- texts[[i]]
    }
    if (str_detect(text, regex)) {
      is_match[[i]] <- 1
    }
    results <- c(results, str_extract_all(text, regex) %>% unlist())
  }
  num_results <- sum(is_match)
  results <- results[!is.na(results)]
  unique_results <- unique(results)
  incidence <- vector('numeric', length(unique_results))
  for (i in seq_along(unique_results)) {
    incidence[[i]] <- sum(results == unique_results[[i]])
  }
  df <- tibble(
    imposto = name,
    `Expressão regular` = regex,
    `Documentos com ao menos 1 ocorrência` = num_results,
    `Casos encontrados` = unique_results,
    `Número total de ocorrências` = incidence
  ) %>% arrange(desc(`Número total de ocorrências`))
  return(df)
}

generate_incidence_table <- function(texts, patterns) {
  incidence_tables <- vector('list', length(patterns))
  for (i in seq_along(patterns)) {
    regex <- patterns[[i]]
    name <- names(patterns)[[i]]
    incidence_tables[[i]] <- match_regex_cases(texts, regex, name)
  }
  return(bind_rows(incidence_tables))
}

generate_tax_count <- function(normas_select, column_range) {
  taxes <- vector('character', length(column_range))
  counts <- vector('numeric', length(column_range))
  idx = 1
  for (i in column_range) {
    taxes[[idx]] <- str_to_upper(names(normas_select)[[i]]) %>% 
      str_replace("_", "/")
    counts[[idx]] <- normas_select[[i]] %>% sum(na.rm=TRUE)
    idx <- idx + 1
  }
  df <- tibble(tax = taxes, n = counts) %>% 
    filter(tax != "PIS" & tax != "PASEP")
  return(df)
}

generate_word_mean_per_year <- function(normas_select) {
  anos <- normas_select$data %>% 
    str_extract("\\d{4}") %>% 
    unique() %>% 
    sort()
  sum_palavras <- vector('numeric', length(anos))
  std_palavras <- vector('numeric', length(anos))
  mean_palavras <- vector('numeric', length(anos))
  median_palavras <- vector('numeric', length(anos))
  for (i in seq_along(anos)) {
    ano_palavras <- normas_select %>% 
      filter(str_extract(data, "\\d{4}") == anos[[i]]) %>% 
      .$palavras
    sum_palavras[[i]] <- sum(ano_palavras, na.rm=TRUE)
    std_palavras[[i]] <- sd(ano_palavras, na.rm=TRUE)
    mean_palavras[[i]] <- mean(ano_palavras, na.rm=TRUE)
    median_palavras[[i]] <- median(ano_palavras, na.rm=TRUE)
  }
  df <- tibble(
    ano = anos,
    sum = sum_palavras,
    std = std_palavras,
    mean = mean_palavras,
    median = median_palavras
  )
  return(df)
}

generate_content_analysis_table <- function(normas_select, pattern, name) {
  list_output <- normas_select$texto %>% 
    str_extract_all(pattern)
  tibble_output <- vector('list', length(list_output))
  for (i in seq_along(list_output)) {
    if (!is_empty(list_output[[i]])) {
      tibble_output[[i]] <- tibble(
        id = normas_select$id[[i]],
        type = name,
        extraction = list_output[[i]]
      )
    }
  }
  return(bind_rows(tibble_output))
}

iterate_content_analysis_tables <- function(normas_select, pattern_list) {
  tibble_list <- vector('list', length(pattern_list))
  for (i in seq_along(pattern_list)) {
    name <- names(pattern_list)[[i]]
    pattern <- pattern_list[[i]]
    tibble_list[[i]] <- generate_content_analysis_table(
      normas_select, pattern, name
    )
  }
  return(bind_rows(tibble_list))
}

generate_ca_table <- function(content_table, normas_select) {
  counts <- content_table %>% count(id, type)
  counts <- bind_cols(counts, ano = "")
  for (i in 1:nrow(counts)) {
    counts$ano[[i]] <- normas_select %>% 
      filter(id == counts$id[[i]]) %>% 
      .$data %>% 
      str_extract("\\d{4}")
  }
  return(
    counts %>% 
      group_by(ano, type) %>% 
      summarise(Documents = n(), 
                N = sum(n, na.rm=TRUE), 
                mean = mean(n, na.rm=TRUE), 
                median = median(n, na.rm=TRUE),
                std = sd(n, na.rm=TRUE))
  )
}

# Data transformations ----

impostos <- list(
  ii = "impostos?(\\s+\\S+){0,3}\\s+importa[cç]([aã]o|[õo]es)",
  irpf = "impostos?(\\s+\\S+){0,3}\\s+renda(\\s+\\S+){0,3}\\s+pessoas?\\s+f[íi]sicas?|\\birpf\\b",
  irpj = "impostos?(\\s+\\S+){0,3}\\s+renda(\\s+\\S+){0,3}\\s+pessoas?\\s+jur[íi]dicas?|\\birpj\\b",
  iof = "impostos?(\\s+\\S+){0,3}\\s+opera[cç]([aã]o|[õo]es)(\\s+\\S+){0,3}\\s+cr[ée]dito|\\biof\\b",
  ipi = "impostos?(\\s+\\S+){0,3}\\s+produtos?(\\s+\\S+){0,3}\\s+industrializados?|\\bipi\\b",
  cofins = "contribui[çc]([ãa]o|[õo]es)(\\s+\\S+){0,3}\\s+socia(l|is)(\\s+\\S+){0,3}\\s+financiamentos?(\\s+\\S+){0,3}\\s+seguridades?(\\s+\\S+){0,3}\\s+socia(l|is)|\\bcofins\\b",
  pis = "programas?(\\s+\\S+){0,3}\\s+integra[çc]([ãa]o|[õo]es)(\\s+\\S+){0,3}\\s+socia(l|is)|\\bpis\\b",
  pasep = "programas?(\\s+\\S+){0,3}\\s+forma[çc]([ãa]o|[õo]es)(\\s+\\S+){0,3}\\s+patrim[ôo]nios?(\\s+\\S+){0,3}\\s+servidor(es)?(\\s+\\S+){0,3}\\s+p[úu]blicos?|\\bpasep\\b",
  csll = "contribui[çc]([ãa]o|[õo]es)(\\s+\\S+){0,3}\\s+socia(l|is)(\\s+\\S+){0,3}\\s+lucros?(\\s+\\S+){0,3}\\s+l[íi]quidos?|\\bcsll\\b",
  inss = "contribui[çc]([ãa]o|[õo]es)(\\s+\\S+){0,3}(?<!excetuadas\\sas)\\s+previd[êe]nci[áa]rias?|\\binss\\b"
)

content_analysis <- list(
  dever = "(\\S+\\s+){0,6}(\\bdeve|\\bobriga|\\brespons|arcar|[ôo]nus)\\S*(\\s+\\S+){0,6}",
  pena = "(\\S+\\s+){0,6}(\\bpena|\\bmulta|\\bsanç|\\binfraç|\\bautua[çd])\\S*(\\s+\\S+){0,6}",
  prazo = "(\\S+\\s+){0,6}(\\bprazo|\\bdia(..)?\\s*([úu]teis|[úu]til|corridos?)?|\\bprorroga|d[ea]\\s+ci[êe]ncia)\\S*(\\s+\\S+){0,6}"
)

normas_select <- normas_select %>% 
  mutate(ii = str_detect(str_to_lower(texto), impostos$ii),
         irpf = str_detect(str_to_lower(texto), impostos$irpf),
         irpj = str_detect(str_to_lower(texto), impostos$irpj),
         iof = str_detect(str_to_lower(texto), impostos$iof),
         ipi = str_detect(str_to_lower(texto), impostos$ipi),
         cofins = str_detect(str_to_lower(texto), impostos$cofins),
         pis = str_detect(str_to_lower(texto), impostos$pis),
         pasep = str_detect(str_to_lower(texto), impostos$pasep),
         pis_pasep = pis | pasep,
         csll = str_detect(str_to_lower(texto), impostos$csll),
         inss = str_detect(str_to_lower(texto), impostos$inss))


normas_select <- normas_select %>% 
  mutate(palavras = str_count(texto, "\\w+"))

mod_relacional <- normas_select %>% 
  left_join(relacional_df, by="id") %>% 
  filter(!is.na(modificaram)) %>% 
  mutate(ano = as.integer(str_extract(data, "\\d{4}"))) %>%
  filter(ano >= 1995 & ano != 2024) %>% 
  group_by(ano) %>% 
  summarise(mod_ativa = log10(sum(modificaram)),
            mod_passiva = log10(sum(modificados)),
            interacoes_total = log10(sum(modificaram + modificados)),
            media_mod_ativa = mean(modificaram),
            media_mod_passiva = mean(modificados))

incidence_table <- generate_incidence_table(normas_select$texto, impostos)

tax_counts <- generate_tax_count(normas_select, 14:24)

word_mean_per_year <- normas_select %>%
  generate_word_mean_per_year()

content_table <- iterate_content_analysis_tables(
  normas_select, content_analysis
)

ca_table <- generate_ca_table(content_table, normas_select)

# Data Output ----

saveRDS(mod_relacional, "data_output/mod_relacional.rds")
write_csv(mod_relacional, "data_output/mod_relacional.csv")
saveRDS(ca_table, "data_output/ca_table.rds")
write_csv(ca_table, "data_output/ca_table.csv")
saveRDS(content_table, "data_output/content_table.rds")
write_csv(content_table, "data_output/content_table.csv")
saveRDS(word_mean_per_year, "data_output/word_mean_per_year.rds")
write_csv(word_mean_per_year, "data_output/word_mean_per_year.csv")
saveRDS(tax_counts, "data_output/tax_counts.rds")
write_csv(tax_counts, "data_output/tax_counts.csv")
saveRDS(incidence_table, "data_output/incidencia_impostos.rds")
write_csv(incidence_table, "data_output/incidencia_impostos.csv")
write_csv(normas_select, "data_output/select_database.csv")
saveRDS(normas_select, "data_output/select_database.rds")
