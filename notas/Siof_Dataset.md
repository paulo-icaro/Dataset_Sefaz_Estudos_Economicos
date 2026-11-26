# Siof Dataset (Asset - Sefaz CE)
Paulo Icaro
2026-11-19

<!------------->

<!-- Parte 1 -->

<!------------->

## Objetivo

<p>

      Este tutorial exibe a etapa final do tratamento aplicado ao
conjunto de dados de Investimentos Públicos no Estado do Ceará.

</p>

<!------------->

<!-- Parte 2 -->

<!------------->

## Bibliotecas, *Scripts* Auxiliares e Base de Dados

<p>

      Esta rotina faz uso das bibliotecas
[tidyr](https://tidyr.tidyverse.org/) e
[dplyr](https://dplyr.tidyverse.org/) para manipulações na base de dados
e [readxl](https://readxl.tidyverse.org/) e
[openxlsx](https://cran.r-project.org/web/packages/openxlsx/index.html)
para modelagem de conjunto de dados e leitura/criação de arquivos
Excel.\
      Além das bibliotecas, os seguintes *scripts* são essenciais no
funcionamento dessa rotina:

- [cumulative_transform](https://github.com/paulo-icaro/Variables_Frequency_Transforming):
  converter a frequência de uma série de dados de acordo com a regra de
  agregação adequada.
- [value_update](https://github.com/paulo-icaro/Update_Variables_Actual_Value):
  atualizar valores monetários para o período desejado.

</p>

``` r
# ============================= #
# === Bibliotecas e Scripts === #
# ============================= #
source('https://raw.githubusercontent.com/paulo-icaro/Variables_Frequency_Transforming/refs/heads/main/variables_frequency_transforming.R')
source('https://raw.githubusercontent.com/paulo-icaro/Update_Variables_Actual_Value/refs/heads/main/update_actual_value.R')
library(dplyr)
library(tidyr)
library(readxl)
library(openxlsx)

# --- Path Auxiliar --- #
path = 'Databases/Inputs/'

# --- Bases Iniciais --- #
#database_invest_programa_regiao = read_excel(path = paste0(path, 'investimentos_siof_ceara_programa_regiao.xlsx'))
#database_invest_funcao = read_excel(path = paste0(path, 'investimentos_siof_ceara_funcao.xlsx'))
```

<p>

      A base de dados principal vem de planilhas que foram previamente
tratadas[^1]. Os dados refletem os Investimentos Públicos por
**Programa** e **região** e Investimentos Públicos por **função**.
Vejamos um recorte dos dados:

</p>

    # A tibble: 10 × 10
       periodo  ano   mes   tipo  cod_regiao regiao  cod_programa programa categoria
       <chr>    <chr> <chr> <chr> <chr>      <chr>   <chr>        <chr>    <chr>    
     1 JUN_2012 2012  06    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     2 JUL_2012 2012  07    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     3 AGO_2012 2012  08    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     4 SET_2012 2012  09    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     5 OUT_2012 2012  10    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     6 NOV_2012 2012  11    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     7 DEZ_2012 2012  12    EQUIP 06         BATURI… 007          INCENTI… empenhad…
     8 JUN_2012 2012  06    EQUIP 06         BATURI… 012          SEGURAN… empenhad…
     9 JUL_2012 2012  07    EQUIP 06         BATURI… 012          SEGURAN… empenhad…
    10 AGO_2012 2012  08    EQUIP 06         BATURI… 012          SEGURAN… empenhad…
    # ℹ 1 more variable: valor <dbl>

<!------------->

<!-- Parte 2 -->

<!------------->

## Funções Específicas

<p>

      Três funções extras foram elaboradas especificamente para essa
rotina. Elas permitem extender, além da agregação `macro`, a análise aos
diferentes tipos de agregação que podem ser considerado ao manipular os
dados: `região`, `tipo` e `programa/função`.\
      As funções são:

- **process_invest**: promove a agregação e sumariza a base de dados
  inicial de acordo com o nível de agregação desejado;
- **bim_transform**: variação da função
  [**cumulative_transform**](https://github.com/paulo-icaro/Variables_Frequency_Transforming),
  onde é necessário inserir apenas o conjunto de dados a ter a
  frequência convertida e as variáveis de agregação a ser consideradas.
- **pivotting**: função para adequar[^2] a base de dados inicial ao
  formato matricial (necessário ao Matlab).

</p>

``` r
# ========================= #
# === Funções Auxliares === #
# ========================= #

# ----------------------------------------------- #
# --- Processamento de Dados - Investimentos ---- #
# ----------------------------------------------- #
process_invest = function(df, group_var, min_year = 2015){
  df |> 
    filter(categoria == 'pago_acumulado', ano >= min_year) |> 
    group_by(across(all_of(group_var))) |> 
    summarize(valor = sum(valor), .groups = 'drop') |> 
    mutate(data = as.character.Date(paste0(ano, '-', mes, '-01')))
}

# ----------------------------------- #
# --- Transformação de Frequência --- #
# ----------------------------------- #
bim_transform = function(df, group_var){
  cumulative_transform(
    transform_type = 'diff_acumulado',
    frequency = 'bimestral',
    dataset = df,
    groupby_variables = group_var)
}

# ------------------------------ #
# --- Matricizacao dos Dados --- #
# ------------------------------ #
pivotting = function(df, var_names = 'tipo', values = 'valor'){
  pivot_wider(df, names_from = var_names, values_from = values)
}
```

<!------------->

<!-- Parte 3 -->

<!------------->

## Processamento de Dados

<p>

      Os seguintes procedimentos foram aplicados no refinamento do
conjunto de dados:

- **Agregação e Conversão de frequência**: a base de dados é
  inicialmente agregada de acordo com o escopo de agregação e na
  sequência os dados são “bimestralizados”;
- **“Matricização” dos Dados**: transformação da base para o padrão
  **matricial**;
- **Atualização dos valores monetários**: todos os valores monetários
  foram atualizados para o período 2025/12;
- **Concatenação da base em termos reais e nominais**: as bases reais e
  nominais foram combinadas, tendo agora uma variável categórica
  indicado se está sendo usado valor real ou nominal;
- **Verticalização da base de dados**: os dados passam pelo processo de
  “verticalização” para atender aos padrões do Tableau.

      De modo a atender a todos os cenários possíveis, os tratamentos
foram implementados em todos os níveis de agregação possíveis, tanto
para os investimentos por programa quanto por função.

</p>

``` r
# ============================== #
# === Processamento de Dados === #
# ============================== #

# ---------------------------------------------------- #
# --- Processamentos e Transformacao de Frequencia --- #
# ---------------------------------------------------- #
invest_programa_tipo_bim                 = bim_transform(process_invest(df = database_invest_programa_regiao, group_var = c('ano', 'mes', 'tipo'), min_year =  2016)[,3:5], c('tipo'))
invest_programa_regiao_bim               = bim_transform(process_invest(df = database_invest_programa_regiao, group_var = c('ano', 'mes', 'regiao'), min_year = 2016)[,3:5], c('regiao'))
invest_programa_tipo_regiao_bim          = bim_transform(process_invest(df = database_invest_programa_regiao, group_var = c('ano', 'mes', 'tipo', 'regiao'), min_year = 2016)[,3:6], c('tipo', 'regiao'))
invest_programa_tipo_regiao_programa_bim = bim_transform(process_invest(df = database_invest_programa_regiao, group_var = c('ano', 'mes', 'tipo', 'regiao', 'programa'), min_year = 2016)[,3:7], c('tipo', 'regiao', 'programa'))
invest_funcao_tipo_bim                   = bim_transform(process_invest(df = database_invest_funcao, group_var = c('ano', 'mes', 'tipo'), min_year =  2016)[,3:5], c('tipo'))
invest_funcao_funcao_bim                 = bim_transform(process_invest(df = database_invest_funcao, group_var = c('ano', 'mes', 'funcao'), min_year =  2016)[,3:5], c('funcao'))
invest_funcao_tipo_funcao_bim            = bim_transform(process_invest(df = database_invest_funcao, group_var = c('ano', 'mes', 'tipo', 'funcao'), min_year =  2016)[,3:6], c('tipo','funcao'))

# ----------------------------- #
# --- Matricizando os Dados --- #
# ----------------------------- #
invest_programa_tipo_curr_bim_m                  = pivotting(invest_programa_tipo_bim)
invest_programa_regiao_curr_bim_m                = pivotting(invest_programa_regiao_bim, var_names = c('regiao'))
invest_programa_tipo_regiao_curr_bim_m           = pivotting(invest_programa_tipo_regiao_bim, var_names = c('tipo', 'regiao'))
invest_programa_tipo_regiao_programa_curr_bim_m  = pivotting(invest_programa_tipo_regiao_programa_bim, var_names = c('tipo', 'regiao', 'programa'))
invest_funcao_tipo_curr_bim_m                    = pivotting(invest_funcao_tipo_bim)
invest_funcao_funcao_curr_bim_m                  = pivotting(invest_funcao_funcao_bim, var_names = 'funcao')
invest_funcao_tipo_funcao_curr_bim_m             = pivotting(invest_funcao_tipo_funcao_bim, var_names = c('tipo', 'funcao'))

# ----------------------------------------- #
# --- Atualizacao de Valores Monetarios --- #
# ----------------------------------------- #
invest_programa_tipo_actual_bim_m                 = value_update(series = invest_programa_tipo_curr_bim_m, variables = colnames(select(invest_programa_tipo_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)
invest_programa_regiao_actual_bim_m               = value_update(series = invest_programa_regiao_curr_bim_m, variables = colnames(select(invest_programa_regiao_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)
invest_programa_tipo_regiao_actual_bim_m          = value_update(series = invest_programa_tipo_regiao_curr_bim_m, variables = colnames(select(invest_programa_tipo_regiao_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)
invest_programa_tipo_regiao_programa_actual_bim_m = value_update(series = invest_programa_tipo_regiao_programa_curr_bim_m, variables = colnames(select(invest_programa_tipo_regiao_programa_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)
invest_funcao_tipo_actual_bim_m                   = value_update(series = invest_funcao_tipo_curr_bim_m, variables = colnames(select(invest_funcao_tipo_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)
invest_funcao_funcao_actual_bim_m                 = value_update(series = invest_funcao_funcao_curr_bim_m, variables = colnames(select(invest_funcao_funcao_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)
invest_funcao_tipo_funcao_actual_bim_m            = value_update(series = invest_funcao_tipo_funcao_curr_bim_m, variables = colnames(select(invest_funcao_tipo_funcao_curr_bim_m, -data)), base_period = '2025-12', start = '2015', show_price_index = FALSE)

# --------------------------------------------- #
# --- Base Final - Valores Nominais e Reais --- #
# --------------------------------------------- #
invest_programa_tipo_bim_m                 = rbind(invest_programa_tipo_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_programa_tipo_actual_bim_m |> mutate(tipo_preco = 'real'))
invest_programa_regiao_bim_m               = rbind(invest_programa_regiao_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_programa_regiao_actual_bim_m |> mutate(tipo_preco = 'real'))
invest_programa_tipo_regiao_bim_m          = rbind(invest_programa_tipo_regiao_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_programa_tipo_regiao_actual_bim_m |> mutate(tipo_preco = 'real'))
invest_programa_tipo_regiao_programa_bim_m = rbind(invest_programa_tipo_regiao_programa_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_programa_tipo_regiao_programa_actual_bim_m |> mutate(tipo_preco = 'real'))
invest_funcao_tipo_bim_m                   = rbind(invest_funcao_tipo_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_funcao_tipo_actual_bim_m |> mutate(tipo_preco = 'real'))
invest_funcao_funcao_bim_m                 = rbind(invest_funcao_funcao_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_funcao_funcao_actual_bim_m |> mutate(tipo_preco = 'real'))
invest_funcao_tipo_funcao_bim_m            = rbind(invest_funcao_tipo_funcao_curr_bim_m |> mutate(tipo_preco = 'nominal'), invest_funcao_tipo_funcao_actual_bim_m |> mutate(tipo_preco = 'real'))

# ------------------------------- #
# --- Verticalizando os Dados --- #
# ------------------------------- #
invest_programa_tipo_bim_t                 = pivot_longer(data = invest_programa_tipo_bim_m, cols = !starts_with(c('data', 'tipo_preco')), names_to = 'variavel', values_to = 'valor')
invest_programa_regiao_bim_t               = pivot_longer(data = invest_programa_regiao_bim_m, cols = !starts_with(c('data', 'tipo_preco', 'regiao')), names_to = 'variavel', values_to = 'valor')
invest_programa_tipo_regiao_bim_t          = pivot_longer(data = invest_programa_tipo_regiao_bim_m, cols = !starts_with(c('data', 'tipo_preco', 'regiao')), names_to = 'variavel', values_to = 'valor') |> separate(col = 'variavel', into = c('tipo', 'regiao'), sep = '_')
invest_programa_tipo_regiao_programa_bim_t = pivot_longer(data = invest_programa_tipo_regiao_programa_bim_m, !starts_with(c('data', 'tipo_preco', 'regiao', 'programa')), names_to = 'variavel', values_to = 'valor') |> separate(col = 'variavel', into = c('tipo', 'regiao', 'programa'), sep = '_')
invest_funcao_tipo_bim_t                   = pivot_longer(data = invest_funcao_tipo_bim_m, cols = !starts_with(c('data', 'tipo_preco')), names_to = 'variavel', values_to = 'valor')
invest_funcao_funcao_bim_t                 = pivot_longer(data = invest_funcao_funcao_bim_m, cols = !starts_with(c('data', 'tipo_preco')), names_to = 'variavel', values_to = 'valor')
invest_funcao_tipo_funcao_bim_t            = pivot_longer(data = invest_funcao_tipo_funcao_bim_m, cols = !starts_with(c('data', 'tipo_preco', 'funcao')), names_to = 'variavel', values_to = 'valor') |> separate(col = 'variavel', into = c('tipo', 'funcao'), sep = '_')
```

<p>

   A execução da rotina irá, portanto, gerar outputs para ambos os
padrões de dados. Padrão Tableau:

</p>

    # A tibble: 10 × 6
       data       tipo_preco tipo  regiao                       programa       valor
       <date>     <chr>      <chr> <chr>                        <chr>          <dbl>
     1 2025-12-01 real       TOTAL SERTÃO DE CANINDÉ            PROMOÇÃO E DE…     0
     2 2025-12-01 real       TOTAL SERTÃO DE SOBRAL             PROMOÇÃO E DE…     0
     3 2025-12-01 real       TOTAL SERTÃO DOS INHAMUNS          PROMOÇÃO E DE…     0
     4 2025-12-01 real       EQUIP ESTADO DO CEARÁ              NORMATIZAÇÃO …    NA
     5 2025-12-01 real       EQUIP SERTÃO DE SOBRAL             QUALIFICA CEA…    NA
     6 2025-12-01 real       OBRAS LITORAL OESTE / VALE DO CURU DESENVOLVIMEN…    NA
     7 2025-12-01 real       OBRAS MACIÇO DO BATURITÉ           PROTEÇÃO E DE…    NA
     8 2025-12-01 real       OBRAS SERTÃO CENTRAL               DESENVOLVIMEN…    NA
     9 2025-12-01 real       OBRAS SERTÃO DOS CRATEÚS           DESENVOLVIMEN…    NA
    10 2025-12-01 real       TOTAL SERTÃO DOS CRATEÚS           DESENVOLVIMEN…    NA

<p>

e padrão Matlab:
</p>

    # A tibble: 10 × 4,002
       data       EQUIP_CARIRI_ABASTECIMENTO DE ÁGUA E ESGO…¹ EQUIP_CARIRI_ACESSO …²
       <date>                                           <dbl>                  <dbl>
     1 2024-06-01                                          NA                     NA
     2 2024-08-01                                          NA                     NA
     3 2024-10-01                                          NA                     NA
     4 2024-12-01                                          NA                     NA
     5 2025-02-01                                          NA                     NA
     6 2025-04-01                                          NA                     NA
     7 2025-06-01                                           0                     NA
     8 2025-08-01                                           0                     NA
     9 2025-10-01                                           0                     NA
    10 2025-12-01                                           0                     NA
    # ℹ abbreviated names:
    #   ¹​`EQUIP_CARIRI_ABASTECIMENTO DE ÁGUA E ESGOTAMENTO SANITÁRIO NO MEIO RURAL`,
    #   ²​`EQUIP_CARIRI_ACESSO E APRENDIZAGEM DAS CRIANÇAS E JOVENS NA IDADE ADEQUADA`
    # ℹ 3,999 more variables:
    #   `EQUIP_CARIRI_ATENÇÃO À SAÚDE INTEGRAL E DE QUALIDADE` <dbl>,
    #   `EQUIP_CARIRI_CEARÁ MAIS VERDE` <dbl>,
    #   `EQUIP_CARIRI_CONTROLE DISCIPLINAR DOS SISTEMAS DE SEGURANÇA PÚBLICA E PENITENCIÁRIO` <dbl>, …

<!------------->

<!-- Parte 4 -->

<!------------->

## Armazenamento

<p>

      Os resultados gerados são armazenados em dois diretórios
distintos. Considerando o caminho base do diretório de armazenamento
`Databases/Outputs/`, os resultados podem ser armazenados nas pastas
*Tableau* ou *Matlab* a depender do padrão do *output* gerado. Assim,
para essa rotina, os *paths* de armazenamento serão
`Databases/Outputs/Tableau` e `Databases/Outputs/Matlab`.\
      Alguns itens são pré-definidos visado padronizar o armazenamento
dos resultados nessa e em outras rotinas. Duas listas são criadas:
**aba** e **dataframe**. Essas listas representam onde e quais dados
serão armazenados. Essa parte é “editável” no script, sendo possível
alternar de modo a atender ao que se deseja armazenar.\
      Na etapa de armazenamento vale atentar que há uma distinção para o
*output* gerado para Matlab. Uma aba adicional, nomeada **tempo** é
acrescentada tendo em vista a necessidade das datas serem especificadas
em padrão numérico[^3] necessário ao software.

``` r
# ==================================== #
# === Armazenamento dos Resultados === #
# ==================================== #

# --- Pre Definicoes --- #
save_path = c('Databases/Outputs/Tableau/db_siof_tableau', 'Databases/Outputs/Matlab/db_siof_matlab')
formato = c('tableau', 'matlab')
aba = list(
  tableau = c('progr_tipo', 'progr_regiao', 'progr_tipo_regiao', 'progr_tipo_regiao_programa', 'func_tipo', 'func_funcao', 'func_tipo_funcao'),
  matlab = c('progr_tipo_real', 'progr_regiao_real', 'progr_tipo_regiao_real', 'progr_tipo_regiao_programa_real', 'func_tipo_real', 'func_funcao_real', 'func_tipo_funcao_real')
  )
dataframe = list(
  tableau = list(invest_programa_tipo_bim_t, invest_programa_regiao_bim_t,
                 invest_programa_tipo_regiao_bim_t, invest_programa_tipo_regiao_programa_bim_t,
                 invest_funcao_tipo_bim_t, invest_funcao_funcao_bim_t, invest_funcao_tipo_funcao_bim_t),
  matlab = list(invest_programa_tipo_actual_bim_m, invest_programa_regiao_actual_bim_m,
                invest_programa_tipo_regiao_actual_bim_m, invest_programa_tipo_regiao_programa_actual_bim_m,
                invest_funcao_tipo_actual_bim_m, invest_funcao_funcao_actual_bim_m,invest_funcao_tipo_funcao_actual_bim_m)
  )

# --- Armazenamento --- #
for(f in seq_along(formato)){
  wb = createWorkbook(creator = 'Sefaz-CE')
  for(s in seq_along(aba[[f]])){
    addWorksheet(wb = wb, sheetName = aba[[f]][s])
    writeData(wb = wb, sheet = aba[[f]][s], x = as.data.frame(dataframe[[f]][s]), rowNames = FALSE, colNames = TRUE)
  }
  if(formato[f] == 'matlab'){
    addWorksheet(wb = wb, sheetName = 'tempo')
    writeData(wb = wb, sheet = 'tempo', as.numeric(invest_programa_tipo_bim_m$data) + 25569, rowNames = FALSE)
  }
  saveWorkbook(wb = wb, file = paste0(save_path[f], '.xlsx'), overwrite = TRUE)
}
```

[^1]: Ver o repositório [Investimentos Públicos
    Sefaz](https://github.com/paulo-icaro/Investimentos_Publicos_Sefaz)

[^2]: A versão original da base de dados vem em um padrão que não é nem
    **matricial** e nem **vertical**

[^3]: O ajuste da data ao padrão numérico envolve a soma da coluna data
    do conjunto de dados com o número 25569. Esse último representa a
    data 01/01/1970, que é a data-início do calendário no R.
