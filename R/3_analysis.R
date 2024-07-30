library(tidyverse)
library(scales)
library(DescTools)
library(lubridate)

# Data ----

normas_select <- readRDS("data_output/select_database.rds")
word_mean_per_year <- readRDS("data_output/word_mean_per_year.rds")
ca_table <- readRDS("data_output/ca_table.rds")
mod_relacional <- readRDS("data_output/mod_relacional.rds")

# Functions ----

save_plot <- function(filename, path = "./plots", height= 6, width= 10, ...) {
  ggsave(filename=filename, height= height, width= width, path = path, ...)
}

plot_content_analysis <- function(content_table, chosen_type, title) {
  content_table %>% 
    filter(type == chosen_type) %>% 
    count(id) %>% 
    right_join(normas_select) %>% 
    mutate(ano = str_extract(data, "\\d{4}")) %>% 
    filter(ano != "2024") %>% 
    mutate(n = ifelse(is.na(n), 0, n)) %>% 
    group_by(ano) %>% 
    summarise(`Incidência total` = sum(n, na.rm = TRUE), `Médias anuais` = mean(n, na.rm = TRUE)) %>% 
    mutate(ano = as.integer(ano)) %>% 
    pivot_longer(cols = c(`Incidência total`, `Médias anuais`)) %>% 
    ggplot(aes(x= ano, y = value, group = "")) +
    geom_point() +
    labs(title = title,
         subtitle = subtitle,
         x = "", y = "") +
    geom_smooth(method = "lm", color = brewer_pal()(7)[5], size = 0.5, linetype = "dashed", se = FALSE) +
    facet_wrap(~name, scales = "free_y")
}

# Analysis ----

subtitle <- c("FONTE: Portal da Receita Federal (1988-2023)", 
              "FONTE: Portal da Receita Federal (1988-2024)",
              "FONTE: Portal da Receita Federal (1995-2023)")

content_plots_info <- list(
  dever = c("dever", 
            "Incidência de termos relacionados ao estabelecimento de deveres / obrigações"),
  pena = c("pena", 
           "Incidência de termos relacionados à imposição de multas e penalidades"),
  prazo = c("prazo", 
            "Incidência de termos relacionados à criação ou alteração de prazos")
)

theme_set(theme_bw() + theme(legend.position = "bottom"))

## 1. Tipologia ----

normas_select %>% 
  ggplot(aes(x = fct_rev(fct_infreq(tipo)))) +
  geom_bar(fill = brewer_pal()(7)[5]) +
  labs(title = "Tipologia das Normas da Receita Federal",
       subtitle = subtitle[1],
       x = "", y = "Número de Normas") +
  coord_flip()

save_plot("1_tipologia.png")

## 2. Evolução ----

normas_select %>% 
  mutate(ano = str_extract(data, "\\d{4}")) %>% 
  filter(ano != "2024") %>% 
  ggplot(aes(x = ano)) +
  geom_bar(fill = brewer_pal()(7)[5]) +
  labs(title = "Evolução da produção normativa da Receita Federal",
       subtitle = subtitle[1],
       x = "", y = "Número de Atos Normativos") +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))

save_plot("2_evolucao.png")

## 3. Evolução do Tamanho Médio ----

word_mean_per_year %>% 
  ggplot(aes(x=ano, y=mean, group="")) +
  geom_point(color=brewer_pal()(7)[5]) +
  geom_line(color=brewer_pal()(7)[5]) +
  geom_smooth(method = "lm", color = "darkgray", size = 0.5, linetype = "dashed", se = FALSE) +
  labs(x = "", y = "Número Médio de Palavras por Ato Normativo",
       title = "Extensão média dos atos normativos da Receita Federal ao longo do tempo",
       subtitle = subtitle[2]) +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))

save_plot("3_tamanho_medio_evolucao.png")

## 4. Analise de conteudo ----

ca_table %>% 
  mutate(class = ifelse(
    type == "dever", "Deveres e Obrigações", ifelse(
      type == "pena", "Multas e Penalidades", "Prazos Legais"
    )),
    ano = as.integer(ano)
  ) %>% 
  filter(ano != 2024) %>% 
  ggplot(aes(x = ano, y = N)) +
  geom_point() +
  geom_smooth(method = "lm", color = brewer_pal()(7)[5], size = 0.5, linetype = "dashed", se = FALSE) +
  labs(title = "Incidência de termos relacionados a obrigações, penalidades e prazos",
       y = "Incidência Total", x = "", subtitle = subtitle) +
  facet_wrap(~class)

save_plot("4a_analise_de_conteudo_geral.png")

plot_content_analysis(content_table, 
                      content_plots_info[[1]][1],
                      content_plots_info[[1]][2])

save_plot("4b_analise_de_conteudo_dever.png", height=5)

plot_content_analysis(content_table, 
                      content_plots_info[[2]][1],
                      content_plots_info[[2]][2])

save_plot("4c_analise_de_conteudo_pena.png", height=5)

plot_content_analysis(content_table, 
                      content_plots_info[[3]][1],
                      content_plots_info[[3]][2])

save_plot("4d_analise_de_conteudo_prazo.png", height=5)

## 5 Dados Relacionais ----

normas_select %>% 
  mutate(relacional = ifelse(tem_relacional, "Sim", "Não"),
         ano = str_extract(data, "\\d{4}")) %>%
  filter(ano != "2024") %>%
  ggplot(aes(x = ano, fill = relacional)) +
  geom_bar(position =  "fill") +
  scale_y_continuous(labels = label_percent()) +
  scale_fill_brewer() +
  labs(y = "Percentual dos Atos Normativos do Ano",
       x = "", fill = "Possui informações relacionais? ",
       title = "Disponibilidade de dados relacionais sobre os atos normativos",
       subtitle = subtitle) +
  theme(axis.text.x = element_text(angle = 90, hjust = 0.5, vjust = 0.5))

save_plot("5a_relacional_disponibilidade.png")

mod_relacional  %>% 
  pivot_longer(cols = c(mod_ativa, mod_passiva, interacoes_total)) %>% 
  mutate(name = str_replace(name,
                            "interacoes_total",
                            "Score de Interações") %>% 
           str_replace("mod_ativa", "Score de Modificações Ativas") %>% 
           str_replace("mod_passiva", "Score de Modificações Passivas")) %>% 
  ggplot(aes(x = ano, y = value, group = name, color = name)) +
  geom_line() +
  geom_point() +
  scale_color_manual(values = brewer_pal(direction=-1)(7)[c(1, 3, 6)]) +
  labs(color = "Dados Relacionais ",
       y = "Score de Interação",
       x = "", title = "Evolução das interações entre as normas da Receita Federal",
       subtitle = subtitle[3])

save_plot("5b_modificacoes_relacionais.png")
