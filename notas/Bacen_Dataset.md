# Bacen Dataset
Paulo Icaro
2026-11-09

<!------------->

<!-- Parte 1 -->

<!------------->

## Objetivo

<p>

      Este tutorial mostra como é realizada a extração e tratamento de
séries macroeconômicas disponíveis na
[API](https://www3.bcb.gov.br/sgspub/localizarseries/localizarSeries.do?method=prepararTelaLocalizarSeries)
do Banco Central.

</p>

<!------------->

<!-- Parte 2 -->

<!------------->

## Bibliotecas e *Scripts* Auxiliares

<p>

      Esta rotina faz uso das bibliotecas
[tidyr](https://tidyr.tidyverse.org/) e
[openxlsx](https://cran.r-project.org/web/packages/openxlsx/index.html)
para modelagem de conjunto de dados e leitura/criação de arquivos Excel,
respectivamente.\
      Além das bibliotecas, os seguintes *scripts* são fundamentais para
o funcionamento dessa rotina:

- [bacen_query](https://github.com/paulo-icaro/Bacen_API/blob/main/readme_pt_br.md):
  realizar consultas aos dados disponíveis na API do Banco Central;
- [cumulative_transform](https://github.com/paulo-icaro/Variables_Frequency_Transforming):
  converter a frequência de uma série de dados de acordo com a regra de
  agregação adequada.
- [value_updating](https://github.com/paulo-icaro/Update_Variables_Actual_Value):
  atualizar valores monetários para o período desejado.

</p>

``` r
# ----------------------------- #
# --- Bibliotecas e Scripts --- #
# ----------------------------- #
source('https://raw.githubusercontent.com/paulo-icaro/Variables_Frequency_Transforming/refs/heads/main/variables_frequency_transforming.R')
source('https://raw.githubusercontent.com/paulo-icaro/Update_Variables_Actual_Value/refs/heads/main/update_actual_value.R')
source('https://raw.githubusercontent.com/paulo-icaro/Bacen_API/main/bacen_query.R')
library(tidyr)
library(openxlsx)
```

<!------------->

<!-- Parte 3 -->

<!------------->

## Extração dos Dados

<p>

      Para extração dos dados, basta informar os seguintes parâmetros
para a função
[bacen_query](https://github.com/paulo-icaro/Bacen_API/blob/main/readme_pt_br.md):
`Código da série`, `Nome da série`, `Data de início` e `Data final`.\
      Para o projeto, as seguintes séries foram coletadas:

| **Série** | **Código** |
|:---|:---|
| Variação de Emprego no Estado do Ceará | 13010 |
| Exportações no Estado do Ceará | 13093 |
| Importações no Estado do Ceará | 13094 |
| Saldo das Operações de Crédito SFN para o Estado do Ceará - Pessoa Física | 14007 |
| Saldo das Operações de Crédito SFN para o Estado do Ceará - Pessoa Física | 14034 |
| Índice de atividade Econômica Regional para o Estado do Ceará - IBCR-CE | 25390 |
| Taxa de Juros Selic - Acumulada no mês - Anualizada Base 252 | 4189 |
| Taxa de Câmbio Livre - Dólar Americano (Compra) - Média do Período | 3697 |
| Índice Nacional de Preços ao Consumo Amplo (IPCA) | 433 |
| Saldo Total das Operações de Crédito do SFN para o Estado do Ceará | 14061 |

      É valido mencionar que procedimentos como ajuste na formatação das
datas e transformação dos valores para padrão numérico foram
implementadas no conjunto de dados. Tais correções visam garantir o
pleno funcionamento da base de dados nas etapas a seguir.

</p>

``` r
# ========================= #
# === Extração de Dados === #
# ========================= #

# --- Informações Prévias --- #
cod_bacen_series = c('13010', '13093', '13094', '14007', '14034', '25390', '4189', '3697', '433', '14061')
name_bacen_series = c('variacao_emprego', 'export', 'import', 'cred_pf', 'cred_pj', 'ibcrce', 'selic_acum_anual', 'tx_cambio_mp', 'inflação_ipca', 'saldo_oper_cred')
start_date = '01/01/2015'
end_date = '31/12/2025'
#end_date = format(Sys.Date(), '%d/%m/%Y')

# --- Extracao --- #
bacen_dataset_curr_m = bacen_query(cod_bacen_series, name_bacen_series, start_date, end_date)

# --- Ajuste na Data --- #
bacen_dataset_curr_m = bacen_dataset_curr_m %>% mutate(data = as.Date(data, tryFormats = c('%d/%m/%Y')))

# --- Ajuste para tipo numérico
bacen_dataset_curr_m[c(-1)] = lapply(X = bacen_dataset_curr_m[c(-1)], FUN = as.numeric)

# --- Prints --- #
head(bacen_dataset_curr_m, n = 10)
```

             data variacao_emprego export import cred_pf cred_pj ibcrce
    1  2015-01-01            -6580  99525 647477   30237   28578  97.91
    2  2015-02-01            -2027  74722 148715   30263   28739  93.64
    3  2015-03-01             -357  78281 215278   30541   28823  96.87
    4  2015-04-01            -3547  74072 211604   30797   28895  94.81
    5  2015-05-01            -1679  72148 252533   31152   30115  97.81
    6  2015-06-01             1222  80672 157724   31425   29991  98.04
    7  2015-07-01            -3411  88933 223834   31680   30517 102.73
    8  2015-08-01              871  80011 136616   31978   30743 102.65
    9  2015-09-01            -1508  95899 243164   32135   31124 102.33
    10 2015-10-01            -4787  98567 146785   32307   31305 100.68
       selic_acum_anual tx_cambio_mp inflação_ipca saldo_oper_cred
    1             11.82       2.6336          1.24           58815
    2             12.15       2.8158          1.22           59002
    3             12.58       3.1389          1.32           59363
    4             12.68       3.0426          0.71           59691
    5             13.15       3.0611          0.74           61267
    6             13.58       3.1111          0.79           61416
    7             13.69       3.2225          0.62           62197
    8             14.15       3.5137          0.22           62722
    9             14.15       3.9058          0.54           63258
    10            14.15       3.8795          0.82           63613

<!------------->

<!-- Parte 4 -->

<!------------->

## Processamento de Dados

<p>

      Uma vez que os dados foram extraídos, estes já se encontram na
forma **matricial**. Além disso, os seguintes procedimentos são adotados
no refinamento da base de dados:

- **Conversão de frequência**: os valores que inicialmente tinham
  frequência mensal foram devidamente bimestralizados;
- **Atualização dos valores monetários**: todos os valores monetários
  foram atualizados para o período 2025/12;
- **Concatenação da base em termos reais e nominais**: as bases reais e
  nominais foram combinadas, tendo agora uma variável categórica
  indicado se está sendo usado valor real ou nominal;
- **Verticalização da base de dados**: os dados passam pelo processo de
  “verticalização” para atender aos padrões do Tableau.

      No processo de “bimestralização” da base de dados, cada série
passou por um tipo de regra de conversão:

| **Série** | **Regra de Conversão** |
|:---|:---|
| Variação de Emprego no Estado do Ceará | Soma |
| Exportações no Estado do Ceará | Soma |
| Importações no Estado do Ceará | Soma |
| Saldo das Operações de Crédito SFN para o Estado do Ceará - Pessoa Física | Período Final |
| Saldo das Operações de Crédito SFN para o Estado do Ceará - Pessoa Física | Período Final |
| Índice de atividade Econômica Regional para o Estado do Ceará - IBCR-CE | Período Final |
| Taxa de Juros Selic - Acumulada no mês - Anualizada Base 252 | Período Final |
| Taxa de Câmbio Livre - Dólar Americano (Compra) - Média do Período | Média |
| Índice Nacional de Preços ao Consumo Amplo (IPCA) | Taxa Acumulada |
| Saldo Total das Operações de Crédito do SFN para o Estado do Ceará | Período Final |

</p>

``` r
# ============================== #
# === Processamento de Dados === #
# ============================== #

# --------------------------------------------- #
# --- Transformacao da Frequencia dos Dados --- #
# --------------------------------------------- #
bacen_dataset_bimonthly_curr_sum_m = cumulative_transform('soma', 'bimestral', bacen_dataset_curr_m[c(1:4)])
bacen_dataset_bimonthly_curr_end_m = cumulative_transform('periodo_final', 'bimestral', bacen_dataset_curr_m[c(1, 5:8, 11)])
bacen_dataset_bimonthly_curr_cum_m = cumulative_transform('tx_acumulada', 'bimestral', bacen_dataset_curr_m[c(1, 10)])
bacen_dataset_bimonthly_curr_mean_m = cumulative_transform('media', 'bimestral', bacen_dataset_curr_m[c(1, 9)])
bacen_dataset_bimonthly_curr_m = left_join(x = bacen_dataset_bimonthly_curr_sum_m, y = bacen_dataset_bimonthly_curr_end_m, by = 'data')
bacen_dataset_bimonthly_curr_m = left_join(x = bacen_dataset_bimonthly_curr_m, y = bacen_dataset_bimonthly_curr_cum_m, by = 'data')
bacen_dataset_bimonthly_curr_m = left_join(x = bacen_dataset_bimonthly_curr_m, y = bacen_dataset_bimonthly_curr_mean_m, by = 'data')

# ----------------------------------------- #
# --- Atualizacao de Valores Monetarios --- #
# ----------------------------------------- #
bacen_dataset_actual_m = 
  value_updating(series = bacen_dataset_curr_m, variables = c('export', 'import', 'cred_pf', 'cred_pj', 'saldo_oper_cred'),
                 base_period = '2025-12', start = '2014', show_price_index = FALSE)

bacen_dataset_bimonthly_actual_m =
  value_updating(series = bacen_dataset_bimonthly_curr_m, variables = c('export', 'import', 'cred_pf', 'cred_pj', 'saldo_oper_cred'),
                 base_period = '2025-12', start = '2014', show_price_index = FALSE)


# --------------------------------------------- #
# --- Base Final - Valores Nominais e Reais --- #
# --------------------------------------------- #
bacen_dataset_m = rbind(bacen_dataset_curr_m %>% mutate(tipo_preco = 'nominal'),
                        bacen_dataset_actual_m %>% mutate(tipo_preco = 'real'))
bacen_dataset_bimonthly_m = rbind(bacen_dataset_bimonthly_curr_m %>% mutate(tipo_preco = 'nominal'),
                                  bacen_dataset_bimonthly_actual_m %>% mutate(tipo_preco = 'real'))


# ------------------------------- #
# --- Verticalizando os Dados --- #
# ------------------------------- #
bacen_dataset_t = pivot_longer(data = bacen_dataset_m, cols = !starts_with(c('data', 'tipo_preco')), names_to = 'variavel', values_to = 'valor')
bacen_dataset_bimonthly_t = pivot_longer(data = bacen_dataset_bimonthly_m, cols = !starts_with(c('data', 'tipo_preco')), names_to = 'variavel', values_to = 'valor')
```

<p>

      A execução da rotina irá gerar *outputs* para ambos os padrões de
dados. Padrão Tableau:

</p>

             data variacao_emprego export import cred_pf cred_pj ibcrce
    1  2015-01-01            -6580  99525 647477   30237   28578  97.91
    2  2015-02-01            -2027  74722 148715   30263   28739  93.64
    3  2015-03-01             -357  78281 215278   30541   28823  96.87
    4  2015-04-01            -3547  74072 211604   30797   28895  94.81
    5  2015-05-01            -1679  72148 252533   31152   30115  97.81
    6  2015-06-01             1222  80672 157724   31425   29991  98.04
    7  2015-07-01            -3411  88933 223834   31680   30517 102.73
    8  2015-08-01              871  80011 136616   31978   30743 102.65
    9  2015-09-01            -1508  95899 243164   32135   31124 102.33
    10 2015-10-01            -4787  98567 146785   32307   31305 100.68
       selic_acum_anual tx_cambio_mp inflação_ipca saldo_oper_cred tipo_preco
    1             11.82       2.6336          1.24           58815    nominal
    2             12.15       2.8158          1.22           59002    nominal
    3             12.58       3.1389          1.32           59363    nominal
    4             12.68       3.0426          0.71           59691    nominal
    5             13.15       3.0611          0.74           61267    nominal
    6             13.58       3.1111          0.79           61416    nominal
    7             13.69       3.2225          0.62           62197    nominal
    8             14.15       3.5137          0.22           62722    nominal
    9             14.15       3.9058          0.54           63258    nominal
    10            14.15       3.8795          0.82           63613    nominal

<p>

e padrão Matlab:
</p>

    # A tibble: 10 × 4
       data       tipo_preco variavel             valor
       <date>     <chr>      <chr>                <dbl>
     1 2015-01-01 nominal    variacao_emprego  -6580   
     2 2015-01-01 nominal    export            99525   
     3 2015-01-01 nominal    import           647477   
     4 2015-01-01 nominal    cred_pf           30237   
     5 2015-01-01 nominal    cred_pj           28578   
     6 2015-01-01 nominal    ibcrce               97.9 
     7 2015-01-01 nominal    selic_acum_anual     11.8 
     8 2015-01-01 nominal    tx_cambio_mp          2.63
     9 2015-01-01 nominal    inflação_ipca         1.24
    10 2015-01-01 nominal    saldo_oper_cred   58815   

<!------------->

<!-- Parte 5 -->

<!------------->

## Armazenamento

<p>

      Os resultados gerados são armazenados em dois diretórios
distintos. Considerando o caminho base do diretório de armazenamento
`Databases/Outputs/`, os resultados podem ser armazenados nas pastas
*Tableau* ou *Matlab* a depender do padrão do *output* gerado.\
      Assim, para essa rotina, os *paths* de armazenamento serão
`Databases/Outputs/Tableau` e `Databases/Outputs/Matlab`.

</p>

``` r
# ==================================== #
# === Armazenamento dos Resultados === #
# ==================================== #

# --- Pre Definicoes --- #
save_path = c('Databases/Outputs/Tableau/db_bacen_tableau', 'Databases/Outputs/Matlab/db_bacen_matlab')
formato = c('tableau', 'matlab')
aba = list(
  tableau = c('bacen_bimestre', 'bacen_original'),
  matlab = c('bacen_bimestre_real', 'bacen_bimestre_nominal', 'bacen_original_real', 'bacen_original_nominal')
)
dataframe = list(
  tableau = list(bacen_dataset_bimonthly_t, bacen_dataset_t),
  matlab = list(bacen_dataset_bimonthly_actual_m, bacen_dataset_bimonthly_curr_m, bacen_dataset_actual_m, bacen_dataset_curr_m)
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
    writeData(wb = wb, sheet = 'tempo', as.numeric(bacen_dataset_bimonthly_curr_m$data) + 25569, rowNames = FALSE)
  }
  saveWorkbook(wb = wb, file = paste0(save_path[f], '.xlsx'), overwrite = TRUE)
}
```
