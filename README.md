# A evolução da produção normativa da Receita Federal do Brasil: análise empírica e implicações regulatórias

Este respositório reúne códigos, na linguagem de programação R, que foram utilizados em um projeto de pesquisas empíricas quantitativas acerca da produção normativa da Receita Federal do Brasil (RFB). Este projeto envolveu o desenvolvimento de um webscraper para coletar, no portal mantido pela RFB, informações sobre atos normativos publicados desde 1988 (ano da promulgação da nossa atual Constituição Federal). Além de levantar o conjunto completo de atos disponibilizados pela RFB em seu portal nesse período, para um subconjunto desses atos – que seriam os propriamente 'normativos' – o raspador também coleta os textos integrais e informações sobre interações entre os atos. Por fim, o repositório reúne também códigos utilizados transformar os dados levantados e produzir as análises gráficas e tabulares utilizadas na pesquisa.

## Importância da pesquisa

Como dito, os códigos armazenados neste repositório são utilizados em um projeto de pesquisas empíricas quantitativas acerca da produção normativa da Receita Federal do Brasil (RFB), desde a promulgação da Constituição Federal, em 1988. Essa pesquisa já deu origem a uma [publicação acadêmica](https://www.scielo.br/j/rdgv/a/fq5sqBqSVYMMzdSJxgdGBts/) cujo objetivo foi trazer para o debate público brasileiro um tema que, apesar de ser de grande importância para o desenvolvimento econômico do país, ainda não foi objeto de investigações científicas sistemáticas.

Com efeito, a crescente complexidade da Administração fiscal em nível federal é fato notório entre os profissionais que lidam cotidianamente com o Direito Tributário. Além disso, o impacto crescente das normas regulamentares editadas pela RFB também já é amplamente reconhecido pelos tributaristas. No entanto, não existe hoje na academia brasileira uma agenda de pesquisa empírica quantitativa voltada para o estudo contínuo da produção normativa da RFB. O trabalho aqui apresentado é uma primeira tentativa de endereçar esta lacuna, propondo uma metodologia de mensuração da evolução dos atos normativos da RFB, incluindo o tamanho dessa produção normativa, as interações entre os atos normativos e os efeitos desses atos normativos sobre obrigações, penalidades e prazos legais (fatores que podem afetar diretamente os contribuintes).

Os resultados obtidos mostram, como esperado, que a produção normativa da RFB está crescendo e se tornando cada vez mais complexa. Não apenas a RFB edita um número crescente de atos normativos a cada ano, mas seus atos estão se tornando mais longos. Há também um crescente volume de interações entre os atos, ou seja, os atos editados com frequência e celeridade crescentes modificam ou são modificados por outros atos. Por fim, foi possível também constatar, utilizando técnicas simples de Processamento Natural de Linguagem (NLP), que o número de dispositivos legais que dispõem sobre penalidades, obrigações e prazos legais está aumentando.

Todos esses fatores apontam para uma atividade normativa com impacto crescente sobre os contribuintes e sobre a sociedade como um todo. No entanto, a pesquisa aqui realizada ainda pode ser, em muitos aspectos, aperfeiçoada, de forma a aprimorar a compreensão da academia acerca da produção normativa da RFB. Com o surgimento dos grandes modelos de linguagem, as técnicas de análise textual disponíveis a estudos como este estão em pleno processo de expansão. Esperamos com este trabalho apenas dar um 'pontapé inicial', contribuindo para um campo que consideramos promissor, com a expectativa de suscitar debates e críticas construtivas sobre este tema.

### Dashboard com os resultados

Além de ter gerado uma publicação acadêmica, a pesquisa também teve seus resultados divulgados em um Shiny Dashboard, que possui um [respositório próprio](https://github.com/lthevenard/dashboard_prod_normativa_da_receita).

## O que você encontra neste repositório

O código do repositório é formado por três scripts principais, salvos na pasta `R/`, entitulados: `1_scraper.R`, `2_data_transformations.R` e `3_analysis.R`.

### Raspagem dos dados

O código do webscraper está no script `1_scraper.R`. Esse script utiliza-se também de algumas funções utilitárias salvas na pasta `Rfunctions/`. O processo de raspagem de dados foi dividido em 3 etapas, descritas a seguir.

#### 1ª Etapa – Dados gerais de todos os atos editados no período

A primeira etapa da raspagem consiste na identificação de todos os atos cujas informações foram disponibilizadas no [Portal de Atos Normativos da RFB](http://normas.receita.fazenda.gov.br/sijut2consulta/consulta.action), em um intervalo de anos pré-determinado. Para tanto, o código gera um link distinto para cada ano (o intervalo de anos é definido pela variável `years`, no início do script). Como as páginas de resultados no portal da RFB são dinâmicas, utilizou-se a biblioteca `RSelenium` para navegar e salvar os códigos fontes das páginas de resultados de cada ano. As tabelas do portal exibem as informações de 100 resultados por página. A partir dessas páginas, foram extraídos os dados que compõem a DataFrame `normas`, salva em `/data_ouput/normas_receita.rds`. 

#### 2ª Etapa – extos dos atos normativos

Após a etapa inicial de mapeamento dos atos divulgados no portal da RFB no período, uma segunda etapa de raspagem consistiu em acessar os links obtidos na etapa anterior para baixar o código fonte de todas as páginas que possuem os textos integrais dos atos normativos. Nessa etapa de raspagem não foi necessário utilizar a biblioteca `RSelenium`, pois as páginas com os textos não são dinâmicas, tendo sido possível baixá-las utilizando requisições simples por meio das bibliotecas `httr` e `rvest`. Cabe destacar que, para economia de recursos, o raspador foi desenvolvido para baixar apenas os textos dos atos considerados efetivamente 'normativos'. Essa seleção é feita a partir da coluna `tipo` da DataFrame `normas`, ou seja, apenas foram baixados os atos de alguns tipos identificados como potencialmente normativos[^1]. Essa seleção gera então uma segunda DataFrame, a variável `normas_select`, salva em `/data_ouput/normas_receita.rds`. Essa DataFrame possui, além de todas as colunas da DataFrame `normas`, algumas informações adicionais, incluindo o texto integral dos atos normativos. 

#### 3ª Etapa – Informações relacionais de parte dos atos normativos

Para a maioria dos atos selecionados na etapa de raspagem anterior, o portal da RFB oferece também o que podemos chamar de "dados relacionais", ou seja, informações sobre as relações estabelecidas entre os atos. Essas páginas indicam quais outros atos modificam um determinado ato normativo ou são por ele modificados. A última etapa da raspagem de dados consistiu, portanto, em acessar e baixar o código fonte das páginas que disponibilizam dados relacionais para, em seguida, extraí-las para uma nova DataFrame. Trata-se da variável `relacional_df`, salva em `data_output/relacional_df.rds`. Novamente, para acessar e baixar esses dados não foi necessário recorrer à biblioteca `RSelenium`, tendo-se utilizado apenas as bibliotecas `httr` e `rvest`.

### Transformações dos dados e análises gráficas

O raspador descrito no item anterior extrai um amplo conjunto de informações sobre os atos normativos editados pela RFB em um intervalo de anos definido. Em uma etapa seguinte da pesquisa, essas informações foram desenvolvidos códigos para processar e extrair novas informações dos dados disponíveis, principalmente do texto dos atos, para ao fim possibilitar as análises e gráficos que foram publicados na pesquisa. 

As transformações dos dados foram realizadas por meio do script `2_data_transformations.R`. Dentre elas, três em particular se destacam. partindo do texto integral dos atos na DataFrame `normas_select`, foi possível (1) identificar menções a tributos específicos e (2) identificar disposições que tratam de obrigações, penalidades e prazos nos atos normativos. Além disso, com base nos dados relacionais disponíveis na DataFrame `relacional_df` foi feita a (3) a contagem de interações entre os atos e criação de scores anuais de modificações.

#### 1. Identificação menções a tributos específicos

Utilizando expressões regulares simples, foram identificadas menções, nos atos normativos, aos seguintes tributos federais: Contribuição para o Financiamento da Seguridade Social (Cofins), Contribuição Social sobre Lucro Líquido (CSLL), Imposto de Importação (II), Imposto sobre Operações de Crédito (IOF), Imposto sobre Produtos Industrializados (IPI), Imposto de Renda de Pessoa Física (IRPF), Imposto de Renda de Pessoa Jurídica (IRPJ), Programa de Integração Social (PIS), Programa de Formação do Patrimônio do Servidor Público (Pasep), assim como as contribuições previdenciárias ao Instituto Nacional do Seguro Social (INSS). Os padrões em regex utilizados podem ser verificados na lista `impostos` do script `2_data_transformations.R`. As informações referentes às menções a impostos foram incluídas como colunas da DataFrame `normas_select`, conforme será identificado a seguir.

#### 2. Identificação de disposições que tratam de deveres ou obrigações, de multas ou penalidades e de prazos

Novamente foram utilizadas expressões regulares simples para identificar citações a temas sensíveis, de interesse para esta pesquisa por se tratarem de disposições que podem gerar impactos diretos sobre os contribuintes. Essas áreas incluiram disposições que tratam de deveres ou obrigações, de multas ou penalidades e de prazos. Essas três dimensões foram escolhidas, também, por estarem associadas a campos semânticos bem determinados. Para a análise de normas referentes às obrigações acessórias, foram utilizadas variações dos termos: “dever”, “obrigação”, “responsabilidade”, “arcar” e “ônus”. Para a análise de normas relacionadas a multas e penalidades, foram usadas variações dos termos “multa”, “pena”, “sanção”, “infração” e “autuação”. Por fim, para a análise de normas relativas a prazo legais, foram utilizadas variações dos termos: “prazo”, “dias (úteis/corridos)”, “prorrogação” e “de/da ciência”. Todas as expressões regulares criadas a partir desses termos incluíram a captura de até seis termos adjacentes, de forma a impedir problemas de múltipla contagem. Os padrões em regex utilizados podem ser verificados na lista `content_analysis` do script `2_data_transformations.R`. As informações a respeito de disposições que tratam de deveres, penalidades e prazos deram origem à DataFrame `ca_table`, salva em `data_output/ca_table.rds`.

#### 3. Contagem de interações entre os atos e criação de scores anuais de modificações

Os dados relacionais presentes na DataFrame `relacional_df` permitiram a contagem anual de interações entre os atos normativos e a construção de escores de modificações (ativas, passivas e totais) para cada ano da série histórica, além das médias de modificações ativas e passivas identificadas ano a ano. Essas informações foram consolidadas na DataFrame `mod_relacional`, salva em `data_output/mod_relacional.rds`.

Os escores de modificações ativas ($S_a$), de modificações passivas ($S_p$) de interações totais (S_t) são dados, respectivamente, pelas seguintes fórmulas:

$$S_a = \log_{10}\left( \sum_{i=1}^N A_i \right)$$

$$S_p = \log_{10}\left( \sum_{i=1}^N P_i \right)$$

$$S_t = \log_{10}\left( \sum_{i=1}^N P_i + A_i \right)$$

onde $N$ é o número total de documentos no ano de referência e $P_i$ é o número total de modificações passivas do documento $i$ e $A_i$ é o número total de modificações ativas do documento $i$.


### Dados disponíveis neste repositório

O raspador descrito anteriormente gera um grande volume de dados, tendo sido alguns deles omitidos deste repositório para diminuir o seu tamanho (ver `.gitignore`). Cabe aqui destacar alguns dados que, apesar de serem gerados pelo código, não foram incluídos no repositório. 

Em todas as etapas de extração, o raspador salva arquivos com o código fonte de todas as páginas das quais foram extraídas as informações (páginas de busca na primeira etapa de extração, páginas internas na segunda etapa e páginas relacionais na terceira etapa). Como esse registro é excessivamente pesado, nenhum arquivo `.html` foi incluído no repositório. 

Além disso, o código salva tabelas de ados intermediárias ou utilizadas para simples verificação do processo de raspagem. A maior das tabelas são também salvas pelo código, por comodidade, em dois tipos de arquivo: `.rds` e `.csv`. O presente repositório não inclui os arquivos de tabelas intermediárias consideradas menos importantes, nem inclui as versões `.csv` dos arquivos. Apesar do formato `.csv` ser mais comum, optou-se por manter apenas os arquivos em formato `.rds` porque esses são os arquivos utilizados pelos scripts de transformação de dados e produção dos gráficos. Sendo assim, esses arquivos são necessários para reproduzir com mais facilidade os resultados da pesquisa.

### Principais DataFrames disponibilizadas

A seguir, uma breve descrição dos dados presentes nas principais DataFrames que acompanham este repositório.

  - A DataFrame `normas` (salva em `/data_ouput/normas_receita.rds`) é gerada na primeira etapa de raspagem dos dados, contendo informações gerais sobre um amplo conjunto de atos editados pela RFB (não apenas os atos normativos). Essa DataFrame é formada pelas seguintes colunas:
    - `id` (`int`): numeração simples que funciona como de identificação dos atos atribuído pelo próprio código do raspador para uma raspagem específica.
    - `idReceita` (`char`): número de identificação do ato no sistema da RFB, extraído do link de cada ato normativo. Como a coluna `id` muda a cada extração, esse identificador é necessário se quisermos comparar os resultados obtidos em procedimentos de raspagem distintos.
    - `tipo` (`char`): refere-se ao tipo do ato, podendo ser `"Portaria"`, `"Instrução Normativa"`, `"Decisão"`, `"Despacho"` etc.
    - `num` (`char`): número do ato, podendo ser utilizado para compor o título do ato juntamente com a coluna de tipo (exemplo: `"Portaria nº 365"`).
    - `orgao` (`char`): órgãos ou departamentos internos responsáveis pela edição do ato.
    - `data` (`char`): data de edição do ato, no formato DD/MM/AAAA.
    - `ementa` (`char`): texto da ementa que descreve brevemente o conteúdo do ato.
    - `link` (`char`): url com o endereço da página onde é possível encontrar o texto integral do ato e dados relacionais (sobre revogação ou interação com outros atos). Como dito, do link foi possível extrair também o número utilizado pelo sistema da RFB como identificador do ato, salvo em uma coluna separada.

- A DataFrame `normas_select` (salva em `data_output/select_database.rds`) é composta por todas as colunas da DataFrame `normas`, mas oferece outras colunas informações adicionais para o subconjunto de atos classificados como normativos. Sendo assim, além das colunas já descritas anteriormente, `normas_select`  inclui também as seguintes colunas:
  - `titulo`(`char`): título do ato normativo por extenso, extraído diretamente da página de texto da norma.
  - `dou`(`char`): indicação da de publicação do ato normativo no Diário Oficial da União, extraída diretamente da página de texto da norma.
  - `assinatura`(`char`): assinatura do ato normativo, extraída diretamente da página de texto da norma.
  - `texto`(`char`): texto integral do ato normativo.
  - `tem_relacional` (`lgl`): variável booleana que identifica se o portal da RFB oferece dados relacionais para aquele ato (`TRUE`) ou não (`FALSE`).
  - `ii` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Imposto de Importação – II (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `irpf` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Imposto de Renda de Pessoa Física – IRPF (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `irpj` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Imposto de Renda de Pessoa Jurídica – IRPJ (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `iof` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Imposto sobre Operações de Crédito – IOF (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `ipi` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Imposto sobre Produtos Industrializados – IPI (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `cofins` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Imposto de Importação – II (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `pis` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita à Contribuição para o Financiamento da Seguridade Social – Cofins (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `pasep` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita ao Programa de Formação do Patrimônio do Servidor Público – Pasep (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `pis_pasep` (`lgl`): variável booleana que identifica se há, no texto da norma, qualquer menção explícita ao à Contribuição para o Financiamento da Seguridade Social – Cofins ou ao Programa de Formação do Patrimônio do Servidor Público – Pasep (`TRUE`) ou se não há qualquer menção explícita a esses tributos (`FALSE`).
  - `csll` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita à Contribuição Social sobre Lucro Líquido – CSLL (`TRUE`) ou se não há menção explícita a esse tributo (`FALSE`).
  - `inss` (`lgl`): variável booleana que identifica se há, no texto da norma, menção explícita às contribuições do Instituto Nacional do Seguro Social – INSS (`TRUE`) ou se não há menção explícita a esses tributos (`FALSE`).
  - `titulo`(`int`): contagem simples do número de palavras do ato normativo, a partir da coluna `texto`. 

 - A DataFrame `ca_table` (salva em `/data_ouput/ca_table.rds`) é gerada a partir do processamento dos textos dos atos normativos para identificar disposições que tratam de deveres ou obrigações, de multas ou penalidades e de prazos. Os dados desta DataFrame consistem em contagens da incidência dessas disposições por ano. Para cada ano do período, portanto, a DataFrame apresenta três entradas distintas, cada uma contendo as contagens de cada um dos tipos de disposição analisados (`"dever"`, `"pena` e `"prazo"`).
   - `ano` (`char`): ano de referência para a contagem de disposições.
   - `type` (`char`): tipo de disposição analisada, pode assumir um dos três valores: `"dever"`, `"pena` ou `"prazo"`.
   - `Documents` (`int`): número de atos normativos naquele ano.
   - `N` (`int`): número total de disposições que tratam do tema designado na coluna `type`, identificadas em todos os atos normativos do ano de referência.
   - `mean` (`dbl`): número médio de disposições, por ato normativo publicado no ano de referência,  que tratam do tema designado na coluna `type`.
   - `median` (`dbl`): número mediano de disposições, por ato normativo publicado no ano de referência, que tratam do tema designado na coluna `type`.
   - `std` (`dbl`): desvio padrão do número de disposições, por ato normativo publicado no ano de referência, que tratam do tema designado na coluna `type`.

 - A DataFrame `mod_relacional` (salva em `/data_ouput/mod_relacional.rds`) é gerada a partir do processamento dos dados relacionais presentes na DataFrame `relacional_df`. Os dados desta DataFrame também estão agregados por ano, consistindo em contagens utilizadas para a construção dos escores de modificações ativas, passivas e totais divulgados na pesquisa. A Dataframe `mod_relacional` é composta pelas seguintes colunas:
   - `ano` (`int`): ano de referência para a contagem de modificações.
   - `mod_ativa` (`dbl`): escore de modificações ativas no ano de referência.
   - `mod_passiva` (`dbl`): escore de modificações passivas no ano de referência.
   - `interacoes_total` (`dbl`): escore de interações totais (passivas + ativas) no ano de referência.
   - `media_mod_ativa` (`dbl`): número médio de modificações ativas, por ato normativo, no ano de referência.
   - `media_mod_passiva` (`dbl`): número médio de modificações passivas, por ato normativo, no ano de referência.



[^1]: A titulo de exemplo, em 15/07/2024 foi realizado uma raspagem, para o intervalo de anos `1988:2024`, na qual foram identificados um total de 100.774 atos distintos, registrados na DataFrame `normas`. Destes, apenas um subgrupo de 15.634 atos (cerca de 15,5%) eram de tipos potencialmente normativos, tendo sido incluídos na segunda etapa de extração.