# Employment Dataset (ASSET - SEFAZ CE)
Paulo Icaro
2026-11-21

<!------------->

<!-- Parte 1 -->

<!------------->

## Objetivo

<p>

      Este tutorial mostra como é realizada o tratamento dos dados de
mercado de trabalho no Estado do Ceará. Esta etapa corresponde a parte
final de refinamento do dos dados a serem utilizados no Tableau e
Matlab.

</p>

<!------------->

<!-- Parte 2 -->

<!------------->

## Bibliotecas e *Scripts* Auxiliares

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
- [value_updating](https://github.com/paulo-icaro/Update_Variables_Actual_Value):
  atualizar valores monetários para o período desejado.
  </p>

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
#employments_macro = read_excel(path = paste0(path, 'empregos_ceara_macro.xlsx'))
#employments_region = read_excel(path = paste0(path, 'empregos_ceara_regiao.xlsx'))
```

<p>

      A base de dados principal vem de planilhas que foram previamente
tratadas[^1]. Os dados refletem o quantitativo de empregos bem como o
salário médio estimados para o Ceará e por região do Estado. Vejamos um
recorte dos dados:

</p>

    # A tibble: 10 × 10
       periodo saldo_empregos_caged massa_salarial_caged estoque_empregos_rais_estab
       <chr>                  <dbl>                <dbl>                       <dbl>
     1 2015/01                -6580             -9787536                           0
     2 2015/02                -2027             -5250327                           0
     3 2015/03                 -357             -4903239                           0
     4 2015/04                -3547             -7248270                           0
     5 2015/05                -1679             -5385291                           0
     6 2015/06                 1222             -2602780                           0
     7 2015/07                -3411             -7406294                           0
     8 2015/08                  871             -2475216                           0
     9 2015/09                -1508             -3902520                           0
    10 2015/10                -4787             -9120623                           0
    # ℹ 6 more variables: estoque_empregos_rais_vinc <dbl>,
    #   massa_salarial_rais_vinc <dbl>, flag_sem_rais <lgl>,
    #   estoque_empregos <dbl>, massa_salarial <dbl>, salario_medio <dbl>

<!------------->

<!-- Parte 2 -->

<!------------->

## Funções Específicas

<p>

      Três funções extras foram elaboradas especificamente para essa
rotina. Tais funções permite realizar análises tanto ao tipo de
agregação `macro` quanto a agregação por `região`.\
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

# ------------------------------------------ #
# --- Processamento de Dados - Empregos ---- #
# ------------------------------------------ #
process_employments = function(df, group_var){
  df |> 
    mutate(data = as.Date(paste0(gsub('/', '-', periodo), '-01'))) %>%
    select(all_of(group_var))
}

# ----------------------------------- #
# --- Transformação de Frequência --- #
# ----------------------------------- #
bim_transform = function(df, transf_type, group_var = NULL){
  cumulative_transform(
    transform_type = transf_type,
    frequency = 'bimestral',
    dataset = df, 
    groupby_variables = group_var)
}

# ------------------------------ #
# --- Matricizacao dos Dados --- #
# ------------------------------ #
pivotting = function(df, var_names, values, preffix){
  pivot_wider(df, names_from = var_names, values_from = values, names_prefix = preffix)
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
- **Junção das bases**: por através de técnicas de *join*, as bases de
  emprego e salário médio foram todas combinadas;
- **Atualização dos valores monetários**: todos os valores monetários
  foram atualizados para o período 2025/12;
- **Concatenação da base em termos reais e nominais**: as bases reais e
  nominais foram combinadas, tendo agora uma variável categórica
  indicado se está sendo usado valor real ou nominal;
- **Verticalização da base de dados**: os dados passam pelo processo de
  “verticalização” para atender aos padrões do Tableau.

</p>

``` r
# ============================== #
# === Processamento de Dados === #
# ============================== #

# ---------------------------------------------------- #
# --- Processamentos e Transformação de Frequência --- #
# ---------------------------------------------------- #
employments_amount_macro_bim = bim_transform(df = process_employments(df = employments_macro, group_var = c('data', 'estoque_empregos')), transf_type = 'periodo_final')
employments_amount_region_bim = bim_transform(df = process_employments(df = employments_region, group_var = c('data', 'regiao', 'estoque_empregos'))[c(1,2,3)], transf_type = 'periodo_final', group_var = 'regiao') 
avg_wage_macro_bim = bim_transform(df = process_employments(df = employments_macro, group_var = c('data', 'salario_medio')), transf_type = 'media')
avg_wage_region_bim = bim_transform(df = process_employments(df = employments_region, group_var = c('data', 'regiao', 'salario_medio')), transf_type = 'media', group_var = 'regiao')


# ----------------------------- #
# --- Matricizando os Dados --- #
# ----------------------------- #
employments_amount_macro_bim_m = employments_amount_macro_bim
employments_amount_region_bim_m = pivotting(employments_amount_region_bim, 'regiao', 'estoque_empregos', 'empregos_')
avg_wage_macro_bim_m = avg_wage_macro_bim
avg_wage_region_bim_m = pivotting(avg_wage_region_bim, 'regiao', 'salario_medio', 's.medio_')


# ------------------------- #
# --- Reunido Variaveis --- #
# ------------------------- #
employments_macro_curr_bim_m = left_join(x = employments_amount_macro_bim_m, y = avg_wage_macro_bim_m, by = 'data')
employments_region_curr_bim_m = left_join(x = employments_amount_region_bim_m, y = avg_wage_region_bim_m, by = 'data')


# ----------------------------------------- #
# --- Atualização de Valores Monetarios --- #
# ----------------------------------------- #
employments_macro_actual_bim_m = value_updating(employments_macro_curr_bim_m, colnames(select(employments_macro_curr_bim_m, !starts_with(c('data', 'estoque_empregos')))), base_period = '2025-12', start = '2015', show_price_index = FALSE)
employments_region_actual_bim_m = value_updating(employments_region_curr_bim_m, colnames(select(employments_region_curr_bim_m, !starts_with(c('data', 'empregos')))), base_period = '2025-12', start = '2015', show_price_index = FALSE)


# --------------------------------------------- #
# --- Base Final - Valores Nominais e Reais --- #
# --------------------------------------------- #
employments_macro_bim_m = rbind(employments_macro_curr_bim_m |> mutate(tipo_preco = 'nominal'), employments_macro_actual_bim_m |> mutate(tipo_preco = 'real'))
employments_region_bim_m = rbind(employments_region_curr_bim_m |> mutate(tipo_preco = 'nominal'), employments_region_actual_bim_m |> mutate(tipo_preco = 'real'))


# ------------------------------- #
# --- Verticalizando os Dados --- #
# ------------------------------- #
employments_macro_bim_t = pivot_longer(data = employments_macro_bim_m, cols = !starts_with((c('data', 'tipo_preco'))), names_to = 'variavel', values_to = 'valor')
employments_region_bim_t = pivot_longer(data = employments_region_bim_m, cols = !starts_with(c('data', 'tipo_preco', 'regiao')), names_to = 'variavel', values_to = 'valor') |> separate(col = 'variavel', into = c('variavel', 'regiao'), sep = '_')
```

<p>

   A execução da rotina irá, portanto, gerar outputs para ambos os
padrões de dados. Padrão Tableau:

</p>

    # A tibble: 10 × 4
       data       tipo_preco variavel            valor
       <date>     <chr>      <chr>               <dbl>
     1 2025-04-01 real       estoque_empregos 1860674 
     2 2025-04-01 real       salario_medio       2692.
     3 2025-06-01 real       estoque_empregos 1873691 
     4 2025-06-01 real       salario_medio       2667.
     5 2025-08-01 real       estoque_empregos 1888291 
     6 2025-08-01 real       salario_medio       2635.
     7 2025-10-01 real       estoque_empregos 1902351 
     8 2025-10-01 real       salario_medio       2595.
     9 2025-12-01 real       estoque_empregos 1896895 
    10 2025-12-01 real       salario_medio       2569.

<p>

e padrão Matlab:
</p>

    # A tibble: 10 × 4
       data       estoque_empregos salario_medio tipo_preco
       <date>                <dbl>         <dbl> <chr>     
     1 2024-06-01          1824210         2911. real      
     2 2024-08-01          1837942         2870. real      
     3 2024-10-01          1850623         2821. real      
     4 2024-12-01          1848011         2782. real      
     5 2025-02-01          1854443         2738. real      
     6 2025-04-01          1860674         2692. real      
     7 2025-06-01          1873691         2667. real      
     8 2025-08-01          1888291         2635. real      
     9 2025-10-01          1902351         2595. real      
    10 2025-12-01          1896895         2569. real      

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

</p>

``` r
# ==================================== #
# === Armazenamento dos Resultados === #
# ==================================== #

# --- Pre Definicoes --- #
save_path = c('Databases/Outputs/Tableau/db_empregos_tableau', 'Databases/Outputs/Matlab/db_empregos_matlab')
formato = c('tableau', 'matlab')
aba = list(
  tableau = c('empregos_macro_bimestre', 'empregos_regiao_bimestre'),
  matlab = c('empregos_macro_bimestre_real', 'empregos_regiao_bimestre_real')
  )
dataframe = list(
  tableau = list(employments_macro_bim_t, employments_region_bim_t),
  matlab = list(employments_macro_actual_bim_m, employments_region_actual_bim_m)
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
    writeData(wb = wb, sheet = 'tempo', as.numeric(employments_region_actual_bim_m$data) + 25569, rowNames = FALSE)
  }
  saveWorkbook(wb = wb, file = paste0(save_path[f], '.xlsx'), overwrite = TRUE)
}
```

[^1]: Ver o repositório [Employments Ceará
    Sefaz](https://github.com/paulo-icaro/Employment_Ceara_Sefaz)

[^2]: O adequamento é aplicado a base de dados por região.

[^3]: O ajuste da data ao padrão numérico envolve a soma da coluna data
    do conjunto de dados com o número 25569. Esse último representa a
    data 01/01/1970, que é a data-início do calendário no R.
